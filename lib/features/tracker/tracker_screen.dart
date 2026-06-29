import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/theme.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final String _searchQuery = '';
  String _selectedGenre = 'Todos';
  double _minRating = 0.0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Filter movies
    final filteredMovies = appState.movies.where((movie) {
      final matchesSearch = movie.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          movie.cinemaName.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesGenre = _selectedGenre == 'Todos' || movie.genre.toLowerCase() == _selectedGenre.toLowerCase();
      final matchesRating = movie.rating >= _minRating;
      return matchesSearch && matchesGenre && matchesRating;
    }).toList();

    // Stats calculations
    final int totalMovies = appState.movies.length;
    final int totalMinutes = appState.movies.fold(0, (sum, item) => sum + item.durationMinutes);
    final double totalHours = totalMinutes / 60.0;

    // Genre count helper
    final Map<String, int> genreCounts = {};
    for (var m in appState.movies) {
      genreCounts[m.genre] = (genreCounts[m.genre] ?? 0) + 1;
    }
    String favoriteGenre = 'Ninguno';
    int maxGenreCount = 0;
    genreCounts.forEach((genre, count) {
      if (count > maxGenreCount) {
        maxGenreCount = count;
        favoriteGenre = genre;
      }
    });

    // Unique list of genres in the database
    final allGenres = ['Todos', ...appState.movies.map((m) => m.genre).toSet()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Historial de Cine'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.jadeGreen,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showAddMovieDialog(context, appState),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.movie_filter_outlined,
                      value: '$totalMovies',
                      label: 'Películas',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.favorite_border_outlined,
                      value: favoriteGenre.split(' ')[0], // short name
                      label: 'Género Favorito',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.hourglass_empty_rounded,
                      value: '${totalHours.toStringAsFixed(1)}h',
                      label: 'Horas Vistas',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search Box
              AppTextField(
                labelText: 'Buscar película o cine...',
                hintText: 'Ej. Dune 2',
                prefixIcon: Icons.search,
                validator: null,
                keyboardType: TextInputType.text,
                controller: TextEditingController(text: _searchQuery)
                  ..selection = TextSelection.collapsed(offset: _searchQuery.length),
                // We recreate standard behavior or simply update query on change
                // Below we will listen to changes via an onChange wrapper
              ),
              const SizedBox(height: 12),

              // Custom filter panel (Mini slider & genre chips)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: allGenres.contains(_selectedGenre) ? _selectedGenre : 'Todos',
                      decoration: InputDecoration(
                        labelText: 'Género',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: allGenres.map((genre) {
                        return DropdownMenuItem<String>(
                          value: genre,
                          child: Text(genre, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedGenre = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<double>(
                      initialValue: _minRating,
                      decoration: InputDecoration(
                        labelText: 'Estrellas mín.',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: [0.0, 1.0, 2.0, 3.0, 4.0, 5.0].map((rating) {
                        return DropdownMenuItem<double>(
                          value: rating,
                          child: Row(
                            children: [
                              Text('${rating.toInt()}+', style: const TextStyle(fontSize: 13)),
                              const Icon(Icons.star, color: AppTheme.goldAccent, size: 14),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _minRating = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Movies list
              Expanded(
                child: filteredMovies.isEmpty
                    ? const EmptyStateWidget(
                        title: 'Sin coincidencias',
                        subtitle: 'No encontramos películas vistas con los filtros actuales.',
                        icon: Icons.movie_creation_outlined,
                      )
                    : ListView.builder(
                        itemCount: filteredMovies.length,
                        itemBuilder: (context, index) {
                          final movie = filteredMovies[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: MovieCard(
                              movie: movie,
                              onTap: () => _showMovieDetailsBottomSheet(context, movie),
                              onDelete: () {
                                appState.deleteMovie(movie.id);
                                showAppSnackbar(context, message: 'Película eliminada del historial.');
                              },
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

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return PremiumCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.jadeGreen, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.5)),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showMovieDetailsBottomSheet(BuildContext context, Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      movie.posterUrl,
                      height: 120,
                      width: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (e, s, t) => Container(
                        height: 120,
                        width: 90,
                        color: AppTheme.mediumGrey,
                        child: const Icon(Icons.movie, color: AppTheme.jadeGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Género: ${movie.genre}',
                          style: const TextStyle(fontSize: 14, color: AppTheme.jadeGreen),
                        ),
                        Text(
                          'Duración: ${movie.durationMinutes} min',
                          style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < movie.rating ? Icons.star : Icons.star_border,
                              color: AppTheme.goldAccent,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Sinopsis',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                movie.description,
                style: TextStyle(fontSize: 14, height: 1.5, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cine visitado:',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  Text(
                    movie.cinemaName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Fecha de visita:',
                    style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  Text(
                    movie.watchDate,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Cerrar Detalles',
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddMovieDialog(BuildContext context, AppState appState) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final cinemaController = TextEditingController(text: 'Cinepolis Altaria');
    final genreController = TextEditingController(text: 'Acción');
    final minutesController = TextEditingController(text: '120');
    final descController = TextEditingController();
    double rating = 4.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Registrar Película Vista'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: titleController,
                    labelText: 'Título de la película',
                    hintText: 'Ej. Dune 2',
                    prefixIcon: Icons.movie_outlined,
                    validator: (v) => v == null || v.isEmpty ? 'Falta el título' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: cinemaController,
                    labelText: 'Cine',
                    hintText: 'Cinepolis Altaria',
                    prefixIcon: Icons.local_play_outlined,
                    validator: (v) => v == null || v.isEmpty ? 'Falta el cine' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: genreController,
                          labelText: 'Género',
                          hintText: 'Ej. Acción',
                          validator: (v) => v == null || v.isEmpty ? 'Falta el género' : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: minutesController,
                          labelText: 'Minutos',
                          hintText: '120',
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || int.tryParse(v) == null ? 'Inválido' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: descController,
                    labelText: 'Comentario / Sinopsis',
                    hintText: 'Cuéntanos un poco sobre la película...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('Tu Calificación', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starVal = index + 1.0;
                      return IconButton(
                        icon: Icon(
                          starVal <= rating ? Icons.star : Icons.star_border,
                          color: AppTheme.goldAccent,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            rating = starVal;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.jadeGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newMovie = Movie(
                    id: 'MOV-${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text,
                    posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=300', // standard fallback poster
                    watchDate: '26/06/2026',
                    cinemaName: cinemaController.text,
                    rating: rating,
                    genre: genreController.text,
                    durationMinutes: int.parse(minutesController.text),
                    description: descController.text.isNotEmpty
                        ? descController.text
                        : 'Sin comentarios registrados por el usuario.',
                  );

                  appState.addMovie(newMovie);
                  Navigator.pop(context);
                  showAppSnackbar(context, message: '¡Película agregada a tu tracker!');
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
