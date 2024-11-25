import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/home_page.dart';

// College Program Table
// INSERT INTO "public"."college_program" ("id", "name", "department_id") VALUES ('1', 'BSIT', '1');

// Teacher Table
// INSERT INTO "public"."teacher" ("id", "first_name", "email", "password", "last_name", "position", "phone", "middle_name", "address", "zip_code", "city", "country", "state", "profilepicture") VALUES ('1', 'Hensonn', 'henz@gmail.com', 'admin', 'Palomado', 'lead', null, null, null, null, null, null, null, null), ('2', 'Audrey', 'audrey@gmail.com', 'audrey123', 'Alinea', 'lead ', '9123456789', 'E', 'Barleta', '1234', '', '🇵🇭    Philippines', 'Laguna', null), ('3', 'Joan', 'jo@gmail.com', 'jo123', 'Lopez', 'lead', null, null, null, null, null, null, null, null);

// Teacher Courses Table
// INSERT INTO "public"."teacher_courses" ("id", "teacher_id", "course_id", "day", "time", "section_id") VALUES ('1', '3', '9', 'Tuesday and Thursday', '8:00 - 9:00', '4'), ('2', '1', '2', 'Tuesday and Thursday', '9:00-10:00', '5'), ('3', '2', '3', 'Monday and Wednesday', '11:00-12:00', '1'), ('4', '2', '6', 'Tuesday and Thursday', '8:00 - 10:30', '3');

// Students Courses Table
// INSERT INTO "public"."student_courses" ("student_id", "course_id", "midterm_grade", "status", "id") VALUES ('2', '3', '1', 'Pending', '3'), ('2', '4', '5', 'Approved', '2'), ('2', '9', '5', 'Pending', '1');

// Students Table
// INSERT INTO "public"."students" ("id", "email", "password", "last_name", "section_id", "program_id", "department_id", "grade_status", "first_name") VALUES ('1', 'test@gmail.com', 'test123', 'Manalo', '2', '1', '1', 'Pending', 'Jiro'), ('2', 'corporal461@gmail.com', 'Alexis-121', 'Corporal ', '1', '1', '1', 'Pending', 'Alexis'), ('3', 'kim@gmail.com', 'kim123', 'Caguite', '1', '1', '1', 'Pending', 'Kim'), ('5', 'hello@gmail.com', '123', 'World', '1', '1', '1', 'Pending', 'Hello');

// College Course Table
// INSERT INTO "public"."college_course" ("id", "name", "year_number", "code", "semester") VALUES ('1', 'Networking 2', '2', 'NET212', '2'), ('2', 'Advanced Software Development', '3', 'ITProfEL1', '1'), ('3', 'Computer Programming 1', '1', 'CC111', '2'), ('4', 'Computer Programming 2', '1', 'CC112', '2'), ('5', 'Computer Programming 3', '2', 'CC123', '1'), ('6', 'Capstone 1', '3', 'CP111', '2'), ('7', 'Teleportation 1', '4', 'TP111', '1'), ('8', 'Teleportation 2', '4', 'TP222', '2'), ('9', 'Living in the IT Era', '1', 'LITE', '1');

// Section Table
// INSERT INTO "public"."section" ("id", "name", "program_id", "year_number", "semester") VALUES ('1', 'C', '1', '1', '2'), ('2', 'D', '1', '2', '1'), ('3', 'E', '1', '3', '2'), ('4', 'A', '1', '1', '1'), ('5', 'B', '1', '3', '1');

class FinalizeGradesScreen extends StatefulWidget {
  @override
  _FinalizeGradesScreenState createState() => _FinalizeGradesScreenState();
}

