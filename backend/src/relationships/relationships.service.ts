import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateRelationshipDto } from './dto/create-relationship.dto';

@Injectable()
export class RelationshipsService {
  constructor(private supabaseService: SupabaseService) {}

  async create(createRelationshipDto: CreateRelationshipDto, userId: string) {
    const supabase = this.supabaseService.getClient();

    // 1. Create the relationship
    const { data: relationship, error: relError } = await supabase
      .from('relationships')
      .insert([
        {
          name: createRelationshipDto.name,
          type: createRelationshipDto.type,
          created_by: userId,
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
