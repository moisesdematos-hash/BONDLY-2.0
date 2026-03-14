import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateCheckinDto } from './dto/create-checkin.dto';
import { GardenService } from '../garden/garden.service';
import { AiService } from '../ai/ai.service'; // Importar AiService

@Injectable()
export class CheckinsService {
  constructor(
    private supabaseService: SupabaseService,
    private gardenService: GardenService,
    private aiService: AiService, // Injetar AiService
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

  async generateInsights(relationshipId: string) {
    // 1. Obter todos os check-ins do último mês (limitar para não sobrecarregar prompt)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const supabase = this.supabaseService.getClient();
    const { data: checkins, error } = await supabase
      .from('emotional_checkins')
      .select('user_id, mood, note, created_at')
      .eq('relationship_id', relationshipId)
      .gte('created_at', thirtyDaysAgo.toISOString())
      .order('created_at', { ascending: true }); // Cronológico para a IA

    if (error) throw error;

    if (!checkins || checkins.length < 5) {
      return { 
        success: false, 
        message: 'Ainda não existem Check-ins suficientes neste mês para gerar Insights precisos. Continuem a partilhar os vossos sentimentos para o Bondly vos poder ajudar!' 
      };
    }

    // 2. Formatar os dados para a IA entender
    const formattedData = checkins.map(c => `[${c.created_at}] User ${c.user_id} sentiu-se "${c.mood}". Nota: "${c.note || 'Sem nota'}"`).join('\n');

    const prompt = `
      Tu és um Psicólogo e Terapeuta de Casais especialista em análise comportamental (O Bondly AI Coach).
      Abaixo tens o histórico dos "Check-ins Emocionais" diários deste casal ao longo do último mês.
      
      Histórico:
      ${formattedData}
      
      Tarefa: Escreve um Relatório Mensal de Relacionamento (Insights) com base EXCLUSIVAMENTE nestes dados. 
      Dirige-te diretamente ao casal, num tom amigável, acolhedor e profissional. Tenta identificar se há dias da semana em que costumam estar mais stressados, ou se um dos parceiros tem estado em baixo ultimamente. Remata com 2 sugestões práticas pontuais para eles melhorarem a sua conexão agora.
      Limite de palavras: 250 palavras. Formata bem a resposta.
    `;

    // 3. Perguntar à IA e retornar
    const resultText = await this.aiService.getAdvice(prompt);
    
    return {
      success: true,
      insightsReport: resultText,
      totalCheckinsAnalyzed: checkins.length
    };
  }
}

