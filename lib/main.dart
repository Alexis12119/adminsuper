import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_page.dart'; // Import the HomePage file

// Faculty Table
// INSERT INTO "public"."faculty" ("id", "email", "password", "name") VALUES ('1', 'admin@gmail.com', 'admin123', 'Joy'), ('2', 'sad@gmail.com', 'sad123', 'Sadness'), ('3', 'anger@gmail.com', 'anger123', 'Anger');
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://eqaqizznngarxghlrpul.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVxYXFpenpubmdhcnhnaGxycHVsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzAyODk5MzgsImV4cCI6MjA0NTg2NTkzOH0.gCKoYLBnY0em8c0WnaWFCdukjgMvWiOmZgGzIstb8Kk',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginPage(), // Start with the LoginPage
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/image/backgroundplsp.jpg.jpg',
              fit: BoxFit
                  .cover, // Change this value to adjust the background image size
            ),
          ),
          // Overlay Color
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF2F8FC)
                  .withOpacity(0.8), // Adjust opacity as needed
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                buildHeader(),
                Spacer(), // Pushes the form down
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      width: screenWidth > 800 ? 400 : 350, // Wider on desktop
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'ADMIN',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            const Text('Admin Email',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4.0),
                            TextFormField(
                              controller: _studentIdController,
                              decoration: const InputDecoration(
                                hintText: 'Enter Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            const Text('Password',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4.0),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20.0),
                            Center(
                              child: SizedBox(
                                width: 150,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C9B44),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final email =
                                          _studentIdController.text.trim();
                                      final password =
                                          _passwordController.text.trim();

                                      try {
                                        // Query the faculty table for a matching username and password
                                        final response = await Supabase
                                            .instance.client
                                            .from('faculty')
                                            .select()
                                            .eq('email', email)
                                            .eq('password', password)
                                            .maybeSingle();

                                        if (response == null) {
                                          // Invalid credentials
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Invalid email or password.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        } else {
                                          // Valid credentials, navigate to HomePage
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage()),
                                          );
                                        }
                                      } catch (error) {
                                        // Handle Supabase errors
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'An error occurred: $error'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'ENTER',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: Color(0xFFF2F8FC)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(), // Pushes the footer up
                buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    double screenWidth = MediaQuery.of(context).size.width;
    double mainFontSize = screenWidth < 800 ? 22.0 : 28.0;
    double subFontSize = screenWidth < 800 ? 14.0 : 18.0;
    double padding = screenWidth < 600 ? 12.0 : 16.0;
    double iconSize = screenWidth < 600 ? 50.0 : 70.0;

    return Container(
      color: const Color(0xFFF2F8FC),
      padding: EdgeInsets.symmetric(vertical: padding, horizontal: padding * 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/image/plsp.png', // Update the path if necessary
            width: iconSize,
            height: iconSize,
          ),
          const SizedBox(width: 10), // Spacing between icon and text

          // Text in the center
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'PAMANTASAN NG LUNGSOD NG SAN PABLO',
                style: TextStyle(
                  fontSize: mainFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4.0),
              Text(
                'College of Computer Studies and Technology',
                style: TextStyle(
                  fontSize: subFontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          const SizedBox(width: 10), // Spacing between text and icon

          // Right icon (ccst.png)
          Image.asset(
            'assets/image/ccst.png', // Add the correct path for the ccst icon
            width: iconSize,
            height: iconSize,
          ),
        ],
      ),
    );
  }

  Widget buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: const Color(0xFF2F8FC),
      child: const Center(
        child: Text(
          '© 2024 Pamantasan ng Lungsod ng San Pablo',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
      ),
    );
  }
}
