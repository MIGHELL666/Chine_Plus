import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  String? _selectedCinemaId;
  bool _processing = false;
  bool _cameraOpen = false;
  String? _scanError;
  String _scanStatus = 'Selecciona un cine para comenzar.';
  String? _lastScannedCode;

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

  Future<void> _handleDetection(
    BuildContext context,
    AppState appState,
    BarcodeCapture capture,
  ) async {
    if (_processing || _selectedCinemaId == null) return;
    final codigo = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstWhere((value) => value.trim().isNotEmpty, orElse: () => '');
    if (codigo.isEmpty) return;
    debugPrint('[DATA][QR][SCANNER] Código detectado: ${codigo.trim()}');
    setState(() {
      _processing = true;
      _scanError = null;
      _scanStatus = 'QR detectado. Validando con Supabase...';
      _lastScannedCode = codigo.trim();
    });
    try {
      final result = await appState.registrarUsoQr(
        codigo: codigo.trim(),
        cineId: _selectedCinemaId!,
      );
      debugPrint('[DATA][QR][SCANNER] RPC aceptada: $result');
      if (!mounted) return;
      final points = result['puntos_obtenidos'] ?? result['puntos'] ?? 50;
      final balance = result['saldo_actual'] ?? result['nuevo_saldo'] ?? result['saldo'] ?? appState.currentUser?.points;
      setState(() {
        _cameraOpen = false;
        _processing = false;
        _scanStatus = 'Escaneo exitoso. QR registrado.';
      });
      showAppSnackbar(
        context,
        message: 'QR registrado: +$points puntos. Saldo: $balance puntos.',
      );
    } catch (error) {
      debugPrint('[DATA][QR][SCANNER][ERROR] $error');
      if (!mounted) return;
      setState(() {
        _scanError = error.toString();
        _processing = false;
        _scanStatus = 'El QR fue rechazado.';
      });
      showAppSnackbar(context, message: _scanError!, isError: true);
    }
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

              DropdownButtonFormField<String>(
                initialValue: _selectedCinemaId,
                decoration: const InputDecoration(
                  labelText: 'Cine donde estás realizando el escaneo',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Selecciona un cine'),
                items: appState.cinemas
                    .map((cinema) => DropdownMenuItem<String>(
                          value: cinema.id,
                          child: Text(cinema.name),
                        ))
                    .toList(),
                onChanged: _processing
                    ? null
                    : (value) => setState(() {
                          _selectedCinemaId = value;
                          _cameraOpen = false;
                          _scanError = null;
                          _scanStatus = value == null ? 'Selecciona un cine para comenzar.' : 'Cine seleccionado. Pulsa Escanear Código QR.';
                          _lastScannedCode = null;
                        }),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (_scanError == null ? AppTheme.jadeGreen : Colors.redAccent).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(_processing ? Icons.sync : (_scanError == null ? Icons.info_outline : Icons.error_outline)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_scanStatus)),
                ]),
              ),
              if (_lastScannedCode != null) ...[
                const SizedBox(height: 8),
                Text('Código leído: $_lastScannedCode', maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 16),

              // Viewfinder camera simulator box
                Expanded(
                  flex: 4,
                  child: PremiumCard(
                  borderColor: AppTheme.jadeGreen.withValues(alpha: 0.4),
                    child: _cameraOpen && _selectedCinemaId != null
                        ? Stack(
                            children: [
                              MobileScanner(
                                onDetect: (capture) =>
                                    _handleDetection(context, appState, capture),
                              ),
                              if (_processing)
                                Container(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  alignment: Alignment.center,
                                  child: const CircularProgressIndicator(),
                                ),
                            ],
                          )
                        : Stack(
                    alignment: Alignment.center,
                    children: [
                      // Camera preview placeholder until the user starts scanning.
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
                onPressed: () {
                  if (_selectedCinemaId == null || _processing) return;
                  setState(() {
                          _cameraOpen = true;
                          _scanError = null;
                          _scanStatus = 'Apunta la cámara al código QR...';
                          _lastScannedCode = null;
                        });
                },
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
