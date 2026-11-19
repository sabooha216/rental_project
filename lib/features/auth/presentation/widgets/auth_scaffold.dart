import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/settings/settings_controller.dart';
import 'package:rental_project/core/widgets/app_logo.dart';

/// Shared layout for login / register: gradient header + floating card.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(12, top + 8, 12, 56),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00897B), Color(0xFF004D40)],
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(36)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (showBack)
                        const BackButton(color: Colors.white)
                      else
                        const SizedBox(width: 48),
                      const Spacer(),
                      IconButton(
                        tooltip: 'language'.tr,
                        icon: const Icon(Icons.translate, color: Colors.white),
                        onPressed: settings.toggleLanguage,
                      ),
                      Obx(() => IconButton(
                            tooltip: 'theme'.tr,
                            icon: Icon(
                              settings.isDark
                                  ? Icons.light_mode
                                  : Icons.dark_mode,
                              color: Colors.white,
                            ),
                            onPressed: settings.toggleTheme,
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const AppLogo(size: 84),
                  const SizedBox(height: 12),
                  Text(
                    'app_title'.tr,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'tagline'.tr,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -32),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 20),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
