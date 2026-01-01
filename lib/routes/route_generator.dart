// routes/route_generator.dart
import 'package:cab_booking_user_mobile_app/screens/auth/google_sign_in.dart';
import 'package:cab_booking_user_mobile_app/screens/reset_password_page.dart';
import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import '../screens/auth/home_screen.dart';

import '../screens/my_Trip/my_trip_screen.dart';
import '../screens/rewards_screen.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/signup_page.dart';
import '../screens/auth/otp_login_page.dart';



import 'app_routes.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.myTrip:
        return MaterialPageRoute(builder: (_) => const MyTripScreen());
      case AppRoutes.rewards:
        return MaterialPageRoute(builder: (_) => const RewardsScreen());
      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      case AppRoutes.contact:
        return MaterialPageRoute(builder: (_) => const ContactScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case AppRoutes.otpLogin:
        return MaterialPageRoute(builder: (_) => const OtpLoginPage());
      case AppRoutes.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordPage());
      case AppRoutes.googleLogin:
        return MaterialPageRoute(builder: (_) => const GoogleLoginPage());

    

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
