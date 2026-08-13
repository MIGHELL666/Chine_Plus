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

  List<Widget> _cinemaMarkers(BuildContext context, List<Cinema> cinemas) {
    if (cinemas.isEmpty) return const [];
    final valid = cinemas
        .where((c) => c.latitude != 0 && c.longitude != 0)
        .toList();
    final minLat = valid.isEmpty ? 0.0 : valid.map((c) => c.latitude).reduce((a, b) => a < b ? a : b);
    final maxLat = valid.isEmpty ? 0.0 : valid.map((c) => c.latitude).reduce((a, b) => a > b ? a : b);
    final minLng = valid.isEmpty ? 0.0 : valid.map((c) => c.longitude).reduce((a, b) => a < b ? a : b);
    final maxLng = valid.isEmpty ? 0.0 : valid.map((c) => c.longitude).reduce((a, b) => a > b ? a : b);
    final latRange = (maxLat - minLat).abs();
    final lngRange = (maxLng - minLng).abs();

    return cinemas.asMap().entries.map((entry) {
      final index = entry.key;
      final cinema = entry.value;
      final hasCoordinates = cinema.latitude != 0 && cinema.longitude != 0;
      double top;
      double left;
      if (hasCoordinates && valid.isNotEmpty) {
        top = 70.0 + (latRange == 0 ? 150 : (maxLat - cinema.latitude) / latRange * 260);
        left = 30.0 + (lngRange == 0 ? 130 : (cinema.longitude - minLng) / lngRange * 260);
      } else {
        // Posición visual estable para que también sean visibles los cines
        // administrados sin coordenadas. No se guarda ni se usa como ubicación real.
        final column = index % 4;
        final row = index ~/ 4;
        left = 30.0 + column * 78.0;
        top = 70.0 + (row % 3) * 82.0;
      }
      final selected = _selectedCinema?.id == cinema.id;
      return Positioned(
        top: top.clamp(20.0, 330.0),
        left: left.clamp(20.0, 300.0),
        child: GestureDetector(
          onTap: () => setState(() => _selectedCinema = cinema),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: selected ? 1.3 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.jadeGreen : AppTheme.mediumGrey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
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
              Text(
                cinema.name,
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Seleccionar únicamente un cine que exista en el catálogo real.
    if (_selectedCinema != null &&
        !appState.cinemas.any((cinema) => cinema.id == _selectedCinema!.id)) {
      _selectedCinema = null;
    }
    if (_selectedCinema == null && appState.cinemas.isNotEmpty) {
      _selectedCinema = appState.cinemas.first;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Cines Cercanos')),
      body: Stack(
        children: [
          // 1. Mapa visual con marcadores del catálogo real.
          Positioned.fill(
            child: Container(
              color: colorScheme.brightness == Brightness.dark
                  ? AppTheme.movieBlack
                  : Colors.grey.shade100,
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 3.0,
                boundaryMargin: const EdgeInsets.all(180),
                panEnabled: true,
                scaleEnabled: true,
                child: SizedBox(
                  width: 720,
                  height: 620,
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

                  // Cinema markers positioned from Supabase latitude/longitude.
                  // The custom map is only a visual canvas; no mock IDs are used.
                      ..._cinemaMarkers(context, appState.cinemas),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: appState.cinemas.isEmpty
                ? _buildEmptyCinemasCard(colorScheme)
                : Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(Icons.local_movies, color: AppTheme.jadeGreen),
                          const SizedBox(width: 8),
                          Text('${appState.cinemas.length} cines disponibles'),
                          TextButton(
                            onPressed: () => _showCinemaPicker(context, appState.cinemas),
                            child: const Text('Ver lista'),
                          ),
                        ],
                      ),
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
                                color: AppTheme.jadeGreen.withValues(
                                  alpha: 0.12,
                                ),
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
                                      const Icon(
                                        Icons.navigation_outlined,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Distancia no calculada',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
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
                            const Icon(
                              Icons.access_time_outlined,
                              size: 14,
                              color: AppTheme.jadeGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Horario: Horario no disponible',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
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

  Widget _buildEmptyCinemasCard(ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_off_outlined, color: Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'No hay cines activos en el catálogo.',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCinemaPicker(BuildContext context, List<Cinema> cinemas) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemCount: cinemas.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final cinema = cinemas[index];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.local_movies)),
              title: Text(cinema.name),
              subtitle: Text(cinema.address.isEmpty ? 'Dirección no disponible' : cinema.address),
              selected: _selectedCinema?.id == cinema.id,
              onTap: () {
                setState(() => _selectedCinema = cinema);
                Navigator.pop(context);
              },
            );
          },
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
            _buildDetailRow(
              Icons.access_time,
              'Horario General',
              'Horario no disponible',
            ),
            _buildDetailRow(
              Icons.navigation,
              'Distancia de Referencia',
              'Distancia no calculada',
            ),
            _buildDetailRow(
              Icons.map,
              'Coordenadas',
              'Lat: ${cinema.latitude}, Lng: ${cinema.longitude}',
            ),
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
                Chip(
                  label: Text('Dulcería 3D', style: TextStyle(fontSize: 11)),
                ),
                Chip(
                  label: Text(
                    'Estacionamiento',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                Chip(
                  label: Text(
                    'Acceso Silla Ruedas',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
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
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
