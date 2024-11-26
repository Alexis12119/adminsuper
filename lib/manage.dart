import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adminsuper/home_page.dart';

class Department {
  final int id;
  final String name;

  Department({required this.id, required this.name});

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Program {
  final int id;
  final String name;
  final int departmentId;

  Program({required this.id, required this.name, required this.departmentId});

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: json['id'],
      name: json['name'],
      departmentId: json['department_id'],
    );
  }
}

class Section {
  final int id;
  final String name;
  final int programId;
  final String yearNumber;
  final int semester;

  Section({
    required this.id,
    required this.name,
    required this.programId,
    required this.yearNumber,
    required this.semester,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
      programId: json['program_id'],
      yearNumber: json['year_number'],
      semester: json['semester'],
    );
  }
}

class UnenrolledStudent {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String status;
  final int yearNumber;
  final int? sectionId;
  final int? programId;
  final int? departmentId;

  UnenrolledStudent({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.status,
    required this.yearNumber,
    this.sectionId,
    this.programId,
    this.departmentId,
  });

  factory UnenrolledStudent.fromJson(Map<String, dynamic> json) {
    return UnenrolledStudent(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      password: json['password'],
      status: json['status'],
      yearNumber: json['year_number'],
      sectionId: json['section_id'],
      programId: json['program_id'],
      departmentId: json['department_id'],
    );
  }
}

