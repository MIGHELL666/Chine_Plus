import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

class UserDashboardScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const UserDashboardScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Cargando información del usuario...'),
        ),
      );
    }

    final userHistory = appState.scanHistory
        .where((s) => s.userId == user.id)
        .toList();

    // Level & points calculation for progress bar
    final int pointsForCurrentLevel = user.points % 500;
    final double levelProgress = pointsForCurrentLevel / 500.0;
    final int pointsToNextLevel = 500 - pointsForCurrentLevel;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => await Future.delayed(const Duration(milliseconds: 800)),
          color: AppTheme.jadeGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Greeting + Theme Toggle)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${user.name} 👋',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '¡Qué película veremos hoy!',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            appState.themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            color: colorScheme.primary,
                          ),
                          onPressed: () => appState.toggleTheme(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_outlined, color: Colors.redAccent),
                          onPressed: () {
                            appState.logout();
                          },
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Profile Card with Level & Points (Gold & Jade styling)
                PremiumCard(
                  gradientColors: colorScheme.brightness == Brightness.dark
                      ? [AppTheme.darkGrey, const Color(0xFF152A20)]
                      : [Colors.white, const Color(0xFFE8F7F0)],
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // User Avatar
                            CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage(user.avatarUrl),
                              backgroundColor: AppTheme.mediumGrey,
                            ),
                            const SizedBox(width: 16),
                            // User Stats
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.jadeGreen.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Nivel ${user.level}',
                                      style: const TextStyle(
                                        color: AppTheme.jadeGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Points Accumulation
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.stars, color: AppTheme.goldAccent, size: 24),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${user.points}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.goldAccent,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Puntos Totales',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Progress Meter
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progreso de nivel',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                                Text(
                                  'Faltan $pointsToNextLevel pts',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.jadeGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: levelProgress,
                                minHeight: 8,
                                backgroundColor: colorScheme.brightness == Brightness.dark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.jadeGreen),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Accesos Rápidos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _buildQuickAction(
                      icon: Icons.qr_code_scanner,
                      label: 'Escanear',
                      color: Colors.blueAccent,
                      onTap: () => onTabChange(3), // QR Scanner Tab
                    ),
                    _buildQuickAction(
                      icon: Icons.card_giftcard,
                      label: 'Premios',
                      color: AppTheme.goldAccent,
                      onTap: () {
                        // Open rewards highlight drawer or dialog
                        _showRewardsListDialog(context, appState);
                      },
                    ),
                    _buildQuickAction(
                      icon: Icons.movie_outlined,
                      label: 'Tracker',
                      color: AppTheme.jadeGreen,
                      onTap: () => onTabChange(0), // Tracker Tab
                    ),
                    _buildQuickAction(
                      icon: Icons.map_outlined,
                      label: 'Cines',
                      color: Colors.purpleAccent,
                      onTap: () => onTabChange(1), // Map Tab
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Featured Rewards Carousel (Horizontal)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recompensas Destacadas',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => _showRewardsListDialog(context, appState),
                      child: const Text('Ver todas'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: appState.rewards.isEmpty
                      ? const Center(
                          child: Text('No hay recompensas disponibles por ahora.'),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: appState.rewards.length,
                          itemBuilder: (context, index) {
                            final reward = appState.rewards[index];
                            return Container(
                              width: 170,
                              margin: const EdgeInsets.only(right: 12, bottom: 8),
                              child: RewardCard(
                                reward: reward,
                                onTap: () => _showRedeemDialog(context, reward, appState),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),

                // Last QR Codes Scanned
                const Text(
                  'Últimos Códigos Escaneados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (userHistory.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text('Aún no has escaneado ningún código QR.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userHistory.length > 5 ? 5 : userHistory.length,
                    itemBuilder: (context, index) {
                      final scan = userHistory[index];
                      final isSuccess = scan.status == 'Completado';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: PremiumCard(
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSuccess
                                    ? AppTheme.jadeGreen.withValues(alpha: 0.1)
                                    : Colors.redAccent.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSuccess ? Icons.qr_code : Icons.qr_code_2,
                                color: isSuccess ? AppTheme.jadeGreen : Colors.redAccent,
                              ),
                            ),
                            title: Text(
                              scan.place,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              scan.date,
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isSuccess ? '+${scan.points} pts' : '0 pts',
                                  style: TextStyle(
                                    color: isSuccess ? AppTheme.jadeGreen : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  scan.status,
                                  style: TextStyle(
                                    color: isSuccess ? AppTheme.jadeGreen : Colors.redAccent,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showRedeemDialog(BuildContext context, Reward reward, AppState appState) {
    if (appState.currentUser == null) return;
    final hasEnoughPoints = appState.currentUser!.points >= reward.pointsRequired;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(reward.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reward.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  reward.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (e, s, t) => Container(
                    height: 120,
                    color: Colors.grey,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(reward.description),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Puntos necesarios:'),
                Text(
                  '${reward.pointsRequired} pts',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldAccent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tus puntos actuales:'),
                Text(
                  '${appState.currentUser!.points} pts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasEnoughPoints ? AppTheme.jadeGreen : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: hasEnoughPoints ? AppTheme.jadeGreen : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: hasEnoughPoints && reward.stock > 0
                ? () {
                    final int updatedPoints = (appState.currentUser!.points - reward.pointsRequired).toInt();
                    final int updatedLevel = (updatedPoints ~/ 500) + 1;
                    appState.saveUser(appState.currentUser!.copyWith(
                      points: updatedPoints,
                      level: updatedLevel,
                    ));
                    appState.saveReward(reward.copyWith(stock: reward.stock - 1));
                    Navigator.pop(context);
                    showAppSnackbar(
                      context,
                      message: '¡Recompensa "${reward.name}" canjeada con éxito! Revisa tu correo.',
                    );
                  }
                : null,
            child: const Text('Canjear'),
          ),
        ],
      ),
    );
  }

  void _showRewardsListDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Catálogo de Premios'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.78,
            ),
            itemCount: appState.rewards.length,
            itemBuilder: (context, index) {
              final reward = appState.rewards[index];
              return RewardCard(
                reward: reward,
                onTap: () {
                  Navigator.pop(context);
                  _showRedeemDialog(context, reward, appState);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
