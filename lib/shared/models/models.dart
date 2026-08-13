class AppUser {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final int level;
  final int points;
  final String role; // 'user' or 'admin'
  final String status; // 'Activo' or 'Inactivo'
  final String registrationDate;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.level,
    required this.points,
    required this.role,
    required this.status,
    required this.registrationDate,
  });

  factory AppUser.fromMap(Map<String, dynamic> row) => AppUser(
    id: row['id'].toString(),
    name: row['nombre'] ?? '',
    email: row['correo'] ?? '',
    avatarUrl: row['avatar_url'] ?? '',
    level: (row['nivel'] ?? 1) as int,
    points: (row['puntos'] ?? 0) as int,
    role: row['rol'] == 'administrador' ? 'admin' : 'user',
    status: row['estado'] == 'activo' ? 'Activo' : 'Inactivo',
    registrationDate: row['fecha_registro']?.toString() ?? '',
  );

  AppUser copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? level,
    int? points,
    String? role,
    String? status,
    String? registrationDate,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      points: points ?? this.points,
      role: role ?? this.role,
      status: status ?? this.status,
      registrationDate: registrationDate ?? this.registrationDate,
    );
  }
}

class Movie {
  final String id;
  /// ID real de public.peliculas. Es null para películas personales.
  final String? catalogMovieId;
  final String? visitId;
  final String title;
  final String posterUrl;
  final String watchDate;
  final String cinemaName;
  final double rating;
  final String genre;
  final int durationMinutes;
  final String description;
  final DateTime? releaseDate;
  final String status;

  Movie({
    required this.id,
    this.catalogMovieId,
    this.visitId,
    required this.title,
    required this.posterUrl,
    required this.watchDate,
    required this.cinemaName,
    required this.rating,
    required this.genre,
    required this.durationMinutes,
    required this.description,
    this.releaseDate,
    this.status = 'activo',
  });

  factory Movie.fromMap(
    Map<String, dynamic> row, {
    String watchDate = '',
    String cinemaName = '',
    String? visitId,
    String? personalTitle,
    String? personalGenre,
    int? personalDuration,
    double? personalRating,
    String? personalComment,
  }) => Movie(
    id: row['id']?.toString() ?? visitId ?? '',
    catalogMovieId: row['id']?.toString(),
    visitId: visitId,
    title: row['titulo'] ?? personalTitle ?? '',
    posterUrl: row['poster_url'] ?? '',
    watchDate: watchDate,
    cinemaName: cinemaName,
    rating: (row['calificacion_personal'] ?? personalRating ?? 0).toDouble(),
    genre: row['genero'] ?? personalGenre ?? '',
    durationMinutes: row['duracion_minutos'] ?? personalDuration ?? 0,
    description: row['descripcion'] ?? personalComment ?? '',
    releaseDate: row['fecha_estreno'] == null ? null : DateTime.tryParse(row['fecha_estreno'].toString()),
    status: row['estado']?.toString() ?? 'activo',
  );

  bool get isCatalogMovie => catalogMovieId != null;

  Movie copyWith({
    String? title,
    String? posterUrl,
    String? watchDate,
    String? cinemaName,
    double? rating,
    String? genre,
    int? durationMinutes,
    String? description,
  }) {
    return Movie(
      id: id,
      catalogMovieId: catalogMovieId,
      visitId: visitId,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      watchDate: watchDate ?? this.watchDate,
      cinemaName: cinemaName ?? this.cinemaName,
      rating: rating ?? this.rating,
      genre: genre ?? this.genre,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
      releaseDate: releaseDate,
      status: status,
    );
  }
}

class Cinema {
  final String id;
  final String googlePlaceId;
  final String name;
  final String address;
  final String schedule;
  final String distance;
  final double latitude;
  final double longitude;
  final String status;

  Cinema({
    required this.id,
    this.googlePlaceId = '',
    required this.name,
    required this.address,
    required this.schedule,
    required this.distance,
    required this.latitude,
    required this.longitude,
    this.status = 'activo',
  });

  factory Cinema.fromMap(Map<String, dynamic> row) => Cinema(
    id: row['id'].toString(),
    googlePlaceId: row['google_place_id']?.toString() ?? '',
    name: row['nombre_referencia'] ?? '',
    address: row['direccion_referencia'] ?? '',
    schedule: '',
    distance: '',
    latitude: (row['latitud'] as num?)?.toDouble() ?? 0,
    longitude: (row['longitud'] as num?)?.toDouble() ?? 0,
    status: row['estado']?.toString() ?? 'activo',
  );
}

class QRCode {
  final String id;
  final String name;
  final String
  type; // 'Boleto', 'Poster', 'Cartón promocional', 'Stand promocional', 'Evento especial'
  final int points;
  final String startDate;
  final String expirationDate;
  final String status; // 'Activo', 'Inactivo', 'Expirado'
  final String description;

  QRCode({
    required this.id,
    required this.name,
    required this.type,
    required this.points,
    required this.startDate,
    required this.expirationDate,
    required this.status,
    required this.description,
  });

  QRCode copyWith({
    String? name,
    String? type,
    int? points,
    String? startDate,
    String? expirationDate,
    String? status,
    String? description,
  }) {
    return QRCode(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      points: points ?? this.points,
      startDate: startDate ?? this.startDate,
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
      description: description ?? this.description,
    );
  }
}

class Reward {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int pointsRequired;
  final int? stock;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final List<String> cinemaIds;

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    required this.stock,
    this.startDate,
    this.endDate,
    required this.status,
    this.cinemaIds = const [],
  });

  factory Reward.fromMap(Map<String, dynamic> row) => Reward(
    id: row['id'].toString(),
    name: row['nombre'] ?? '',
    description: row['descripcion'] ?? '',
    imageUrl: row['imagen_url'] ?? '',
    pointsRequired: row['puntos_requeridos'] ?? 0,
    stock: row['existencias'] as int?,
    startDate: row['fecha_inicio'] == null ? null : DateTime.tryParse(row['fecha_inicio'].toString()),
    endDate: row['fecha_fin'] == null ? null : DateTime.tryParse(row['fecha_fin'].toString()),
    status: row['estado']?.toString() ?? 'borrador',
    cinemaIds: ((row['promociones_cines'] as List?) ?? [])
        .map((link) => (link as Map)['cine_id'].toString())
        .toList(),
  );

  Reward copyWith({
    String? name,
    String? description,
    String? imageUrl,
    int? pointsRequired,
    int? stock,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    List<String>? cinemaIds,
  }) {
    return Reward(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      stock: stock ?? this.stock,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      cinemaIds: cinemaIds ?? this.cinemaIds,
    );
  }
}

class ScanHistory {
  final String id;
  final String userId;
  final String date;
  final String place;
  final int points;
  final String status; // 'Completado', 'Fallido', 'Duplicado'

  ScanHistory({
    required this.id,
    required this.userId,
    required this.date,
    required this.place,
    required this.points,
    required this.status,
  });
}
