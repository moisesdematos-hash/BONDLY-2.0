import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/checkins_provider.dart';
import '../../relationship/domain/relationship_provider.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  int _selectedMood = 3;
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'value': 1, 'label': 'Péssimo', 'icon': Icons.sentiment_very_dissatisfied, 'color': Color(0xFFF87171)},
    {'value': 2, 'label': 'Triste', 'icon': Icons.sentiment_dissatisfied, 'color': Color(0xFFFB923C)},
    {'value': 3, 'label': 'Ok', 'icon': Icons.sentiment_neutral, 'color': Color(0xFFFBBF24)},
    {'value': 4, 'label': 'Bem', 'icon': Icons.sentiment_satisfied, 'color': Color(0xFF4ADE80)},
    {'value': 5, 'label': 'Incrível', 'icon': Icons.sentiment_very_satisfied, 'color': Color(0xFF2DD4BF)},
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
      if (relationshipId != null) {
        ref.read(checkinsProvider.notifier).fetchPartnerStatus(relationshipId);
        ref.read(checkinsProvider.notifier).fetchHistory(relationshipId);
      }
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkinsProvider);
    final relationshipId = ref.watch(relationshipProvider).selectedRelationship?['id'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Check-in Emocional'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPartnerStatus(state),
                const SizedBox(height: 40),
                const Text(
                  'Como está seu coração no relacionamento hoje?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildMoodSelector(),
                const SizedBox(height: 48),
                _buildNoteInput(),
                const SizedBox(height: 40),
                _buildSaveButton(state, relationshipId),
                if (state.history.isNotEmpty) ...[
                  const SizedBox(height: 56),
                  _buildHistorySection(state),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerStatus(CheckinsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            state.partnerCheckedInToday ? Icons.stars : Icons.hourglass_empty,
            color: state.partnerCheckedInToday ? Colors.amberAccent : Colors.white38,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            state.partnerCheckedInToday 
              ? 'Seu parceiro já abriu o coração hoje! ✨' 
              : 'Aguardando o check-in do parceiro...',
            style: TextStyle(
              color: state.partnerCheckedInToday ? Colors.white : Colors.white38,
              fontSize: 14,
              fontWeight: state.partnerCheckedInToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _moods.map((mood) => _buildMoodItem(mood)).toList(),
        );
      },
    );
  }

  Widget _buildMoodItem(Map<String, dynamic> mood) {
    final isSelected = _selectedMood == mood['value'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = mood['value']),
      child: Column(
        children: [
          AnimatedScale(
            scale: isSelected ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? mood['color'].withOpacity(0.2) : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? mood['color'] : Colors.white10,
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: mood['color'].withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  )
                ] : [],
              ),
              child: Icon(
                mood['icon'],
                size: 28,
                color: isSelected ? mood['color'] : Colors.white38,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isSelected ? mood['label'] : '',
            style: TextStyle(
              fontSize: 12,
              color: mood['color'],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alguma nota sobre hoje? (Opcional)',
          style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Como foi a conexão hoje...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(CheckinsState state, String? relationshipId) {
    return ElevatedButton(
      onPressed: state.isLoading || relationshipId == null
          ? null
          : () async {
              await ref.read(checkinsProvider.notifier).saveCheckin(
                    relationshipId: relationshipId,
                    mood: _selectedMood,
                    note: _noteController.text.trim(),
                  );
              if (mounted && state.error == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Check-in salvo! Que seu dia seja incrível. ❤️')),
                );
                Navigator.pop(context);
              }
            },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 8,
      ),
      child: state.isLoading
          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('Salvar Check-in Diário', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHistorySection(CheckinsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Histórico Recente',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.history.take(5).length,
          itemBuilder: (context, index) {
            final checkin = state.history[index];
            final moodData = _moods.firstWhere((m) => m['value'] == checkin['mood'], orElse: () => _moods[2]);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Icon(moodData['icon'], color: moodData['color'], size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          checkin['note']?.toString().isNotEmpty == true ? checkin['note'] : 'Sem observações',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          checkin['created_at'].toString().substring(0, 10),
                          style: TextStyle(color: Colors.white30, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
