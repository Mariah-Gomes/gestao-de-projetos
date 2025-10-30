import 'dart:ui' show FontFeature;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Reaproveita as cores do seu arquivo
const _cTeal   = Color(0xFF0F6C73);
const _cOrange = Color(0xFFF0A94A);
const _cBg     = Color(0xFFF7F7F7);

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int _sortColumnIndex = 0;     // 0: Data, 1: Descrição, 2: Tipo, 3: Valor
  bool _sortAscending  = false; // padrão: data descendente (mais recente primeiro)

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Apenas acrescentei o orderBy no servidor para vir já por data desc.
    final q = FirebaseFirestore.instance
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true);

    final money = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Scaffold(
      backgroundColor: _cBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Histórico',
            style: TextStyle(color: _cTeal, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: _cTeal),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _cOrange, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: q.snapshots(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = (snap.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[])
                  .map((d) => d.data())
                  .toList();

              // ---------- Ordenação client-side conforme coluna/ordem selecionadas ----------
              docs.sort((a, b) {
                int cmp;
                switch (_sortColumnIndex) {
                  case 0: // Data
                    final da = (a['date'] is Timestamp)
                        ? (a['date'] as Timestamp).toDate()
                        : (a['date'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0));
                    final db = (b['date'] is Timestamp)
                        ? (b['date'] as Timestamp).toDate()
                        : (b['date'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0));
                    cmp = da.compareTo(db);
                    break;
                  case 1: // Descrição
                    final sa = (a['description'] ?? '').toString().toLowerCase();
                    final sb = (b['description'] ?? '').toString().toLowerCase();
                    cmp = sa.compareTo(sb);
                    break;
                  case 2: // Tipo
                    final ta = (a['type'] ?? '').toString().toLowerCase();
                    final tb = (b['type'] ?? '').toString().toLowerCase();
                    cmp = ta.compareTo(tb);
                    break;
                  case 3: // Valor
                    final va = _toDouble(a['amount']);
                    final vb = _toDouble(b['amount']);
                    cmp = va.compareTo(vb);
                    break;
                  default:
                    cmp = 0;
                }
                return _sortAscending ? cmp : -cmp;
              });

              // ---------- Tabela (layout igual ao seu) ----------
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    headingRowColor: WidgetStateProperty.all(_cTeal.withOpacity(0.06)),
                    headingTextStyle: const TextStyle(
                      color: _cTeal, fontWeight: FontWeight.w800, letterSpacing: .3),
                    dataTextStyle: const TextStyle(fontSize: 14),
                    columns: [
                      _sortableColumn('Data', 0),
                      _sortableColumn('Descrição', 1, min: 220),
                      _sortableColumn('Tipo', 2),
                      _sortableColumn('Valor', 3, isRight: true),
                    ],
                    rows: docs.map((m) {
                      final date = (m['date'] is Timestamp)
                          ? (m['date'] as Timestamp).toDate()
                          : (m['date'] as DateTime?);
                      final type = (m['type'] ?? '').toString();
                      final amount = _toDouble(m['amount']);

                      return DataRow(
                        cells: [
                          DataCell(Text(
                            date != null ? DateFormat('dd/MM/yyyy').format(date) : '-',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          )),
                          DataCell(SizedBox(
                            width: 260,
                            child: Text((m['description'] ?? '').toString(),
                                overflow: TextOverflow.ellipsis),
                          )),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: type == 'income'
                                  ? Colors.green.withOpacity(.08)
                                  : Colors.red.withOpacity(.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              type == 'income' ? 'Entrada' : 'Saída',
                              style: TextStyle(
                                color: type == 'income' ? Colors.green[800] : Colors.red[800],
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )),
                          DataCell(Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              money.format(amount),
                              style: const TextStyle(
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Cabeçalho com “setinhas” (↑/↓) ao lado do texto — igual ao seu
  DataColumn _sortableColumn(String title, int index, {double? min, bool isRight = false}) {
    final isActive = _sortColumnIndex == index;
    final icon = _sortAscending ? Icons.arrow_upward : Icons.arrow_downward;

    return DataColumn(
      numeric: isRight,
      onSort: (i, asc) => setState(() {
        _sortColumnIndex = index;
        _sortAscending = asc;
      }),
      label: InkWell(
        onTap: () => setState(() {
          if (_sortColumnIndex == index) {
            _sortAscending = !_sortAscending;
          } else {
            _sortColumnIndex = index;
            _sortAscending = true;
          }
        }),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: min ?? 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title),
              const SizedBox(width: 6),
              Icon(
                isActive ? icon : Icons.unfold_more, // “setinhas” do card
                size: 18,
                color: isActive ? _cTeal : Colors.black45,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _toDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return (num.tryParse('$v') ?? 0).toDouble();
}
