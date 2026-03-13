import { Module, Global } from '@nestjs/common';
import { AiService } from './ai.service';
import { AiCoachController } from './ai-coach.controller';

@Global()
@Module({
  providers: [AiService],
  exports: [AiService],
  controllers: [AiCoachController],
})
export class AiModule {}
