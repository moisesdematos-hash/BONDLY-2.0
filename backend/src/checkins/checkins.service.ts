import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateCheckinDto } from './dto/create-checkin.dto';

import { GardenService } from '../garden/garden.service';

@Injectable()
export class CheckinsService {
  constructor(
    private supabaseService: SupabaseService,
    private gardenService: GardenService,
  ) {}

  async create(createCheckinDto: CreateCheckinDto, userId: string) {

    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('emotional_checkins')
      .insert([
        {
          user_id: userId,
          relationship_id: createCheckinDto.relationship_id,
          mood: createCheckinDto.mood,
          note: createCheckinDto.note,
        },
      ])
      .select()
      .single();

    if (error) throw error;

    await this.gardenService.addXp(createCheckinDto.relationship_id, 20);

    return data;
  }


  async findAllForRelationship(relationshipId: string) {
    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('emotional_checkins')
      .select('*')
      .eq('relationship_id', relationshipId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    return data;
  }

  async findPersonalHistory(userId: string) {
    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('emotional_checkins')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    return data;
  }

  async getPartnerStatus(relationshipId: string, userId: string) {
    const supabase = this.supabaseService.getClient();
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const { data, error } = await supabase
      .from('emotional_checkins')
      .select('id')
      .eq('relationship_id', relationshipId)
      .neq('user_id', userId)
      .gte('created_at', today.toISOString())
      .limit(1);

    if (error) throw error;

    return {
      partner_checked_in: data.length > 0,
    };
  }
}

