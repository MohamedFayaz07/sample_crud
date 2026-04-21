import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final AuthService _authService = AuthService();
  String errorText = "";
  bool isLoading = false;

  void validateLogin() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      setState(() {
        errorText = "Please enter email & password";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorText = "";
    });

    final result = await _authService.login(email.text, password.text);

    setState(() {
      isLoading = false;
      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        errorText = result['message'] ?? "Login failed";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome Back",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(height: 40),

            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 15),

            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 10),

            if (errorText.isNotEmpty)
              Text(errorText, style: TextStyle(color: Colors.red)),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : validateLogin,
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text("Login"),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignupPage()),
                );
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}