import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adminsuper/home_page.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const FacultyMembersPage(),
    );
  }
}

class FacultyMembersPage extends StatefulWidget {
  const FacultyMembersPage({super.key});

  @override
  State<FacultyMembersPage> createState() => _FacultyMembersPageState();
}

class _FacultyMembersPageState extends State<FacultyMembersPage> {
  final List<Faculty> facultyList = [];
  bool isLoading = true;

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
            'assets/image/plsp.png',
            width: iconSize,
            height: iconSize,
          ),
          const SizedBox(width: 10),
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
          const SizedBox(width: 10),
          Image.asset(
            'assets/image/ccst.png',
            width: iconSize,
            height: iconSize,
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchFaculty();
  }

  Future<void> fetchFaculty() async {
    try {
      final response =
          await Supabase.instance.client.from('faculty').select('*');
      final List<Faculty> fetchedFaculty = (response as List)
          .map((facultyData) => Faculty(
                id: facultyData['id'].toString(),
                name: facultyData['name'],
                email: facultyData['email'],
                password: facultyData['password'],
                color: Colors.grey,
              ))
          .toList();
      print(response);

      setState(() {
        facultyList.clear();
        facultyList.addAll(fetchedFaculty);
        isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching faculty data: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

Future<void> updateFaculty(Faculty faculty) async {
  try {
      await Supabase.instance.client.from('faculty').update({
        'name': faculty.name,
        'email': faculty.email,
        'password': faculty.password,
      }).eq('id', faculty.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${faculty.name}\'s data updated successfully!'),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
        ),
      );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update ${faculty.name}: $e'),
        action: SnackBarAction(
          label: 'Retry',
          onPressed: () {
            updateFaculty(faculty); // Retry updating
          },
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty'),
        backgroundColor: Color(0xFFF2F8FC),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C9B44)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
      backgroundColor: Color(0xFFF2F8FC),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth < 600
                    ? 1 // Single column for narrow screens
                    : constraints.maxWidth < 1024
                        ? 2 // Two columns for medium screens
                        : 3; // Three columns for wider screens
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      buildHeader(), // Add the header here
                      const SizedBox(
                          height: 16), // Add some spacing below the header
                      GridView.builder(
                        itemCount: facultyList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final faculty = facultyList[index];
                          return FacultyCard(
                            faculty: faculty,
                            onSave: (updatedFaculty) {
                              setState(() {
                                facultyList[index] = updatedFaculty;
                              });
                              updateFaculty(updatedFaculty);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class Faculty {
  final String id;
  final String name;
  final String email;
  final String password;
  final Color color;

  Faculty({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.color,
  });
}

class FacultyCard extends StatefulWidget {
  final Faculty faculty;
  final void Function(Faculty updatedFaculty) onSave;

  const FacultyCard({
    super.key,
    required this.faculty,
    required this.onSave,
  });

  @override
  _FacultyCardState createState() => _FacultyCardState();
}

class _FacultyCardState extends State<FacultyCard> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.faculty.name);
    emailController = TextEditingController(text: widget.faculty.email);
    passwordController = TextEditingController(text: widget.faculty.password);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: widget.faculty.color,
            child: const Icon(Icons.person, size: 40),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              widget.onSave(
                Faculty(
                  id: widget.faculty.id,
                  name: nameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  color: widget.faculty.color,
                ),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }
}
