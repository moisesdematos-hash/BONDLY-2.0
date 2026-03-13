import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bondly AI Coach'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionCard(
              context,
              title: 'Check-in Emocional',
              subtitle: 'Como você está se sentindo hoje?',
              icon: Icons.mood,
              color: Colors.pinkAccent,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Pergunta do Dia',
              subtitle: 'Fortaleça sua conexão com uma conversa profunda.',
              icon: Icons.question_answer,
              color: Colors.blueAccent,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Chat com Parceiro',
              subtitle: 'AI-Enhanced chat para melhor comunicação.',
              icon: Icons.chat_bubble,
              color: Colors.greenAccent,
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              title: 'Simulador de Conversa',
              subtitle: 'Pratique conversas difíceis com feedback de IA.',
              icon: Icons.psychology,
              color: Colors.orangeAccent,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const Text(
              'Desafios da Semana',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChallengeList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildChallengeList() {
    return Column(
      children: [
        _buildChallengeItem('Elogio Diário', 'Dê um elogio genuíno para seu parceiro hoje.', 10),
        _buildChallengeItem('Noite sem Telas', 'Passem 2 horas juntos sem eletrônicos.', 50),
      ],
    );
  }

  Widget _buildChallengeItem(String title, String description, int points) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Chip(
          label: Text('+$points pts'),
          backgroundColor: Colors.amber.withOpacity(0.2),
        ),
      ),
    );
  }
}
