import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url =
      'https://tixfuomhijuybybdhozu.supabase.co';

  static const String publishableKey =
       'sb_publishable_07_3OnpOpOCOGPKOB8zhUw_mPcDXIN9';

  static Future<void> inicializar() async {
   await Supabase.initialize(
  url: url,
  publishableKey: publishableKey,
);
  }
}