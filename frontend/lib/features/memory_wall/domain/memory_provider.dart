import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/memory_service.dart';

class MemoryState {
  final List<dynamic> memories;
  final bool isLoading;
  final String? error;

  MemoryState({
    this.memories = const [],
    this.isLoading = false,
    this.error,
  });

  MemoryState copyWith({
    List<dynamic>? memories,
    bool? isLoading,
    String? error,
  }) {
    return MemoryState(
      memories: memories ?? this.memories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class MemoryNotifier extends StateNotifier<MemoryState> {
  final MemoryService _memoryService;

  MemoryNotifier(this._memoryService) : super(MemoryState());

  Future<void> fetchMemories(String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final memories = await _memoryService.getMemories(relationshipId);
      state = state.copyWith(memories: memories, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addMemory(String relationshipId, String mediaUrl, String mediaType, String? caption) async {
    try {
      final newMemory = await _memoryService.createMemory(relationshipId, mediaUrl, mediaType, caption);
      state = state.copyWith(memories: [newMemory, ...state.memories]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeMemory(String id) async {
    try {
      await _memoryService.deleteMemory(id);
      state = state.copyWith(
        memories: state.memories.where((m) => m['id'] != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final memoryProvider = StateNotifierProvider<MemoryNotifier, MemoryState>((ref) {
  final service = ref.watch(memoryServiceProvider);
  return MemoryNotifier(service);
});
