import { Controller, Get, Post, Body, UseGuards, Param, Patch } from '@nestjs/common';
import { ChallengesService } from './challenges.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('challenges')
@UseGuards(JwtAuthGuard)
export class ChallengesController {
  constructor(private challengesService: ChallengesService) {}

  @Get()
  async findAll(@GetUser('role') role: string) {
    return this.challengesService.findAll(role === 'premium');
  }

  @Post(':id/participate')
  async participate(
    @Param('id') challengeId: string,
    @GetUser('userId') userId: string,
  ) {
    return this.challengesService.participate(userId, challengeId);
  }

  @Patch('participation/:id/complete')
  async complete(
    @Param('id') participationId: string,
    @GetUser('userId') userId: string,
  ) {
    return this.challengesService.complete(participationId, userId);
  }
}
