import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateCheckinDto } from './dto/create-checkin.dto';

@Injectable()
export class CheckinsService {
  constructor(private supabaseService: SupabaseService) {}

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
}
