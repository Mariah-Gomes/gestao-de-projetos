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

  /// Função chamada pelo RefreshIndicator
  Future<void> _refresh() async {
    // Força um rebuild (mesmo que snapshots já atualize sozinho)
    setState(() {});
    await Future.delayed(const Duration(milliseconds: 300)); // só para dar tempo de animar
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // define início e fim do mês selecionado
    final firstDayOfMonth = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDayOfMonth =
    DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

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
            'Minhas Finanças - ${DateFormat('MM/yyyy').format(selectedMonth)}'),
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
              Navigator.pushReplacementNamed(context, '/welcome');
            },
          )
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

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              // physics sempre para poder puxar mesmo sem itens
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
                final amount = data['amount'] ?? 0;
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
                    // abrir tela de edição
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
          // abrir tela de adição
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
