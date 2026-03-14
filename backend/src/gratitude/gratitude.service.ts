import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { AiService } from '../ai/ai.service';

@Injectable()
export class GratitudeService {
  constructor(
    private readonly supabaseService: SupabaseService,
    private readonly aiService: AiService,
  ) {}

  async create(relationshipId: string, userId: string, file: Express.Multer.File) {
    const supabase = this.supabaseService.getClient();
    const fileExt = file.originalname.split('.').pop();
    const fileName = `${relationshipId}/${userId}_${Date.now()}.${fileExt}`;

    // 1. Upload to Supabase Storage
    const { data: storageData, error: storageError } = await supabase.storage
      .from('gratitude-audios')
      .upload(fileName, file.buffer, {
        contentType: file.mimetype,
        upsert: true,
      });

    if (storageError) throw new Error(`Falha no upload do áudio: ${storageError.message}`);

    const audioUrl = supabase.storage.from('gratitude-audios').getPublicUrl(fileName).data.publicUrl;

    // 2. Transcribe with Whisper
    const transcription = await this.aiService.transcribeAudio(file.buffer, file.originalname);

    // 3. Analyze Sentiment
    const sentiment = await this.aiService.analyzeSentiment(transcription);

    // 4. Save to Database
    const { data, error } = await supabase
      .from('gratitude_entries')
      .insert([
        {
          relationship_id: relationshipId,
          user_id: userId,
          audio_url: audioUrl,
          transcription: transcription,
          sentiment_score: sentiment.score || 0.5,
        },
      ])
      .select()
      .single();

    if (error) throw new Error(`Falha ao guardar gratidão: ${error.message}`);
    return data;
  }

  async findAllByRelationship(relationshipId: string) {
    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('gratitude_entries')
      .select(`
        *,
        user:users!user_id(id, name, avatar_url)
      `)
      .eq('relationship_id', relationshipId)
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    return data;
  }

  async remove(id: string, userId: string) {
    const supabase = this.supabaseService.getClient();
    
    const { error } = await supabase
      .from('gratitude_entries')
      .delete()
      .eq('id', id)
      .eq('user_id', userId);

    if (error) throw new Error(error.message);
    return { success: true };
  }
}
