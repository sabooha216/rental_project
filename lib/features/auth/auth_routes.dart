import 'package:get/get.dart';
import 'package:rental_project/features/auth/presentation/screens/login_screen.dart';
import 'package:rental_project/features/auth/presentation/screens/register_screen.dart';
import 'package:rental_project/features/auth/presentation/screens/splash_screen.dart';

abstract class AuthRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
}

abstract class AuthPages {
  static final pages = <GetPage>[
    GetPage(
      name: AuthRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AuthRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AuthRoutes.register,
      page: () => const RegisterScreen(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
