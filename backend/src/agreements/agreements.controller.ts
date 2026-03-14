import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { AgreementsService } from './agreements.service';
import { CreateAgreementDto } from './dto/create-agreement.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('agreements')
@UseGuards(JwtAuthGuard)
export class AgreementsController {
  constructor(private readonly agreementsService: AgreementsService) {}

  @Post()
  create(
    @Body() createAgreementDto: CreateAgreementDto,
    @GetUser('userId') userId: string,
  ) {
    return this.agreementsService.create(createAgreementDto, userId);
  }

  @Get('relationship/:id')
  findAllByRelationship(@Param('id') relationshipId: string) {
    return this.agreementsService.findAllByRelationship(relationshipId);
  }

  @Patch(':id/agree')
  agree(
    @Param('id') id: string,
    @GetUser('userId') userId: string,
  ) {
    return this.agreementsService.agree(id, userId);
  }

  @Delete(':id')
  remove(
    @Param('id') id: string,
    @GetUser('userId') userId: string,
  ) {
    return this.agreementsService.remove(id, userId);
  }
}
