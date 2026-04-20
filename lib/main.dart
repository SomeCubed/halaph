import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'services/simple_plan_service.dart';
import 'screens/home_screen.dart';

import 'screens/explore_screen.dart';

import 'screens/create_plan_screen.dart';

import 'screens/plan_details_screen.dart';

import 'screens/explore_details_screen.dart';

import 'screens/my_plans_screen.dart';

import 'screens/profile_screen.dart';

import 'screens/map_screen.dart';




void main() {

  runApp(const HalaPhApp());

}



final GoRouter _router = GoRouter(

  routes: [

    GoRoute(

      path: '/',

      builder: (context, state) => const MainNavigation(),

    ),

    GoRoute(

      path: '/explore-details',

      builder: (context, state) => ExploreDetailsScreen(

        destinationId: state.uri.queryParameters['destinationId'] ?? '',

        source: state.uri.queryParameters['source'],

      ),

    ),

    GoRoute(

      path: '/plan-details',

      builder: (context, state) {
        final planId = state.uri.queryParameters['planId'];
        if (planId != null && planId.isNotEmpty) {
          // Load the plan from service
          final plan = SimplePlanService.getPlanById(planId);
          return PlanDetailsScreen(plan: plan);
        }
        return const PlanDetailsScreen(plan: null);
      },

    ),

    GoRoute(

      path: '/view',

      builder: (context, state) => const MapScreen(),

    ),

    GoRoute(

      path: '/create-plan',

      builder: (context, state) => const CreatePlanScreen(),

    ),

  ],

);



class MainNavigation extends StatefulWidget {

  const MainNavigation({super.key});



  @override

  State<MainNavigation> createState() => _MainNavigationState();

}



class _MainNavigationState extends State<MainNavigation> {

  int _currentIndex = 0;



  final List<Widget> _screens = [

    const HomeScreen(),

    const ExploreScreen(),

    const MyPlansScreen(),

    const ProfileScreen(),

  ];



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(

        index: _currentIndex,

        children: _screens,

      ),

      bottomNavigationBar: Container(

        decoration: const BoxDecoration(

          color: Colors.white,

          boxShadow: [

            BoxShadow(

              color: Colors.black12,

              blurRadius: 10,

              offset: Offset(0, -2),

            ),

          ],

        ),

        child: SafeArea(

          child: Padding(

            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                _buildNavItem(Icons.home, 'Home', 0),

                _buildNavItem(Icons.explore, 'Explore', 1),

                _buildNavItem(Icons.calendar_today, 'Plans', 2),

                _buildNavItem(Icons.person, 'Profile', 3),

              ],

            ),

          ),

        ),

      ),

    );

  }



  Widget _buildNavItem(IconData icon, String label, int index) {

    final isActive = _currentIndex == index;

    

    return GestureDetector(

      onTap: () => setState(() => _currentIndex = index),

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Icon(

            icon,

            size: 24,

            color: isActive ? Colors.blue[600] : Colors.grey[400],

          ),

          const SizedBox(height: 4),

          Text(

            label,

            style: TextStyle(

              fontSize: 12,

              color: isActive ? Colors.blue[600] : Colors.grey[400],

              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,

            ),

          ),

        ],

      ),

    );

  }

}



class HalaPhApp extends StatelessWidget {

  const HalaPhApp({super.key});



  @override

  Widget build(BuildContext context) {

    return MaterialApp.router(

      debugShowCheckedModeBanner: false,

      title: 'HalaPH - Discover Philippines',

      theme: ThemeData(

        primarySwatch: Colors.blue,

        fontFamily: 'Roboto',

        scaffoldBackgroundColor: const Color(0xFFF8F9FA),

        appBarTheme: const AppBarTheme(

          backgroundColor: Colors.white,

          elevation: 0,

          titleTextStyle: TextStyle(

            color: Colors.black,

            fontSize: 18,

            fontWeight: FontWeight.w600,

          ),

        ),

      ),

      routerConfig: _router,

    );

  }

}

