import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:newapp/pages/home_screen.dart';
import 'package:newapp/pages/signup_screen.dart';
import 'package:newapp/services/auth_service.dart';
import 'package:newapp/theme/theme_data.dart';
import 'package:newapp/widgets/const_sizedbox.dart';
import 'package:newapp/widgets/custom_button.dart';
import 'package:newapp/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    void _login() async {
      if (_formKey.currentState!.validate()) {
        try {
          await Provider.of<AuthService>(context, listen: false).login(
            email: _usernameController.text,
            password: _passwordController.text,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } catch (e) {
          log(e.toString());
        }
      }
    }

    ColorScheme myColorScheme = themeData.colorScheme;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: myColorScheme.surface,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Satmat Login",
          style: themeData.textTheme.titleLarge,
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CustomTextField(
                obscureText: false,
                controller: _usernameController,
                validator: (value) => value!.isEmpty ? 'Enter email id' : null,
                labelText: "E-mail ID",
              ),
              const MidSizedBoxHeight(),
              CustomTextField(
                validator: (value) =>
                    value!.isEmpty ? 'Enter a password' : null,
                obscureText: true,
                controller: _passwordController,
                labelText: "Password",
              ),
              const LargeSizedBoxHeight(),
              CustomButton(
                onPressed: _login,
                myColorScheme: myColorScheme,
                buttonText: const Text("Login"),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account ?",
                  ),
                  TextButton(
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(
                        EdgeInsets.all(0),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text("Signup"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
