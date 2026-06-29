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
  final String title;
  final String posterUrl;
  final String watchDate;
  final String cinemaName;
  final double rating;
  final String genre;
  final int durationMinutes;
  final String description;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.watchDate,
    required this.cinemaName,
    required this.rating,
    required this.genre,
    required this.durationMinutes,
    required this.description,
  });

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
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      watchDate: watchDate ?? this.watchDate,
      cinemaName: cinemaName ?? this.cinemaName,
      rating: rating ?? this.rating,
      genre: genre ?? this.genre,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      description: description ?? this.description,
    );
  }
}

class Cinema {
  final String id;
  final String name;
  final String address;
  final String schedule;
  final String distance;
  final double latitude;
  final double longitude;

  Cinema({
    required this.id,
    required this.name,
    required this.address,
    required this.schedule,
    required this.distance,
    required this.latitude,
    required this.longitude,
  });
}

class QRCode {
  final String id;
  final String name;
  final String type; // 'Boleto', 'Poster', 'Cartón promocional', 'Stand promocional', 'Evento especial'
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
  final int stock;
  final String status; // 'Activo' or 'Inactivo'

  Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.pointsRequired,
    required this.stock,
    required this.status,
  });

  Reward copyWith({
    String? name,
    String? description,
    String? imageUrl,
    int? pointsRequired,
    int? stock,
    String? status,
  }) {
    return Reward(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      stock: stock ?? this.stock,
      status: status ?? this.status,
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
