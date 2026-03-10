import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 72),
            const SizedBox(height: 20),
            const Text(
              'A verification email has been sent to your email address. Please verify your email before continuing.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      final verified =
                          await context.read<AuthProvider>().checkEmailVerified();

                      if (!context.mounted) return;

                      if (verified) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email is not verified yet.'),
                          ),
                        );
                      }
                    },
              child: authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('I Have Verified My Email'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await context.read<AuthProvider>().resendVerificationEmail();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Verification email sent again.'),
                  ),
                );
              },
              child: const Text('Resend Verification Email'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}