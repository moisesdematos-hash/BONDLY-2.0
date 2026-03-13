import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { AiService } from './ai.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('ai-coach')
@UseGuards(JwtAuthGuard)
export class AiCoachController {
  constructor(private aiService: AiService) {}

  @Post('suggest')
  async getSuggestion(
    @Body() body: { message: string; relationshipType: string; language: string },
    @GetUser('role') role: string,
  ) {
    return this.aiService.getCoachSuggestion({
      message: body.message,
      relationshipType: body.relationshipType,
      isPremium: role === 'premium',
      language: body.language || 'pt',
    });
  }
}
