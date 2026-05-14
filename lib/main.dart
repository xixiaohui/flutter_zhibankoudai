import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'design/theme_data.dart';
import 'providers/module_provider.dart';
import 'providers/daily_content_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(AppThemeData.overlayStyle(Brightness.light));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: ".env");

  runApp(const ZhiBanKouDaiApp());
}

class ZhiBanKouDaiApp extends StatelessWidget {
  const ZhiBanKouDaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => DailyContentProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, _) {
          final brightness = switch (themeProvider.mode) {
            ThemeMode.light => Brightness.light,
            ThemeMode.dark => Brightness.dark,
            ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness,
          };
          SystemChrome.setSystemUIOverlayStyle(AppThemeData.overlayStyle(brightness));

          return MaterialApp.router(
            title: '智伴口袋',
            debugShowCheckedModeBanner: false,
            theme: AppThemeData.light,
            darkTheme: AppThemeData.dark,
            themeMode: themeProvider.mode,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
