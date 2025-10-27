import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dashboard_charts.dart';

/// Cores do protótipo
const _cTeal   = Color(0xFF0F6C73);
const _cOrange = Color(0xFFF0A94A);
const _cBg     = Color(0xFFF7F7F7);

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/welcome'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // intervalo do mês (1º dia … último dia 23:59)
    final first = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final last  = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    final q = FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('date', isGreaterThanOrEqualTo: first)
        .where('date', isLessThanOrEqualTo: last);

    return Scaffold(
      backgroundColor: _cBg,
      body: Row(
        children: [
          // ----------------- SIDEBAR -----------------
          _Sidebar(onTapIndex: (i) {
            switch (i) {
              case 0: break; // Home/Dashboard
              case 1: Navigator.pushNamed(context, '/mov'); break;
              case 2: Navigator.pushNamed(context, '/historico'); break;
              case 3: Navigator.pushNamed(context, '/perfil'); break;
            }
          }),

          // ----------------- CONTEÚDO -----------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: q.snapshots(),
                builder: (context, snap) {
                  final docs = snap.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];

                  double entradas = 0, saidas = 0;
                  for (final d in docs) {
                    final m = d.data();
                    final v = (m['amount'] is num)
                        ? (m['amount'] as num).toDouble()
                        : (num.tryParse('${m['amount']}') ?? 0).toDouble();
                    (m['type'] == 'income') ? entradas += v : saidas += v;
                  }
                  final total = entradas - saidas;
                  final money = NumberFormat.simpleCurrency(locale: 'pt_BR');

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // topo: mês + ações
                      Row(
                        children: [
                          Text(
                            DateFormat('MM/yyyy').format(_selectedMonth),
                            style: const TextStyle(
                              color: _cTeal, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Trocar mês',
                            icon: const Icon(Icons.calendar_month, color: _cTeal),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedMonth,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2100),
                                initialDatePickerMode: DatePickerMode.year,
                                helpText: 'Selecione um dia do mês',
                              );
                              if (picked != null) setState(() => _selectedMonth = picked);
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Sair',
                            icon: const Icon(Icons.logout, color: _cTeal),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context, '/welcome');
                              }
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // cards TOTAL | ENTRADA | SAÍDA
                      Row(
                        children: [
                          Expanded(child: _SumCard(title: 'TOTAL',   value: money.format(total))),
                          const SizedBox(width: 12),
                          Expanded(child: _SumCard(title: 'ENTRADA', value: money.format(entradas))),
                          const SizedBox(width: 12),
                          Expanded(child: _SumCard(title: 'SAÍDA',   value: money.format(saidas))),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Center(
                        child: Text(
                          'Dashboard',
                          style: TextStyle(
                            color: _cOrange,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // QUADRÃO do Dashboard (onde entram os gráficos)
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: _cOrange, width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: snap.connectionState == ConnectionState.waiting
                              ? const Center(child: CircularProgressIndicator())
                              : DashboardCharts(docs: docs),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ----------------- SIDEBAR (mantém o estilo, imagens encostadas nas bordas) -----------------
class _Sidebar extends StatefulWidget {
  const _Sidebar({required this.onTapIndex});
  final void Function(int index) onTapIndex;

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cTeal, width: 2.5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // --- LOGO SUPERIOR (FrenteLogo encostada) ---
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.asset(
                'assets/images/FrenteLogo.png',
                fit: BoxFit.cover,
                height: 80,
                errorBuilder: (_, __, ___) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover, height: 80),
                  );
                },
              ),
            ),
          ),

          // --- LOGO INFERIOR (TrasLogo encostada) ---
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Image.asset(
                'assets/images/TrasLogo.png',
                fit: BoxFit.cover,
                height: 90,
                errorBuilder: (_, __, ___) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                    child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover, height: 90),
                  );
                },
              ),
            ),
          ),

          // --- ITENS DE MENU ---
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 90, 12, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SideItem(
                    label: 'Home',
                    selected: selected == 0,
                    onTap: () { setState(() => selected = 0); widget.onTapIndex(0); },
                  ),
                  _SideItem(
                    label: 'Movimentação',
                    selected: selected == 1,
                    onTap: () { setState(() => selected = 1); widget.onTapIndex(1); },
                  ),
                  _SideItem(
                    label: 'Histórico',
                    selected: selected == 2,
                    onTap: () { setState(() => selected = 2); widget.onTapIndex(2); },
                  ),
                  _SideItem(
                    label: 'Perfil',
                    selected: selected == 3,
                    onTap: () { setState(() => selected = 3); widget.onTapIndex(3); },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Item com “pill” + barra à esquerda quando selecionado
class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseText = TextStyle(
      fontSize: 16,
      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
      letterSpacing: 0.2,
      color: selected ? _cTeal : Colors.black87,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _cTeal.withOpacity(0.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: 28,
              decoration: BoxDecoration(
                color: selected ? _cTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: baseText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// Cards superiores
class _SumCard extends StatelessWidget {
  const _SumCard({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cOrange, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _cTeal,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              shadows: [Shadow(blurRadius: 2, color: Colors.black26, offset: Offset(0, 1))],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _cTeal,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
