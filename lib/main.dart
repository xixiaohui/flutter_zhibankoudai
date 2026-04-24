import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/module_provider.dart';
import 'providers/daily_content_provider.dart';
import 'xui/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ZbApp());
}

class ZbApp extends StatelessWidget {
  const ZbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '智伴口袋',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
        brightness: Brightness.light,
        fontFamily: 'NotoSansSC',
        fontFamilyFallback: [
          'PingFang SC',
          'Microsoft YaHei',
          'SimSun',
        ]
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        fontFamily: 'NotoSansSC',
        fontFamilyFallback: [
          'PingFang SC',
          'Microsoft YaHei',
          'SimSun',
        ],
      ),
      themeMode: ThemeMode.system,
    );
  }
}

class ZhiBanKouDaiApp extends StatelessWidget {
  const ZhiBanKouDaiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModuleProvider()),
        ChangeNotifierProvider(create: (_) => DailyContentProvider()),
      ],
      child: MaterialApp.router(
        title: '智伴口袋',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
