import 'package:flutter/material.dart';
import '../../shared/models/models.dart';

class AppState extends ChangeNotifier {
  // Theme state
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
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
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
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
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
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
      avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
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
      avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
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
      posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300',
      watchDate: '12/03/2026',
      cinemaName: 'Cinepolis Altaria',
      rating: 5.0,
      genre: 'Ciencia Ficción',
      durationMinutes: 166,
      description: 'Paul Atreides se une a Chani y a los Fremen mientras busca venganza contra los conspiradores que destruyeron a su familia.',
    ),
    Movie(
      id: 'MOV-002',
      title: 'Oppenheimer',
      posterUrl: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=300',
      watchDate: '20/02/2026',
      cinemaName: 'Cinemark Lindavista',
      rating: 4.5,
      genre: 'Drama / Histórica',
      durationMinutes: 180,
      description: 'La historia del científico estadounidense J. Robert Oppenheimer y su papel en el desarrollo de la bomba atómica.',
    ),
    Movie(
      id: 'MOV-003',
      title: 'Spider-Man: Across the Spider-Verse',
      posterUrl: 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=300',
      watchDate: '05/01/2026',
      cinemaName: 'Cinepolis Altaria',
      rating: 5.0,
      genre: 'Animación / Acción',
      durationMinutes: 140,
      description: 'Miles Morales es catapultado a través del Multiverso, donde se encuentra con un equipo de Spider-People encargados de proteger su existencia.',
    ),
  ];

  List<Movie> get movies => _movies;

  // Mock cinemas
  final List<Cinema> _cinemas = [
    Cinema(
      id: 'CIN-001',
      name: 'Cinepolis Altaria',
      address: 'Centro Comercial Altaria, Col. Trojes de Alonso',
      schedule: '11:00 AM - 11:30 PM',
      distance: '1.2 km',
      latitude: 21.9213,
      longitude: -102.2915,
    ),
    Cinema(
      id: 'CIN-002',
      name: 'Cinemark Lindavista',
      address: 'Av. Lindavista 236, Gustavo A. Madero, CDMX',
      schedule: '12:00 PM - 11:00 PM',
      distance: '3.5 km',
      latitude: 21.9123,
      longitude: -102.2815,
    ),
    Cinema(
      id: 'CIN-003',
      name: 'Cine Star Plaza',
      address: 'Plaza del Cine Local #10, Av. de las Américas',
      schedule: '1:00 PM - 10:30 PM',
      distance: '5.8 km',
      latitude: 21.9023,
      longitude: -102.3015,
    ),
  ];

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
      description: 'Código QR otorgado en la compra de boletos para Dune: Part Two en preventa.',
    ),
    QRCode(
      id: 'QR-002',
      name: 'Poster Promocional Avengers',
      type: 'Poster',
      points: 50,
      startDate: '01/03/2026',
      expirationDate: '31/12/2026',
      status: 'Activo',
      description: 'Escanear el código del poster en el pasillo central del cine.',
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
      description: 'Canjeable por una cubeta de palomitas grandes de mantequilla en dulcería.',
      imageUrl: 'https://images.unsplash.com/photo-1578244182942-18427f3caca6?w=200',
      pointsRequired: 300,
      stock: 45,
      status: 'Activo',
    ),
    Reward(
      id: 'REW-002',
      name: 'Boleto 2D Tradicional',
      description: 'Un boleto gratis para cualquier función 2D en salas tradicionales de lunes a domingo.',
      imageUrl: 'https://images.unsplash.com/photo-1595769816263-9b910be24d5f?w=200',
      pointsRequired: 500,
      stock: 120,
      status: 'Activo',
    ),
    Reward(
      id: 'REW-003',
      name: 'Combo Pareja CinePlus',
      description: '2 refrescos medianos + 1 palomitas grandes + 1 hot-dog.',
      imageUrl: 'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=200',
      pointsRequired: 800,
      stock: 15,
      status: 'Activo',
    ),
    Reward(
      id: 'REW-004',
      name: 'Vaso Coleccionable Edición Especial',
      description: 'Vaso de acrílico coleccionable de la película del mes.',
      imageUrl: 'https://images.unsplash.com/photo-1517256064527-09c53b2d0bc6?w=200',
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
    // Basic verification for mock
    AppUser? foundUser;
    for (var u in _users) {
      if (u.email.toLowerCase() == email.trim().toLowerCase() && u.role == selectedRole) {
        foundUser = u;
        break;
      }
    }

    if (foundUser != null) {
      if (foundUser.status == 'Inactivo') {
        return false;
      }
      _currentUser = foundUser;
      notifyListeners();
      return true;
    }

    // Fallback: Create mock user if logging in first time to make testing super fluid
    if (email.isNotEmpty && password.length >= 4) {
      _currentUser = AppUser(
        id: selectedRole == 'admin' ? 'ADM-999' : 'USR-999',
        name: email.split('@')[0],
        email: email,
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        level: 1,
        points: selectedRole == 'admin' ? 9999 : 200,
        role: selectedRole,
        status: 'Activo',
        registrationDate: '26/06/2026',
      );
      // Add to list if not present
      _users.add(_currentUser!);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void register(String name, String email, String password) {
    final newUser = AppUser(
      id: 'USR-${_users.length + 1}'.padRight(7, '0'),
      name: name,
      email: email,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      level: 1,
      points: 150, // Starting bonus
      role: 'user',
      status: 'Activo',
      registrationDate: '26/06/2026',
    );
    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
  }

  // User Actions: Tracker Management
  void addMovie(Movie movie) {
    _movies.insert(0, movie);
    notifyListeners();
  }

  void deleteMovie(String movieId) {
    _movies.removeWhere((m) => m.id == movieId);
    notifyListeners();
  }

  // QR Scanning Simulation Action
  ScanHistory scanQRCodeSimulation(String title, int pointsValue) {
    final curUserId = _currentUser?.id ?? 'INV-USER';

    // Check if user has already scanned this QR successfully
    final hasAlreadyScanned = pointsValue > 0 &&
        _scanHistory.any((scan) =>
            scan.userId == curUserId &&
            scan.place == title &&
            scan.status == 'Completado');

    final ScanHistory newScan;
    if (hasAlreadyScanned) {
      newScan = ScanHistory(
        id: 'SCAN-${_scanHistory.length + 1}'.padRight(8, '0'),
        userId: curUserId,
        date: '26/06/2026',
        place: title,
        points: 0,
        status: 'Duplicado',
      );
    } else {
      newScan = ScanHistory(
        id: 'SCAN-${_scanHistory.length + 1}'.padRight(8, '0'),
        userId: curUserId,
        date: '26/06/2026',
        place: title,
        points: pointsValue,
        status: pointsValue > 0 ? 'Completado' : 'Fallido',
      );
    }

    _scanHistory.insert(0, newScan);

    if (newScan.status == 'Completado' && _currentUser != null) {
      // Award points
      final updatedPoints = _currentUser!.points + pointsValue;
      // Recalculate level based on points (e.g. 500 points per level)
      final newLevel = (updatedPoints ~/ 500) + 1;
      _currentUser = _currentUser!.copyWith(
        points: updatedPoints,
        level: newLevel,
      );

      // Also update in user list
      final index = _users.indexWhere((u) => u.id == _currentUser!.id);
      if (index != -1) {
        _users[index] = _currentUser!;
      }
    }

    notifyListeners();
    return newScan;
  }

  // Admin Actions: User Management
  void updateUserStatus(String userId, String status) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(status: status);
      if (_currentUser?.id == userId) {
        _currentUser = _users[index];
      }
      notifyListeners();
    }
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  void saveUser(AppUser user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      if (_currentUser?.id == user.id) {
        _currentUser = user;
      }
    } else {
      _users.add(user);
    }
    notifyListeners();
  }

  // Admin Actions: Rewards CRUD
  void saveReward(Reward reward) {
    final index = _rewards.indexWhere((r) => r.id == reward.id);
    if (index != -1) {
      _rewards[index] = reward;
    } else {
      _rewards.add(reward);
    }
    notifyListeners();
  }

  void deleteReward(String rewardId) {
    _rewards.removeWhere((r) => r.id == rewardId);
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
