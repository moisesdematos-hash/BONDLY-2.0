import { Module } from '@nestjs/common';
import { ChallengesController } from './challenges.controller';
import { ChallengesService } from './challenges.service';
import { GardenModule } from '../garden/garden.module';


@Module({
  imports: [GardenModule],
  controllers: [ChallengesController],
  providers: [ChallengesService]

})
export class ChallengesModule {}
