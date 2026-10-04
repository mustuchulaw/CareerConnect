import 'dart:ui';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatbotScreen extends StatefulWidget {
  final String selectedCareer;

  const ChatbotScreen({super.key, required this.selectedCareer});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  bool isLoading = false;

  // Get the API key from dotenv
  String get _apiKey => dotenv.env['GROQ_API_KEY'] ?? '';

  @override
  void initState() {
    super.initState();
    messages.add({
      "bot": "Hello! I am your ${widget.selectedCareer} AI assistant. I will be taking your interview today. Are you ready to begin?",
      "animated": true
    });
  }

  Future<void> sendMessage() async {
    if (_controller.text.isEmpty) return;
    
    final userText = _controller.text;
    setState(() {
      messages.add({"user": userText});
      _controller.clear();
      isLoading = true;
    });

    try {
      // Build the conversation history for Groq (skip the first bot greeting)
      List<Map<String, dynamic>> apiMessages = [
        {
          "role": "system",
          "content": "You are a technical interviewer and career guide for a ${widget.selectedCareer} role. You must conduct a 10-question multiple-choice interview.\nRules:\n1. Ask the questions ONE at a time. Each question must have 4 options (A, B, C, D). Ensure the questions are highly diverse and randomized.\n2. When the user provides an answer, check if they selected A, B, C, or D. Any choice of A, B, C, or D is a valid selection, even if it is the wrong answer. Accept it immediately and ask the next question. However, if they select an invalid option (like E, F, or a random word), you MUST reject it, tell them it's invalid, and force them to choose A, B, C, or D before moving on.\n3. Do NOT tell the user if their answer is correct or incorrect during the test. Keep it a secret until the end.\n4. If the user asks a question related to ${widget.selectedCareer}, answer it helpfully. If they ask completely unrelated questions (like sports, movies, weather), strictly REFUSE to answer, remind them this is a technical interview, and ask the next question.\n5. After the 10th question is answered, output 'Interview Complete!', reveal which answers they got right and wrong, and provide a personalized study guide on what they need to improve.\n6. After the interview, act as a career mentor for ${widget.selectedCareer}.\n7. Do NOT use any Markdown formatting in your responses. Do not use asterisks (*), bolding, or italics. Output plain text only."
        }
      ];

      for (int i = 1; i < messages.length; i++) {
        var msg = messages[i];
        if (msg.containsKey("user")) {
          apiMessages.add({"role": "user", "content": msg["user"]});
        } else if (msg.containsKey("bot")) {
          apiMessages.add({"role": "assistant", "content": msg["bot"]});
        }
      }

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          "model": "qwen/qwen3.8-27b", // Using Qwen 3.8 27B which supports fast standard text generation
          "messages": apiMessages,
          "temperature": 0.7, // Increased from 0.3 to 0.7 to ensure question variety and shuffling
          "max_tokens": 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botText = data['choices'][0]['message']['content'];
        setState(() {
          messages.add({"bot": botText, "animated": false});
        });
      } else if (response.statusCode == 429) {
        setState(() {
          messages.add({"bot": "I'm receiving too many messages at once! Please wait a few seconds and try again.", "animated": false});
        });
      } else if (response.statusCode == 503) {
        setState(() {
          messages.add({"bot": "The AI servers are currently experiencing high demand. Please wait a few seconds and try sending your message again.", "animated": false});
        });
      } else {
        setState(() {
          messages.add({"bot": "Oops, something went wrong (Error ${response.statusCode}). Please try again.", "animated": false});
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"bot": "Error connecting to the server. Please check your internet connection.", "animated": false});
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.selectedCareer, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isUser = messages[index].keys.first == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isUser
                          ? const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)])
                          : const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isUser ? 20 : 0),
                        bottomRight: Radius.circular(isUser ? 0 : 20),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: isUser
                        ? Text(
                            messages[index]["user"] as String,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          )
                        : (messages[index]["animated"] == false)
                            ? TypewriterText(
                                text: messages[index]["bot"] as String,
                                onFinished: () {
                                  if (mounted) {
                                    setState(() {
                                      messages[index]["animated"] = true;
                                    });
                                  }
                                },
                              )
                            : Text(
                                messages[index]["bot"] as String,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                  ),
                );
              },
            ),
          ),
          if (isLoading)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12, left: 20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                child: const TypingIndicator(),
              ),
            ),
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: sendMessage,
                      child: const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF06B6D4),
                        child: Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            double value = _controller.value - (index * 0.2);
            if (value < 0) value += 1.0;
            // The sine wave completes half a cycle (a hop) from 0 to 0.5
            final offset = value < 0.5 ? sin(value * pi * 2) * -6 : 0.0;
            return Transform.translate(
              offset: Offset(0, offset),
              child: child,
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 3),
            child: CircleAvatar(radius: 4, backgroundColor: Colors.white70),
          ),
        );
      }),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final VoidCallback onFinished;

  const TypewriterText({super.key, required this.text, required this.onFinished});

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  late List<String> words;
  int currentIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    words = widget.text.split(' ');
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (currentIndex < words.length) {
        setState(() {
          currentIndex++;
        });
      } else {
        timer.cancel();
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= words.length) {
      return Text(
        widget.text,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      );
    }
    List<TextSpan> spans = [];
    for (int i = 0; i < currentIndex; i++) {
      bool isLast = i == currentIndex - 1;
      spans.add(TextSpan(
        text: words[i] + (i < words.length - 1 ? ' ' : ''),
        style: TextStyle(
          color: isLast ? Colors.greenAccent : Colors.white,
          fontSize: 16,
        ),
      ));
    }
    return RichText(
      text: TextSpan(children: spans),
    );
  }
}