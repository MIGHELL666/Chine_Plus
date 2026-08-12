import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'core/state/app_state.dart';
import 'core/theme/theme.dart';
import 'core/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.inicializar();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ChinePlusApp(),
    ),
  );
}

class ChinePlusApp extends StatelessWidget {
  const ChinePlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final router = AppRouter.createRouter(appState);

    return MaterialApp.router(
      title: 'Chine Plus',
      debugShowCheckedModeBanner: false,
      themeMode: appState.themeMode,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      routerConfig: router,
    );
  }
}
