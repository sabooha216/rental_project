import 'package:get/get.dart';
import 'package:rental_project/features/finance/presentation/controllers/finance_controller.dart';

class FinanceBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => FinanceController());
}
