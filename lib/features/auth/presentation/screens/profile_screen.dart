import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/features/auth/domain/entities/app_user.dart';
import 'package:rental_project/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rental_project/features/auth/presentation/controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('profile'.tr)),
        body: controller.obx(
          (user) => _Details(user: user!),
          onLoading: const Center(child: CircularProgressIndicator()),
          onEmpty: const _GuestView(),
          onError: (e) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 8),
                Text(e ?? ''),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: controller.load,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          ),
        ),
      );
}

class _Details extends StatelessWidget {
  const _Details({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: cs.primaryContainer,
            child: Text(
              (user.name.isEmpty ? '?' : user.name.substring(0, 1)).toUpperCase(),
              style: theme.textTheme.headlineMedium
                  ?.copyWith(color: cs.onPrimaryContainer),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(user.name,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 20),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.phone_outlined),
                title: Text('phone'.tr),
                subtitle: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(user.phone),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text('account_type'.tr),
                subtitle: Text(user.role.labelKey.tr),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          style:
              OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          onPressed: Get.find<AuthController>().logout,
          icon: const Icon(Icons.logout),
          label: Text('logout'.tr),
        ),
      ],
    );
  }
}

class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text('guest_profile_msg'.tr, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: Get.find<AuthController>().logout,
                child: Text('sign_in'.tr),
              ),
            ],
          ),
        ),
      );
}
