import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Cinema? _selectedCinema;

  @override
  void initState() {
    super.initState();
    // Default select first cinema
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Set default selected cinema if not set
    if (_selectedCinema == null && appState.cinemas.isNotEmpty) {
      _selectedCinema = appState.cinemas.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cines Cercanos'),
      ),
      body: Stack(
        children: [
          // 1. Stylized Mock Map Background
          Positioned.fill(
            child: Container(
              color: colorScheme.brightness == Brightness.dark
                  ? AppTheme.movieBlack
                  : Colors.grey.shade100,
              child: Stack(
                children: [
                  // Map Grid Lines representation
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MapGridPainter(
                        gridColor: colorScheme.brightness == Brightness.dark
                            ? Colors.grey.shade900
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),

                  // Decorative stylized map details (green areas, roads, lakes)
                  Positioned(
                    top: 120,
                    left: 40,
                    child: _buildMapFeature(
                      width: 140,
                      height: 80,
                      color: AppTheme.jadeGreen.withValues(alpha: 0.08),
                      label: 'Bosque Central',
                    ),
                  ),
                  Positioned(
                    bottom: 220,
                    right: 30,
                    child: _buildMapFeature(
                      width: 180,
                      height: 120,
                      color: Colors.blue.withValues(alpha: 0.06),
                      label: 'Lago del Parque',
                    ),
                  ),

                  // Roads
                  Positioned(
                    top: 240,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 24,
                      color: colorScheme.brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.grey.shade200,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Av. de la Constitución',
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 180,
                    child: Container(
                      width: 24,
                      color: colorScheme.brightness == Brightness.dark
                          ? Colors.grey.shade900
                          : Colors.grey.shade200,
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          'Calzada del Cine',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Cinema Pin Markers
                  ...appState.cinemas.map((cinema) {
                    final isSelected = _selectedCinema?.id == cinema.id;
                    // Determine coordinates for mock pins
                    double top = 100;
                    double left = 80;
                    if (cinema.id == 'CIN-001') {
                      top = 180;
                      left = 90;
                    } else if (cinema.id == 'CIN-002') {
                      top = 280;
                      left = 240;
                    } else if (cinema.id == 'CIN-003') {
                      top = 80;
                      left = 220;
                    }

                    return Positioned(
                      top: top,
                      left: left,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCinema = cinema;
                          });
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedScale(
                              scale: isSelected ? 1.3 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.jadeGreen : AppTheme.mediumGrey,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: const Icon(
                                  Icons.local_play,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppTheme.jadeGreen : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                cinema.name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 2. Info Card Overlay at Bottom
          if (_selectedCinema != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutQuart,
                child: PremiumCard(
                  borderColor: AppTheme.jadeGreen.withValues(alpha: 0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.jadeGreen.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.business_outlined,
                                color: AppTheme.jadeGreen,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCinema!.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.navigation_outlined, size: 12, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        'A ${_selectedCinema!.distance} de ti',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedCinema!.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time_outlined, size: 14, color: AppTheme.jadeGreen),
                            const SizedBox(width: 6),
                            Text(
                              'Horario: ${_selectedCinema!.schedule}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          text: 'Ver Información',
                          onPressed: () {
                            _showCinemaDetails(context, _selectedCinema!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapFeature({
    required double width,
    required double height,
    required Color color,
    required String label,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showCinemaDetails(BuildContext context, Cinema cinema) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(cinema.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles del Cine',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.pin_drop, 'Dirección', cinema.address),
            _buildDetailRow(Icons.access_time, 'Horario General', cinema.schedule),
            _buildDetailRow(Icons.navigation, 'Distancia de Referencia', cinema.distance),
            _buildDetailRow(Icons.map, 'Coordenadas del Simulador', 'Lat: ${cinema.latitude}, Lng: ${cinema.longitude}'),
            const SizedBox(height: 16),
            const Text(
              'Servicios Disponibles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Dulcería 3D', style: TextStyle(fontSize: 11))),
                Chip(label: Text('Estacionamiento', style: TextStyle(fontSize: 11))),
                Chip(label: Text('Acceso Silla Ruedas', style: TextStyle(fontSize: 11))),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.jadeGreen, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 13,
                ),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for stylized map grids
class MapGridPainter extends CustomPainter {
  final Color gridColor;
  MapGridPainter({required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    const double step = 40.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
