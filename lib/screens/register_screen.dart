import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  final confirm = TextEditingController();

  bool loading = false;
  bool showPass = false;

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> register() async {
    final e = email.text.trim();
    final p = pass.text.trim();
    final c = confirm.text.trim();

    if (e.isEmpty || p.isEmpty || c.isEmpty) {
      showMsg("Please fill all fields");
      return;
    }

    if (p != c) {
      showMsg("Passwords do not match");
      return;
    }

    try {
      setState(() => loading = true);

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: e,
        password: p,
      );

      await cred.user!.sendEmailVerification();
      showMsg("Verification email sent to $e");

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pop(context); // ⭐ FIXED: return to login
    } catch (e) {
      showMsg(e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                "Create Account",
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

              const SizedBox(height: 12),

              TextField(
                controller: confirm,
                obscureText: !showPass,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9C6BFF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: loading ? null : register,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
              ),

              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
