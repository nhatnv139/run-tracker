import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:runvie/app.dart';
import 'package:runvie/core/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock portrait for MVP.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // Load .env (silent if missing — handled in Env getters).
  try {
    await Env.load();
  } catch (_) {
    // .env not present in some build configs; continue.
  }

  // Local storage
  await Hive.initFlutter();

  // Supabase — only init if config present.
  if (Env.supabaseUrl.isNotEmpty && Env.supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: false,
    );
  }

  runApp(const ProviderScope(child: RunVieApp()));
}
