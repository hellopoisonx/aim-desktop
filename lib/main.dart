import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'src/aim_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(isOptional: true);
  } catch (_) {
    // .env is optional; --dart-define AIM_GATEWAY_URL remains supported.
  }
  runApp(const ProviderScope(child: AimDesktopApp()));
}
