import { Module } from '@nestjs/common';
import { StripeService } from './stripe.service';
import { PaymentsController } from './payments.controller';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [SupabaseModule],
  providers: [StripeService],
  controllers: [PaymentsController],
  exports: [StripeService],
})
export class PaymentsModule {}
