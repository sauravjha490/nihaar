import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Import Google SignIn
 
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
 
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
 
class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn(); // Initialize GoogleSignIn
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Track loading state
 
  void _login() async {
    setState(() {
      _isLoading = true; // Show the loading spinner
    });
 
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to HomePage after successful login
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print(e); // Handle login error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide the loading spinner
      });
    }
  }
 
  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true; // Show loading spinner
    });
 
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        UserCredential userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          // Navigate to HomePage after successful login
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      print(e); // Handle Google sign-in error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide the loading spinner
      });
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      resizeToAvoidBottomInset: true, // Adjusts the UI when keyboard appears
      body: SingleChildScrollView( // Wrap content in a scrollable view
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Center the items
            children: [
              // Add logo image
              Image.asset(
                'assets/logo1.png', // Adjust the path as needed
                height: 100, // Adjust the height as needed
              ),
              const SizedBox(height: 8.0),
              // Title text
              const Text(
                'Nihaar',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.center, // Center align text
              ),
              const SizedBox(height: 8.0),
              // Subtitle text
              const Text(
                'Discover Quality and Craftsmanship in every detail',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Color.fromARGB(255, 44, 44, 15),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0), // Space between text and login fields
              // Email TextField
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // Password TextField
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              // Login Button
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 121, 214, 205)),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 18.0),
                      ),
              ),
              const SizedBox(height: 20),
              // Google Sign-In Button
              ElevatedButton.icon(
                onPressed: _loginWithGoogle,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                icon: const Icon(Icons.login),
                label: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        'Sign in with Google',
                        style: TextStyle(fontSize: 18.0),
                      ),
              ),
              const SizedBox(height: 20),
              // Register Button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registration');
                  },
                  child: const Text(
                    'No account? Register here',
                    style: TextStyle(fontSize: 16.0, color: Colors.teal),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
