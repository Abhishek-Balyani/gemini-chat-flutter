import 'package:get/get.dart';
import '../bindings/auth_binding.dart';
import 'login_view.dart';

abstract class AuthRoutes {
  static const login = '/auth/login';

  static final routes = <GetPage>[
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
  ];
}
