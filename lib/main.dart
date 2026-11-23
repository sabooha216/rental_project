import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/bindings/initial_binding.dart';
import 'package:rental_project/core/locale/extra_translation.dart';
import 'package:rental_project/core/routes/app_pages.dart';
import 'package:rental_project/core/routes/auth_middleware.dart';
import 'package:rental_project/core/services/app_services.dart';
import 'package:rental_project/core/services/storage_service.dart';
import 'package:rental_project/core/settings/settings_controller.dart';
import 'package:rental_project/core/theme/app_theme.dart';
import 'package:rental_project/features/auth/auth_routes.dart';
import 'package:rental_project/features/settings/settings_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await initServices(); // opens the Drift database + loads saved data
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (_) => 'app_title'.tr,
        // theme (light / dark) - restored from GetStorage
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: SettingsController.initialTheme(),
        // language (Arabic / English) - restored from GetStorage
        translations: MergedTranslation(),
        locale: SettingsController.initialLocale(),
        fallbackLocale: const Locale('en', 'US'),
        supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialBinding: InitialBinding(),
        initialRoute: AuthRoutes.splash,
        getPages: [
          // every existing app page is protected by the auth middleware
          ...AppPages.pages.map(_guard),
          ...AuthPages.pages,
          ...SettingsPages.pages,
        ],
      );
}

/// Rebuilds a page with [AuthMiddleware] added (keeps its other settings).
GetPage _guard(GetPage p) => GetPage(
      name: p.name,
      page: p.page,
      binding: p.binding,
      bindings: p.bindings,
      transition: p.transition,
      transitionDuration: p.transitionDuration,
      curve: p.curve,
      children: p.children,
      middlewares: [...?p.middlewares, AuthMiddleware()],
    );
