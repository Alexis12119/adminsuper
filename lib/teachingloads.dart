import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adminsuper/home_page.dart';

// College Course Table
// INSERT INTO "public"."college_course" ("id", "name", "year_number", "code", "semester") VALUES ('1', 'Networking 2', '2', 'NET212', '2'), ('2', 'Advanced Software Development', '3', 'ITProfEL1', '1'), ('3', 'Computer Programming 1', '1', 'CC111', '2'), ('4', 'Computer Programming 2', '1', 'CC112', '2'), ('5', 'Computer Programming 3', '2', 'CC123', '1'), ('6', 'Capstone 1', '3', 'CP111', '2'), ('7', 'Teleportation 1', '4', 'TP111', '1'), ('8', 'Teleportation 2', '4', 'TP222', '2'), ('9', 'Living in the IT Era', '1', 'LITE', '1');

// Teacher Courses Table
// INSERT INTO "public"."teacher_courses" ("id", "teacher_id", "course_id", "day", "time") VALUES ('1', '3', '9', 'Tuesday and Thursday', '8:00 - 9:00'), ('2', '1', '2', 'Tuesday and Thursday', '9:00-10:00'), ('3', '2', '3', 'Monday and Wednesday', '11:00-12:00'), ('4', '2', '6', 'Tuesday and Thursday', '8:00 - 10:30');

