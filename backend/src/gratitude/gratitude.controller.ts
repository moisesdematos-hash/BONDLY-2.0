import { Controller, Get, Post, Param, Delete, UseGuards, UseInterceptors, UploadedFile, Body } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { GratitudeService } from './gratitude.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('gratitude')
@UseGuards(JwtAuthGuard)
export class GratitudeController {
  constructor(private readonly gratitudeService: GratitudeService) {}

  @Post('upload')
  @UseInterceptors(FileInterceptor('file'))
  async uploadAudio(
    @UploadedFile() file: Express.Multer.File,
    @Body('relationship_id') relationshipId: string,
    @GetUser('userId') userId: string,
  ) {
    return this.gratitudeService.create(relationshipId, userId, file);
  }

  @Get('relationship/:id')
  findAllByRelationship(@Param('id') relationshipId: string) {
    return this.gratitudeService.findAllByRelationship(relationshipId);
  }

  @Delete(':id')
  remove(
    @Param('id') id: string,
    @GetUser('userId') userId: string,
  ) {
    return this.gratitudeService.remove(id, userId);
  }
}
