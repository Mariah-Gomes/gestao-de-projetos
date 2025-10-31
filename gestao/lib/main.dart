import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

// SUAS PÁGINAS
import 'dashboard_page.dart';
import 'welcome_page.dart';
import 'profile_page.dart';

// adicione esses imports conforme os nomes dos seus arquivos:
import 'history_page.dart';        // contém: class HistoryPage extends StatefulWidget/StatelessWidget
//import 'movimentacao_page.dart';   // contém: class MovimentacaoPage ...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance App',
      theme: ThemeData(primarySwatch: Colors.blue),

      // usamos rotas nomeadas
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthGate(),          // decide entre login e home
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const DashboardPage(), // sua dashboard (Home)

        // ✅ novas rotas para o menu
        '/historico': (context) => const HistoryPage(),
        //'/mov': (context) => const MovimentacaoPage(),
        '/perfil': (context) => ProfilePage(),
      },

      // (opcional) fallback se chamar uma rota inexistente
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const DashboardPage(),
      ),
    );
  }
}

/// Decide para onde o usuário vai (login ou home)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          // logado → Dashboard
          return const DashboardPage();
        } else {
          // não logado → Welcome/Login
          return const WelcomePage();
        }
      },
    );
  }
}
