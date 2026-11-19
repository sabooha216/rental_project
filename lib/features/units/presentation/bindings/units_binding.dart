import 'package:get/get.dart';
import 'package:rental_project/features/units/presentation/controllers/units_controller.dart';

class UnitsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => UnitsController());
}
