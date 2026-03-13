import 'package:flutter/material.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  int _selectedMood = 3;
  final TextEditingController _noteController = TextEditingController();

  final List<Map<String, dynamic>> _moods = [
    {'value': 1, 'label': 'Péssimo', 'icon': Icons.sentiment_very_dissatisfied, 'color': Colors.red},
    {'value': 2, 'label': 'Triste', 'icon': Icons.sentiment_dissatisfied, 'color': Colors.orange},
    {'value': 3, 'label': 'Neutro', 'icon': Icons.sentiment_neutral, 'color': Colors.amber},
    {'value': 4, 'label': 'Bem', 'icon': Icons.sentiment_satisfied, 'color': Colors.lightGreen},
    {'value': 5, 'label': 'Incrível', 'icon': Icons.sentiment_very_satisfied, 'color': Colors.green},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in Diário')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Como você está se sentindo em relação ao seu relacionamento hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _moods.map((mood) => _buildMoodIcon(mood)).toList(),
            ),
            const SizedBox(height: 48),
            const Text(
              'Quer adicionar uma nota?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Como foi o dia? Algo que queira registrar?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Salvar check-in
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Salvar Check-in', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodIcon(Map<String, dynamic> mood) {
    bool isSelected = _selectedMood == mood['value'];
    return GestureDetector(
      onTap: () => setState(() => _selectedMood = mood['value']),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? mood['color'].withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? mood['color'] : Colors.grey[700]!,
                width: 2,
              ),
            ),
            child: Icon(
              mood['icon'],
              size: 32,
              color: isSelected ? mood['color'] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mood['label'],
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? mood['color'] : Colors.grey[400],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
