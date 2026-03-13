import { Controller, Get, Post, Body, UseGuards, Query } from '@nestjs/common';
import { SimulationService } from './simulation.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('simulation')
@UseGuards(JwtAuthGuard)
export class SimulationController {
  constructor(private simulationService: SimulationService) {}

  @Post()
  async simulate(
    @Body() body: { message: string; relationshipType: string; language: string },
    @GetUser('userId') userId: string,
    @GetUser('role') role: string,
  ) {
    return this.simulationService.simulate({
      message: body.message,
      relationshipType: body.relationshipType,
      userId: userId,
      language: body.language || 'pt',
      isPremium: role === 'premium',
    });
  }

  @Get('history')
  async getHistory(@GetUser('userId') userId: string) {
    return this.simulationService.getHistory(userId);
  }
}
