import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Stripe from 'stripe';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class StripeService {
  private stripe: Stripe;
  private readonly logger = new Logger(StripeService.name);

  constructor(
    private configService: ConfigService,
    private supabaseService: SupabaseService,
  ) {
    const apiKey = this.configService.get<string>('STRIPE_SECRET_KEY');
    this.stripe = new Stripe(apiKey || 'sk_test_placeholder', {
      apiVersion: '2025-01-27ts' as any,
    });
  }

  async createCheckoutSession(userId: string, userEmail: string) {
    try {
      const session = await this.stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        line_items: [
          {
            price_data: {
              currency: 'brl',
              product_data: {
                name: 'Bondly Premium',
                description: 'Assinatura mensal para acesso total às ferramentas de IA.',
              },
              unit_amount: 2990, // R$ 29,90
              recurring: {
                interval: 'month',
              },
            },
            quantity: 1,
          },
        ],
        mode: 'subscription',
        success_url: `${this.configService.get('FRONTEND_URL')}/payment-success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${this.configService.get('FRONTEND_URL')}/premium`,
        customer_email: userEmail,
        client_reference_id: userId,
        metadata: {
          userId: userId,
        },
      });

      return { url: session.url };
    } catch (error) {
      this.logger.error(`Error creating checkout session: ${error.message}`);
      throw error;
    }
  }

  async handleWebhook(signature: string, payload: Buffer) {
    const webhookSecret = this.configService.get<string>('STRIPE_WEBHOOK_SECRET');
    let event: Stripe.Event;

    if (!webhookSecret) {
      throw new Error('Stripe webhook secret is not configured');
    }

    try {
      event = this.stripe.webhooks.constructEvent(payload, signature, webhookSecret);
    } catch (err) {
      this.logger.error(`Webhook signature verification failed: ${err.message}`);
      throw new Error(`Webhook Error: ${err.message}`);
    }

    if (event.type === 'checkout.session.completed') {
      const session = event.data.object as Stripe.Checkout.Session;
      const userId = session.client_reference_id || session.metadata?.userId;

      if (userId) {
        await this.upgradeUserToPremium(userId);
      }
    }

    return { received: true };
  }

  private async upgradeUserToPremium(userId: string) {
    const supabase = this.supabaseService.getClient();
    const { error } = await supabase
      .from('users')
      .update({ role: 'premium' })
      .eq('id', userId);

    if (error) {
      this.logger.error(`Failed to upgrade user ${userId} to premium: ${error.message}`);
    } else {
      this.logger.log(`User ${userId} successfully upgraded to premium.`);
    }
  }
}
