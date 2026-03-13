import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

import { GardenService } from '../garden/garden.service';

@Injectable()
export class ChallengesService {
  constructor(
    private supabaseService: SupabaseService,
    private gardenService: GardenService,
  ) {}


  async findAll(userId: string, isPremium: boolean) {
    const supabase = this.supabaseService.getClient();
    
    // Get all challenges
    let challengesQuery = supabase.from('challenges').select('*');
    if (!isPremium) {
      challengesQuery = challengesQuery.eq('premium_only', false);
    }
    const { data: challenges, error: challengesError } = await challengesQuery;
    if (challengesError) throw challengesError;

    // Get current user participations
    const { data: participations, error: participationsError } = await supabase
      .from('challenge_participation')
      .select('*')
      .eq('user_id', userId);
    
    if (participationsError) throw participationsError;

    // Map participation to challenges
    return challenges.map(challenge => {
      const participation = participations.find(p => p.challenge_id === challenge.id);
      return {
        ...challenge,
        participation: participation || null,
      };
    });
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

    if (challenge) {
      await supabase.from('achievements').insert([
        {
          user_id: userId,
          type: 'challenge_completed',
          points: challenge.points,
        },
      ]);

      // Award Garden XP
      const { data: space } = await supabase
        .from('relationship_spaces')
        .select('relationship_id')
        .eq('user_id', userId)
        .single();
      
      if (space) {
        await this.gardenService.addXp(space.relationship_id, 100);
      }
    }



    return data;
  }

  async findAllAchievements(userId: string) {
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('achievements')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }
}

