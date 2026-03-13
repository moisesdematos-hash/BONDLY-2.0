import { Module } from '@nestjs/common';
import { DatesService } from './dates.service';
import { DatesController } from './dates.controller';
import { AiModule } from '../ai/ai.module';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [AiModule, SupabaseModule],
  providers: [DatesService],
  controllers: [DatesController],
})
export class DatesModule {}
