import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;
  bool showPass = false;

  String? error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF6EDFF),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 360,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.1),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "PetSync Login",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B5CF6),
                ),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: pass,
                obscureText: !showPass,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPass ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => showPass = !showPass),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    if (email.text.isEmpty) {
                      setState(() => error = "Enter your email first.");
                      return;
                    }

                    try {
                      await auth.resetPassword(email.text.trim());
                      setState(() => error = "Password reset email sent.");
                    } catch (e) {
                      setState(() => error = e.toString());
                    }
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),

              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C6BFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: loading
                    ? null
                    : () async {
                        setState(() {
                          loading = true;
                          error = null;
                        });

                        try {
                          await auth.signIn(
                            email.text.trim(),
                            pass.text.trim(),
                          );
                        } catch (e) {
                          setState(() => error = e.toString());
                        }

                        setState(() => loading = false);
                      },
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login"),
              ),

              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("Create new account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
