import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/providers.dart';
import 'screens/home_screen.dart';
import 'storage/persistent_storage.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  requestPersistentStorage();
  runApp(const ProviderScope(child: NomenEstApp()));
}

class NomenEstApp extends ConsumerWidget {
  const NomenEstApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The stored choice arrives one frame late, from the database. Following
    // the device in the meantime means the first frame already matches the
    // room, so at worst there is a single correction rather than a white flash
    // on a device that is set to dark.
    final mode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return MaterialApp(
      title: 'Nomen est',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: const HomeScreen(),
    );
  }
}
