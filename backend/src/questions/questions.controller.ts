import { Controller, Get, Post, Body, UseGuards, Query } from '@nestjs/common';
import { QuestionsService } from './questions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('questions')
@UseGuards(JwtAuthGuard)
export class QuestionsController {
  constructor(private questionsService: QuestionsService) {}

  @Get('daily')
  async getDaily(
    @Query('relationshipType') relationshipType: string,
    @Query('language') language: string,
  ) {
    return this.questionsService.getDailyQuestion(relationshipType, language || 'pt');
  }

  @Post('answer')
  async submitAnswer(
    @Body() body: { questionId: string; relationshipId: string; answerText: string },
    @GetUser('userId') userId: string,
  ) {
    return this.questionsService.submitAnswer(
      body.questionId,
      userId,
      body.relationshipId,
      body.answerText,
    );
  }
}
