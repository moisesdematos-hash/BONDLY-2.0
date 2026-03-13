import 'package:flutter/material.dart';

class BondlyChatScreen extends StatefulWidget {
  const BondlyChatScreen({super.key});

  @override
  State<BondlyChatScreen> createState() => _BondlyChatScreenState();
}

class _BondlyChatScreenState extends State<BondlyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Oi! Como foi seu dia?',
      'sentiment': 0.8, // Positivo
    },
    {
      'isMe': true,
      'text': 'Foi bem produtivo, mas estou um pouco cansada.',
      'sentiment': 0.6, // Neutro/Levemente positivo
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Parceiro'),
            Text('Clima: Harmonioso ✨', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg['text'], msg['isMe'], msg['sentiment']);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isMe, double sentiment) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF6366F1) : Colors.grey[800],
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(0),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Icon(
              sentiment > 0.7 ? Icons.sentiment_very_satisfied : 
              sentiment < 0.4 ? Icons.sentiment_very_dissatisfied : Icons.sentiment_neutral,
              size: 14,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black26,
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Digite aqui...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF6366F1)),
            onPressed: () {
              if (_messageController.text.isNotEmpty) {
                setState(() {
                  _messages.add({
                    'isMe': true,
                    'text': _messageController.text,
                    'sentiment': 0.7,
                  });
                  _messageController.clear();
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
