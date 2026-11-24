import 'package:rental_project/features/dashboard/presentation/bindings/dashboard_binding.dart';
import 'package:get/get.dart';
import 'package:rental_project/features/contracts/presentation/bindings/contracts_binding.dart';
import 'package:rental_project/features/finance/presentation/bindings/finance_binding.dart';
import 'package:rental_project/features/home/presentation/controllers/home_controller.dart';
import 'package:rental_project/features/tenants/presentation/bindings/tenants_binding.dart';
import 'package:rental_project/features/units/presentation/bindings/units_binding.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    // the four tabs hosted by Home
    UnitsBinding().dependencies();
    TenantsBinding().dependencies();
    ContractsBinding().dependencies();
    FinanceBinding().dependencies();
    DashboardBinding().dependencies();
  }
}
