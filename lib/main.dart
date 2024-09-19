import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nihaar/firebase_options.dart';
import 'package:nihaar/login_page.dart';
import 'package:nihaar/productslist.dart';
import 'package:nihaar/registration_screen.dart';
import 'package:nihaar/itemRegistration_screen.dart'; // Import your item registration screen
import 'package:nihaar/homepage.dart'; // Import the new HomePage
import 'package:nihaar/sales_data.dart';
import 'package:nihaar/scanner.dart'; // Import the ScannerPage
 
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
 
class MyApp extends StatelessWidget {
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login', // Set the initial route
      routes: {
        '/login': (context) => const LoginScreen(),
        '/registration': (context) => const RegistrationScreen(),
        '/item-registration': (context) => const ItemRegistrationScreen(),
        '/home': (context) => const HomePage(), // New route for HomePage
        '/scanner': (context) =>  ScannerPage(), // Route for ScannerPage
        '/products': (context) => const ProductsPage(),
        '/sales': (context) => SalesDataPage(),
      },
    );
  }
}