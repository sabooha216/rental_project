import 'package:get/get.dart';
import 'package:rental_project/core/routes/auth_middleware.dart';
import 'package:rental_project/features/settings/presentation/screens/settings_screen.dart';

abstract class SettingsRoutes {
  static const settings = '/settings';
}

abstract class SettingsPages {
  static final pages = <GetPage>[
    GetPage(
      name: SettingsRoutes.settings,
      page: () => const SettingsScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
