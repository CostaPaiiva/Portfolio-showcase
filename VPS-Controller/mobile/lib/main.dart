import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/live_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthService();
  await auth.initialize();
  final live = LiveService()..connect();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: live),
        Provider(create: (_) => ApiService(auth)),
      ],
      child: const VpsControllerApp(),
    ),
  );
}

class VpsControllerApp extends StatelessWidget {
  const VpsControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VPS Controller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: Consumer<AuthService>(
        builder: (_, auth, __) {
          if (auth.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.signedIn ? const HomeShell() : const LoginScreen();
        },
      ),
    );
  }
}
