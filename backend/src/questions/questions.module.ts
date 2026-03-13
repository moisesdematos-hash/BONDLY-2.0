import { Module } from '@nestjs/common';
import { QuestionsController } from './questions.controller';
import { QuestionsService } from './questions.service';
import { GardenModule } from '../garden/garden.module';


@Module({
  imports: [GardenModule],
  controllers: [QuestionsController],
  providers: [QuestionsService]

})
export class QuestionsModule {}
