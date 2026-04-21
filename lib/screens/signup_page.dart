import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final AuthService _authService = AuthService();
  String message = "";
  bool isLoading = false;

  void createAccount() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      setState(() {
        message = "All fields are required";
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = "";
    });

    final result = await _authService.signup(email.text, password.text);

    setState(() {
      isLoading = false;
      if (result['success']) {
        message = "Account created! You can login now.";
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
        });
      } else {
        message = result['message'] ?? "Signup failed";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Create Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),

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

            if (message.isNotEmpty)
              Text(message,
                  style:
                  TextStyle(color: message.contains("created") ? Colors.green : Colors.red)),

            SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : createAccount,
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text("Sign Up"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
