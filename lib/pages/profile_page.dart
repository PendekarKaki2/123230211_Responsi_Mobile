import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/favorite_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final favoriteController = Get.find<FavoriteController>();
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: colorScheme.primary,
              child: Icon(
                Icons.person_rounded,
                color: colorScheme.onPrimary,
                size: 36,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authController.username.value.isEmpty
                          ? 'Pengguna'
                          : authController.username.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Latihan Responsi Praktikum Mobile',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _ProfileSection(
          title: 'Ringkasan',
          children: [
            Obx(
              () => _InfoTile(
                icon: Icons.favorite_rounded,
                label: 'Total favorit',
                value: '${favoriteController.favorites.length} show',
              ),
            ),
            const _InfoTile(
              icon: Icons.storage_rounded,
              label: 'Penyimpanan session',
              value: 'SharedPreferences',
            ),
            const _InfoTile(
              icon: Icons.inventory_2_rounded,
              label: 'Penyimpanan favorit',
              value: 'Hive',
            ),
            const _InfoTile(
              icon: Icons.route_rounded,
              label: 'State & routing',
              value: 'GetX',
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _ProfileSection(
          title: 'Kesan dan Pesan',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Text(
                'Praktikum Mobile membantu saya memahami alur pembuatan aplikasi Flutter, mulai dari layout, navigasi, pengambilan data API, penyimpanan lokal, sampai manajemen state. Semoga praktikum berikutnya tetap seru, jelas, dan makin banyak studi kasus yang dekat dengan kebutuhan aplikasi nyata.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: colorScheme.onSurface.withValues(alpha: 0.76),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            onPressed: () => _confirmLogout(context, authController),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    AuthController authController,
  ) async {
    final shouldLogout =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Logout?'),
              content: const Text('Session login akan dihapus dari perangkat.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Logout'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldLogout) {
      await authController.logout();
    }
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 21, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.68),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
