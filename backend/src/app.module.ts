import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { SupabaseModule } from './supabase/supabase.module';
import { RelationshipsModule } from './relationships/relationships.module';
import { CheckinsModule } from './checkins/checkins.module';
import { AiModule } from './ai/ai.module';
import { QuestionsModule } from './questions/questions.module';
import { ChallengesModule } from './challenges/challenges.module';
import { SimulationModule } from './simulation/simulation.module';
import { ChatModule } from './chat/chat.module';
import { GardenModule } from './garden/garden.module';
import { MemoriesModule } from './memories/memories.module';
import { DatesModule } from './dates/dates.module';
import { NudgesModule } from './nudges/nudges.module';





@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    SupabaseModule,
    AuthModule,
    UsersModule,
    RelationshipsModule,
    CheckinsModule,
    AiModule,
    QuestionsModule,
    ChallengesModule,
    SimulationModule,
    ChatModule,
    GardenModule,
    MemoriesModule,
    DatesModule,
    NudgesModule,




  ],
})
export class AppModule {}
