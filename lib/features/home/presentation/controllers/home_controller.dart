import 'package:get/get.dart';
import 'package:rental_project/features/contracts/presentation/controllers/contracts_controller.dart';
import 'package:rental_project/features/finance/presentation/controllers/finance_controller.dart';
import 'package:rental_project/features/tenants/presentation/controllers/tenants_controller.dart';
import 'package:rental_project/features/units/presentation/controllers/units_controller.dart';

class HomeController extends GetxController {
  static const titleKeys = ['units', 'tenants', 'contracts', 'finance'];
  static const addKeys = ['add_unit', 'add_tenant', 'add_contract', 'add_payment'];

  final index = 0.obs;

  void change(int i) => index.value = i;

  /// The floating button adds whatever the current tab manages.
  void onAdd() {
    switch (index.value) {
      case 0:
        Get.find<UnitsController>().addUnit();
      case 1:
        Get.find<TenantsController>().addTenant();
      case 2:
        Get.find<ContractsController>().openForm();
      case 3:
        Get.find<FinanceController>().openPaymentForm();
    }
  }
}