class ManageStudentsScreen extends StatefulWidget {
  @override
  _ManageStudentsScreenState createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  TabController? _tabController;
  List<UnenrolledStudent> pendingStudents = [];
  List<Map<String, dynamic>> approvedStudents = [];
  List<Department> departments = [];
  List<Program> programs = [];
  List<Section> sections = [];
  bool isLoading = true;
  List<RealtimeChannel> channels = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  final supabse = Supabase.instance.client;
  void subscribeToChannels() async {
    final unenerolledStudentsChannel = supabase
        .channel('public')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'unenrolled_students',
            callback: (payload) {
              _loadUnenrolledStudents();
            })
        .subscribe();
    final studentsChannel = supabase
        .channel('public')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'students',
            callback: (payload) {
              _loadAllStudents();
            })
        .subscribe();
    channels.add(unenerolledStudentsChannel);
    channels.add(studentsChannel);
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);

      // Load departments
      final departmentsResponse =
          await supabase.from('college_department').select();
      departments = (departmentsResponse as List)
          .map((json) => Department.fromJson(json))
          .toList();

      // Load programs
      final programsResponse = await supabase.from('college_program').select();
      programs = (programsResponse as List)
          .map((json) => Program.fromJson(json))
          .toList();

      // Load sections
      final sectionsResponse = await supabase.from('section').select();
      sections = (sectionsResponse as List)
          .map((json) => Section.fromJson(json))
          .toList();

      // Load all students
      await _loadAllStudents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadAllStudents() async {
    // Load pending students
    final pendingResponse = await supabase
        .from('unenrolled_students')
        .select()
        .eq('status', 'Pending');

    // Load approved students
    final approvedResponse = await supabase.from('students').select('''
          *,
          college_department:department_id(name),
          college_program:program_id(name),
          section:section_id(name, year_number)
        ''').eq('grade_status', 'Pending');

    setState(() {
      pendingStudents = (pendingResponse as List)
          .map((json) => UnenrolledStudent.fromJson(json))
          .toList();
      approvedStudents =
          List<Map<String, dynamic>>.from(approvedResponse as List);
    });
  }

  Future<void> _loadUnenrolledStudents() async {
    final response = await supabase
        .from('unenrolled_students')
        .select()
        .eq('status', 'Pending')
        .not('midterm_grade', 'is', null);

    setState(() {
      pendingStudents = (response as List)
          .map((json) => UnenrolledStudent.fromJson(json))
          .toList();
    });
  }

  Future<void> _approveStudent(UnenrolledStudent student) async {
    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => EnrollmentDialog(
        departments: departments,
        programs: programs,
        sections: sections,
        yearNumber: student.yearNumber,
      ),
    );

    if (result != null) {
      try {
        // Insert into students table
        await supabase.from('students').insert({
          'email': student.email,
          'first_name': student.firstName,
          'last_name': student.lastName,
          'password': student.password,
          'department_id': result['departmentId'],
          'program_id': result['programId'],
          'section_id': result['sectionId'],
          'grade_status': 'Pending',
        });

        // Delete from unenrolled_students
        await supabase
            .from('unenrolled_students')
            .delete()
            .eq('id', student.id);

        _loadUnenrolledStudents();
        _loadAllStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student approved successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error approving student: $e')),
        );
      }
    }
  }

  Future<void> _rejectStudent(UnenrolledStudent student) async {
    try {
      await supabase.from('unenrolled_students').delete().eq('id', student.id);

      await _loadUnenrolledStudents();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rejecting student: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F8FC),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                buildHeader(),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  tabs: [
                    Tab(text: '1st Year'),
                    Tab(text: '2nd Year'),
                    Tab(text: '3rd Year'),
                    Tab(text: '4th Year'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children:
                        List.generate(4, (index) => _buildYearTab(index + 1)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildYearTab(int yearNumber) {
    final yearPendingStudents = pendingStudents
        .where((student) => student.yearNumber == yearNumber)
        .toList();

    final yearApprovedStudents = approvedStudents
        .where((student) =>
            student['section']['year_number'] == yearNumber.toString())
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pending Students Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Students',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: yearPendingStudents.isEmpty
                      ? Center(child: Text('No pending students'))
                      : ListView.builder(
                          itemCount: yearPendingStudents.length,
                          itemBuilder: (context, index) {
                            final student = yearPendingStudents[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                    '${student.firstName} ${student.lastName}'),
                                subtitle: Text(student.email),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () => _approveStudent(student),
                                    ),
                                    IconButton(
                                      icon:
                                          Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _rejectStudent(student),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          // Vertical Divider
          Container(
            width: 1,
            color: Colors.grey[300],
            margin: EdgeInsets.symmetric(horizontal: 16),
          ),
          // Approved Students Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approved Students',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: yearApprovedStudents.isEmpty
                      ? Center(child: Text('No approved students'))
                      : ListView.builder(
                          itemCount: yearApprovedStudents.length,
                          itemBuilder: (context, index) {
                            final student = yearApprovedStudents[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                    '${student['first_name']} ${student['last_name']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(student['email']),
                                    Text(
                                        'Department: ${student['college_department']['name']}'),
                                    Text(
                                        'Program: ${student['college_program']['name']}'),
                                    Text(
                                        'Year & Section: ${student['section']['year_number']}${student['section']['name']}'),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            );
                          },
                        ),
                ),
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

class EnrollmentDialog extends StatefulWidget {
  final List<Department> departments;
  final List<Program> programs;
  final List<Section> sections;
  final int yearNumber;

  EnrollmentDialog({
    required this.departments,
    required this.programs,
    required this.sections,
    required this.yearNumber,
  });

  @override
  _EnrollmentDialogState createState() => _EnrollmentDialogState();
}

class _EnrollmentDialogState extends State<EnrollmentDialog> {
  Department? selectedDepartment;
  Program? selectedProgram;
  Section? selectedSection;

  @override
  Widget build(BuildContext context) {
    final filteredPrograms = widget.programs
        .where((p) =>
            selectedDepartment != null &&
            p.departmentId == selectedDepartment!.id)
        .toList();

    print(widget.sections);
    final filteredSections = widget.sections
        .where((s) =>
            selectedProgram != null &&
            s.programId == selectedProgram!.id &&
            s.yearNumber == widget.yearNumber.toString())
        .toList();

    return AlertDialog(
      title: Text('Select Department, Program, and Section'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Department>(
            value: selectedDepartment,
            hint: Text('Select Department'),
            items: widget.departments.map((dept) {
              return DropdownMenuItem(
                value: dept,
                child: Text(dept.name),
              );
            }).toList(),
            onChanged: (dept) {
              setState(() {
                selectedDepartment = dept;
                selectedProgram = null;
                selectedSection = null;
              });
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<Program>(
            value: selectedProgram,
            hint: Text('Select Program'),
            items: filteredPrograms.map((prog) {
              return DropdownMenuItem(
                value: prog,
                child: Text(prog.name),
              );
            }).toList(),
            onChanged: selectedDepartment == null
                ? null
                : (prog) {
                    setState(() {
                      selectedProgram = prog;
                      selectedSection = null;
                    });
                  },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<Section>(
            value: selectedSection,
            hint: Text('Select Section'),
            items: filteredSections.map((sect) {
              return DropdownMenuItem(
                value: sect,
                child: Text(sect.name),
              );
            }).toList(),
            onChanged: selectedProgram == null
                ? null
                : (sect) {
                    setState(() {
                      selectedSection = sect;
                    });
                  },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedSection == null
              ? null
              : () {
                  Navigator.pop(context, {
                    'departmentId': selectedDepartment!.id,
                    'programId': selectedProgram!.id,
                    'sectionId': selectedSection!.id,
                  });
                },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
