import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class GardenService {
  constructor(private supabaseService: SupabaseService) {}

  async getGardenStats(relationshipId: string) {
    const supabase = this.supabaseService.getClient();
    
    // Check if entry exists, if not create it
    let { data, error } = await supabase
      .from('garden_stats')
      .select('*')
      .eq('relationship_id', relationshipId)
      .single();

    if (error && error.code === 'PGRST116') { // Record not found
      const { data: newData, error: insertError } = await supabase
        .from('garden_stats')
        .insert([{ relationship_id: relationshipId }])
        .select()
        .single();
      
      if (insertError) throw insertError;
      return newData;
    }

    if (error) throw error;

    // Apply health decay if needed
    if (data.last_activity_at) {
      const lastActivity = new Date(data.last_activity_at).getTime();
      const now = new Date().getTime();
      const hoursSinceActivity = (now - lastActivity) / (1000 * 60 * 60);

      if (hoursSinceActivity > 24) {
        const decayAmount = Math.floor(hoursSinceActivity - 24);
        const newHealth = Math.max(0, data.health - decayAmount);
        
        if (newHealth < data.health) {
          const { data: updatedData } = await supabase
            .from('garden_stats')
            .update({ health: newHealth, updated_at: new Date().toISOString() })
            .eq('id', data.id)
            .select()
            .single();
          return updatedData || data;
        }
      }
    }

    return data;
  }


  async addXp(relationshipId: string, amount: number) {
    const supabase = this.supabaseService.getClient();
    const stats = await this.getGardenStats(relationshipId);

    let newXp = stats.xp + amount;
    let newLevel = stats.level;
    
    while (newXp >= newLevel * 100) {
      newXp -= newLevel * 100;
      newLevel += 1;
    }


    const { data, error } = await supabase
      .from('garden_stats')
      .update({
        xp: newXp,
        level: newLevel,
        health: Math.min(100, stats.health + 5), // Reward health on activity
        last_activity_at: new Date().toISOString(),
        updated_at: new Date().toISOString(),
      })
      .eq('relationship_id', relationshipId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }
}
