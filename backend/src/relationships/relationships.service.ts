import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateRelationshipDto } from './dto/create-relationship.dto';

@Injectable()
export class RelationshipsService {
  constructor(private supabaseService: SupabaseService) {}

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
}
