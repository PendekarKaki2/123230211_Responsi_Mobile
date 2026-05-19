import 'package:get/get.dart';

import '../controllers/show_controller.dart';
import '../pages/detail_page.dart';
import '../pages/login_page.dart';
import '../pages/main_page.dart';

abstract class AppRoutes {
  static const login = '/login';
  static const main = '/main';
  static const detail = '/detail';
}

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainPage(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ShowController>()) {
          Get.lazyPut<ShowController>(() => ShowController(), fenix: true);
        }
      }),
    ),
    GetPage(name: AppRoutes.detail, page: () => const DetailPage()),
  ];
}
