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
        title: const Text('Diário de Gratidão ✨'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: BondlyTheme.mainGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildSummaryHeader(state.entries),
              Expanded(
                child: state.isLoading && state.entries.isEmpty
                    ? const BondlyLoadingWidget(message: 'A sintonizar gratidão...')
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: state.entries.length,
                        itemBuilder: (context, index) {
                          final entry = state.entries[index];
                          return _GratitudeEntryCard(
                            entry: entry,
                            onPlay: () {
                              HapticFeedback.lightImpact();
                              _playAudio(entry['audio_url']);
                            },
                            onDelete: () {
                              HapticFeedback.warningAlaram();
                              ref.read(gratitudeProvider.notifier).deleteEntry(entry['id'], relId!);
                            },
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
      child: BondlyCard(
        padding: 20,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BondlyTheme.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: BondlyTheme.accent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entries.length} Momentos Guardados',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Reouvir cria memórias eternas.',
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
        color: Colors.black.withOpacity(0.2),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Column(
        children: [
          GestureDetector(
            onLongPressStart: (_) {
              HapticFeedback.mediumImpact();
              _startRecording();
            },
            onLongPressEnd: (_) {
              HapticFeedback.heavyImpact();
              _stopRecording();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(_isRecording ? 30 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording ? BondlyTheme.error : BondlyTheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: (_isRecording ? BondlyTheme.error : BondlyTheme.primary).withOpacity(0.3),
                    blurRadius: _isRecording ? 30 : 15,
                    spreadRadius: _isRecording ? 8 : 2,
                  )
                ],
              ),
              child: Icon(
                _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isRecording ? 'A ouvir o teu coração...' : 'Segura para gravar um agradecimento',
            style: TextStyle(
              color: _isRecording ? BondlyTheme.error : Colors.white60,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BondlyCard(
        padding: 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                top: -10,
                child: Icon(
                  isHappy ? Icons.favorite_rounded : Icons.mood_rounded,
                  size: 90,
                  color: (isHappy ? BondlyTheme.accent : BondlyTheme.secondary).withOpacity(0.03),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: entry['user']['avatar_url'] != null
                              ? NetworkImage(entry['user']['avatar_url'])
                              : null,
                          child: entry['user']['avatar_url'] == null ? const Icon(Icons.person, size: 18) : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          entry['user']['name'] ?? 'Parceiro',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.play_circle_filled_rounded, color: BondlyTheme.primary, size: 36),
                          onPressed: onPlay,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry['transcription'] ?? 'O mestre Whisper está a transcrever...',
                      style: const TextStyle(color: Colors.white, height: 1.5, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(entry['created_at']),
                          style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        GestureDetector(
                          onTap: onDelete,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white24, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day}/${date.month} às ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
