import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

import { GardenService } from '../garden/garden.service';

@Injectable()
export class QuestionsService {
  constructor(
    private supabaseService: SupabaseService,
    private gardenService: GardenService,
  ) {}


  async getDailyQuestion(userId: string, relationshipId: string, relationshipType: string, language: string) {
    const supabase = this.supabaseService.getClient();

    // 1. Get current daily question
    const { data: question, error: questionError } = await supabase
      .from('daily_questions')
      .select('*')
      .eq('relationship_type', relationshipType)
      .eq('language', language)
      .limit(1)
      .single();

    if (questionError && questionError.code !== 'PGRST116') throw questionError;
    
    if (!question) {
      return {
        id: 'fallback-01',
        question_text: language === 'pt' 
          ? 'Qual é a sua lembrança favorita de nós dois ultimamente?' 
          : 'What is your favorite recent memory of us?',
        relationship_type: relationshipType,
        user_answered: false,
        partner_answered: false,
      };
    }


    // 2. Check user's answer
    const { data: userAnswer } = await supabase
      .from('daily_answers')
      .select('*')
      .eq('question_id', question.id)
      .eq('user_id', userId)
      .single();

    // 3. Check partner's answer
    const { data: partnerAnswer } = await supabase
      .from('daily_answers')
      .select('*')
      .eq('question_id', question.id)
      .eq('relationship_id', relationshipId)
      .neq('user_id', userId)
      .single();

    return {
      ...question,
      user_answered: !!userAnswer,
      user_answer_text: userAnswer?.answer_text,
      partner_answered: !!partnerAnswer,
      partner_answer: (!!userAnswer && !!partnerAnswer) ? partnerAnswer.answer_text : null,
    };
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

    await this.gardenService.addXp(relationshipId, 50);

    return data;
  }

}
