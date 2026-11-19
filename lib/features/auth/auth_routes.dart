import 'package:get/get.dart';
import 'package:rental_project/core/routes/auth_middleware.dart';
import 'package:rental_project/features/auth/presentation/bindings/auth_binding.dart';
import 'package:rental_project/features/auth/presentation/bindings/profile_binding.dart';
import 'package:rental_project/features/auth/presentation/screens/login_screen.dart';
import 'package:rental_project/features/auth/presentation/screens/profile_screen.dart';
import 'package:rental_project/features/auth/presentation/screens/register_screen.dart';
import 'package:rental_project/features/auth/presentation/screens/splash_screen.dart';

abstract class AuthRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const profile = '/profile';
}

abstract class AuthPages {
  static final pages = <GetPage>[
    GetPage(
      name: AuthRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AuthRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AuthRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AuthRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
