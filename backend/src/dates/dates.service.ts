import { Injectable } from '@nestjs/common';
import { AiService } from '../ai/ai.service';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class DatesService {
  constructor(
    private aiService: AiService,
    private supabaseService: SupabaseService,
  ) {}

  async getSuggestions(relationshipId: string, language: string = 'pt') {
    const supabase = this.supabaseService.getClient();

    // 1. Fetch relationship info
    const { data: relationship } = await supabase
      .from('relationships')
      .select('*')
      .eq('id', relationshipId)
      .single();

    if (!relationship) throw new Error('Relacionamento não encontrado');

    // 2. Fetch recent moods for context
    const { data: checkins } = await supabase
      .from('emotional_checkins')
      .select('mood')
      .eq('relationship_id', relationshipId)
      .order('created_at', { ascending: false })
      .limit(5);

    const moods = checkins?.map(c => c.mood) || [];

    // 3. Generate suggestions via AI
    return this.aiService.generateDateSuggestions({
      relationshipType: relationship.type,
      recentMoods: moods,
      language,
      isPremium: true, // For now, could be based on relationship/user status
    });
  }
}
