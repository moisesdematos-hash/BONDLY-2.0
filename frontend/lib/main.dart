import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/bondly_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/questions/presentation/questions_screen.dart';
import 'features/checkin/presentation/checkin_screen.dart';
import 'features/challenges/presentation/challenges_screen.dart';
import 'features/ai_coach/presentation/ai_coach_screen.dart';
import 'features/simulation/presentation/simulation_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/premium_screen.dart';
import 'features/relationship/presentation/relationship_setup_screen.dart';
import 'features/memory_wall/presentation/memory_wall_screen.dart';
import 'features/dates/presentation/date_planner_screen.dart';
import 'features/wishlist/presentation/wishlist_screen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase initialization removed as we use the custom NestJS backend
  
  runApp(const ProviderScope(child: BondlyApp()));
}

class BondlyApp extends StatelessWidget {
  const BondlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bondly',
      debugShowCheckedModeBanner: false,
      theme: BondlyTheme.darkTheme,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/relationship-setup': (context) => const RelationshipSetupScreen(),
        '/questions': (context) => const QuestionsScreen(),
        '/checkin': (context) => const CheckinScreen(),
        '/challenges': (context) => const ChallengesScreen(),
        '/ai-coach': (context) => const AiCoachScreen(),
        '/simulation': (context) => const SimulationScreen(),
        '/chat': (context) => const BondlyChatScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/premium': (context) => const PremiumScreen(),
        '/memory-wall': (context) => const MemoryWallScreen(),
        '/dates': (context) => const DatePlannerScreen(),
        '/wishlist': (context) => const WishlistScreen(),
      },
    );
  }
}
