import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:responsi/controllers/auth_controller.dart';
import 'package:responsi/main.dart';
import 'package:responsi/routes/app_routes.dart';
import 'package:responsi/services/session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Get.testMode = true;
    Get.reset();
    SharedPreferences.setMockInitialValues({});

    final preferences = await SharedPreferences.getInstance();
    Get.put(SessionService(preferences), permanent: true);
    Get.put(AuthController(), permanent: true);
  });

  tearDown(Get.reset);

  testWidgets('menampilkan halaman login', (tester) async {
    await tester.pumpWidget(const MyApp(initialRoute: AppRoutes.login));

    expect(find.text('Hydra Games'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
