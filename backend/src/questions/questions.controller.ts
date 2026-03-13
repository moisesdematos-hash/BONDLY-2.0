import { Controller, Get, Post, Body, UseGuards, Query, Param } from '@nestjs/common';
import { QuestionsService } from './questions.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('questions')
@UseGuards(JwtAuthGuard)
export class QuestionsController {
  constructor(private questionsService: QuestionsService) {}

  @Get('daily/:relationshipId')
  async getDaily(
    @Param('relationshipId') relationshipId: string,
    @Query('relationshipType') relationshipType: string,
    @Query('language') language: string,
    @GetUser('userId') userId: string,
  ) {
    return this.questionsService.getDailyQuestion(
      userId,
      relationshipId,
      relationshipType,
      language || 'pt'
    );
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
