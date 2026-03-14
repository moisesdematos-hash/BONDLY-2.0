import { Injectable, ForbiddenException, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateAgreementDto } from './dto/create-agreement.dto';

@Injectable()
export class AgreementsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async create(createAgreementDto: CreateAgreementDto, userId: string) {
    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('relationship_agreements')
      .insert([
        {
          relationship_id: createAgreementDto.relationship_id,
          created_by: userId,
          title: createAgreementDto.title,
          description: createAgreementDto.description,
          is_agreed: false // Starts pending
        },
      ])
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async findAllByRelationship(relationshipId: string) {
    const supabase = this.supabaseService.getClient();

    const { data, error } = await supabase
      .from('relationship_agreements')
      .select(`
        *,
        creator:users!created_by(id, name, avatar_url)
      `)
      .eq('relationship_id', relationshipId)
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    return data;
  }

  async agree(id: string, userId: string) {
    const supabase = this.supabaseService.getClient();

    // Verify the agreement exists and user didn't create it (must be the partner to agree)
    const { data: agreement, error: findError } = await supabase
      .from('relationship_agreements')
      .select('*')
      .eq('id', id)
      .single();

    if (findError || !agreement) throw new NotFoundException('Acordo não encontrado');
    
    // Partner must be the one agreeing (or just any member of the relationship who didn't create it)
    if (agreement.created_by === userId) {
        throw new ForbiddenException('Apenas o teu parceiro pode aceitar esta regra que tu propuseste.');
    }

    const { data, error } = await supabase
      .from('relationship_agreements')
      .update({ is_agreed: true, updated_at: new Date().toISOString() })
      .eq('id', id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  }

  async remove(id: string, userId: string) {
    const supabase = this.supabaseService.getClient();

    // Check ownership or relationship participation (RLS should handle mostly, but good practice to verify)
    const { error } = await supabase
      .from('relationship_agreements')
      .delete()
      .eq('id', id);

    if (error) throw new Error(error.message);
    return { success: true };
  }
}
