import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Cores do protótipo
const _cTeal = Color(0xFF0F6C73);
const _cOrange = Color(0xFFF0A94A);
const _cBg = Color(0xFFF7F7F7);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controladores para os campos do formulário
  late final TextEditingController _nameController;
  late final TextEditingController _dobController; // Data de Aniversário

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Estados de edição para cada campo
  bool _isNameEditing = false;
  bool _isDobEditing = false;

  // Simulação de data de aniversário, Firebase Auth não armazena isso.
  // Você precisaria de um Cloud Firestore ou similar para persistir.
  DateTime? _selectedDob;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');

    // Para a data de aniversário, assumindo que ela pode vir de algum lugar
    // ou ser definida aqui temporariamente.
    // Para persistir, precisaríamos de outro serviço (Firestore, por exemplo).
    _selectedDob = DateTime(1990, 1, 1); // Exemplo de data inicial
    _dobController = TextEditingController(
      text: _selectedDob != null ? DateFormat('dd/MM/yyyy').format(_selectedDob!) : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Função de Logout - AGORA ESTÁ SENDO USADA
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      // Usamos pushNamedAndRemoveUntil para limpar a pilha de navegação
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    }
  }

  // Função para salvar o perfil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return; // Não faz nada se o formulário for inválido
    }

    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Atualiza o nome no Firebase Auth
      if (_isNameEditing && user.displayName != _nameController.text) {
        await user.updateDisplayName(_nameController.text);
      }

      // Se a data de aniversário foi editada, salve-a (simulado aqui)
      if (_isDobEditing && _selectedDob != null) {
        // LÓGICA PARA SALVAR NO FIRESTORE IRIA AQUI
        debugPrint('Data de aniversário salva (simulado): $_selectedDob');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      // Desativa o modo de edição após salvar
      setState(() {
        _isNameEditing = false;
        _isDobEditing = false;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar perfil: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Seletor de data para Aniversário
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecione sua data de aniversário',
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/welcome'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: _cBg,
      body: Row(
        children: [
          // ----------------- SIDEBAR -----------------
          _Sidebar(
            selectedIndex: 3, // "Perfil" é o índice 3
            onTapIndex: (i) {
              switch (i) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/mov');
                  break;
                case 2:
                  Navigator.pushNamed(context, '/historico');
                  break;
                case 3:
                  break; // Já estamos aqui
              }
            },
          ),

          // ----------------- CONTEÚDO DO PERFIL -----------------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // --- Topo: Título Centralizado + Botão de Sair ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        'Seus dados pessoais',
                        style: TextStyle(
                          color: _cOrange,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: 'Sair',
                          icon: const Icon(Icons.logout, color: _cTeal, size: 28),
                          onPressed: _signOut, // USANDO A FUNÇÃO AQUI
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // --- Card Branco Principal para os campos ---
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _cOrange, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ProfileField(
                              label: 'Nome:',
                              controller: _nameController,
                              isEditing: _isNameEditing,
                              onEditPressed: () => setState(() => _isNameEditing = true),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Insira seu nome.' : null,
                              readOnly: !_isNameEditing,
                            ),
                            const SizedBox(height: 32),

                            _ProfileField(
                              label: 'Data de aniversário:',
                              controller: _dobController,
                              isEditing: _isDobEditing,
                              onEditPressed: () async {
                                setState(() => _isDobEditing = true);
                                await _selectDateOfBirth(context);
                              },
                              validator: (v) => v == null || v.trim().isEmpty ? 'Insira sua data.' : null,
                              readOnly: true,
                              suffixIcon: _isDobEditing ? Icons.calendar_month : null,
                              onTap: _isDobEditing ? () => _selectDateOfBirth(context) : null,
                            ),
                            const SizedBox(height: 32),

                            _ProfileField(
                              label: 'Senha:',
                              controller: TextEditingController(text: '********'),
                              isEditing: false,
                              onEditPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcionalidade de troca de senha a ser implementada.'),
                                  backgroundColor: Colors.blueAccent,
                                ),
                              ),
                              readOnly: true,
                            ),
                            const Spacer(),

                            Center(
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: _cOrange)
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _cOrange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        minimumSize: const Size(280, 50),
                                      ),
                                      onPressed: (_isNameEditing || _isDobEditing) ? _saveProfile : null,
                                      child: const Text(
                                        'CLIQUE PARA SALVAR TODAS AS ALTERAÇÕES',
                                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
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

// ===================================================================
// =================== WIDGETS AUXILIARES ====================
// ===================================================================
// DICA DE MESTRE: Mova estes widgets (_ProfileField, _Sidebar, _SideItem)
// para arquivos separados na pasta `lib/widgets/` para organizar melhor!
// ===================================================================

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.onEditPressed,
    required this.readOnly,
    this.validator,
    this.suffixIcon,
    this.onTap,
  });

  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onEditPressed;
  final String? Function(String?)? validator;
  final bool readOnly;
  final IconData? suffixIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _cTeal, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                readOnly: readOnly,
                onTap: onTap,
                validator: validator,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _cTeal, width: 1.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _cTeal, width: 1.5)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: _cTeal, width: 2.5)),
                  suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: _cTeal) : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(color: _cTeal, fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 160,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: onEditPressed,
                child: const Text('Clique para editar', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Sidebar extends StatefulWidget {
  const _Sidebar({required this.onTapIndex, required this.selectedIndex});
  final void Function(int index) onTapIndex;
  final int selectedIndex;

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedIndex;
    return Container(
      width: 190,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cTeal, width: 2.5),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0, right: 0, top: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.asset('assets/images/FrenteLogo.png', fit: BoxFit.cover, height: 80, errorBuilder: (_, __, ___) => ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(24)), child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover, height: 80))),
            ),
          ),
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              child: Image.asset('assets/images/TrasLogo.png', fit: BoxFit.cover, height: 90, errorBuilder: (_, __, ___) => ClipRRect(borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)), child: Image.asset('assets/images/Logo.png', fit: BoxFit.cover, height: 90))),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 90, 12, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SideItem(label: 'Home', selected: selected == 0, onTap: () => widget.onTapIndex(0)),
                  _SideItem(label: 'Movimentação', selected: selected == 1, onTap: () => widget.onTapIndex(1)),
                  _SideItem(label: 'Histórico', selected: selected == 2, onTap: () => widget.onTapIndex(2)),
                  _SideItem(label: 'Perfil', selected: selected == 3, onTap: () => widget.onTapIndex(3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseText = TextStyle(fontSize: 16, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, letterSpacing: 0.2, color: selected ? _cTeal : Colors.black87);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: selected ? _cTeal.withOpacity(0.10) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            AnimatedContainer(duration: const Duration(milliseconds: 180), width: 4, height: 28, decoration: BoxDecoration(color: selected ? _cTeal : Colors.transparent, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 10),
            Expanded(child: Text(label.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: baseText)),
          ],
        ),
      ),
    );
  }
}
