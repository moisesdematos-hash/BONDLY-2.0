import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { AiService } from '../ai/ai.service';

@Injectable()
export class ChatService {
  constructor(
    private supabaseService: SupabaseService,
    private aiService: AiService,
  ) {}

  async sendMessage(userId: string, relationshipId: string, content: string) {
    const supabase = this.supabaseService.getClient();

    // 1. Analyze Sentiment
    const sentiment = await this.aiService.analyzeSentiment(content);

    // 2. Save Message
    const { data, error } = await supabase
      .from('messages')
      .insert([
        {
          sender_id: userId,
          relationship_id: relationshipId,
          content: content,
          sentiment_score: sentiment.score,
        },
      ])
      .select()
      .single();

    if (error) throw error;

    return {
      ...data,
      sentiment_label: sentiment.label,
    };
  }

  async getMessages(relationshipId: string, limit: number = 50) {
    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('messages')
      .select(`
        *,
        sender:users(id, name)
      `)
      .eq('relationship_id', relationshipId)
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw error;

    return data;
  }
}
