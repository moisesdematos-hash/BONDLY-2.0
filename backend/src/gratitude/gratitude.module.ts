import { Module } from '@nestjs/common';
import { GratitudeController } from './gratitude.controller';
import { GratitudeService } from './gratitude.service';
import { AiModule } from '../ai/ai.module';

@Module({
  imports: [AiModule],
  controllers: [GratitudeController],
  providers: [GratitudeService],
})
export class GratitudeModule {}
