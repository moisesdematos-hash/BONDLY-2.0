import { Controller, Get, Post, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { Request as ExpressRequest } from 'express';

import { MemoriesService } from './memories.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('memories')
@UseGuards(JwtAuthGuard)
export class MemoriesController {
  constructor(private memoriesService: MemoriesService) {}

  @Get(':relationshipId')
  async findAll(@Param('relationshipId') relationshipId: string) {
    return this.memoriesService.findAll(relationshipId);
  }

  @Post()
  async create(@Request() req: ExpressRequest & { user: any }, @Body() body: { relationship_id: string; image_url: string; caption?: string }) {
    return this.memoriesService.create(
      body.relationship_id,
      req.user.userId,
      body.image_url,
      body.caption,
    );
  }

  @Delete(':id')
  async delete(@Request() req: ExpressRequest & { user: any }, @Param('id') id: string) {

    return this.memoriesService.delete(id, req.user.userId);
  }
}
