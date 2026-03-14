import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class WishlistsService {
  constructor(private supabaseService: SupabaseService) {}

  async findAll(relationshipId: string) {
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('shared_wishlists')
      .select('*')
      .eq('relationship_id', relationshipId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }

  async create(relationshipId: string, userId: string, title: string, description?: string, linkUrl?: string) {
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('shared_wishlists')
      .insert([
        {
          relationship_id: relationshipId,
          user_id: userId,
          title,
          description,
          link_url: linkUrl,
        },
      ])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async markAsPurchased(wishlistId: string, userId: string) {
    const supabase = this.supabaseService.getClient();
    
    // Qualquer membro do relacionamento pode marcar como comprado, 
    // a verificação RLS fará o match do relationship_id
    const { data, error } = await supabase
      .from('shared_wishlists')
      .update({ is_purchased: true })
      .eq('id', wishlistId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  async delete(wishlistId: string, userId: string) {
    const supabase = this.supabaseService.getClient();
    const { data, error } = await supabase
      .from('shared_wishlists')
      .delete()
      .eq('id', wishlistId)
      .eq('user_id', userId) // RLS também protege, mas double-check aqui
      .select()
      .single();

    if (error) throw error;
    return data;
  }
}
