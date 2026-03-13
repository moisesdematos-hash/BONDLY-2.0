import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { DatesService } from './dates.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('dates')
@UseGuards(JwtAuthGuard)
export class DatesController {
  constructor(private datesService: DatesService) {}

  @Get('suggestions/:relationshipId')
  async getSuggestions(
    @Param('relationshipId') relationshipId: string,
    @Query('lang') lang: string,
  ) {
    return this.datesService.getSuggestions(relationshipId, lang);
  }
}
