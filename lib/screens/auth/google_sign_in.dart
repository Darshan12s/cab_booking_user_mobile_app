// screens/auth/google_sign_in.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cab_booking_user_mobile_app/widgets/auth/auth_header.dart';
import 'package:cab_booking_user_mobile_app/widgets/auth/google_sign_in_button.dart';
import 'package:cab_booking_user_mobile_app/widgets/auth/auth_divider.dart';
import 'package:cab_booking_user_mobile_app/widgets/auth/alternative_auth_options.dart';
import 'package:cab_booking_user_mobile_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({super.key});

  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  Future<void> _checkPhoneVerificationStatus(User user) async {
    try {
      // First check our custom users table for verification status
      final userData = await _supabase
          .from('users')
          .select('phone_verified, phone_no')
          .eq('id', user.id)
          .single();

      if (userData['phone_verified'] == true) {
        // Phone is verified in our database
        return;
      }

      // Check Supabase Auth for phone confirmation
      final hasVerifiedPhone =
          user.phone != null && user.phoneConfirmedAt != null;

      if (hasVerifiedPhone) {
        // Update our users table to sync the verification status
        await _supabase
            .from('users')
            .update({'phone_verified': true, 'phone_no': user.phone})
            .eq('id', user.id);
      } else {
        // Final check in our custom users table
        final userData = await _supabase
            .from('users')
            .select('phone_verified, phone_no')
            .eq('id', user.id)
            .single();

        if (userData['phone_verified'] != true) {
          // No phone verification found
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/phone-verification');
          }
        }
      }
    } catch (error) {
      // ignore: duplicate_ignore
      // ignore: avoid_print
      print('Error checking phone verification status: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying phone status: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final authService = AuthService();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isSmallScreen ? size.width * 0.9 : 400,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Sign in with Google',
                    subtitle: 'Continue with your Google account',
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GoogleSignInButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              print('Starting Google sign-in...');
                              final result = await authService
                                  .signInWithGoogle();
                              print('Google sign-in result: $result');

                              if (result is User) {
                                await _checkPhoneVerificationStatus(
                                  result as User,
                                );
                                if (context.mounted) {
                                  print('Navigating to home...');
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                  );
                                }
                              } else if (result == false) {
                                print('Google sign-in returned false');
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Google sign-in was cancelled or failed.',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              print('Google sign-in error: $e');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                        ),
                  const SizedBox(height: 24),
                  const AuthDivider(text: 'OR'),
                  const SizedBox(height: 24),
                  AlternativeAuthOptions(
                    primaryText: 'Use Email Instead',
                    secondaryText: 'Back to login options',
                    onPrimaryPressed: () async {
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/otp-login');
                      }
                      // ignore: avoid_returning_null_for_void
                      return null;
                    },
                    onPressed: () async {
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/otp-login');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
