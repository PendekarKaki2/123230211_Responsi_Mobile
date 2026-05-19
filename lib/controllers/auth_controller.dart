import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../services/session_service.dart';
import 'show_controller.dart';

class AuthController extends GetxController {
  final SessionService _sessionService = Get.find<SessionService>();

  final username = ''.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsername();
  }

  Future<void> loadUsername() async {
    username.value = await _sessionService.getUsername();
  }

  Future<void> login({
    required String usernameInput,
    required String passwordInput,
  }) async {
    final trimmedUsername = usernameInput.trim();
    final trimmedPassword = passwordInput.trim();

    if (trimmedUsername.isEmpty || trimmedPassword.isEmpty) {
      _showWarning('Email dan password wajib diisi.');
      return;
    }

    isLoading.value = true;
    await _sessionService.saveLogin(trimmedUsername);
    username.value = trimmedUsername;
    isLoading.value = false;

    Get.offAllNamed(AppRoutes.main);
  }

  Future<void> logout() async {
    await _sessionService.logout();
    username.value = '';

    if (Get.isRegistered<ShowController>()) {
      Get.delete<ShowController>(force: true);
    }

    Get.offAllNamed(AppRoutes.login);
  }

  void _showWarning(String message) {
    Get.snackbar(
      'Periksa input',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade50,
      colorText: Colors.orange.shade900,
      margin: const EdgeInsets.all(16),
    );
  }
}
