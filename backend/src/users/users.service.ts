import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
  constructor(private supabaseService: SupabaseService) {}

  async findByEmail(email: string) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error && error.code !== 'PGRST116') {
      throw error;
    }

    return data;
  }

  async create(userData: {
    name: string;
    email: string;
    password_hash: string;
    language?: string;
  }) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .insert([userData])
      .select()
      .single();

    if (error) {
      throw error;
    }

    return data;
  }

  async findById(id: string) {

    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .select('*')
      .eq('id', id)
      .single();

    if (error) throw error;
    return data;
  }

  async update(id: string, updateData: { name?: string; language?: string }) {
    const { data, error } = await this.supabaseService
      .getClient()
      .from('users')
      .update(updateData)
      .eq('id', id)
      .select()
      .single();

    if (error) throw error;
    return data;
  }
}

