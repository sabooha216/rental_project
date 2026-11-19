import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/bindings/initial_binding.dart';
import 'package:rental_project/core/locale/app_translation.dart';
import 'package:rental_project/core/routes/app_pages.dart';
import 'package:rental_project/core/theme/app_theme.dart';
import 'package:rental_project/features/auth/auth_routes.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (_) => 'app_title'.tr,
        // theme (light / dark)
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        // language (Arabic / English)
        translations: AppTranslation(),
        locale: const Locale('ar', 'SA'),
        fallbackLocale: const Locale('en', 'US'),
        supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialBinding: InitialBinding(),
        initialRoute: AuthRoutes.splash,
        getPages: [...AppPages.pages, ...AuthPages.pages],
      );
}
