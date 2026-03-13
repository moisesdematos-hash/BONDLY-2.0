import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { AiService } from '../ai/ai.service';

@Injectable()
export class SimulationService {
  constructor(
    private supabaseService: SupabaseService,
    private aiService: AiService,
  ) {}

  async simulate(context: {
    message: string;
    relationshipType: string;
    userId: string;
    language: string;
    isPremium: boolean;
  }) {
    // 1. Get AI specialized Simulation Feedback
    const aiFeedback = await this.aiService.getSimulationFeedback({
      message: context.message,
      relationshipType: context.relationshipType,
      isPremium: context.isPremium,
      language: context.language,
    });

    // 2. Log simulation
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('conversation_simulations')
      .insert([
        {
          user_id: context.userId,
          simulated_message: context.message,
          feedback: JSON.stringify(aiFeedback),
        },
      ])
      .select()
      .single();

    if (error) throw error;

    return {
      id: data.id,
      ...aiFeedback,
    };
  }


  async getHistory(userId: string) {
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('conversation_simulations')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    return data.map(item => ({
      ...item,
      feedback: JSON.parse(item.feedback),
    }));
  }
}
