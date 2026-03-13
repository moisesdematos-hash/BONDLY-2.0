import { IsInt, IsString, IsOptional, IsUUID, Min, Max } from 'class-validator';

export class CreateCheckinDto {
  @IsUUID()
  relationship_id: string;

  @IsInt()
  @Min(1)
  @Max(5)
  mood: number;

  @IsString()
  @IsOptional()
  note?: string;
}
