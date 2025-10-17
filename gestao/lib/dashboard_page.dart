import 'package:flutter/material.dart';

class MyDashboard extends StatelessWidget {
  const MyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Row(
          children: const [
            SideMenu(),
            Expanded(child: DashboardContent()),
          ],
        ),
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LOGO
          Center(
            child: Image.asset(
              'assets/images/Logo.png', // substitua pelo seu logo
              height: 100,
            ),
          ),
          const SizedBox(height: 40),

          // LINKS DO MENU
          const MenuItem(title: "Home", selected: true),
          const MenuItem(title: "Movimentação"),
          const MenuItem(title: "Histórico"),
          const MenuItem(title: "Perfil"),

          const Spacer(),

          Center(
              child: ElevatedButton.icon(
                onPressed: () {
                },
                icon: const Icon(Icons.logout), // Ícone padrão de logout do Material
                label: const Text('Sair'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF005C60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final String title;
  final bool selected;

  const MenuItem({super.key, required this.title, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: InkWell(
        onTap: () {},
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: selected ? const Color(0xFFCC8B2F) : Colors.black87,
            decoration:
            selected ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFDFCF9),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // CARDS SUPERIORES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              DashboardCard(title: 'TOTAL'),
              DashboardCard(title: 'ENTRADA'),
              DashboardCard(title: 'SAÍDA'),
            ],
          ),
          const SizedBox(height: 30),

          // ÁREA DO DASHBOARD
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFCC8B2F), width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCC8B2F),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  const DashboardCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFCC8B2F), width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF005C60),
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 4,
              )
            ],
          ),
        ),
      ),
    );
  }
}