import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/widgets.dart';

// --- SPLASH SCREEN ---

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate to welcome screen after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.movieBlack,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cinema Projector Logo Emblem
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.jadeGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.jadeGreen, width: 2),
                  ),
                  child: const Icon(
                    Icons.movie_creation_rounded,
                    size: 80,
                    color: AppTheme.jadeGreen,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    children: [
                      TextSpan(text: 'CHINE', style: TextStyle(color: Colors.white)),
                      TextSpan(text: ' PLUS', style: TextStyle(color: AppTheme.jadeGreen)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tu cine, tus recompensas',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- WELCOME SCREEN ---

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background visual graphic (Simulated cinema lights/gradient)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppTheme.movieBlack, AppTheme.darkGrey]
                      : [Colors.white, const Color(0xFFF0F2F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.jadeGreen.withValues(alpha: isDark ? 0.08 : 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const Spacer(),
                  // Branding logo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.jadeGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.local_activity_rounded,
                      size: 64,
                      color: AppTheme.jadeGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '¡Bienvenido a Chine Plus!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Registra tus películas favoritas, asiste a cines cercanos, escanea códigos QR y gana recompensas exclusivas del séptimo arte.',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Actions
                  AppButton(
                    text: 'Iniciar Sesión',
                    onPressed: () => context.push('/login'),
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'Crear Cuenta',
                    isPrimary: false,
                    onPressed: () => context.push('/register'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- LOGIN SCREEN ---

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'miguel@chineplus.com');
  final _passwordController = TextEditingController(text: '123456');
  String _selectedRole = 'user'; // 'user' or 'admin'
  bool _isLoading = false;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulating network delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        final appState = Provider.of<AppState>(context, listen: false);
        final success = appState.login(
          _emailController.text,
          _passwordController.text,
          _selectedRole,
        );

        setState(() {
          _isLoading = false;
        });

        if (success) {
          showAppSnackbar(context, message: '¡Sesión iniciada con éxito!');
          if (_selectedRole == 'admin') {
            context.go('/admin');
          } else {
            context.go('/user');
          }
        } else {
          showAppSnackbar(
            context,
            message: 'Credenciales incorrectas o usuario inactivo.',
            isError: true,
          );
        }
      });
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Recuperar Contraseña'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu correo registrado y te enviaremos las instrucciones de recuperación.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: emailController,
              labelText: 'Correo Electrónico',
              hintText: 'correo@ejemplo.com',
              prefixIcon: Icons.email_outlined,
            ),
          ],
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
              Navigator.pop(context);
              showAppSnackbar(
                context,
                message: 'Se ha enviado un enlace de recuperación a ${emailController.text}',
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  '¡Qué gusto verte de nuevo!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Accede para ver tus estadísticas y reclamar premios.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Role Selector (Premium Design tab-style bar)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.brightness == Brightness.dark
                        ? AppTheme.darkGrey
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(
                            Icons.person_outline,
                            color: _selectedRole == 'user'
                                ? Colors.white
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            size: 18,
                          ),
                          label: Center(
                            child: Text(
                              'Usuario',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == 'user'
                                    ? Colors.white
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          selected: _selectedRole == 'user',
                          selectedColor: AppTheme.jadeGreen,
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedRole = 'user';
                                _emailController.text = 'miguel@chineplus.com';
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: ChoiceChip(
                          showCheckmark: false,
                          avatar: Icon(
                            Icons.admin_panel_settings_outlined,
                            color: _selectedRole == 'admin'
                                ? Colors.white
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            size: 18,
                          ),
                          label: Center(
                            child: Text(
                              'Administrador',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedRole == 'admin'
                                    ? Colors.white
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          selected: _selectedRole == 'admin',
                          selectedColor: AppTheme.jadeGreen,
                          backgroundColor: Colors.transparent,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedRole = 'admin';
                                _emailController.text = 'admin@chineplus.com';
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Fields
                AppTextField(
                  controller: _emailController,
                  labelText: 'Correo Electrónico',
                  hintText: 'correo@chineplus.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 4) {
                      return 'La contraseña debe tener al menos 4 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                AppButton(
                  text: 'Iniciar Sesión',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Crear Cuenta',
                  isPrimary: false,
                  onPressed: () => context.push('/register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- REGISTER SCREEN ---

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulating registration delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        final appState = Provider.of<AppState>(context, listen: false);
        appState.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        showAppSnackbar(context, message: '¡Cuenta creada con éxito! Bienvenido.');
        context.go('/user');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Únete a Chine Plus',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Comienza a registrar tus películas favoritas y canjea increíbles recompensas.',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Fields
                AppTextField(
                  controller: _nameController,
                  labelText: 'Nombre Completo',
                  hintText: 'Ingresa tu nombre',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  labelText: 'Correo Electrónico',
                  hintText: 'correo@ejemplo.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu correo electrónico';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un correo electrónico válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordController,
                  labelText: 'Contraseña',
                  hintText: 'Mínimo 6 caracteres',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                AppButton(
                  text: 'Registrarse',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes una cuenta? ',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Inicia sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
