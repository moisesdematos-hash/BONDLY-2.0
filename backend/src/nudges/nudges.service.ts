import { Injectable } from '@nestjs/common';
import { AiService } from '../ai/ai.service';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class NudgesService {
  constructor(
    private aiService: AiService,
    private supabaseService: SupabaseService,
  ) {}

  async getNudge(relationshipId: string, currentUserId: string, language: string = 'pt') {
    const supabase = this.supabaseService.getClient();

    // 1. Fetch relationship info
    const { data: relationship } = await supabase
      .from('relationships')
      .select('*')
      .eq('id', relationshipId)
      .single();

    if (!relationship) return { nudge: null };

    // 2. Fetch partner's ID
    const { data: spaces } = await supabase
      .from('relationship_spaces')
      .select('user_id')
      .eq('relationship_id', relationshipId);
    
    const partnerId = spaces?.find(s => s.user_id !== currentUserId)?.user_id;

    // 3. Fetch partner's latest mood
    let partnerMood: string | undefined;
    if (partnerId) {
      const { data: checkin } = await supabase
        .from('emotional_checkins')
        .select('mood')
        .eq('user_id', partnerId)
        .order('created_at', { ascending: false })
        .limit(1)
        .single();
      partnerMood = checkin?.mood;
    }

    // 4. Fetch garden health
    const { data: garden } = await supabase
      .from('garden_stats')
      .select('health')
      .eq('relationship_id', relationshipId)
      .single();

    // 5. Generate Nudge
    return this.aiService.generateNudge({
      partnerMood,
      gardenHealth: garden?.health || 100,
      relationshipType: relationship.type,
      language,
    });
  }
}
