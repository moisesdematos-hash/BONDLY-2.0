import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class QuestionsService {
  constructor(private supabaseService: SupabaseService) {}

  async getDailyQuestion(relationshipType: string, language: string) {
    const supabase = this.supabaseService.getClient();

    // In a real scenario, this would check the current date.
    // For MVP, we'll fetch a random question for this type and language.
    const { data, error } = await supabase
      .from('daily_questions')
      .select('*')
      .eq('relationship_type', relationshipType)
      .eq('language', language)
      .limit(1)
      .single();

    if (error && error.code !== 'PGRST116') throw error;
    
    // If no question found, returned a fallback
    if (!data) {
      return {
        id: null,
        question_text: language === 'pt' 
          ? 'Qual foi o melhor momento que passaram juntos hoje?' 
          : 'What was the best moment you spent together today?',
        relationship_type: relationshipType,
      };
    }

    return data;
  }

  async submitAnswer(questionId: string, userId: string, relationshipId: string, answerText: string) {
    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('daily_answers')
      .insert([
        {
          question_id: questionId,
          user_id: userId,
          relationship_id: relationshipId,
          answer_text: answerText,
        },
      ])
      .select()
      .single();

    if (error) throw error;

    return data;
  }
}
