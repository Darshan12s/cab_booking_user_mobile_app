// screens/auth/auth_page_template.dart
import 'package:cab_booking_user_mobile_app/routes/app_routes.dart';
import 'package:flutter/material.dart';

class AuthPageTemplate extends StatelessWidget {
  final String title;
  final List<Widget> formFields;
  final String actionButtonText;
  final VoidCallback? onActionPressed;
  final String bottomText;
  final String bottomActionText;
  final String navigateRoute;
  final String backgroundImage;

  const AuthPageTemplate({
    super.key,
    required this.title,
    required this.formFields,
    required this.actionButtonText,
    this.onActionPressed,
    required this.bottomText,
    required this.bottomActionText,
    required this.navigateRoute,
    required this.backgroundImage,
    required ButtonStyle actionButtonStyle,
    required EdgeInsets actionButtonPadding,
    required TextStyle titleStyle,
    required TextStyle bottomTextStyle,
    required TextStyle bottomActionTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark Overlay
          Container(color: Colors.black.withAlpha(102)),

          // Content
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const Spacer(),
                          // Form Container
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: 500, // Maximum width for larger screens
                            ),
                            margin: const EdgeInsets.only(bottom: 0),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ...formFields,
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: onActionPressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[700],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      actionButtonText,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        'or Sign in with',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.googleLogin,
                                          );
                                        },
                                        icon: Image.network(
                                          'https://cdn2.iconfinder.com/data/icons/social-media-free-20/32/google_search_online_social_media-128.png',
                                          width: 35,
                                          height: 35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Bottom Navigation Text
                          Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Center(
                              child: TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  navigateRoute,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: '$bottomText ',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: bottomActionText,
                                        style: TextStyle(
                                          color: Colors.green[300],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
