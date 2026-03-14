import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/relationship_provider.dart';

class RelationshipSetupScreen extends ConsumerStatefulWidget {
  const RelationshipSetupScreen({super.key});

  @override
  ConsumerState<RelationshipSetupScreen> createState() => _RelationshipSetupScreenState();
}

class _RelationshipSetupScreenState extends ConsumerState<RelationshipSetupScreen> {
  String _selectedType = 'casal';
  final _nameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _isJoining = false;

  final List<Map<String, dynamic>> _types = [
    {'value': 'casal', 'label': 'Casal', 'icon': Icons.favorite},
    {'value': 'amizade', 'label': 'Amizade Íntima', 'icon': Icons.people},
    {'value': 'familia', 'label': 'Família', 'icon': Icons.home},
    {'value': 'colegas', 'label': 'Colegas Próximos', 'icon': Icons.work},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relState = ref.watch(relationshipProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurar Relacionamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isJoining = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isJoining ? const Color(0xFF6366F1) : Colors.grey[800],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Criar Novo'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _isJoining = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isJoining ? const Color(0xFF6366F1) : Colors.grey[800],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Entrar com Código'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (!_isJoining) ...[
              const Text(
                'Que tipo de conexão você quer fortalecer?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ..._types.map((type) => _buildTypeCard(type)).toList(),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Relacionamento (Ex: Nosso Cantinho)',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              const Text(
                'Insira o código enviado pelo seu parceiro',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _inviteCodeController,
                decoration: const InputDecoration(
                  labelText: 'Código de Convite',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.vpn_key),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
            const SizedBox(height: 40),
            if (relState.lastCreatedInviteCode != null) ...[
              const Divider(height: 48),
              const Text(
                'Espaço Criado! 🎉',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Compartilhe este código com seu parceiro para que ele possa entrar:',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF6366F1), width: 2),
                ),
                child: SelectableText(
                  relState.lastCreatedInviteCode!,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: relState.lastCreatedInviteCode!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código copiado para a área de transferência!')),
                  );
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar Código'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF6366F1)),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Ir para o Dashboard'),
              ),
            ] else ...[
              ElevatedButton(
                onPressed: relState.isLoading
                    ? null
                    : () async {
                        if (_isJoining) {
                          await ref.read(relationshipProvider.notifier).joinRelationship(
                                _inviteCodeController.text.trim(),
                              );
                          if (mounted && relState.error == null) {
                            Navigator.pushReplacementNamed(context, '/dashboard');
                          }
                        } else {
                          await ref.read(relationshipProvider.notifier).createRelationship(
                                _selectedType,
                                _nameController.text,
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: relState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isJoining ? 'Entrar no Espaço' : 'Começar Jornada'),
              ),
            ],
            if (relState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  relState.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard(Map<String, dynamic> type) {
    bool isSelected = _selectedType == type['value'];
    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF6366F1) : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Icon(type['icon'], color: isSelected ? const Color(0xFF6366F1) : Colors.white60),
        title: Text(
          type['label'],
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF6366F1) : Colors.white,
          ),
        ),
        trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF6366F1)) : null,
        onTap: () => setState(() => _selectedType = type['value']),
      ),
    );
  }
}
