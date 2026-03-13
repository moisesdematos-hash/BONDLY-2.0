import { Module } from '@nestjs/common';
import { NudgesService } from './nudges.service';
import { NudgesController } from './nudges.controller';
import { AiModule } from '../ai/ai.module';
import { SupabaseModule } from '../supabase/supabase.module';
import { RelationshipsModule } from '../relationships/relationships.module';

@Module({
  imports: [AiModule, SupabaseModule, RelationshipsModule],
  providers: [NudgesService],
  controllers: [NudgesController],
})
export class NudgesModule {}
