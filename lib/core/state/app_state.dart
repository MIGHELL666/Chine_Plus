import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/models.dart';
import '../../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  final SupabaseService _service = SupabaseService();
  bool _loading = true;
  bool get loading => _loading;
  final List<Movie> _catalogMovies = [];
  List<Movie> get catalogMovies => _catalogMovies;
  final List<Movie> _adminMovies = [];
  List<Movie> get adminMovies => List.unmodifiable(_adminMovies);
  final List<Movie> _favoriteMovies = [];
  List<Movie> get favoriteMovies => List.unmodifiable(_favoriteMovies);
  final List<Map<String, dynamic>> _userQrCodes = [];
  List<Map<String, dynamic>> get userQrCodes => List.unmodifiable(_userQrCodes);
  String? _lastQrCode;
  String? get lastQrCode => _lastQrCode;
  String? _pendingQrCode;
  String? get pendingQrCode => _pendingQrCode;

  String? consumePendingQrCode() {
    final code = _pendingQrCode;
    _pendingQrCode = null;
    return code;
  }
  Map<String, dynamic>? _lastCanjeResult;
  Map<String, dynamic>? get lastCanjeResult => _lastCanjeResult;
  String? _authError;
  String? get authError => _authError;

  AppState() {
    // Production state starts empty. Supabase is the only source for data.
    _users.clear();
    _movies.clear();
    _catalogMovies.clear();
    _favoriteMovies.clear();
    _cinemas.clear();
    _qrCodes.clear();
    _rewards.clear();
    _scanHistory.clear();
    _restoreSession();
    _loadCatalogs();
  }

  Future<void> _loadCatalogs() async {
    _movies.clear();
    _catalogMovies.clear();
    _cinemas.clear();
    _rewards.clear();
    await Future.wait([
      _loadMoviesCatalog(),
      _loadCinemasCatalog(),
      _loadRewardsCatalog(),
    ]);
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadMoviesCatalog() async {
    try {
      _catalogMovies
        ..clear()
        ..addAll(await _service.obtenerPeliculas());
    } catch (error, stack) {
      _catalogMovies.clear();
      debugPrint('[DATA][PELICULAS][ERROR] No se pudieron cargar: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _loadCinemasCatalog() async {
    try {
      _cinemas
        ..clear()
        ..addAll(await _service.obtenerCines());
    } catch (error, stack) {
      _cinemas.clear();
      debugPrint('[DATA][CINES][ERROR] No se pudieron cargar: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _loadRewardsCatalog() async {
    try {
      _rewards
        ..clear()
        ..addAll(await _service.obtenerPromociones());
    } catch (error, stack) {
      _rewards.clear();
      debugPrint('[DATA][PROMOCIONES][ERROR] No se pudieron cargar: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> _restoreSession() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        _currentUser = await _service.asegurarPerfil(
          id: user.id,
          email: user.email ?? '',
        );
        debugPrint('[AUTH][RESTORE] perfil cargado id=${_currentUser?.id}');
        await _loadWatchedMovies();
        await _loadFavorites();
        await _loadUserQrCodes();
        if (_currentUser?.role == 'admin') await _loadAdminUsers();
        if (_currentUser?.role == 'admin') await cargarPeliculasAdmin();
        if (_currentUser?.role == 'admin') await cargarCinesAdmin();
        notifyListeners();
      } catch (error) {
        debugPrint('[AUTH][RESTORE][ERROR] $error');
      }
    }
  }

  Future<void> _loadWatchedMovies() async {
    final userId = _currentUser?.id;
    if (userId == null) return;
    try {
      _movies
        ..clear()
        ..addAll(await _service.obtenerPeliculasVistas(userId));
      notifyListeners();
    } catch (error) {
      debugPrint(
        '[DATA][VISITAS][ERROR] No se pudo cargar el historial: $error',
      );
    }
  }

  Future<void> _loadFavorites() async {
    final userId = _currentUser?.id;
    if (userId == null) return;
    try {
      _favoriteMovies
        ..clear()
        ..addAll(await _service.obtenerFavoritos(userId));
      notifyListeners();
    } catch (error) {
      _favoriteMovies.clear();
      debugPrint('[DATA][FAVORITOS][ERROR] No se pudieron cargar: $error');
    }
  }

  Future<void> _loadAdminUsers() async {
    try {
      _users
        ..clear()
        ..addAll(await _service.obtenerUsuarios());
      notifyListeners();
    } catch (error, stack) {
      debugPrint('[DATA][PERFILES][ERROR] No se pudieron cargar usuarios: $error');
      debugPrintStack(stackTrace: stack);
    }
  }

  Future<void> cargarPeliculasAdmin() async {
    _adminMovies
      ..clear()
      ..addAll(await _service.obtenerPeliculasAdmin());
    notifyListeners();
  }

  Future<void> crearPeliculaAdmin({
    required String titulo,
    String? posterUrl,
    String? genero,
    int? duracionMinutos,
    String? descripcion,
    DateTime? fechaEstreno,
    String estado = 'activo',
  }) async {
    await _service.crearPelicula(titulo: titulo, posterUrl: posterUrl, genero: genero,
      duracionMinutos: duracionMinutos, descripcion: descripcion,
      fechaEstreno: fechaEstreno, estado: estado);
    await cargarPeliculasAdmin();
  }

  Future<void> actualizarPeliculaAdmin(Movie movie) async {
    await _service.actualizarPelicula(movie);
    await cargarPeliculasAdmin();
  }

  Future<String> subirPosterAdmin(Uint8List bytes, String extension) {
    return _service.subirPoster(bytes, extension);
  }

  Future<void> eliminarPosterAnteriorAdmin(String? url) {
    return _service.eliminarPosterSiEsDelBucket(url);
  }

  Future<void> actualizarEstadoPeliculaAdmin(Movie movie) async {
    final next = movie.status == 'activo' ? 'inactivo' : 'activo';
    await _service.actualizarEstadoPelicula(movie.id, next);
    await cargarPeliculasAdmin();
  }

  Future<void> cargarCinesAdmin() async {
    _adminCinemas..clear()..addAll(await _service.obtenerCinesAdmin());
    notifyListeners();
  }

  Future<void> crearCineAdmin({required String googlePlaceId, required String nombre, String? direccion, double? latitud, double? longitud}) async {
    await _service.crearCine(googlePlaceId: googlePlaceId, nombre: nombre, direccion: direccion, latitud: latitud, longitud: longitud);
    await cargarCinesAdmin();
  }

  Future<void> actualizarCineAdmin(Cinema cine) async {
    await _service.actualizarCine(cine);
    await cargarCinesAdmin();
  }

  Future<void> actualizarEstadoCineAdmin(Cinema cine) async {
    await _service.actualizarEstadoCine(cine.id, cine.status == 'activo' ? 'inactivo' : 'activo');
    await cargarCinesAdmin();
  }

  // Theme state
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  // Active/Current User Session State
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';

  // Mock list of users (for admin panel)
  final List<AppUser> _users = [
    AppUser(
      id: 'USR-001',
      name: 'Miguel Ángel',
      email: 'miguel@chineplus.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      level: 4,
      points: 1250,
      role: 'user',
      status: 'Activo',
      registrationDate: '15/01/2026',
    ),
    AppUser(
      id: 'USR-002',
      name: 'Sofía Reyes',
      email: 'sofia@gmail.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
      level: 2,
      points: 450,
      role: 'user',
      status: 'Activo',
      registrationDate: '03/03/2026',
    ),
    AppUser(
      id: 'USR-003',
      name: 'Carlos Mendoza',
      email: 'carlos.m@yahoo.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
      level: 1,
      points: 120,
      role: 'user',
      status: 'Inactivo',
      registrationDate: '28/05/2026',
    ),
    AppUser(
      id: 'USR-004',
      name: 'Admin ChinePlus',
      email: 'admin@chineplus.com',
      avatarUrl:
          'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
      level: 10,
      points: 9999,
      role: 'admin',
      status: 'Activo',
      registrationDate: '01/01/2026',
    ),
  ];

  List<AppUser> get users => _users;

  // Mock list of movies watched (for tracker)
  final List<Movie> _movies = [
    Movie(
      id: 'MOV-001',
      title: 'Dune: Part Two',
      posterUrl:
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300',
      watchDate: '12/03/2026',
      cinemaName: 'Cinepolis Altaria',
      rating: 5.0,
      genre: 'Ciencia Ficción',
      durationMinutes: 166,
      description:
          'Paul Atreides se une a Chani y a los Fremen mientras busca venganza contra los conspiradores que destruyeron a su familia.',
    ),
    Movie(
      id: 'MOV-002',
      title: 'Oppenheimer',
      posterUrl:
          'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=300',
      watchDate: '20/02/2026',
      cinemaName: 'Cinemark Lindavista',
      rating: 4.5,
      genre: 'Drama / Histórica',
      durationMinutes: 180,
      description:
          'La historia del científico estadounidense J. Robert Oppenheimer y su papel en el desarrollo de la bomba atómica.',
    ),
    Movie(
      id: 'MOV-003',
      title: 'Spider-Man: Across the Spider-Verse',
      posterUrl:
          'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=300',
      watchDate: '05/01/2026',
      cinemaName: 'Cinepolis Altaria',
      rating: 5.0,
      genre: 'Animación / Acción',
      durationMinutes: 140,
      description:
          'Miles Morales es catapultado a través del Multiverso, donde se encuentra con un equipo de Spider-People encargados de proteger su existencia.',
    ),
  ];

  List<Movie> get movies => _movies;

  // Production catalog. It is populated exclusively from Supabase.
  final List<Cinema> _cinemas = [];
  final List<Cinema> _adminCinemas = [];
  List<Cinema> get adminCinemas => List.unmodifiable(_adminCinemas);

  List<Cinema> get cinemas => _cinemas;

  // Mock QR Codes Generator List (Admin panel)
  final List<QRCode> _qrCodes = [
    QRCode(
      id: 'QR-001',
      name: 'Boleto Dune 2 - Preventa',
      type: 'Boleto',
      points: 100,
      startDate: '10/02/2026',
      expirationDate: '30/06/2026',
      status: 'Activo',
      description:
          'Código QR otorgado en la compra de boletos para Dune: Part Two en preventa.',
    ),
    QRCode(
      id: 'QR-002',
      name: 'Poster Promocional Avengers',
      type: 'Poster',
      points: 50,
      startDate: '01/03/2026',
      expirationDate: '31/12/2026',
      status: 'Activo',
      description:
          'Escanear el código del poster en el pasillo central del cine.',
    ),
    QRCode(
      id: 'QR-003',
      name: 'Stand de Palomitas ChinePlus',
      type: 'Stand promocional',
      points: 30,
      startDate: '15/04/2026',
      expirationDate: '15/05/2026',
      status: 'Expirado',
      description: 'Código del stand promocional de ChinePlus.',
    ),
  ];

  List<QRCode> get qrCodes => _qrCodes;

  // Mock Rewards
  final List<Reward> _rewards = [
    Reward(
      id: 'REW-001',
      name: 'Palomitas Grandes Gratis',
      description:
          'Canjeable por una cubeta de palomitas grandes de mantequilla en dulcería.',
      imageUrl:
          'https://images.unsplash.com/photo-1578244182942-18427f3caca6?w=200',
      pointsRequired: 300,
      stock: 45,
      status: 'Activo',
    ),
    Reward(
      id: 'REW-002',
      name: 'Boleto 2D Tradicional',
      description:
          'Un boleto gratis para cualquier función 2D en salas tradicionales de lunes a domingo.',
      imageUrl:
          'https://images.unsplash.com/photo-1595769816263-9b910be24d5f?w=200',
      pointsRequired: 500,
      stock: 120,
      status: 'Activo',
    ),
    Reward(
      id: 'REW-003',
      name: 'Combo Pareja CinePlus',
      description: '2 refrescos medianos + 1 palomitas grandes + 1 hot-dog.',
      imageUrl:
          'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=200',
      pointsRequired: 800,
      stock: 15,
      status: 'Activo',
    ),
    Reward(
      id: 'REW-004',
      name: 'Vaso Coleccionable Edición Especial',
      description: 'Vaso de acrílico coleccionable de la película del mes.',
      imageUrl:
          'https://images.unsplash.com/photo-1517256064527-09c53b2d0bc6?w=200',
      pointsRequired: 400,
      stock: 0,
      status: 'Inactivo',
    ),
  ];

  List<Reward> get rewards => _rewards;

  // Mock Scan History
  final List<ScanHistory> _scanHistory = [
    ScanHistory(
      id: 'SCAN-001',
      userId: 'USR-001',
      date: '25/06/2026',
      place: 'Cinepolis Altaria (Boleto)',
      points: 100,
      status: 'Completado',
    ),
    ScanHistory(
      id: 'SCAN-002',
      userId: 'USR-001',
      date: '20/06/2026',
      place: 'Cinemark Lindavista (Poster)',
      points: 50,
      status: 'Completado',
    ),
    ScanHistory(
      id: 'SCAN-003',
      userId: 'USR-001',
      date: '10/06/2026',
      place: 'Código Invalido',
      points: 0,
      status: 'Fallido',
    ),
  ];

  List<ScanHistory> get scanHistory => _scanHistory;

  // Login handler
  bool login(String email, String password, String selectedRole) {
    // This legacy synchronous API no longer authenticates mock users.
    return false;
  }

  Future<bool> loginWithSupabase(
    String email,
    String password,
    String selectedRole,
  ) async {
    _authError = null;
    try {
      final user = await _service.iniciarSesion(email.trim(), password);
      if ((selectedRole == 'admin') != (user.role == 'admin') ||
          user.status != 'Activo') {
        _authError = 'Perfil rechazado: rol o estado no coincide';
        debugPrint('[AUTH][6][ERROR] $_authError');
        return false;
      }
      _currentUser = user;
      // The initial catalog load can happen before Auth restores the session.
      // Reload it after login so authenticated users receive the real cinemas.
      await _loadCatalogs();
      await _loadWatchedMovies();
      await _loadFavorites();
      await _loadUserQrCodes();
      if (_currentUser?.role == 'admin') {
        await _loadAdminUsers();
        await cargarPeliculasAdmin();
        await cargarCinesAdmin();
      }
      notifyListeners();
      return true;
    } catch (error) {
      _authError = error.toString();
      debugPrint('[AUTH][6][ERROR] $_authError');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    _favoriteMovies.clear();
    _service.cerrarSesion().catchError((_) {});
    notifyListeners();
  }

  bool isFavorite(String movieId) =>
      _favoriteMovies.any((movie) => movie.catalogMovieId == movieId);

  Future<void> toggleFavorite(Movie movie) async {
    if (!movie.isCatalogMovie) {
      throw StateError('Las películas personales no pueden marcarse como favoritas');
    }
    final catalogMovieId = movie.catalogMovieId!;
    final wasFavorite = isFavorite(catalogMovieId);
    if (wasFavorite) {
      await _service.eliminarFavorito(catalogMovieId);
      _favoriteMovies.removeWhere((favorite) => favorite.catalogMovieId == catalogMovieId);
    } else {
      await _service.guardarFavorito(catalogMovieId);
      _favoriteMovies.insert(0, movie);
    }
    notifyListeners();
  }

  Future<bool> registerWithSupabase(
    String name,
    String email,
    String password,
  ) async {
    _authError = null;
    try {
      _currentUser = await _service.registrar(
        name.trim(),
        email.trim(),
        password,
      );
      debugPrint(
        '[AUTH][6] registro completado, preparando navegación user=${_currentUser?.id}',
      );
      notifyListeners();
      return true;
    } catch (error) {
      _authError = error.toString();
      debugPrint('[AUTH][6][ERROR] $_authError');
      return false;
    }
  }

  Future<bool> redeemReward(Reward reward) async {
    try {
      final qr = await _service.canjear(reward);
      debugPrint('[DATA][CANJES][APPSTATE] Resultado: $qr');
      debugPrint('[DATA][CANJES][APPSTATE] codigo: ${qr['codigo']}');
      _lastCanjeResult = {
        'canje_id': qr['canje_id'],
        'qr_id': qr['qr_id'],
        'codigo': qr['codigo'],
        'puntos_utilizados': qr['puntos_utilizados'],
        'saldo_actual': qr['saldo_actual'],
        'existencias_restantes': qr['existencias_restantes'],
      };
      _lastQrCode = _lastCanjeResult!['codigo']?.toString();
      _pendingQrCode = _lastQrCode;
      debugPrint('[DATA][CANJES][APPSTATE] lastQrCode: $_lastQrCode');
      if (_currentUser != null) {
        final refreshedProfile = await _service.obtenerPerfil(_currentUser!.id);
        if (refreshedProfile != null) _currentUser = refreshedProfile;
      }
      await _reloadRewards();
      await _loadUserQrCodes();
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint('[DATA][CANJES][ERROR] No se pudo completar el canje: $error');
      return false;
    }
  }

  Future<void> _loadUserQrCodes() async {
    final userId = _currentUser?.id;
    if (userId == null) return;
    try {
      final qrCodes = await _service.obtenerCodigosQr(userId);
      debugPrint('[DATA][QR][APPSTATE] cargando ${qrCodes.length} códigos');
      _userQrCodes
        ..clear()
        ..addAll(qrCodes);
      notifyListeners();
    } catch (error) {
      debugPrint('[DATA][QR][ERROR] No se pudieron cargar los QR: $error');
    }
  }

  /// Recarga los códigos QR reales del usuario desde Supabase.
  Future<void> cargarMisQr() => _loadUserQrCodes();

  void register(String name, String email, String password) {
    debugPrint('[AUTH] register() legacy ignorado: usa Supabase Auth.');
  }

  // User Actions: Tracker Management
  void addMovie(Movie movie) {
    _movies.insert(0, movie);
    notifyListeners();
  }

  Future<bool> registrarPeliculaVista({
    String? peliculaId,
    required String cineId,
    required DateTime fechaVisita,
    String? tituloPersonal,
    String? generoPersonal,
    int? duracionMinutosPersonal,
    double? calificacionPersonal,
    String? comentarioPersonal,
  }) async {
    final usuarioId = _currentUser?.id;
    if (usuarioId == null) return false;
    try {
      await _service.registrarVisita(
        peliculaId: peliculaId,
        cineId: cineId,
        fechaVisita: fechaVisita,
        tituloPersonal: tituloPersonal,
        generoPersonal: generoPersonal,
        duracionMinutosPersonal: duracionMinutosPersonal,
        calificacionPersonal: calificacionPersonal,
        comentarioPersonal: comentarioPersonal,
      );
      await _loadWatchedMovies();
      final refreshedProfile = await _service.obtenerPerfil(usuarioId);
      if (refreshedProfile != null) {
        _currentUser = refreshedProfile;
      }
      notifyListeners();
      return true;
    } catch (error) {
      debugPrint(
        '[DATA][VISITAS][ERROR] No se pudo registrar la visita: $error',
      );
      return false;
    }
  }

  Future<bool> actualizarPeliculaVista({
    required String visitaId,
    required String cineId,
    required DateTime fechaVisita,
    String? tituloPersonal,
    String? generoPersonal,
    int? duracionMinutosPersonal,
    double? calificacionPersonal,
    String? comentarioPersonal,
  }) async {
    final usuarioId = _currentUser?.id;
    if (usuarioId == null) return false;
    try {
      await _service.actualizarVisita(
        visitaId: visitaId,
        usuarioId: usuarioId,
        cineId: cineId,
        fechaVisita: fechaVisita,
        tituloPersonal: tituloPersonal,
        generoPersonal: generoPersonal,
        duracionMinutosPersonal: duracionMinutosPersonal,
        calificacionPersonal: calificacionPersonal,
        comentarioPersonal: comentarioPersonal,
      );
      await _loadWatchedMovies();
      return true;
    } catch (error) {
      debugPrint('[DATA][VISITAS][ERROR] No se pudo actualizar: $error');
      return false;
    }
  }

  Future<bool> eliminarPeliculaVista(String visitaId) async {
    final usuarioId = _currentUser?.id;
    if (usuarioId == null) return false;
    try {
      await _service.eliminarVisita(visitaId: visitaId, usuarioId: usuarioId);
      await _loadWatchedMovies();
      return true;
    } catch (error) {
      debugPrint('[DATA][VISITAS][ERROR] No se pudo eliminar: $error');
      return false;
    }
  }

  void deleteMovie(String movieId) {
    _movies.removeWhere((m) => m.id == movieId);
    notifyListeners();
  }

  Future<Map<String, dynamic>> registrarUsoQr({
    required String codigo,
    required String cineId,
  }) async {
    final result = await _service.registrarUsoQrConPuntos(
      codigo: codigo,
      cineId: cineId,
    );
    final userId = _currentUser?.id;
    if (userId != null) {
      final refreshedProfile = await _service.obtenerPerfil(userId);
      if (refreshedProfile != null) _currentUser = refreshedProfile;
    }
    final points = (result['puntos_obtenidos'] ?? result['puntos'] ?? 50) as num;
    final cinema = _cinemas.where((c) => c.id == cineId).map((c) => c.name).firstOrNull ?? cineId;
    _scanHistory.insert(0, ScanHistory(
      id: result['uso_qr_id']?.toString() ?? result['id']?.toString() ?? codigo,
      userId: userId ?? '',
      date: DateTime.now().toLocal().toString(),
      place: cinema,
      points: points.toInt(),
      status: 'Completado',
    ));
    notifyListeners();
    return result;
  }

  // Admin Actions: User Management
  Future<void> updateUserStatus(String userId, String status) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = await _service.actualizarPerfilAdmin(
        _users[index].copyWith(status: status),
      );
      if (_currentUser?.id == userId) {
        _currentUser = _users[index];
      }
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    if (_currentUser?.id == userId) {
      throw StateError('No puedes eliminar el perfil administrador en sesión');
    }
    await _service.eliminarPerfilAdmin(userId);
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  Future<void> saveUser(AppUser user) async {
    final savedUser = await _service.actualizarPerfilAdmin(user);
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = savedUser;
      if (_currentUser?.id == user.id) {
        _currentUser = user;
      }
    } else {
      _users.add(savedUser);
    }
    notifyListeners();
  }

  // Admin Actions: Rewards CRUD
  Future<void> saveReward(Reward reward) async {
    if (_rewards.any((r) => r.id == reward.id)) {
      await _service.actualizarPromocion(reward);
    } else {
      await _service.crearPromocion(reward);
    }
    await _reloadRewards();
  }

  Future<String> subirImagenPromocionAdmin(Uint8List bytes, String extension) {
    return _service.subirImagenPromocion(bytes, extension);
  }

  Future<void> eliminarImagenPromocionAnteriorAdmin(String? url) {
    return _service.eliminarImagenPromocionSiEsDelBucket(url);
  }

  Future<void> deleteReward(String rewardId) async {
    await _service.eliminarPromocion(rewardId);
    await _reloadRewards();
  }

  Future<void> _reloadRewards() async {
    final rewards = await _service.obtenerPromociones();
    _rewards
      ..clear()
      ..addAll(rewards);
    notifyListeners();
  }

  // Admin Actions: QR Management
  void saveQRCode(QRCode qrCode) {
    final index = _qrCodes.indexWhere((q) => q.id == qrCode.id);
    if (index != -1) {
      _qrCodes[index] = qrCode;
    } else {
      _qrCodes.add(qrCode);
    }
    notifyListeners();
  }

  void deleteQRCode(String qrCodeId) {
    _qrCodes.removeWhere((q) => q.id == qrCodeId);
    notifyListeners();
  }
}
