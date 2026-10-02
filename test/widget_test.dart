import 'package:careerconnect/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CareerConnect App loads successfully', (WidgetTester tester) async {
    // Load the app
    await tester.pumpWidget(const CareerConnectApp());

    // Check if "Login" button is present
    expect(find.text("Login"), findsOneWidget);
  });

  testWidgets('Login with correct credentials', (WidgetTester tester) async {
    await tester.pumpWidget(const CareerConnectApp());

    // Enter username and password
    await tester.enterText(find.byType(TextField).at(0), "admin");
    await tester.enterText(find.byType(TextField).at(1), "123");

    // Tap login button
    await tester.tap(find.text("Login"));
    await tester.pumpAndSettle();

    // Check if Career Selection screen is loaded
    expect(find.text("CareerConnect"), findsOneWidget);
  });

  testWidgets('Login with incorrect credentials', (WidgetTester tester) async {
    await tester.pumpWidget(const CareerConnectApp());

    // Enter wrong username/password
    await tester.enterText(find.byType(TextField).at(0), "WrongUser");
    await tester.enterText(find.byType(TextField).at(1), "WrongPass");

    // Tap login button
    await tester.tap(find.text("Login"));
    await tester.pump();

    // Expect an error message
    expect(find.text("Invalid credentials. Try again."), findsOneWidget);
  });
}