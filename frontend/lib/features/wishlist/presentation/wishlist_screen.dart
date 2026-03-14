import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/wishlist_provider.dart';
import '../../relationship/domain/relationship_provider.dart';
import '../../../core/theme/bondly_theme.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
      if (relationshipId != null) {
        ref.read(wishlistProvider.notifier).fetchWishlists(relationshipId);
      }
    });
  }

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    
    // Assegura url bem formada
    var cleanUrl = urlString;
    if (!cleanUrl.startsWith('http')) {
      cleanUrl = 'https://$cleanUrl';
    }

    final Uri url = Uri.parse(cleanUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wishlistProvider);
    final relationshipId = ref.watch(relationshipProvider).selectedRelationship?['id'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lista de Desejos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: BondlyTheme.mainGradient),
        child: SafeArea(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.wishlists.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.wishlists.length,
                      itemBuilder: (context, index) {
                        return _buildWishlistCard(state.wishlists[index]);
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => _showAddWishlistDialog(context, relationshipId),
        icon: const Icon(Icons.card_giftcard),
        label: const Text("Adicionar Presente"),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.redeem_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text(
            'Nenhum desejo na vossa lista.',
            style: TextStyle(fontSize: 18, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Acabou-se a dúvida do "O que lhe ofereço?" 😄',
            style: TextStyle(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(dynamic item) {
    final isPurchased = item['is_purchased'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BondlyTheme.glassDecoration(
        opacity: isPurchased ? 0.05 : 0.15,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          isPurchased ? Icons.check_circle : Icons.volunteer_activism,
          color: isPurchased ? Colors.greenAccent : const Color(0xFFEC4899),
          size: 32,
        ),
        title: Text(
          item['title'] ?? 'Sem Título',
          style: TextStyle(
            color: isPurchased ? Colors.white54 : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            decoration: isPurchased ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item['description'] != null && item['description'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item['description'],
                style: const TextStyle(color: Colors.white70),
              ),
            ],
            if (item['link_url'] != null && item['link_url'].isNotEmpty) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _launchUrl(item['link_url']),
                child: Row(
                  children: [
                    const Icon(Icons.link, size: 16, color: Colors.blueAccent),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Ver/Comprar na Loja',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          decoration: TextDecoration.underline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
        trailing: isPurchased
            ? null
            : PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF1E293B),
                onSelected: (value) {
                  if (value == 'mark_purchased') {
                    ref.read(wishlistProvider.notifier).markAsPurchased(item['id']);
                  } else if (value == 'delete') {
                    ref.read(wishlistProvider.notifier).removeWishlist(item['id']);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'mark_purchased',
                    child: Text('Marcar como Comprado', style: TextStyle(color: Colors.white)),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Apagar', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
      ),
    );
  }

  void _showAddWishlistDialog(BuildContext context, String? relationshipId) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final linkController = TextEditingController(); 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Adicionar Desejo', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'O que queres? *',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Detalhes (ex: Tamanho M, Cor Azul)',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: linkController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Link de uma Loja (Opcional)',
                  labelStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (relationshipId != null && titleController.text.isNotEmpty) {
                ref.read(wishlistProvider.notifier).addWishlist(
                      relationshipId,
                      titleController.text,
                      descriptionController.text,
                      linkController.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
