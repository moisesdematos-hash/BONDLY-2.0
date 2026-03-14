import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { Request as ExpressRequest } from 'express';

import { WishlistsService } from './wishlists.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('wishlists')
@UseGuards(JwtAuthGuard)
export class WishlistsController {
  constructor(private wishlistsService: WishlistsService) {}

  @Get(':relationshipId')
  async findAll(@Param('relationshipId') relationshipId: string) {
    return this.wishlistsService.findAll(relationshipId);
  }

  @Post()
  async create(
    @Request() req: ExpressRequest & { user: any }, 
    @Body() body: { relationship_id: string; title: string; description?: string; link_url?: string }
  ) {
    return this.wishlistsService.create(
      body.relationship_id,
      req.user.userId,
      body.title,
      body.description,
      body.link_url,
    );
  }

  @Put(':id/purchased')
  async markAsPurchased(@Request() req: ExpressRequest & { user: any }, @Param('id') id: string) {
    return this.wishlistsService.markAsPurchased(id, req.user.userId);
  }

  @Delete(':id')
  async delete(@Request() req: ExpressRequest & { user: any }, @Param('id') id: string) {
    return this.wishlistsService.delete(id, req.user.userId);
  }
}
