import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'welcome_page.dart';
import 'home_page.dart';

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

      // agora usamos rotas nomeadas
      initialRoute: '/',
      routes: {
        '/': (context) =>
            const AuthGate(), // wrapper que decide entre login e home
        '/welcome': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

/// Este widget decide para onde o usuário vai (login ou home)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // usuário logado → manda para HomePage
          return const HomePage();
        } else {
          // não logado → manda para WelcomePage (login/registro)
          return const WelcomePage();
        }
      },
    );
  }
}
