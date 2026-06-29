import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(_laserController);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _triggerMockScan(BuildContext context, AppState appState) {
    // Show a modal sheet to select which mock code to scan
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final activeQRs = appState.qrCodes.where((q) => q.status == 'Activo').toList();
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Simulador de Escáner QR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona qué código promocional deseas simular escanear:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (activeQRs.isEmpty)
                const Center(child: Text('No hay códigos QR activos para escanear.'))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: activeQRs.length + 1, // list + 1 invalid code option
                    itemBuilder: (context, index) {
                      if (index == activeQRs.length) {
                        return ListTile(
                          leading: const Icon(Icons.error_outline, color: Colors.redAccent),
                          title: const Text('Código QR Inválido / Expirado'),
                          subtitle: const Text('Simula un error de lectura'),
                          onTap: () {
                            Navigator.pop(context);
                            appState.scanQRCodeSimulation('Código Inválido', 0);
                            showAppSnackbar(
                              context,
                              message: 'Error al escanear código QR.',
                              isError: true,
                            );
                          },
                        );
                      }

                      final qr = activeQRs[index];
                      return ListTile(
                        leading: const Icon(Icons.qr_code, color: AppTheme.jadeGreen),
                        title: Text(qr.name),
                        subtitle: Text('${qr.type} - Otorga ${qr.points} pts'),
                        trailing: Text(
                          '+${qr.points} pts',
                          style: const TextStyle(
                            color: AppTheme.goldAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          final result = appState.scanQRCodeSimulation(qr.name, qr.points);
                          if (result.status == 'Completado') {
                            showAppSnackbar(
                              context,
                              message: '¡Escaneo exitoso! Obtuviste +${qr.points} puntos.',
                            );
                          } else if (result.status == 'Duplicado') {
                            showAppSnackbar(
                              context,
                              message: 'Este código QR ya fue canjeado por ti.',
                              isError: true,
                            );
                          } else {
                            showAppSnackbar(
                              context,
                              message: 'Error al escanear código QR.',
                              isError: true,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userHistory = appState.scanHistory
        .where((s) => s.userId == appState.currentUser?.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Viewfinder camera simulator box
              Expanded(
                flex: 4,
                child: PremiumCard(
                  borderColor: AppTheme.jadeGreen.withValues(alpha: 0.4),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Dark tint background mimicking camera aperture
                      Container(color: Colors.black.withValues(alpha: 0.85)),

                      // Scanning camera guideline frame
                      Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            // Corner guidelines (viewfinder brackets)
                            _buildViewfinderCorners(),

                            // Laser animation line
                            AnimatedBuilder(
                              animation: _laserAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: 230 * _laserAnimation.value,
                                  left: 20,
                                  right: 20,
                                  child: Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: AppTheme.jadeGreen,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.jadeGreen.withValues(alpha: 0.8),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Information guidance texts
                      Positioned(
                        bottom: 24,
                        child: Text(
                          'Alinea el código QR dentro del recuadro',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Positioned(
                        top: 24,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.flash_on, color: AppTheme.goldAccent, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Cámara Lista',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Scan trigger button
              AppButton(
                text: 'Escanear Código QR',
                icon: Icons.camera_alt_outlined,
                onPressed: () => _triggerMockScan(context, appState),
              ),

              const SizedBox(height: 24),

              // Scanner history title
              const Text(
                'Historial de Escaneos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Scanner history list
              Expanded(
                flex: 3,
                child: userHistory.isEmpty
                    ? const Center(
                        child: Text('No hay registros de escaneo.'),
                      )
                    : ListView.builder(
                        itemCount: userHistory.length,
                        itemBuilder: (context, index) {
                          final scan = userHistory[index];
                          final isSuccess = scan.status == 'Completado';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: PremiumCard(
                              borderColor: isSuccess ? Colors.transparent : Colors.redAccent.withValues(alpha: 0.2),
                              child: ListTile(
                                leading: Icon(
                                  isSuccess ? Icons.check_circle : Icons.cancel,
                                  color: isSuccess ? AppTheme.jadeGreen : Colors.redAccent,
                                ),
                                title: Text(
                                  scan.place,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                subtitle: Text(
                                  'Fecha: ${scan.date}',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViewfinderCorners() {
    const double length = 20.0;
    const double thickness = 4.0;
    const Color color = AppTheme.jadeGreen;

    return Stack(
      children: [
        // Top-left
        Positioned(
          top: 0,
          left: 0,
          child: Container(width: length, height: thickness, color: color),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(width: thickness, height: length, color: color),
        ),
        // Top-right
        Positioned(
          top: 0,
          right: 0,
          child: Container(width: length, height: thickness, color: color),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(width: thickness, height: length, color: color),
        ),
        // Bottom-left
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(width: length, height: thickness, color: color),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(width: thickness, height: length, color: color),
        ),
        // Bottom-right
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(width: length, height: thickness, color: color),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(width: thickness, height: length, color: color),
        ),
      ],
    );
  }
}
