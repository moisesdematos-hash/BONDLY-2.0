import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class MemoriesService {
  constructor(private supabaseService: SupabaseService) {}

  async findAll(relationshipId: string) {
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('memories')
      .select('*')
      .eq('relationship_id', relationshipId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }

  async create(relationshipId: string, userId: string, mediaUrl: string, mediaType: string, caption?: string) {
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('memories')
      .insert([
        {
          relationship_id: relationshipId,
          user_id: userId,
          media_url: mediaUrl,
          media_type: mediaType,
          caption: caption,
        },
      ])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async delete(memoryId: string, userId: string) {
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('memories')
      .delete()
      .eq('id', memoryId)
      .eq('user_id', userId) // Only the owner can delete
      .select()
      .single();

    if (error) throw error;
    return data;
  }
}
