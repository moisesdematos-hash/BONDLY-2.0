import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../domain/gratitude_provider.dart';
import '../../relationship/domain/relationship_provider.dart';
import '../../auth/domain/auth_provider.dart';
import '../../../core/theme/bondly_theme.dart';

class GratitudeScreen extends ConsumerStatefulWidget {
  const GratitudeScreen({super.key});

  @override
  ConsumerState<GratitudeScreen> createState() => _GratitudeScreenState();
}

class _GratitudeScreenState extends ConsumerState<GratitudeScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  String? _recordingPath;
  StreamSubscription<RecordState>? _recordSub;

  @override
  void initState() {
    super.initState();
    _recordSub = _audioRecorder.onStateChanged().listen((state) {
      if (mounted) {
        setState(() => _isRecording = state == RecordState.record);
      }
    });
    
    Future.microtask(() {
      final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
      if (relationshipId != null) {
        ref.read(gratitudeProvider.notifier).fetchEntries(relationshipId);
      }
    });
  }

  @override
  void dispose() {
    _recordSub?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _recordingPath = '${directory.path}/gratitude_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const config = RecordConfig();
        await _audioRecorder.start(config, path: _recordingPath!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao gravar: $e')));
    }
  }

  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    if (path != null) {
      final relationshipId = ref.read(relationshipProvider).selectedRelationship?['id'];
      if (relationshipId != null) {
        try {
          await ref.read(gratitudeProvider.notifier).uploadAudio(relationshipId, path);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gratidão enviada com sucesso! ✨')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no envio: $e')));
        }
      }
    }
  }

  void _playAudio(String url) async {
    await _audioPlayer.play(UrlSource(url));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gratitudeProvider);
    final relationshipState = ref.watch(relationshipProvider);
    final relId = relationshipState.selectedRelationship?['id'];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Diário de Gratidão', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: Column(
            children: [
              _buildSummaryHeader(state.entries),
              Expanded(
                child: state.isLoading && state.entries.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFF472B6)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: state.entries.length,
                        itemBuilder: (context, index) {
                          final entry = state.entries[index];
                          return _GratitudeEntryCard(
                            entry: entry,
                            onPlay: () => _playAudio(entry['audio_url']),
                            onDelete: () => ref.read(gratitudeProvider.notifier).deleteEntry(entry['id'], relId!),
                          );
                        },
                      ),
              ),
              _buildRecorderSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(List<dynamic> entries) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BondlyTheme.glassDecoration(opacity: 0.1),
        child: Row(
          children: [
            const Icon(Icons.favorite, color: Color(0xFFF472B6), size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entries.length} Momentos de Gratidão',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Ouvir a gratidão fortalece o vínculo.',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecorderSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          GestureDetector(
            onLongPressStart: (_) => _startRecording(),
            onLongPressEnd: (_) => _stopRecording(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(_isRecording ? 30 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? Colors.redAccent.withOpacity(0.8) : const Color(0xFFF472B6),
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? Colors.redAccent : const Color(0xFFF472B6)).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: _isRecording ? 10 : 2,
                  )
                ],
              ),
              child: Icon(
                _isRecording ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isRecording ? 'Gravando gratidão...' : 'Segure para gravar um agradecimento',
            style: TextStyle(
              color: _isRecording ? Colors.redAccent : Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GratitudeEntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const _GratitudeEntryCard({
    required this.entry,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final score = (entry['sentiment_score'] ?? 0.5) as num;
    final isHappy = score > 0.6;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BondlyTheme.glassDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                isHappy ? Icons.favorite : Icons.sentiment_satisfied,
                size: 80,
                color: (isHappy ? Colors.pink : Colors.teal).withOpacity(0.05),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: entry['user']['avatar_url'] != null
                            ? NetworkImage(entry['user']['avatar_url'])
                            : null,
                        child: entry['user']['avatar_url'] == null ? const Icon(Icons.person, size: 16) : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry['user']['name'] ?? 'Parceiro',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.play_circle_fill, color: Color(0xFFF472B6), size: 32),
                        onPressed: onPlay,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry['transcription'] ?? 'Processando transcrição...',
                    style: const TextStyle(color: Colors.white90, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(entry['created_at']),
                        style: const TextStyle(color: Colors.white24, fontSize: 11),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(Icons.delete_outline, color: Colors.white24, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
