import { Controller, Get, Patch, Body, UseGuards, Delete } from '@nestjs/common';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../auth/decorators/get-user.decorator';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('me')
  async getMe(@GetUser('userId') userId: string) {
    const user = await this.usersService.findById(userId);
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password_hash, ...result } = user;
    return result;
  }

  @Patch('me')
  async updateMe(
    @GetUser('userId') userId: string,
    @Body() updateData: { name?: string; language?: string },
  ) {
    const user = await this.usersService.update(userId, updateData);
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password_hash, ...result } = user;
    return result;
  }

  @Delete('me')
  async deleteMe(@GetUser('userId') userId: string) {
    return this.usersService.remove(userId);
  }
}
