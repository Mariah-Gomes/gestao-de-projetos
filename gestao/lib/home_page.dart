import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_edit_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedMonth = DateTime.now();

  Future<void> _refresh() async {
    setState(() {}); // força rebuild do StreamBuilder
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // não logado, redirecionar
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/welcome'));
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userId = user.uid;

    // início e fim do mês selecionado
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    // último dia do mês
    final lastDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

    // IMPORTANTE: campo 'date' precisa ser Timestamp no Firestore
    final transactionsQuery = FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: firstDayOfMonth)
        .where('date', isLessThanOrEqualTo: lastDayOfMonth)
        .orderBy('date', descending: true);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Minhas Finanças - ${DateFormat('MM/yyyy').format(selectedMonth)}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedMonth,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
                helpText: 'Selecione um mês',
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                setState(() {
                  selectedMonth = picked;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/welcome');
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: StreamBuilder<QuerySnapshot>(
          stream: transactionsQuery.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Erro: ${snapshot.error}'),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            // Debug: imprime no console
            for (var d in docs) {
              debugPrint('doc: ${d.id} => ${d.data()}');
            }

            if (docs.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: Text('Nenhuma transação neste mês.')),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final amount = (data['amount'] ?? 0).toDouble();
                final type = data['type'] ?? 'income';
                final description = data['description'] ?? '';
                final date = (data['date'] as Timestamp).toDate();

                return ListTile(
                  leading: Icon(
                    type == 'income'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: type == 'income' ? Colors.green : Colors.red,
                  ),
                  title: Text(description),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(date)),
                  trailing: Text(
                    'R\$ ${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: type == 'income' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditTransactionPage(
                          docId: docs[index].id,
                          data: data,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditTransactionPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
