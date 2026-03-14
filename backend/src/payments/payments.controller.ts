import { Controller, Post, Body, UseGuards, Headers, Req } from '@nestjs/common';
import type { RawBodyRequest } from '@nestjs/common';
import { Request } from 'express';
import { StripeService } from './stripe.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('payments')
export class PaymentsController {
  constructor(private stripeService: StripeService) {}

  @Post('create-checkout')
  @UseGuards(JwtAuthGuard)
  async createCheckout(
    @GetUser('userId') userId: string,
    @GetUser('email') email: string,
  ) {
    return this.stripeService.createCheckoutSession(userId, email);
  }

  @Post('webhook')
  async handleWebhook(
    @Headers('stripe-signature') signature: string,
    @Req() req: RawBodyRequest<Request>,
  ) {
    // Note: We need raw body for Stripe webhook verification
    return this.stripeService.handleWebhook(signature, (req as any).rawBody);
  }
}
