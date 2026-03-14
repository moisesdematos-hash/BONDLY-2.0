import { Module } from '@nestjs/common';
import { CheckinsController } from './checkins.controller';
import { CheckinsService } from './checkins.service';
import { GardenModule } from '../garden/garden.module';
import { AiModule } from '../ai/ai.module';


@Module({
  imports: [GardenModule, AiModule],
  controllers: [CheckinsController],
  providers: [CheckinsService]

})
export class CheckinsModule {}
