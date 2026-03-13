import { Module } from '@nestjs/common';
import { CheckinsController } from './checkins.controller';
import { CheckinsService } from './checkins.service';
import { GardenModule } from '../garden/garden.module';


@Module({
  imports: [GardenModule],
  controllers: [CheckinsController],
  providers: [CheckinsService]

})
export class CheckinsModule {}
