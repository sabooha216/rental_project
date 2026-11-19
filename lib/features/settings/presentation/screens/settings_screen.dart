import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/settings/settings_controller.dart';

/// Uses GetBuilder (manual update()) on the permanent SettingsController.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('settings'.tr)),
        body: GetBuilder<SettingsController>(
          builder: (s) => ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _Section(
                title: 'language'.tr,
                icon: Icons.translate,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 'ar', label: Text('العربية')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {s.locale.value.languageCode},
                  onSelectionChanged: (v) => s.setLanguage(v.first),
                ),
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'appearance'.tr,
                icon: Icons.palette_outlined,
                child: SegmentedButton<ThemeMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode),
                      label: Text('theme_light'.tr),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode),
                      label: Text('theme_dark'.tr),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.brightness_auto),
                      label: Text('theme_system'.tr),
                    ),
                  ],
                  selected: {s.themeMode.value},
                  onSelectionChanged: (v) => s.setTheme(v.first),
                ),
              ),
            ],
          ),
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ]),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: child),
            ],
          ),
        ),
      );
}
