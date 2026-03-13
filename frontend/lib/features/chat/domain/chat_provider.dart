import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/chat_service.dart';

class ChatState {
  final bool isLoading;
  final List<dynamic> messages;
  final String? error;

  ChatState({
    this.isLoading = false,
    this.messages = const [],
    this.error,
  });

  ChatState copyWith({
    bool? isLoading,
    List<dynamic>? messages,
    String? error,
  }) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      messages: messages ?? this.messages,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  RealtimeChannel? _channel;

  ChatNotifier(this._chatService) : super(ChatState());

  Future<void> initChat(String relationshipId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Fetch history
      final messages = await _chatService.getMessages(relationshipId);
      state = state.copyWith(isLoading: false, messages: messages.reversed.toList());

      // 2. Subscribe to realtime
      _channel = Supabase.instance.client
          .channel('public:messages:relationship_id=eq.$relationshipId')
          .on(
            RealtimeListenTypes.postgresChanges,
            ChannelFilter(
              event: 'INSERT',
              schema: 'public',
              table: 'messages',
              filter: 'relationship_id=eq.$relationshipId',
            ),
            (payload, [ref]) {
              final newMessage = payload['new'];
              state = state.copyWith(
                messages: [newMessage, ...state.messages],
              );
            },
          )
          .subscribe();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendMessage(String relationshipId, String content) async {
    try {
      await _chatService.sendMessage(
        relationshipId: relationshipId,
        content: content,
      );
      // O realtime cuidará de adicionar a mensagem na lista
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatNotifier(chatService);
});
