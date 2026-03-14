import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateRelationshipDto } from './dto/create-relationship.dto';
import { AiService } from '../ai/ai.service'; // Import AI Service para os Icebreakers

@Injectable()
export class RelationshipsService {
  constructor(
    private supabaseService: SupabaseService,
    private aiService: AiService // Injetar AI Service
  ) {}

  async create(createRelationshipDto: CreateRelationshipDto, userId: string) {
    const supabase = this.supabaseService.getClient();
    const inviteCode = Math.random().toString(36).substring(2, 8).toUpperCase();

    // 1. Create the relationship
    const { data: relationship, error: relError } = await supabase
      .from('relationships')
      .insert([
        {
          name: createRelationshipDto.name,
          type: createRelationshipDto.type,
          created_by: userId,
          invite_code: inviteCode,
        },
      ])
      .select()
      .single();

    if (relError) throw relError;

    // 2. Create the relationship space for the creator
    const { error: spaceError } = await supabase
      .from('relationship_spaces')
      .insert([
        {
          relationship_id: relationship.id,
          user_id: userId,
        },
      ]);

    if (spaceError) throw spaceError;

    return relationship;
  }

  async joinRelationship(inviteCode: string, userId: string) {
    const supabase = this.supabaseService.getClient();

    // 1. Find the relationship by invite code
    const { data: relationship, error: relError } = await supabase
      .from('relationships')
      .select('id')
      .eq('invite_code', inviteCode.toUpperCase())
      .single();

    if (relError || !relationship) {
      throw new Error('Código de convite inválido');
    }

    // 2. Check if user is already in this relationship
    const { data: existingSpace } = await supabase
      .from('relationship_spaces')
      .select('id')
      .eq('relationship_id', relationship.id)
      .eq('user_id', userId)
      .single();

    if (existingSpace) {
      return relationship;
    }

    // 3. Join the relationship space
    const { error: joinError } = await supabase
      .from('relationship_spaces')
      .insert([
        {
          relationship_id: relationship.id,
          user_id: userId,
        },
      ]);

    if (joinError) throw joinError;

    return relationship;
  }

  async findAllForUser(userId: string) {

    const supabase = this.supabaseService.getClient();
    
    const { data, error } = await supabase
      .from('relationship_spaces')
      .select(`
        relationship_id,
        relationships (
          id,
          name,
          type,
          created_at
        )
      `)
      .eq('user_id', userId);

    if (error) throw error;
    
    return data.map(item => item.relationships);
  }

  async remove(relationshipId: string, userId: string) {
    const supabase = this.supabaseService.getClient();

    // Verify ownership or membership before and then delete
    // In this MVP, we'll allow the creator to delete the whole relationship
    const { data: relationship, error: findError } = await supabase
      .from('relationships')
      .select('id, created_by')
      .eq('id', relationshipId)
      .single();

    if (findError || !relationship) throw new Error('Relacionamento não encontrado');
    if (relationship.created_by !== userId) {
      throw new Error('Apenas o criador pode excluir o relacionamento');
    }

    const { error: deleteError } = await supabase
      .from('relationships')
      .delete()
      .eq('id', relationshipId);

    if (deleteError) throw deleteError;

    return { deleted: true };
  }

  async triggerIcebreaker(relationshipId: string, userId: string) {
    // 1. Marcar estado da Relação como 'em conflito' (poderia persistir na BD, mas para enviar imediato serve só IA)
    
    // 2. Pedir um Icebreaker poderoso ao Bondly AI Coach
    const prompt = `
      Um utilizador do Bondly (uma app para casais) acaba de carregar no Botão de Pânico/SOS ('Icebreaker').
      Isto significa que eles tiveram uma discussão/tensão no momento e estão com dificuldades em dar o primeiro passo para fazer as pazes.
      
      Gera um "Icebreaker" com muito humor, auto-depreciação ou um desafio engraçado e amoroso que possa quebrar este gelo imediatamente.
      O texto deve ser uma notificação curta e impactante para eles lerem juntos ou enviarem um ao outro agora as pazes.
      Sem hashtags. Apenas o texto do conselho em tom apaziguador e brincalhão.
    `;

    const icebreakerMessage = await this.aiService.getAdvice(prompt);
    
    // Nesta fase, devolvemos a mensagem ao FrontEnd. 
    // Em produção total: guardar na base de dados "Nudges" e enviar Firebase Push Notification para o Parceiro.
    return {
      success: true,
      message: icebreakerMessage
    };
  }
}
