-- =====================================================
-- BASE DE DATOS CHINE PLUS
-- Migración inicial mejorada
-- =====================================================

-- Permite generar identificadores UUID
CREATE EXTENSION IF NOT EXISTS pgcrypto;


-- =====================================================
-- 1. TABLA: perfiles
-- Información adicional de los usuarios registrados
-- =====================================================

CREATE TABLE perfiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nombre TEXT NOT NULL,
    correo TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    nivel INTEGER NOT NULL DEFAULT 1 CHECK (nivel >= 1),
    puntos INTEGER NOT NULL DEFAULT 0 CHECK (puntos >= 0),
    rol TEXT NOT NULL DEFAULT 'usuario'
        CHECK (rol IN ('usuario', 'administrador')),
    estado TEXT NOT NULL DEFAULT 'activo'
        CHECK (estado IN ('activo', 'inactivo')),
    fecha_registro TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE perfiles IS
'Información adicional de los usuarios registrados con Supabase Auth';


-- =====================================================
-- 2. TABLA: cines
-- Catálogo de cines disponibles en Chine Plus 
--Recordatorio: la infor de los cines vendra directamnete de google maps
--por eso la simplificacion de la tabla.
-- =====================================================

-- =====================================================
-- 2. TABLA: cines
-- Referencias de cines obtenidos desde Google Maps
-- =====================================================

CREATE TABLE cines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    google_place_id TEXT UNIQUE NOT NULL,
    nombre_referencia TEXT NOT NULL,
    direccion_referencia TEXT,
    latitud DOUBLE PRECISION,
    longitud DOUBLE PRECISION,
    estado TEXT NOT NULL DEFAULT 'activo'
        CHECK (estado IN ('activo', 'inactivo')),
    fecha_creacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE cines IS
'Cines obtenidos desde Google Maps que tienen actividad dentro de Chine Plus';


-- =====================================================
-- 3. TABLA: peliculas
-- Catálogo general de películas
-- =====================================================

CREATE TABLE peliculas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo TEXT NOT NULL,
    poster_url TEXT,
    genero TEXT,
    duracion_minutos INTEGER
        CHECK (duracion_minutos IS NULL OR duracion_minutos > 0),
    descripcion TEXT,
    fecha_estreno DATE,
    estado TEXT NOT NULL DEFAULT 'activo'
        CHECK (estado IN ('activo', 'inactivo')),
    fecha_creacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE peliculas IS
'Catálogo de películas que los usuarios pueden marcar como favoritas';


-- =====================================================
-- 4. TABLA: promociones
-- Promociones creadas por los administradores
-- =====================================================

CREATE TABLE promociones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre TEXT NOT NULL,
    descripcion TEXT,
    imagen_url TEXT,
    puntos_requeridos INTEGER NOT NULL DEFAULT 0
        CHECK (puntos_requeridos >= 0),
    existencias INTEGER
        CHECK (existencias IS NULL OR existencias >= 0),
    fecha_inicio TIMESTAMP WITH TIME ZONE,
    fecha_fin TIMESTAMP WITH TIME ZONE,
    estado TEXT NOT NULL DEFAULT 'borrador'
        CHECK (
            estado IN (
                'borrador',
                'activa',
                'inactiva',
                'agotada',
                'expirada'
            )
        ),
    fecha_creacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),

    CHECK (
        fecha_fin IS NULL
        OR fecha_inicio IS NULL
        OR fecha_fin > fecha_inicio
    )
);

COMMENT ON TABLE promociones IS
'Promociones que los usuarios pueden obtener utilizando sus puntos';
-- =====================================================
-- 5. TABLA: peliculas_favoritas
-- Relación entre usuarios y sus películas favoritas
-- =====================================================

CREATE TABLE peliculas_favoritas (
    usuario_id UUID NOT NULL
        REFERENCES perfiles(id)
        ON DELETE CASCADE,

    pelicula_id UUID NOT NULL
        REFERENCES peliculas(id)
        ON DELETE CASCADE,

    fecha_agregado TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    PRIMARY KEY (usuario_id, pelicula_id)
);

COMMENT ON TABLE peliculas_favoritas IS
'Películas marcadas como favoritas por cada usuario';

-- =====================================================
-- 6. TABLA: promociones_cines
-- Cines donde puede utilizarse cada promoción
-- =====================================================

CREATE TABLE promociones_cines (
    promocion_id UUID NOT NULL
        REFERENCES promociones(id)
        ON DELETE CASCADE,

    cine_id UUID NOT NULL
        REFERENCES cines(id)
        ON DELETE CASCADE,

    fecha_asignacion TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    PRIMARY KEY (promocion_id, cine_id)
);

