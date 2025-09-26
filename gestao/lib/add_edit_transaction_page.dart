import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditTransactionPage extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? data;

  const AddEditTransactionPage({super.key, this.docId, this.data});

  @override
  State<AddEditTransactionPage> createState() => _AddEditTransactionPageState();
}

class _AddEditTransactionPageState extends State<AddEditTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  String type = 'income';
  final amountController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      type = widget.data!['type'] ?? 'income';
      amountController.text = widget.data!['amount'].toString();
      descriptionController.text = widget.data!['description'] ?? '';
      selectedDate = (widget.data!['date'] as Timestamp).toDate();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.docId == null ? 'Adicionar Transação' : 'Editar Transação'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Entrada')),
                  DropdownMenuItem(value: 'expense', child: Text('Saída')),
                ],
                onChanged: (v) => setState(() => type = v!),
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o valor' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Escolher Data'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // referência para a coleção
                    final docRef = FirebaseFirestore.instance.collection('transactions');

                    // dados com userId
                    final data = {
                      'type': type,
                      'amount': double.tryParse(amountController.text) ?? 0,
                      'description': descriptionController.text,
                      'date': selectedDate,
                      'userId': userId, // <-- atrela ao usuário logado
                    };

                    if (widget.docId == null) {
                      await docRef.add(data);
                    } else {
                      await docRef.doc(widget.docId).update(data);
                    }

                    Navigator.pop(context);
                  }
                },
                child: Text(widget.docId == null ? 'Adicionar' : 'Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