// Section table
// INSERT INTO "public"."section" ("id", "name", "program_id", "year_number", "semester") VALUES ('1', 'C', '1', '1', '2'), ('2', 'D', '1', '2', '1'), ('3', 'E', '1', '3', '2'), ('4', 'A', '1', '1', '1'), ('5', 'B', '1', '3', '1');
// Teacher Table
// INSERT INTO "public"."teacher" ("id", "first_name", "email", "password", "last_name", "position", "phone", "middle_name", "address", "zip_code", "city", "country", "state", "profilepicture") VALUES ('1', 'Hensonn', 'henz@gmail.com', 'admin', 'Palomado', 'lead', null, null, null, null, null, null, null, null), ('2', 'Audrey', 'audrey@gmail.com', 'audrey123', 'Alinea', 'lead ', '9123456789', 'E', 'Barleta', '4004', '*City', '🇵🇭    Philippines', 'Laguna', null), ('3', 'Joan', 'jo@gmail.com', 'jo123', 'Lopez', 'lead', null, null, null, null, null, null, null, null);
class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final TextEditingController courseController = TextEditingController();
  final TextEditingController semesterController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController courseTitleController = TextEditingController();
  final List<String> courses = [];
  int courseId = 0;
  final List<RealtimeChannel> _subscriptions = [];
  // Dropdown values for instructor, day, time, and section
  List<Map<String, dynamic>> instructors = [];
  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  List<String> times = ['8:00 - 9:00', '9:00 - 10:00', '10:00 - 11:00'];
  List<Map<String, dynamic>> sections = [];

  bool showCourseForm = false;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    fetchCourses();
    fetchInstructors();
    fetchSections();
    subscribeToCourseChanges();
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.unsubscribe();
    }
    super.dispose();
  }

  void subscribeToCourseChanges() {
    final courseChannel = supabase
        .channel('public')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'college_course',
            callback: (payload) {
              fetchCourses();
            })
        .subscribe();
    _subscriptions.add(courseChannel);
  }

  // Fetch current courses from Supabase
  Future<void> fetchCourses() async {
    final response = await supabase
        .from('college_course')
        .select('id, name, year_number, code, semester');
    final List<dynamic> fetchedCourses = response;
    setState(() {
      courses.clear();
      for (var course in fetchedCourses) {
        courses.add('${course['code']} - ${course['name']}');
      }
      print(courses);
    });
  }

  // Fetch instructors from Supabase
  Future<void> fetchInstructors() async {
    final response =
        await supabase.from('teacher').select('id, first_name, last_name');
    final List<dynamic> fetchedInstructors = response;
    setState(() {
      instructors = fetchedInstructors
          .map((instructor) => {
                'id': instructor['id'],
                'name': '${instructor['first_name']} ${instructor['last_name']}'
              })
          .toList();
    });
  }

  // Fetch sections from Supabase
  Future<void> fetchSections() async {
    final response =
        await supabase.from('section').select('id, name, year_number');
    final List<dynamic> fetchedSections = response;
    setState(() {
      sections = fetchedSections
          .map((section) => {
                'id': section['id'],
                'name': section['name'],
                'year': section['year_number']
              })
          .toList();
    });
  }

  // Show form for adding new course
  void showCourseFormDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fill out the Information'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Course Code Field
                TextField(
                  controller: courseController,
                  decoration: InputDecoration(
                    labelText: 'Course Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // Course Title Field
                TextField(
                  controller: courseTitleController,
                  decoration: InputDecoration(
                    labelText: 'Course Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // Semester Field
                TextField(
                  controller: semesterController,
                  decoration: InputDecoration(
                    labelText: 'Semester',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),

                // Academic Year Field
                TextField(
                  controller: yearController,
                  decoration: InputDecoration(
                    labelText: 'Year Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),

                // Row for the buttons (Add Course and Cancel)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),

                    // Add Course Button
                    ElevatedButton(
                      onPressed: addCourse,
                      child: Text('Add Course'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2C9B44),
                        foregroundColor: Color(0xFFF2F8FC),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add new course
  Future<void> addCourse() async {
    if (courseTitleController.text.isNotEmpty &&
        semesterController.text.isNotEmpty &&
        yearController.text.isNotEmpty &&
        courseController.text.isNotEmpty) {
      final response = await supabase.from('college_course').insert([
        {
          'name': courseTitleController.text,
          'semester': semesterController.text,
          'year_number': yearController.text,
          'code': courseController.text,
        }
      ]);

      if (response.error == null) {
        setState(() {
          courses.add(courseTitleController.text);
        });
        courseTitleController.clear();
        semesterController.clear();
        yearController.clear();
        courseController.clear(); // Clear the course code controller
      } else {
        print('Error adding course: ${response.error?.message}');
      }
      Navigator.of(context).pop();
    }
  }

  // Delete a specific course
  Future<void> deleteCourse(int index) async {
    final courseName = courses[index];
    final courseCode = courseName.split(' - ')[0];

    final response =
        await supabase.from('college_course').delete().eq('code', courseCode);

    if (response.error == null) {
      setState(() {
        courses.removeAt(index);
      });
    } else {
      print('Error deleting course: ${response.error?.message}');
    }
  }

  void showSelectCourseDialog(String courseTitle) async {
    String? selectedInstructor;
    String? selectedDay;
    String? selectedTime;
    String? selectedSection;
    int? courseYearNumber;
    List<Map<String, dynamic>> availableInstructors = [];

    final courseCode = courseTitle.split(' - ')[0];

    // Get course details including ID
    final courseResponse = await supabase
        .from('college_course')
        .select('id, year_number, semester')
        .eq('code', courseCode)
        .single();

    courseYearNumber = courseResponse['year_number'];
    final courseId = courseResponse['id'];

    // Get already assigned instructors for this course
    final assignedInstructors = await supabase
        .from('teacher_courses')
        .select('teacher_id')
        .eq('course_id', courseId);

    // Create a set of assigned instructor IDs for easier lookup
    final assignedInstructorIds = Set.from(
        assignedInstructors.map((record) => record['teacher_id'].toString()));

    // Filter out already assigned instructors
    availableInstructors = instructors
        .where((instructor) =>
            !assignedInstructorIds.contains(instructor['id'].toString()))
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            double screenWidth = MediaQuery.of(context).size.width;
            double headerFontSize = screenWidth < 600 ? 18.0 : 24.0;
            double padding = screenWidth < 600 ? 12.0 : 20.0;

            return AlertDialog(
              title: Container(
                padding: EdgeInsets.all(padding),
                color: Colors.green,
                child: Text(
                  courseTitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    if (availableInstructors.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'All instructors are already assigned to this course.',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    DropdownButton<String>(
                      hint: Text('Select Instructor'),
                      value: selectedInstructor,
                      items: availableInstructors
                          .map((instructor) => DropdownMenuItem<String>(
                                value: instructor['id'].toString(),
                                child: Text(instructor['name']),
                              ))
                          .toList(),
                      onChanged: availableInstructors.isEmpty
                          ? null
                          : (value) {
                              setDialogState(() {
                                selectedInstructor = value;
                                print('Instructor selected: $value');
                              });
                            },
                    ),
                    DropdownButton<String>(
                      hint: Text('Select Day'),
                      value: selectedDay,
                      items: days
                          .map((day) => DropdownMenuItem<String>(
                                value: day,
                                child: Text(day),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDay = value;
                          print('Day selected: $value');
                        });
                      },
                    ),
                    DropdownButton<String>(
                      hint: Text('Select Time'),
                      value: selectedTime,
                      items: times
                          .map((time) => DropdownMenuItem<String>(
                                value: time,
                                child: Text(time),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedTime = value;
                          print('Time selected: $value');
                        });
                      },
                    ),
                    DropdownButton<String>(
                      hint: Text('Select Section'),
                      value: selectedSection,
                      items: sections
                          .where((section) =>
                              section['year'] == courseYearNumber.toString())
                          .map((section) => DropdownMenuItem<String>(
                                value: section['id'].toString(),
                                child: Text(
                                    '${section['year']}${section['name']}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSection = value;
                          print('Section ID selected: $selectedSection');
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: availableInstructors.isEmpty
                              ? null
                              : () async {
                                  if (selectedInstructor != null &&
                                      selectedDay != null &&
                                      selectedTime != null &&
                                      selectedSection != null) {
                                    await supabase
                                        .from('teacher_courses')
                                        .insert([
                                      {
                                        'teacher_id': selectedInstructor,
                                        'course_id': courseId,
                                        'day': selectedDay,
                                        'time': selectedTime,
                                        'section_id': selectedSection,
                                      }
                                    ]);
                                    Navigator.of(context).pop();
                                  } else {
                                    print('Please select all fields');
                                  }
                                },
                          child: Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      home: Scaffold(
        backgroundColor: Color(0xFFF2F8FC),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildHeader(),
              SizedBox(height: 20),
              Text(
                'Teaching Loads',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: showCourseFormDialog,
                    child: Text('Add Course'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      side: BorderSide(
                        color: Colors.green,
                        width: 2.0,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    courses.length,
                    (index) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        color: Color(0xFF2C9B44),
                        elevation: 4,
                        child: ListTile(
                          title: Text(courses[index],
                              style: TextStyle(color: Color(0xFFF2F8FC))),
                          onTap: () {
                            showSelectCourseDialog(courses[index]);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
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

}