COMMENT ON TABLE promociones_cines IS
'Cines en los que está disponible cada promoción';
-- =====================================================
-- 7. TABLA: visitas
-- Registro de visitas realizadas por los usuarios
-- =====================================================

CREATE TABLE visitas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    usuario_id UUID NOT NULL
        REFERENCES perfiles(id)
        ON DELETE CASCADE,

    cine_id UUID NOT NULL
        REFERENCES cines(id)
        ON DELETE CASCADE,

    fecha_visita TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    puntos_generados INTEGER NOT NULL DEFAULT 0
        CHECK (puntos_generados >= 0),

    estado TEXT NOT NULL DEFAULT 'validada'
        CHECK (estado IN ('pendiente', 'validada', 'rechazada')),

    fecha_creacion TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE visitas IS
'Visitas realizadas por los usuarios a los cines registrados en Chine Plus';

-- =====================================================
-- 8. TABLA: movimientos_puntos
-- Historial de puntos ganados y utilizados
-- =====================================================

CREATE TABLE movimientos_puntos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    usuario_id UUID NOT NULL
        REFERENCES perfiles(id)
        ON DELETE CASCADE,

    tipo TEXT NOT NULL
        CHECK (tipo IN ('ganancia', 'uso', 'ajuste')),

    cantidad INTEGER NOT NULL
        CHECK (cantidad <> 0),

    concepto TEXT NOT NULL,

    referencia_tipo TEXT,
    referencia_id UUID,

    fecha_movimiento TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE movimientos_puntos IS
'Historial de movimientos que aumentan o disminuyen los puntos de cada usuario';

-- =====================================================
-- 9. TABLA: canjes
-- Registro de promociones canjeadas por los usuarios
-- =====================================================

CREATE TABLE canjes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    usuario_id UUID NOT NULL
        REFERENCES perfiles(id)
        ON DELETE CASCADE,

    promocion_id UUID NOT NULL
        REFERENCES promociones(id)
        ON DELETE CASCADE,

    puntos_utilizados INTEGER NOT NULL
        CHECK (puntos_utilizados >= 0),

    estado TEXT NOT NULL DEFAULT 'pendiente'
        CHECK (
            estado IN (
                'pendiente',
                'utilizado',
                'cancelado',
                'expirado'
            )
        ),

    fecha_canje TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW()
);
-- =====================================================
-- 10. TABLA: codigos_qr
-- Códigos QR generados a partir de los canjes
-- =====================================================

CREATE TABLE codigos_qr (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    canje_id UUID NOT NULL UNIQUE
        REFERENCES canjes(id)
        ON DELETE CASCADE,

    codigo TEXT NOT NULL UNIQUE,

    estado TEXT NOT NULL DEFAULT 'activo'
        CHECK (
            estado IN (
                'activo',
                'utilizado',
                'cancelado',
                'expirado'
            )
        ),

    fecha_generacion TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW(),

    fecha_uso TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE codigos_qr IS
'Códigos QR personalizados generados después del canje de una promoción';

COMMENT ON TABLE canjes IS
'Registro de promociones obtenidas por los usuarios mediante el uso de puntos';
-- =====================================================
-- 11. TABLA: uso_codigos_qr
-- Registro del uso de los códigos QR
-- =====================================================

CREATE TABLE uso_codigos_qr (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    codigo_qr_id UUID NOT NULL UNIQUE
        REFERENCES codigos_qr(id)
        ON DELETE CASCADE,

    cine_id UUID NOT NULL
        REFERENCES cines(id)
        ON DELETE CASCADE,

    fecha_uso TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE uso_codigos_qr IS
'Registro del momento en que un código QR fue utilizado en un cine';

-- =====================================================
-- 12. TABLA: configuracion_puntos
-- Valores de puntos utilizados por la aplicación
-- =====================================================

CREATE TABLE configuracion_puntos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    clave TEXT NOT NULL UNIQUE,

    descripcion TEXT NOT NULL,

    puntos INTEGER NOT NULL
        CHECK (puntos >= 0),

    estado TEXT NOT NULL DEFAULT 'activo'
        CHECK (estado IN ('activo', 'inactivo')),

    fecha_actualizacion TIMESTAMP WITH TIME ZONE
        NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE configuracion_puntos IS
'Configuración sencilla de los puntos otorgados por distintas acciones de la aplicación';