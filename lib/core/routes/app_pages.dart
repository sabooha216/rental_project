import 'package:get/get.dart';
import 'package:rental_project/core/routes/app_routes.dart';
import 'package:rental_project/features/home/presentation/bindings/home_binding.dart';
import 'package:rental_project/features/home/presentation/screens/home_screen.dart';
import 'package:rental_project/features/tenants/presentation/bindings/tenant_statement_binding.dart';
import 'package:rental_project/features/tenants/presentation/screens/tenant_statement_screen.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(name: Routes.home, page: () => const HomeScreen(), binding: HomeBinding()),
    GetPage(
      name: Routes.tenantStatement,
      page: () => const TenantStatementScreen(),
      binding: TenantStatementBinding(),
    ),
  ];
}
