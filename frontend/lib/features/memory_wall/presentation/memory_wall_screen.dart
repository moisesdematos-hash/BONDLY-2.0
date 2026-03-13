import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/memory_provider.dart';
import '../../relationship/domain/relationship_provider.dart';
import '../../../core/theme/bondly_theme.dart';

class MemoryWallScreen extends ConsumerStatefulWidget {
  const MemoryWallScreen({super.key});

  @override
  ConsumerState<MemoryWallScreen> createState() => _MemoryWallScreenState();
}

class _MemoryWallScreenState extends ConsumerState<MemoryWallScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
      if (relationshipId != null) {
        ref.read(memoryProvider.notifier).fetchMemories(relationshipId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(memoryProvider);
    final relationshipId = ref.watch(relationshipProvider).selectedRelationship?['id'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mural de Memórias'),
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
              : state.memories.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: state.memories.length,
                      itemBuilder: (context, index) {
                        return _buildMemoryCard(state.memories[index]);
                      },
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => _showAddMemoryDialog(context, relationshipId),
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 20),
          const Text(
            'Nenhuma memória ainda.',
            style: TextStyle(fontSize: 18, color: Colors.white54),
          ),
          const SizedBox(height: 8),
          const Text(
            'Suba a primeira foto de vocês!',
            style: TextStyle(fontSize: 14, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(dynamic memory) {
    return Container(
      decoration: BondlyTheme.glassDecoration(opacity: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Image.network(
                memory['image_url'],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white10,
                  child: const Icon(Icons.broken_image, color: Colors.white24),
                ),
              ),
            ),
          ),
          if (memory['caption'] != null && memory['caption'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                memory['caption'],
                style: const TextStyle(fontSize: 13, color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _showAddMemoryDialog(BuildContext context, String? relationshipId) {
    final captionController = TextEditingController();
    final urlController = TextEditingController(); // Simulado para MVP, em produção seria picker + storage

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Nova Memória', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'URL da Imagem',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: captionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Legenda',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (relationshipId != null && urlController.text.isNotEmpty) {
                ref.read(memoryProvider.notifier).addMemory(
                      relationshipId,
                      urlController.text,
                      captionController.text,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
