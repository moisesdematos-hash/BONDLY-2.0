import { IsString, IsEnum, IsOptional } from 'class-validator';

export enum RelationshipType {
  CASAL = 'casal',
  AMIZADE = 'amizade',
  FAMILIA = 'familia',
  COLEGAS = 'colegas',
}

export class CreateRelationshipDto {
  @IsString()
  @IsOptional()
  name?: string;

  @IsEnum(RelationshipType)
  type: RelationshipType;
}
