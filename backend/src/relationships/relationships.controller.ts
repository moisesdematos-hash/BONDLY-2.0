import { Controller, Get, Post, Body, UseGuards, Delete, Param } from '@nestjs/common';
import { RelationshipsService } from './relationships.service';
import { CreateRelationshipDto } from './dto/create-relationship.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('relationships')
@UseGuards(JwtAuthGuard)
export class RelationshipsController {
  constructor(private relationshipsService: RelationshipsService) {}

  @Post()
  async create(
    @Body() createRelationshipDto: CreateRelationshipDto,
    @GetUser('userId') userId: string,
  ) {
    return this.relationshipsService.create(createRelationshipDto, userId);
  }

  @Get()
  async findAll(@GetUser('userId') userId: string) {
    return this.relationshipsService.findAllForUser(userId);
  }

  @Post('join')
  async join(
    @Body('inviteCode') inviteCode: string,
    @GetUser('userId') userId: string,
  ) {
    return this.relationshipsService.joinRelationship(inviteCode, userId);
  }

  @Delete(':id')
  async remove(
    @Param('id') id: string,
    @GetUser('userId') userId: string,
  ) {
    return this.relationshipsService.remove(id, userId);
  }

  @Post(':id/icebreaker')
  async triggerIcebreaker(
    @Param('id') relationshipId: string,
    @GetUser('userId') userId: string,
  ) {
    return this.relationshipsService.triggerIcebreaker(relationshipId, userId);
  }
}