class _FinalizeGradesScreenState extends State<FinalizeGradesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> pendingGrades = [];
  List<Map<String, dynamic>> approvedGrades = [];
  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  final supabase = Supabase.instance.client;

  Future<void> _fetchGrades() async {
    try {
      final pendingResponse = await supabase.from('student_courses').select('''
    id,
    student_id, 
    course_id, 
    midterm_grade, 
    status, 
    students (
      first_name, 
      last_name, 
      program:program_id (name), 
      section:section_id (name, year_number)
    ),
    college_course (name, code)
  ''').eq('status', 'Pending');

      final approvedResponse = await supabase.from('student_courses').select('''
    id,
    student_id, 
    course_id, 
    midterm_grade, 
    status, 
    students (
      first_name, 
      last_name, 
      program:program_id (name), 
      section:section_id (name, year_number)
    ),
    college_course (name, code)
  ''').eq('status', 'Approved');

      setState(() {
        pendingGrades = pendingResponse
            .map((grade) => {
                  "name":
                      "${grade['students']['first_name']} ${grade['students']['last_name']}",
                  "subject":
                      "${grade['college_course']['code']} - ${grade['college_course']['name']}",
                  "section": grade['students']['program']['name'] +
                      ' - ' +
                      grade['students']['section']['year_number'] +
                      grade['students']['section']['name'],
                  "avatar": 'assets/image/fear.png', // Default avatar
                  "student_course_id": grade['id'],
                  "id": grade['id'],
                })
            .toList();

        approvedGrades = approvedResponse
            .map((grade) => {
                  "name":
                      "${grade['students']['first_name']} ${grade['students']['last_name']}",
                  "subject":
                      "${grade['college_course']['code']} - ${grade['college_course']['name']}",
                  "section": grade['students']['program']['name'] +
                      ' - ' +
                      grade['students']['section']['year_number'] +
                      grade['students']['section']['name'],
                  "avatar": 'assets/image/joy.png', // Default avatar
                  "student_course_id": grade['id'],
                  "id": grade['id'],
                })
            .toList();
      });
      _isLoading = false;
    } catch (error) {
      print('Error fetching grades: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load grades')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> approveGrade(int index) async {
    try {
      final studentCourseId = pendingGrades[index]["student_course_id"];

      // Update status in Supabase
      await supabase
          .from('student_courses')
          .update({'status': 'Approved'}).eq('id', studentCourseId);

      setState(() {
        approvedGrades.add(pendingGrades[index]);
        pendingGrades.removeAt(index);
      });
    } catch (error) {
      print('Error approving grade: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve grade')),
      );
    }
  }

  Future<void> showApproveDialog(int index) async {
    String name = pendingGrades[index]["name"]!;
    bool confirmed = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Approve Grade"),
            content: Text("Do you want to approve this grade for $name?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("Yes"),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await approveGrade(index);
    }
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left icon
          Image.asset(
            'assets/image/plsp.png',
            width: iconSize,
            height: iconSize,
          ),
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
          // Right icon and home button
          Row(
            children: [
              Image.asset(
                'assets/image/ccst.png',
                width: iconSize,
                height: iconSize,
              ),
              IconButton(
                icon: Icon(Icons.home),
                iconSize: iconSize / 2,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildHeader(),
                SizedBox(height: 10),
                Text(
                  "Student Grades",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        // Pending Grades Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Pending Grades",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: pendingGrades.length,
                                  itemBuilder: (context, index) {
                                    return gradeCard(
                                      pendingGrades[index]["name"]!,
                                      pendingGrades[index]["subject"]!,
                                      pendingGrades[index]["section"]!,
                                      pendingGrades[index]["avatar"]!,
                                      onApprove: () => showApproveDialog(index),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        VerticalDivider(thickness: 1, color: Colors.grey),
                        // Approved Grades Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Approved Grades",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              SizedBox(height: 10),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: approvedGrades.length,
                                  itemBuilder: (context, index) {
                                    return gradeCard(
                                      approvedGrades[index]["name"]!,
                                      approvedGrades[index]["subject"]!,
                                      approvedGrades[index]["section"]!,
                                      approvedGrades[index]["avatar"]!,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget gradeCard(
      String name, String subject, String section, String avatarPath,
      {VoidCallback? onApprove}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(avatarPath),
        ),
        title: Text(
          name,
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subject, style: TextStyle(fontFamily: 'Montserrat')),
            Text(section, style: TextStyle(fontFamily: 'Montserrat')),
          ],
        ),
        trailing: onApprove != null
            ? ElevatedButton(
                onPressed: onApprove,
                child: Text("Approve"),
              )
            : null,
      ),
    );
  }
}
