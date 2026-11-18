// Ponto de entrada do app: inicializa o Firebase, define as rotas nomeadas
// e protege as telas com o AuthGate.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/game.dart';
import 'screens/game_form_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

/// Nomes das rotas centralizados para evitar erros de digitação nas chamadas de Navigator.pushNamed.
class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const gameForm = '/game-form';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estante Virtual de Jogos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      // AuthGate decide entre Login e Home conforme o estado de autenticação.
      home: const AuthGate(),

      // Gera as rotas sob demanda. As rotas protegidas (home e formulário)
      // verificam se há usuário logado; se não houver, mostram o login.
      onGenerateRoute: (settings) {
        final loggedIn = FirebaseAuth.instance.currentUser != null;

        switch (settings.name) {
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          // Rotas protegidas: sem usuário logado, redireciona para o login.
          case AppRoutes.home:
            return MaterialPageRoute(
              builder: (_) => loggedIn ? const HomeScreen() : const LoginScreen(),
            );
          case AppRoutes.gameForm:
            // O jogo chega como argumento: null = criar, preenchido = editar.
            final game = settings.arguments as Game?;
            return MaterialPageRoute(
              builder: (_) =>
                  loggedIn ? GameFormScreen(game: game) : const LoginScreen(),
            );
        }
        return null;
      },
    );
  }
}

/// Proteção de telas: só mostra a Home para usuários autenticados.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.hasData ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
