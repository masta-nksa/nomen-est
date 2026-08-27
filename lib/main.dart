import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/providers.dart';
import 'screens/home_screen.dart';
import 'storage/persistent_storage.dart';
import 'theme/app_theme.dart';
import 'theme/browser_branding.dart';

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

    // Same story for the school: the default paints the first frame, the stored
    // choice corrects it. Tab icon and browser bars are told separately — they
    // are not part of the widget tree and keep whatever `index.html` set.
    final palette = ref.watch(brandProvider).valueOrNull ?? BrandPalette.nksa;
    applyBrowserBranding(palette);

    return MaterialApp(
      title: 'Nomen est',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(palette),
      darkTheme: AppTheme.dark(palette),
      themeMode: mode,
      home: const HomeScreen(),
    );
  }
}
