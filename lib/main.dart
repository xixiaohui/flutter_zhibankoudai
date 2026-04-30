import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/module_provider.dart';
import 'providers/daily_content_provider.dart';
import 'xui/pages/home.dart';
import 'package:flutter/gestures.dart';

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


  WidgetsFlutterBinding.ensureInitialized(); // ⭐ 必须

  await dotenv.load(fileName: ".env"); // ⭐ 必须先加载

  // runApp(const ZbApp());
  runApp(const ZhiBanKouDaiApp());
  // runApp(const MyXiaoMiApp());
}

class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
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
        fontFamily: 'NotoSansSC-Bold',
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
        fontFamily: 'NotoSansSC-Bold',
        fontFamilyFallback: [
          'PingFang SC',
          'Microsoft YaHei',
          'SimSun',
        ],
      ),
      themeMode: ThemeMode.system,
      scrollBehavior: MyScrollBehavior(),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MyXiaoMiApp extends StatelessWidget {
  const MyXiaoMiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZhiBan',
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'My Home Page'),
    );
  }
}