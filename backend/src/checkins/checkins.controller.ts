import { Controller, Get, Post, Body, UseGuards, Param } from '@nestjs/common';
import { CheckinsService } from './checkins.service';
import { CreateCheckinDto } from './dto/create-checkin.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('checkins')
@UseGuards(JwtAuthGuard)
export class CheckinsController {
  constructor(private checkinsService: CheckinsService) {}

  @Post()
  async create(
    @Body() createCheckinDto: CreateCheckinDto,
    @GetUser('userId') userId: string,
  ) {
    return this.checkinsService.create(createCheckinDto, userId);
  }

  @Get('relationship/:id')
  async findAllByRelationship(@Param('id') relationshipId: string) {
    return this.checkinsService.findAllForRelationship(relationshipId);
  }

  @Get('partner-status/:id')
  async getPartnerStatus(
    @Param('id') relationshipId: string,
    @GetUser('userId') userId: string,
  ) {
    return this.checkinsService.getPartnerStatus(relationshipId, userId);
  }

  @Get('history')
  async getPersonalHistory(@GetUser('userId') userId: string) {
    return this.checkinsService.findPersonalHistory(userId);
  }
}

