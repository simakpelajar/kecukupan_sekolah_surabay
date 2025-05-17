import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/data_service.dart';
import 'services/location_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => DataService()),
        Provider(create: (_) => LocationService()),
      ],
      child: MaterialApp(        title: 'SMA Surabaya',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Color(0xFF3E64FF),    // Royal Blue
            secondary: Color(0xFF5EDFFF),  // Cyan
            tertiary: Color(0xFFFFBD69),   // Light Orange
            background: Color(0xFFF5F7FC), // Light blue-gray background
            surface: Colors.white,         // Surface color
            error: Color(0xFFFF7675),      // Error/inadequate color
          ),
          brightness: Brightness.light,
          scaffoldBackgroundColor: Color(0xFFF5F7FC),
          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xFF3E64FF),
            elevation: 0,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1E293B),
            selectedItemColor: Color(0xFF06B6D4),
            unselectedItemColor: Colors.grey,
          ),
          textTheme: TextTheme(
            titleLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: TextStyle(color: Colors.white), // bodyText1 diganti dengan bodyLarge
            bodyMedium: TextStyle(color: Colors.grey[300]), // bodyText2 diganti dengan bodyMedium
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}