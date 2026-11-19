import 'package:get/get.dart';
import 'package:rental_project/features/contracts/presentation/controllers/contracts_controller.dart';

class ContractsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => ContractsController());
}
