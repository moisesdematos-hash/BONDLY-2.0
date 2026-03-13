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

    const content = response.choices[0].message.content;
    if (!content) throw new Error('Falha ao obter análise de sentimento');
    return JSON.parse(content);
  }


  async getCoachSuggestion(context: {
    message: string;
    relationshipType: string;
    isPremium: boolean;
    language: string;
  }) {
    if (!this.openai) return { suggestion: 'AI Coach is busy, please try again later.' };

    const prompt = `Você é o Bondly AI Coach, um especialista em relacionamentos focado em comunicação não-violenta e inteligência emocional.
    
    CONTEXTO DO USUÁRIO:
    - Mensagem/Situação: "${context.message}"
    - Tipo de Relacionamento: ${context.relationshipType}
    - Idioma: ${context.language}
    - Status: ${context.isPremium ? 'Premium' : 'Standard'}

    OBJETIVO:
    Analise a situação de forma profunda e ofereça uma resposta que:
    1. Valide os sentimentos descritos.
    2. Identifique possíveis necessidades não atendidas.
    3. Sugira uma forma prática e empática de agir ou responder (se aplicável).
    4. Proponha uma reflexão para o usuário.

    FORMATO DE RETORNO (JSON):
    {
      "sugestao": "Texto completo da orientação do coach, estruturado com parágrafos claros.",
      "emocao_detectada": "Uma palavra ou frase curta identificando o tom da mensagem.",
      "alerta_conflito": true/false (true se houver sinais claros de agressividade ou hostilidade),
      "dica_rapida": "Uma frase curta de incentivo ou ação imediata."
    }`;

    const response = await this.openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        { 
          role: 'system', 
          content: 'Você é um coach de relacionamentos empático e experiente.' 
        },
        { 
          role: 'user', 
          content: prompt 
        }
      ],
      response_format: { type: 'json_object' },
    });

    const content = response.choices[0].message.content;
    if (!content) throw new Error('Falha ao obter sugestão do AI Coach');
    return JSON.parse(content);
  }

  async getSimulationFeedback(context: {
    message: string;
    relationshipType: string;
    isPremium: boolean;
    language: string;
  }) {
    if (!this.openai) return { reaction: 'AI is unavailable', feedback: 'Please try again later.' };

    const prompt = `Você é o Bondly Simulator. Seu objetivo é ajudar o usuário a ensaiar conversas difíceis.
    
    SITUAÇÃO:
    O usuário pretende dizer o seguinte para seu parceiro: "${context.message}"
    Tipo de Relacionamento: ${context.relationshipType}

    SUA TAREFA:
    1. REAÇÃO SIMULADA: Escreva como o parceiro provavelmente responderia (em primeira pessoa, como se fosse o parceiro). Seja realista, baseando-se no tom da mensagem original.
    2. ANÁLISE DE IMPACTO: Explique por que o parceiro reagiria assim. Quais sentimentos ou gatilhos foram ativados?
    3. SUGESTÃO BONDLY: Dê uma sugestão de como refrasear ou abordar o assunto de forma mais conectiva (CNV).

    FORMATO DE RETORNO (JSON):
    {
      "reacao_parceiro": "Sua resposta curta em primeira pessoa...",
      "analise_impacto": "Explicação do impacto emocional...",
      "sugestao_coach": "Como falar melhor...",
      "tom_detectado": "Neutro/Agressivo/Vulnerável/etc",
      "conselho_rapido": "Uma frase de encorajamento."
    }`;

    const response = await this.openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        { 
          role: 'system', 
          content: 'Você é um simulador de conversas de relacionamento especializado em empatia.' 
        },
        { role: 'user', content: prompt }
      ],
      response_format: { type: 'json_object' },
    });

    const content = response.choices[0].message.content;
    if (!content) throw new Error('Falha ao obter feedback da simulação');
    return JSON.parse(content);
  }

  async generateDateSuggestions(context: {
    relationshipType: string;
    recentMoods?: string[];
    language: string;
    isPremium: boolean;
  }) {
    if (!this.openai) return { suggestions: [] };

    const moodContext = context.recentMoods?.length 
      ? `O clima recente do casal tem sido: ${context.recentMoods.join(', ')}.`
      : 'Não há dados recentes de humor.';

    const prompt = `Você é o Bondly Date Planner, um especialista em criar momentos de conexão para casais.
    
    CONTEXTO:
    - Tipo de Relacionamento: ${context.relationshipType}
    - Clima Recente: ${moodContext}
    - Status: ${context.isPremium ? 'Premium' : 'Standard'}
    - Idioma: ${context.language}

    SUA TAREFA:
    Gere 3 sugestões criativas e personalizadas de "Date Night" (encontros). 
    Para cada sugestão, explique brevemente por que você a escolheu com base no contexto (clima recente e tipo de relação). 
    As sugestões devem variar entre atividades em casa e fora.

    FORMATO DE RETORNO (JSON):
    {
      "sugestoes": [
        {
          "titulo": "Nome criativo do encontro",
          "descricao": "O que fazer exatamente...",
          "por_que": "Explicação do porquê combinada com o clima recente...",
          "tipo": "casa/rua",
          "premium": true/false
        }
      ]
    }`;

    const response = await this.openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        { 
          role: 'system', 
          content: 'Você é um planejador de encontros românticos focado em conexão profunda.' 
        },
        { role: 'user', content: prompt }
      ],
      response_format: { type: 'json_object' },
    });

    const content = response.choices[0].message.content;
    if (!content) throw new Error('Falha ao gerar sugestões de datas');
    return JSON.parse(content);
  }

  async generateNudge(context: {
    partnerMood?: string;
    gardenHealth: number;
    relationshipType: string;
    language: string;
  }) {
    if (!this.openai) return { nudge: null };

    const moodContext = context.partnerMood 
      ? `O parceiro se sente: ${context.partnerMood}.`
      : 'O humor do parceiro não foi registrado hoje.';

    const prompt = `Você é o Bondly Nudge, um assistente proativo de inteligência emocional para casais.
    
    CONTEXTO ATUAL:
    - Humor do Parceiro: ${moodContext}
    - Saúde do Jardim: ${context.gardenHealth}%
    - Tipo de Relacionamento: ${context.relationshipType}
    - Idioma: ${context.language}

    SUA TAREFA:
    Gere um "empurrãozinho" (nudge) curto, empático e acionável para o usuário. 
    O objetivo é incentivar a conexão baseando-se no estado emocional do parceiro ou na necessidade de cuidar do jardim.
    
    REGRAS:
    - Seja extremamente breve (máximo 2 frases).
    - Se o humor for negativo, seja acolhedor.
    - Se a saúde do jardim estiver baixa, incentive uma pequena ação de manutenção da relação.
    - Retorne null no campo "mensagem" se não houver nada relevante para sugerir agora.

    FORMATO DE RETORNO (JSON):
    {
      "mensagem": "Texto do nudge aqui...",
      "prioridade": "alta/media/baixa"
    }`;

    const response = await this.openai.chat.completions.create({
      model: 'gpt-4',
      messages: [
        { 
          role: 'system', 
          content: 'Você é um assistente proativo de conexão emocional.' 
        },
        { role: 'user', content: prompt }
      ],
      response_format: { type: 'json_object' },
    });

    const content = response.choices[0].message.content;
    if (!content) throw new Error('Falha ao gerar nudge');
    return JSON.parse(content);
  }
}





