import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../shared/models/models.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Movie>> obtenerPeliculas() async =>
      (await _supabase.from('peliculas').select().eq('estado', 'activo'))
          .map((r) => Movie.fromMap(r))
          .toList();

  Future<List<Movie>> obtenerPeliculasAdmin() async =>
      (await _supabase.from('peliculas').select().order('fecha_creacion', ascending: false))
          .map((r) => Movie.fromMap(r))
          .toList();

  Future<void> crearPelicula({
    required String titulo,
    String? posterUrl,
    String? genero,
    int? duracionMinutos,
    String? descripcion,
    DateTime? fechaEstreno,
    String estado = 'activo',
  }) async {
    await _supabase.from('peliculas').insert({
      'titulo': titulo.trim(),
      'poster_url': posterUrl?.trim().isEmpty == true ? null : posterUrl?.trim(),
      'genero': genero?.trim().isEmpty == true ? null : genero?.trim(),
      'duracion_minutos': duracionMinutos,
      'descripcion': descripcion?.trim().isEmpty == true ? null : descripcion?.trim(),
      'fecha_estreno': fechaEstreno?.toIso8601String().split('T').first,
      'estado': estado,
    });
  }

  Future<void> actualizarPelicula(Movie movie) async {
    await _supabase.from('peliculas').update({
      'titulo': movie.title.trim(),
      'poster_url': movie.posterUrl.trim().isEmpty ? null : movie.posterUrl.trim(),
      'genero': movie.genre.trim().isEmpty ? null : movie.genre.trim(),
      'duracion_minutos': movie.durationMinutes == 0 ? null : movie.durationMinutes,
      'descripcion': movie.description.trim().isEmpty ? null : movie.description.trim(),
      'fecha_estreno': movie.releaseDate?.toIso8601String().split('T').first,
      'estado': movie.status,
    }).eq('id', movie.id);
  }

  Future<void> actualizarEstadoPelicula(String id, String estado) async {
    if (estado != 'activo' && estado != 'inactivo') {
      throw ArgumentError('Estado de película inválido');
    }
    await _supabase.from('peliculas').update({'estado': estado}).eq('id', id);
  }

  Future<List<Movie>> obtenerPeliculasVistas(String usuarioId) async {
    final rows = await _supabase
        .from('visitas')
        .select(
          'id, fecha_visita, pelicula_id, titulo_personal, genero_personal, duracion_minutos_personal, calificacion_personal, comentario_personal, peliculas(*), cines(*)',
        )
        .eq('usuario_id', usuarioId)
        .order('fecha_visita', ascending: false);
    return rows.map((row) {
      final movie = row['peliculas'] == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(row['peliculas'] as Map);
      final cinema = row['cines'] == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(row['cines'] as Map);
      return Movie.fromMap(
        movie,
        visitId: row['id'].toString(),
        watchDate: row['fecha_visita']?.toString() ?? '',
        cinemaName: cinema['nombre_referencia']?.toString() ?? '',
        personalTitle: row['titulo_personal']?.toString(),
        personalGenre: row['genero_personal']?.toString(),
        personalDuration: row['duracion_minutos_personal'] as int?,
        personalRating: (row['calificacion_personal'] as num?)?.toDouble(),
        personalComment: row['comentario_personal']?.toString(),
      );
    }).toList();
  }

  Future<String> registrarVisita({
    String? peliculaId,
    required String cineId,
    required DateTime fechaVisita,
    String? tituloPersonal,
    String? generoPersonal,
    int? duracionMinutosPersonal,
    double? calificacionPersonal,
    String? comentarioPersonal,
  }) async {
    final result = await _supabase.rpc(
      'registrar_visita_con_puntos',
      params: {
        'p_cine_id': cineId,
        'p_fecha_visita': fechaVisita.toIso8601String(),
        'p_pelicula_id': peliculaId,
        'p_titulo_personal': tituloPersonal,
        'p_genero_personal': generoPersonal,
        'p_duracion_minutos_personal': duracionMinutosPersonal,
        'p_calificacion_personal': calificacionPersonal,
        'p_comentario_personal': comentarioPersonal,
      },
    );
    return result.toString();
  }

  Future<void> actualizarVisita({
    required String visitaId,
    required String usuarioId,
    required String cineId,
    required DateTime fechaVisita,
    String? tituloPersonal,
    String? generoPersonal,
    int? duracionMinutosPersonal,
    double? calificacionPersonal,
    String? comentarioPersonal,
  }) async {
    await _supabase
        .from('visitas')
        .update({
          'cine_id': cineId,
          'fecha_visita': fechaVisita.toUtc().toIso8601String(),
          'titulo_personal': tituloPersonal,
          'genero_personal': generoPersonal,
          'duracion_minutos_personal': duracionMinutosPersonal,
          'calificacion_personal': calificacionPersonal,
          'comentario_personal': comentarioPersonal,
        })
        .eq('id', visitaId)
        .eq('usuario_id', usuarioId);
  }

  Future<void> eliminarVisita({
    required String visitaId,
    required String usuarioId,
  }) async {
    await _supabase
        .from('visitas')
        .delete()
        .eq('id', visitaId)
        .eq('usuario_id', usuarioId);
  }

  Future<List<Cinema>> obtenerCines() async =>
      (await _supabase.from('cines').select().eq('estado', 'activo'))
          .map((r) => Cinema.fromMap(r))
          .toList();

  Future<List<Cinema>> obtenerCinesAdmin() async =>
      (await _supabase.from('cines').select().order('fecha_creacion', ascending: false)).map((r) => Cinema.fromMap(r)).toList();

  Future<void> crearCine({required String googlePlaceId, required String nombre, String? direccion, double? latitud, double? longitud}) async {
    await _supabase.from('cines').insert({'google_place_id': googlePlaceId.trim(), 'nombre_referencia': nombre.trim(), 'direccion_referencia': direccion?.trim().isEmpty == true ? null : direccion?.trim(), 'latitud': latitud, 'longitud': longitud});
  }

  Future<void> actualizarCine(Cinema cine) async {
    await _supabase.from('cines').update({'google_place_id': cine.googlePlaceId.trim(), 'nombre_referencia': cine.name.trim(), 'direccion_referencia': cine.address.trim().isEmpty ? null : cine.address.trim(), 'latitud': cine.latitude, 'longitud': cine.longitude, 'estado': cine.status}).eq('id', cine.id);
  }

  Future<void> actualizarEstadoCine(String id, String estado) async {
    await _supabase.from('cines').update({'estado': estado}).eq('id', id);
  }
  Future<List<Reward>> obtenerPromociones() async =>
      (await _supabase.from('promociones').select('id,nombre,descripcion,imagen_url,puntos_requeridos,existencias,fecha_inicio,fecha_fin,estado,fecha_creacion,fecha_actualizacion,promociones_cines(cine_id)'))
          .map((r) => Reward.fromMap(r))
          .toList();

  Future<String> crearPromocion(Reward reward) async {
    final row = await _supabase
        .from('promociones')
        .insert(_promotionPayload(reward))
        .select('id')
        .single();
    final id = row['id'].toString();
    await _addPromotionCinemas(id, reward.cinemaIds);
    return id;
  }

  Future<void> actualizarPromocion(Reward reward) async {
    await _supabase
        .from('promociones')
        .update(_promotionPayload(reward))
        .eq('id', reward.id);
    await _replacePromotionCinemas(reward.id, reward.cinemaIds);
  }

  Future<void> eliminarPromocion(String promotionId) async {
    await _supabase.from('promociones').delete().eq('id', promotionId);
  }

  Future<void> _replacePromotionCinemas(
    String promotionId,
    List<String> cinemaIds,
  ) async {
    await _supabase
        .from('promociones_cines')
        .delete()
        .eq('promocion_id', promotionId);
    if (cinemaIds.isEmpty) return;
    await _addPromotionCinemas(promotionId, cinemaIds);
  }

  Future<void> _addPromotionCinemas(
    String promotionId,
    List<String> cinemaIds,
  ) async {
    if (cinemaIds.isEmpty) return;
    await _supabase.from('promociones_cines').insert(
      cinemaIds
          .map((cinemaId) => {
                'promocion_id': promotionId,
                'cine_id': cinemaId,
              })
          .toList(),
    );
  }

  Map<String, dynamic> _promotionPayload(Reward reward) => {
        'nombre': reward.name,
        'descripcion': reward.description,
        'imagen_url': reward.imageUrl.isEmpty ? null : reward.imageUrl,
        'puntos_requeridos': reward.pointsRequired,
        'existencias': reward.stock,
        'fecha_inicio': reward.startDate?.toUtc().toIso8601String(),
        'fecha_fin': reward.endDate?.toUtc().toIso8601String(),
        'estado': reward.status,
      };

  Future<AppUser?> obtenerPerfil(String id) async {
    debugPrint('[AUTH][5] consultando public.perfiles id=$id');
    try {
      final row = await _supabase
          .from('perfiles')
          .select()
          .eq('id', id)
          .maybeSingle();
      debugPrint(
        '[AUTH][5] perfiles respuesta: ${row == null ? 'SIN FILA' : 'fila encontrada'}',
      );
      return row == null ? null : AppUser.fromMap(row);
    } on Object catch (error, stack) {
      debugPrint('[AUTH][5][ERROR] ${_describeError(error)}');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
  }

  Future<List<AppUser>> obtenerUsuarios() async {
    final rows = await _supabase.from('perfiles').select().order('fecha_registro');
    return rows.map((row) => AppUser.fromMap(row)).toList();
  }

  Future<AppUser> actualizarPerfilAdmin(AppUser user) async {
    final row = await _supabase
        .from('perfiles')
        .update({
          'nombre': user.name.trim(),
          'correo': user.email.trim().toLowerCase(),
          'rol': user.role == 'admin' ? 'administrador' : 'usuario',
          'estado': user.status == 'Activo' ? 'activo' : 'inactivo',
          'fecha_actualizacion': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', user.id)
        .select()
        .single();
    return AppUser.fromMap(row);
  }

  Future<void> eliminarPerfilAdmin(String userId) async {
    await _supabase.from('perfiles').delete().eq('id', userId);
  }

  Future<AppUser> crearPerfil({
    required String id,
    required String name,
    required String email,
  }) async {
    final sessionUser = _supabase.auth.currentUser;
    if (sessionUser == null || sessionUser.id != id) {
      throw const AuthException(
        'No existe una sesión válida para crear el perfil',
      );
    }
    debugPrint('[AUTH][4] insertando perfil id=$id');
    try {
      await _supabase.from('perfiles').insert({
        'id': id,
        'nombre': name.trim().isEmpty ? email.split('@').first : name.trim(),
        'correo': email.trim().toLowerCase(),
      });
      debugPrint('[AUTH][4] perfil insertado correctamente');
    } on Object catch (error, stack) {
      debugPrint('[AUTH][4][ERROR] ${_describeError(error)}');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
    final profile = await obtenerPerfil(id);
    if (profile == null) {
      throw const PostgrestException(
        message: 'El perfil se insertó pero no se pudo consultar',
      );
    }
    return profile;
  }

  Future<AppUser> asegurarPerfil({
    required String id,
    required String email,
  }) async {
    final existing = await obtenerPerfil(id);
    if (existing != null) return existing;
    return crearPerfil(id: id, name: email.split('@').first, email: email);
  }

  Future<AppUser> registrar(String name, String email, String password) async {
    debugPrint('[AUTH][1] iniciando signUp email=$email');
    late AuthResponse result;
    try {
      result = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'nombre': name},
      );
      debugPrint(
        '[AUTH][2] signUp completado user=${result.user?.id} session=${result.session != null}',
      );
    } on Object catch (error, stack) {
      debugPrint('[AUTH][1][ERROR] ${_describeError(error)}');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
    final user = result.user;
    if (user == null) throw const AuthException('No se pudo crear el usuario');
    debugPrint(
      '[AUTH][3] auth.users creado id=${user.id}; sesión actual=${_supabase.auth.currentSession != null}',
    );
    if (result.session == null || _supabase.auth.currentSession == null) {
      throw const AuthException(
        'Supabase no devolvió sesión. Desactiva Confirm email para desarrollo.',
      );
    }
    return crearPerfil(id: user.id, name: name, email: email);
  }

  Future<AppUser> iniciarSesion(String email, String password) async {
    debugPrint('[AUTH][1] iniciando signInWithPassword email=$email');
    late AuthResponse result;
    try {
      result = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint(
        '[AUTH][2] signIn completado user=${result.user?.id} session=${result.session != null}',
      );
    } on Object catch (error, stack) {
      debugPrint('[AUTH][1][ERROR] ${_describeError(error)}');
      debugPrintStack(stackTrace: stack);
      rethrow;
    }
    final user = result.user;
    if (user == null) throw const AuthException('Credenciales inválidas');
    return asegurarPerfil(id: user.id, email: user.email ?? email);
  }

  String _describeError(Object error) {
    if (error is AuthException) {
      return 'type=AuthException message=${error.message} statusCode=${error.statusCode}';
    }
    if (error is PostgrestException) {
      return 'type=PostgrestException message=${error.message} code=${error.code} details=${error.details} hint=${error.hint}';
    }
    if (error is StorageException) {
      return 'type=StorageException message=${error.message} statusCode=${error.statusCode}';
    }
    return 'type=${error.runtimeType} message=$error';
  }

  Future<void> cerrarSesion() => _supabase.auth.signOut();

  Future<void> guardarFavorito(String movieId) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw const AuthException('Sesión no autenticada');
    await _supabase.from('peliculas_favoritas').upsert({
      'usuario_id': uid,
      'pelicula_id': movieId,
    });
  }

  Future<void> eliminarFavorito(String movieId) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw const AuthException('Sesión no autenticada');
    await _supabase.from('peliculas_favoritas').delete().match({
      'usuario_id': uid,
      'pelicula_id': movieId,
    });
  }

  Future<Map<String, dynamic>> registrarUsoQrConPuntos({
    required String codigo,
    required String cineId,
  }) async {
    final result = await _supabase.rpc(
      'registrar_uso_qr_con_puntos',
      params: {
        'p_codigo': codigo,
        'p_cine_id': cineId,
      },
    );
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return Map<String, dynamic>.from(result);
    throw const PostgrestException(
      message: 'La RPC no devolvió el saldo actualizado',
    );
  }

  Future<List<Movie>> obtenerFavoritos(String usuarioId) async {
    final rows = await _supabase
        .from('peliculas_favoritas')
        .select('pelicula_id, fecha_agregado, peliculas(*)')
        .eq('usuario_id', usuarioId)
        .order('fecha_agregado', ascending: false);
    return rows.map((row) {
      final movie = row['peliculas'] == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(row['peliculas'] as Map);
      return Movie.fromMap(movie);
    }).toList();
  }

  Future<Map<String, dynamic>> canjear(Reward reward) async {
    final result = await _supabase.rpc(
      'canjear_promocion_con_qr',
      params: {'p_promocion_id': reward.id},
    );
    debugPrint('[DATA][CANJES][RPC] Resultado: $result');
    if (result is Map<String, dynamic>) return result;
    if (result is Map) return Map<String, dynamic>.from(result);
    if (result is List && result.isNotEmpty && result.first is Map) {
      return Map<String, dynamic>.from(result.first as Map);
    }
    throw const PostgrestException(
      message: 'La RPC no devolvió los datos del canje',
    );
  }

  Future<List<Map<String, dynamic>>> obtenerCodigosQr(String usuarioId) async {
    final rows = await _supabase
        .from('canjes')
        .select(
          'id,usuario_id,codigos_qr(id,codigo,estado,fecha_generacion,fecha_uso)',
        )
        .eq('usuario_id', usuarioId)
        .order('fecha_canje', ascending: false);
    final qrCodes = <Map<String, dynamic>>[];
    for (final row in rows) {
      final qr = row['codigos_qr'];
      if (qr is Map) {
        qrCodes.add(Map<String, dynamic>.from(qr));
      } else if (qr is List) {
        for (final item in qr) {
          if (item is Map) qrCodes.add(Map<String, dynamic>.from(item));
        }
      }
    }
    debugPrint('[DATA][QR] códigos encontrados para $usuarioId: ${qrCodes.length}');
    return qrCodes;
  }
}
