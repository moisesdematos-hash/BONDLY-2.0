import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class ChallengesService {
  constructor(private supabaseService: SupabaseService) {}

  async findAll(isPremium: boolean) {
    const supabase = this.supabaseService.getClient();
    let query = supabase.from('challenges').select('*');

    if (!isPremium) {
      query = query.eq('premium_only', false);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  }

  async participate(userId: string, challengeId: string) {
    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('challenge_participation')
      .insert([{ user_id: userId, challenge_id: challengeId, status: 'pending' }])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async complete(participationId: string, userId: string) {
    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('challenge_participation')
      .update({ status: 'completed', completed_at: new Date().toISOString() })
      .eq('id', participationId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;

    // Award points
    const { data: challenge } = await supabase
      .from('challenges')
      .select('points')
      .eq('id', data.challenge_id)
      .single();

    await supabase.from('achievements').insert([
      {
        user_id: userId,
        type: 'challenge_completed',
        points: challenge.points,
      },
    ]);

    return data;
  }
}
