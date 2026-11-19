import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rental_project/features/auth/auth_routes.dart';
import 'package:rental_project/features/auth/presentation/controllers/auth_controller.dart';
import 'package:rental_project/features/auth/presentation/widgets/auth_field.dart';
import 'package:rental_project/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:rental_project/features/auth/presentation/widgets/auth_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true;

  AuthController get auth => Get.find<AuthController>();

  @override
  void dispose() {
    _phone.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    auth.login(phone: _phone.text, password: _pass.text);
  }

  @override
  Widget build(BuildContext context) => AuthScaffold(
        title: 'welcome_back'.tr,
        subtitle: 'login_sub'.tr,
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthField(
                controller: _phone,
                label: 'phone'.tr,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                ltr: true,
                validator: AuthValidators.phone,
              ),
              const SizedBox(height: 14),
              AuthField(
                controller: _pass,
                label: 'password'.tr,
                icon: Icons.lock_outline,
                obscure: _hide,
                ltr: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                validator: AuthValidators.required,
                suffix: IconButton(
                  icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _hide = !_hide),
                ),
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
                        : Text('sign_in'.tr),
                  )),
              const SizedBox(height: 14),
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or'.tr),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
                onPressed: auth.continueAsGuest,
                icon: const Icon(Icons.person_outline),
                label: Text('continue_guest'.tr),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('no_account'.tr),
                  TextButton(
                    onPressed: () => Get.toNamed(AuthRoutes.register),
                    child: Text('create_account'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
