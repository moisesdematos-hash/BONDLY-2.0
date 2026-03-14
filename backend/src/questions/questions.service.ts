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

    // 1. Get all questions for this type and language to rotate
    const { data: questions, error: questionsError } = await supabase
      .from('daily_questions')
      .select('*')
      .eq('relationship_type', relationshipType)
      .eq('language', language)
      .order('created_at', { ascending: true });

    if (questionsError) throw questionsError;
    
    let question;
    if (!questions || questions.length === 0) {
      question = {
        id: 'fallback-01',
        question_text: language === 'pt' 
          ? 'Qual é a sua lembrança favorita de nós dois ultimamente?' 
          : 'What is your favorite recent memory of us?',
        relationship_type: relationshipType,
      };
    } else {
      // Rotation logic: pick one based on the day of the year
      const now = new Date();
      const start = new Date(now.getFullYear(), 0, 0);
      const diff = (now.getTime() - start.getTime()) + ((start.getTimezoneOffset() - now.getTimezoneOffset()) * 60 * 1000);
      const oneDay = 1000 * 60 * 60 * 24;
      const dayOfYear = Math.floor(diff / oneDay);
      
      question = questions[dayOfYear % questions.length];
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
