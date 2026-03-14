import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/chat_provider.dart';
import '../../auth/domain/auth_provider.dart';
import '../../relationship/domain/relationship_provider.dart';

class BondlyChatScreen extends ConsumerStatefulWidget {
  const BondlyChatScreen({super.key});

  @override
  ConsumerState<BondlyChatScreen> createState() => _BondlyChatScreenState();
}

class _BondlyChatScreenState extends ConsumerState<BondlyChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
      if (relationshipId != null) {
        ref.read(chatProvider.notifier).initChat(relationshipId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final relationshipState = ref.watch(relationshipProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(relationshipState),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: _buildMessageList(chatState, authState),
              ),
              _buildInputArea(relationshipState),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(RelationshipState state) {
    return AppBar(
      backgroundColor: Colors.black.withOpacity(0.2),
      elevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
            child: const Icon(Icons.favorite, size: 16, color: Color(0xFF6366F1)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.selectedRelationship?['name'] ?? 'Chat',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.greenAccent),
                  SizedBox(width: 4),
                  Text('Clima: Positivo', style: TextStyle(fontSize: 10, color: Colors.white60)),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
      actions: [
        IconButton(
          icon: const Icon(Icons.ac_unit, color: Colors.cyanAccent),
          tooltip: 'Icebreaker (SOS)',
          onPressed: () {
            final relId = state.selectedRelationship?['id'];
            if (relId != null) {
              _triggerIcebreaker(context, relId);
            }
          },
        ),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }

  Future<void> _triggerIcebreaker(BuildContext context, String relationshipId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.cyan)),
    );

    try {
      // 1. Chamar Endpoint do NestJS
      import '../../../core/network/api_client.dart';
      final response = await ApiClient.post('/relationships/$relationshipId/icebreaker', {});
      
      if (mounted) {
        Navigator.pop(context); // Fechar loading
        
        final msg = response['message'] as String?;
        if (msg != null && msg.isNotEmpty) {
          // Mostrar num belo Dialog de "desafio para quebrar o gelo"
          _showIcebreakerDialog(context, msg);
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ativar Icebreaker: $e')),
        );
      }
    }
  }

  void _showIcebreakerDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.cyanAccent)),
        title: const Row(
          children: [
            Icon(Icons.ac_unit, color: Colors.cyanAccent),
            SizedBox(width: 8),
            Text('O Gelo Quebrou!', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido! 😄', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState chatState, AuthState authState) {
    if (chatState.isLoading && chatState.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final msg = chatState.messages[index];
        final isMe = msg['sender_id'] == authState.user?['id'];
        return _ChatBubble(
          message: msg,
          isMe: isMe,
        );
      },
    );
  }

  Widget _buildInputArea(RelationshipState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          _ActionButton(icon: Icons.add, onTap: () {}),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Fale com o coração...',
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _SendButton(
            onTap: () {
              final content = _messageController.text.trim();
              final relId = state.selectedRelationship?['id'];
              if (content.isNotEmpty && relId != null) {
                ref.read(chatProvider.notifier).sendMessage(relId, content);
                _messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final sentiment = (message['sentiment_score'] ?? 0.5);
    final isNegative = sentiment < 0.4;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                const CircleAvatar(radius: 12, backgroundColor: Colors.white10),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe 
                      ? const Color(0xFF6366F1) 
                      : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 20),
                    ),
                    boxShadow: isMe ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : [],
                  ),
                  child: Text(
                    message['content'] ?? '',
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.white.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 8),
                _SentimentIndicator(score: sentiment),
              ],
            ],
          ),
          if (message['meta']?['tip'] != null && isMe) 
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 30),
              child: Text(
                '💡 ${message['meta']['tip']}',
                style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }
}

class _SentimentIndicator extends StatelessWidget {
  final double score;
  const _SentimentIndicator({required this.score});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.white24;
    IconData icon = Icons.sentiment_neutral;
    
    if (score > 0.7) {
      color = const Color(0xFF2DD4BF);
      icon = Icons.sentiment_very_satisfied;
    } else if (score < 0.4) {
      color = const Color(0xFFF87171);
      icon = Icons.sentiment_very_dissatisfied;
    }

    return Icon(icon, size: 14, color: color);
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white60, size: 20),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFF6366F1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}
