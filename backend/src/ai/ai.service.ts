import { Injectable, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import OpenAI from 'openai';

@Injectable()
export class AiService implements OnModuleInit {
  private openai: OpenAI;

  constructor(private configService: ConfigService) {}

  onModuleInit() {
    const apiKey = this.configService.get<string>('OPENAI_API_KEY');
    if (!apiKey) {
      console.warn('OPENAI_API_KEY not found in environment variables');
      return;
    }
    this.openai = new OpenAI({ apiKey });
  }

  async analyzeSentiment(text: string) {
    if (!this.openai) return { sentiment_score: 0.5 };

    const prompt = `Analise o sentimento da seguinte mensagem em um contexto de relacionamento. 
    Retorne apenas um JSON no formato: {"score": 0.0 a 1.0, "label": "positivo/neutro/negativo"}.
    Mensagem: "${text}"`;

    const response = await this.openai.chat.completions.create({
      model: 'gpt-4',
      messages: [{ role: 'user', content: prompt }],
      response_format: { type: 'json_object' },
    });

    return JSON.parse(response.choices[0].message.content);
  }

  async getCoachSuggestion(context: {
    message: string;
    relationshipType: string;
    isPremium: boolean;
    language: string;
  }) {
    if (!this.openai) return { suggestion: 'AI Coach is busy, please try again later.' };

    const prompt = `Você é o Bondly AI Coach.
    Usuário: ${context.message}
    Relacionamento: ${context.relationshipType}
    Premium: ${context.isPremium}
    Idioma: ${context.language}
    
    Objetivo: gerar sugestão empática, evitar conflito, propor pergunta significativa.
    Formato: JSON {"sugestao": "...", "emocao_detectada": "...", "alerta_conflito": true/false}`;

    const response = await this.openai.chat.completions.create({
      model: 'gpt-4',
      messages: [{ role: 'user', content: prompt }],
      response_format: { type: 'json_object' },
    });

    return JSON.parse(response.choices[0].message.content);
  }
}
