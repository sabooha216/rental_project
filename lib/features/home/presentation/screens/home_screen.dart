import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/core/settings/settings_controller.dart';
import 'package:rental_project/features/auth/auth_routes.dart';
import 'package:rental_project/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rental_project/features/contracts/presentation/screens/contracts_screen.dart';
import 'package:rental_project/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:rental_project/features/finance/presentation/screens/finance_screen.dart';
import 'package:rental_project/features/home/presentation/controllers/home_controller.dart';
import 'package:rental_project/features/settings/settings_routes.dart';
import 'package:rental_project/features/tenants/presentation/screens/tenants_screen.dart';
import 'package:rental_project/features/units/presentation/screens/units_screen.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  SettingsController get settings => Get.find<SettingsController>();
  AuthController get auth => Get.find<AuthController>();

  @override
  Widget build(BuildContext context) => Obx(() {
        final i = controller.index.value;
        return Scaffold(
          appBar: AppBar(
            title: Text(HomeController.titleKeys[i].tr),
            actions: [
              IconButton(
                tooltip: 'language'.tr,
                icon: const Icon(Icons.translate),
                onPressed: settings.toggleLanguage,
              ),
              Obx(() => IconButton(
                    tooltip: 'theme'.tr,
                    icon: Icon(settings.themeMode.value == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode),
                    onPressed: settings.toggleTheme,
                  )),
              PopupMenuButton<String>(
                tooltip: 'account'.tr,
                icon: const Icon(Icons.account_circle_outlined),
                onSelected: (v) {
                  switch (v) {
                    case 'profile':
                      Get.toNamed(AuthRoutes.profile);
                      break;
                    case 'settings':
                      Get.toNamed(SettingsRoutes.settings);
                      break;
                    case 'logout':
                      auth.logout();
                      break;
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem<String>(
                    enabled: false,
                    child: Text(auth.displayName),
                  ),
                  const PopupMenuDivider(),
                  _item('profile', Icons.person_outline, 'profile'.tr),
                  _item('settings', Icons.settings_outlined, 'settings'.tr),
                  _item(
                    'logout',
                    Icons.logout,
                    (auth.user.value == null ? 'sign_in' : 'logout').tr,
                  ),
                ],
              ),
            ],
          ),
          body: IndexedStack(
            index: i,
            children: const [DashboardScreen(), UnitsScreen(), TenantsScreen(), ContractsScreen(), FinanceScreen()],
          ),
          floatingActionButton: i == 0 ? null
              : FloatingActionButton.extended(
                  onPressed: controller.onAdd,
                  icon: const Icon(Icons.add),
                  label: Text(HomeController.addKeys[i].tr),
                ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: i,
            onDestinationSelected: controller.change,
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.dashboard), label: 'dashboard'.tr),
              NavigationDestination(
                  icon: const Icon(Icons.apartment), label: 'units'.tr),
              NavigationDestination(
                  icon: const Icon(Icons.people), label: 'tenants'.tr),
              NavigationDestination(
                  icon: const Icon(Icons.description), label: 'contracts'.tr),
              NavigationDestination(
                  icon: const Icon(Icons.account_balance_wallet),
                  label: 'finance'.tr),
              
            ],
          ),
        );
      });

  PopupMenuItem<String> _item(String value, IconData icon, String label) =>
      PopupMenuItem<String>(
        value: value,
        child: Row(children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(label),
        ]),
      );
}