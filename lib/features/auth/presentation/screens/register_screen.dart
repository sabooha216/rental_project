import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/features/auth/data/models/app_user.dart';
import 'package:rental_project/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rental_project/features/auth/presentation/widgets/auth_field.dart';
import 'package:rental_project/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:rental_project/features/auth/presentation/widgets/auth_validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  UserRole _role = UserRole.owner;
  bool _hide = true;

  AuthController get auth => Get.find<AuthController>();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    auth.register(
      name: _name.text,
      phone: _phone.text,
      password: _pass.text,
      role: _role,
    );
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        title: 'create_account'.tr,
        subtitle: 'register_sub'.tr,
        showBack: true,
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthField(
                controller: _name,
                label: 'full_name'.tr,
                icon: Icons.person_outline,
                validator: AuthValidators.name,
              ),
              const SizedBox(height: 14),
              AuthField(
                controller: _phone,
                label: 'phone'.tr,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                ltr: true,
                validator: AuthValidators.phone,
              ),
              const SizedBox(height: 16),
              Text('account_type'.tr,
                  style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<UserRole>(
                showSelectedIcon: false,
                segments: [
                  for (final r in UserRole.values)
                    ButtonSegment<UserRole>(
                      value: r,
                      label: Text(r.labelKey.tr),
                      icon: Icon(r == UserRole.owner
                          ? Icons.home_work_outlined
                          : Icons.manage_accounts_outlined),
                    ),
                ],
                selected: {_role},
                onSelectionChanged: (s) => setState(() => _role = s.first),
              ),
              const SizedBox(height: 16),
              AuthField(
                controller: _pass,
                label: 'password'.tr,
                icon: Icons.lock_outline,
                obscure: _hide,
                ltr: true,
                validator: AuthValidators.password,
                suffix: IconButton(
                  icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
              ),
              const SizedBox(height: 14),
              AuthField(
                controller: _confirm,
                label: 'confirm_password'.tr,
                icon: Icons.lock_reset,
                obscure: _hide,
                ltr: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: AuthValidators.confirm(() => _pass.text),
              ),
              const SizedBox(height: 22),
              Obx(() => FilledButton(
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52)),
                    onPressed: auth.loading.value ? null : _submit,
                    child: auth.loading.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text('create_account'.tr),
                  )),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('have_account'.tr),
                  TextButton(
                    onPressed: Get.back,
                    child: Text('sign_in'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
