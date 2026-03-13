import { Controller, Get, Param, UseGuards } from '@nestjs/common';
import { GardenService } from './garden.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('garden')
@UseGuards(JwtAuthGuard)
export class GardenController {
  constructor(private gardenService: GardenService) {}

  @Get(':relationshipId')
  async getGarden(@Param('relationshipId') relationshipId: string) {
    return this.gardenService.getGardenStats(relationshipId);
  }
}
