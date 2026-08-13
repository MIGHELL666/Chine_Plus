import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/state/app_state.dart';

class QrCodesScreen extends StatelessWidget {
  const QrCodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final qrCodes = appState.userQrCodes
        .where((qr) => (qr['codigo']?.toString() ?? '').isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis códigos QR'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => context.read<AppState>().cargarMisQr(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: qrCodes.isEmpty
          ? RefreshIndicator(
              onRefresh: () => context.read<AppState>().cargarMisQr(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Todavía no tienes códigos QR generados.')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => context.read<AppState>().cargarMisQr(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: qrCodes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final qr = qrCodes[index];
                  final code = qr['codigo'].toString();
                  final estado = qr['estado']?.toString() ?? 'activo';
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showQr(context, code, estado),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            QrImageView(data: code, size: 120),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Código QR'),
                                  const SizedBox(height: 8),
                                  SelectableText(code),
                                  const SizedBox(height: 8),
                                  Text('Estado: $estado'),
                                  const SizedBox(height: 4),
                                  const Text('Toca para ampliar'),
                                ],
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
    );
  }

  void _showQr(BuildContext context, String code, String estado) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código QR generado'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(data: code, size: 220),
              const SizedBox(height: 12),
              SelectableText(code, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Estado: $estado'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
