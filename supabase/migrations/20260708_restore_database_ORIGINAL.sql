-- ==========================================
-- SCRIPT DE BASE DE DATOS PARA SUPABASE
-- PROYECTO: Chine Plus
-- FECHA: 2026-06-25
-- ==========================================

-- Limpiar tablas si existen (para recreación limpia)
DROP TABLE IF EXISTS scan_history CASCADE;
DROP TABLE IF EXISTS rewards CASCADE;
DROP TABLE IF EXISTS qr_codes CASCADE;
DROP TABLE IF EXISTS cinemas CASCADE;
DROP TABLE IF EXISTS movies CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- ==========================================
-- 1. TABLA: profiles (Usuarios)
-- Nota: En Supabase, se recomienda asociar esta tabla
-- con la tabla de autenticación de Supabase `auth.users`
-- ==========================================
CREATE TABLE profiles (
    id TEXT PRIMARY KEY, -- O UUID si se usa con Auth de Supabase
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    level INTEGER DEFAULT 1,
    points INTEGER DEFAULT 0,
    role TEXT DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    status TEXT DEFAULT 'Activo' CHECK (status IN ('Activo', 'Inactivo')),
    registration_date TEXT NOT NULL, -- Guardado como texto según el modelo de Flutter
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Habilitar comentarios para claridad
COMMENT ON TABLE profiles IS 'Tabla de perfiles de usuario vinculada o independiente';

-- ==========================================
-- 2. TABLA: movies (Películas Vistas)
-- ==========================================
CREATE TABLE movies (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    poster_url TEXT,
    watch_date TEXT NOT NULL,
    cinema_name TEXT,
    rating NUMERIC(3, 2) DEFAULT 0.0 CHECK (rating >= 0.0 AND rating <= 5.0),
    genre TEXT,
    duration_minutes INTEGER,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==========================================
-- 3. TABLA: cinemas (Cines cercanos)
-- ==========================================
CREATE TABLE cinemas (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT,
    schedule TEXT,
    distance TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==========================================
-- 4. TABLA: qr_codes (Códigos QR Generados)
-- ==========================================
CREATE TABLE qr_codes (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT CHECK (type IN ('Boleto', 'Poster', 'Cartón promocional', 'Stand promocional', 'Evento especial', 'Otro')),
    points INTEGER DEFAULT 0,
    start_date TEXT,
    expiration_date TEXT,
    status TEXT DEFAULT 'Activo' CHECK (status IN ('Activo', 'Inactivo', 'Expirado')),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==========================================
-- 5. TABLA: rewards (Recompensas / Premios)
-- ==========================================
CREATE TABLE rewards (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    points_required INTEGER DEFAULT 0,
    stock INTEGER DEFAULT 0,
    status TEXT DEFAULT 'Activo' CHECK (status IN ('Activo', 'Inactivo')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==========================================
-- 6. TABLA: scan_history (Historial de Escaneos)
-- ==========================================
CREATE TABLE scan_history (
    id TEXT PRIMARY KEY,
    user_id TEXT REFERENCES profiles(id) ON DELETE CASCADE,
    date TEXT NOT NULL,
    place TEXT NOT NULL,
    points INTEGER DEFAULT 0,
    status TEXT DEFAULT 'Completado' CHECK (status IN ('Completado', 'Fallido', 'Duplicado')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);


-- ==========================================
-- INSERCIÓN DE DATOS INICIALES (MOCK DATA)
-- ==========================================

-- Datos para profiles
INSERT INTO profiles (id, name, email, avatar_url, level, points, role, status, registration_date) VALUES
('USR-001', 'Admin ChinePlus', 'admin@chineplus.com', 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150', 10, 9999, 'admin', 'Activo', '01/01/2026');

-- Datos para movies
INSERT INTO movies (id, title, poster_url, watch_date, cinema_name, rating, genre, duration_minutes, description) VALUES
('MOV-001', 'Dune: Part Two', 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=300', '12/03/2026', 'Cinepolis Altaria', 5.0, 'Ciencia Ficción', 166, 'Paul Atreides se une a Chani y a los Fremen mientras busca venganza contra los conspiradores que destruyeron a su familia.');

-- Datos para cinemas
INSERT INTO cinemas (id, name, address, schedule, distance, latitude, longitude) VALUES
('CIN-001', 'Cinepolis Altaria', 'Centro Comercial Altaria, Col. Trojes de Alonso', '11:00 AM - 11:30 PM', '1.2 km', 21.9213, -102.2915);

-- Datos para rewards
INSERT INTO rewards (id, name, description, image_url, points_required, stock, status) VALUES
('REW-001', 'Palomitas Grandes Gratis', 'Canjeable por una cubeta de palomitas grandes de mantequilla en dulcería.', 'https://images.unsplash.com/photo-1578244182942-18427f3caca6?w=200', 300, 45, 'Activo'),
('REW-002', 'Boleto 2D Tradicional', 'Un boleto gratis para cualquier función 2D en salas tradicionales de lunes a domingo.', 'https://images.unsplash.com/photo-1595769816263-9b910be24d5f?w=200', 500, 120, 'Activo'),
('REW-003', 'Combo Pareja CinePlus', '2 refrescos medianos + 1 palomitas grandes + 1 hot-dog.', 'https://images.unsplash.com/photo-1513151233558-d860c5398176?w=200', 800, 15, 'Activo'),
('REW-004', 'Vaso Coleccionable Edición Especial', 'Vaso de acrílico coleccionable de la película del mes.', 'https://images.unsplash.com/photo-1517256064527-09c53b2d0bc6?w=200', 400, 0, 'Inactivo');


-- ==========================================
-- OPCIONAL: Integración con Supabase Auth (Triggers)
-- ==========================================
-- Si deseas que los usuarios de Supabase Auth se agreguen automáticamente
-- a la tabla `profiles`, puedes ejecutar lo siguiente:
--
-- CREATE OR REPLACE FUNCTION public.handle_new_user()
-- RETURNS trigger AS $$
-- BEGIN
--   INSERT INTO public.profiles (id, name, email, avatar_url, level, points, role, status, registration_date)
--   VALUES (
--     new.id::text,
--     COALESCE(new.raw_user_meta_data->>'name', 'Usuario Nuevo'),
--     new.email,
--     COALESCE(new.raw_user_meta_data->>'avatar_url', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150'),
--     1,
--     150, -- Bono inicial
--     'user',
--     'Activo',
--     to_char(now(), 'DD/MM/YYYY')
--   );
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- CREATE OR REPLACE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
