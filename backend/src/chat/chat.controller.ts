import { Controller, Get, Post, Body, UseGuards, Query, Param } from '@nestjs/common';
import { ChatService } from './chat.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('chat')
@UseGuards(JwtAuthGuard)
export class ChatController {
  constructor(private chatService: ChatService) {}

  @Post('send')
  async sendMessage(
    @Body() body: { relationshipId: string; content: string },
    @GetUser('userId') userId: string,
  ) {
    return this.chatService.sendMessage(userId, body.relationshipId, body.content);
  }

  @Get('relationship/:id')
  async getMessages(
    @Param('id') relationshipId: string,
    @Query('limit') limit?: number,
  ) {
    return this.chatService.getMessages(relationshipId, limit);
  }
}
