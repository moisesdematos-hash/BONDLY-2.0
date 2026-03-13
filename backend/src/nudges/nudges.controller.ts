import { Controller, Get, UseGuards, Request, Query } from '@nestjs/common';
import { Request as ExpressRequest } from 'express';

import { NudgesService } from './nudges.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('nudges')
@UseGuards(JwtAuthGuard)
export class NudgesController {
  constructor(private nudgesService: NudgesService) {}

  @Get()
  async getNudge(@Request() req: ExpressRequest & { user: any }, @Query('relationshipId') relationshipId: string, @Query('lang') lang: string) {

    return this.nudgesService.getNudge(relationshipId, req.user.userId, lang);
  }
}
