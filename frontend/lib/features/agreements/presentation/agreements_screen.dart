import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/agreements_provider.dart';
import '../../relationship/domain/relationship_provider.dart';
import '../../auth/domain/auth_provider.dart';
import '../../../core/theme/bondly_theme.dart';

class AgreementsScreen extends ConsumerStatefulWidget {
  const AgreementsScreen({super.key});

  @override
  ConsumerState<AgreementsScreen> createState() => _AgreementsScreenState();
}

class _AgreementsScreenState extends ConsumerState<AgreementsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
      if (relationshipId != null) {
        ref.read(agreementsProvider.notifier).fetchAgreements(relationshipId);
      }
    });
  }

  void _showAddAgreementDialog(BuildContext context, String relationshipId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Propor Novo Acordo 🤝', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Título da Regra',
                labelStyle: TextStyle(color: Colors.white60),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Descrição / Motivo (Opcional)',
                labelStyle: TextStyle(color: Colors.white60),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2DD4BF)),
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                ref.read(agreementsProvider.notifier).proposeAgreement(
                      relationshipId,
                      title,
                      descriptionController.text.trim(),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Propor Parceiro', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agreementsProvider);
    final relationshipState = ref.watch(relationshipProvider);
    final authState = ref.watch(authProvider);
    final relId = relationshipState.selectedRelationship?['id'];

    if (relId == null) return const Scaffold(body: Center(child: Text('Nenhum relacionamento')));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Acordos do Casal', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: state.isLoading && state.agreements.isEmpty
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2DD4BF)))
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: state.agreements.length,
                  itemBuilder: (context, index) {
                    final agreement = state.agreements[index];
                    return _buildAgreementCard(
                      context: context,
                      agreement: agreement,
                      currentUserId: authState.user?['id'],
                      relationshipId: relId,
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAgreementDialog(context, relId),
        backgroundColor: const Color(0xFF2DD4BF),
        icon: const Icon(Icons.handshake, color: Colors.black),
        label: const Text('Novo Acordo', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAgreementCard({
    required BuildContext context,
    required Map<String, dynamic> agreement,
    required String? currentUserId,
    required String relationshipId,
  }) {
    final isAgreed = agreement['is_agreed'] == true;
    final isCreator = agreement['created_by'] == currentUserId;
    
    // Mostar botão de Aceitar apenas se: não foi acordado e o currentUser NÃO for o criador
    final canAgree = !isAgreed && !isCreator;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BondlyTheme.glassDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  agreement['title'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isAgreed ? const Color(0xFF2DD4BF) : Colors.amber,
                    decoration: isAgreed ? null : TextDecoration.none, // Retirado rasurado
                  ),
                ),
              ),
              if (isAgreed)
                const Icon(Icons.check_circle, color: Color(0xFF2DD4BF), size: 28)
              else
                const Icon(Icons.pending_actions, color: Colors.amber, size: 28),
            ],
          ),
          if (agreement['description'] != null && agreement['description'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              agreement['description'],
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Proposto por: ${agreement['creator']?['name']?.split(' ')[0] ?? 'Alguém'}',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              Row(
                children: [
                  if (canAgree)
                    TextButton.icon(
                      onPressed: () async {
                        try {
                          await ref.read(agreementsProvider.notifier).agreeToRule(agreement['id'], relationshipId);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      icon: const Icon(Icons.handshake, color: Color(0xFF2DD4BF), size: 18),
                      label: const Text('Aceitar Acordo', style: TextStyle(color: Color(0xFF2DD4BF))),
                    )
                  else if (!isAgreed && isCreator)
                    const Text('Aguardar Parceiro', style: TextStyle(color: Colors.amber, fontSize: 12, fontStyle: FontStyle.italic)),
                  
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                    onPressed: () {
                      ref.read(agreementsProvider.notifier).deleteAgreement(agreement['id'], relationshipId);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
