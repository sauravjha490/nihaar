import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nihaar'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No previous page to go back to.')),
              );
            }
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Company Logo
              Center(
                child: Image.asset(
                  'assets/logo1.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 20),
              // Welcome Text
              Text(
                'Welcome to Nihaar',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 20, 51, 48),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Sales Report Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/sales'); // Navigate to SalesDataPage
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green, // Change to a suitable color
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: const Icon(Icons.article), // Icon for Sales Report
                label: const Text(
                  'Sales Report',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 20),
              // Item Registration Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/item-registration');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: const Icon(Icons.add), // Icon for Item Registration
                label: const Text(
                  'Go to Item Registration',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 20),
              // Scanner Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/scanner');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: const Icon(Icons.camera_alt), // Icon for Scanner
                label: const Text(
                  'Go to Scanner',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 20),
              // Products Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/products');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue, // Change to a suitable color
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: const Icon(Icons.view_list), // Icon for Products
                label: const Text(
                  'View Products',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              const SizedBox(height: 20),
              // Logout Button
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: const Icon(Icons.logout), // Icon for Logout
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
