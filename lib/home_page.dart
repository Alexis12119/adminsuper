import 'package:flutter/material.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'main.dart';
import 'finalizegrades.dart';
import 'teachingloads.dart';
import 'manage.dart';
import 'accounts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> cardOrder = ['Manage Students', 'Finalize Grades', 'Teaching Loads', 'Account'];
  final SwiperController _swiperController = SwiperController();

  // Configurable button sizes
  double logoutButtonSize = 40.0;
  double fabButtonSize = 60.0;

  // Function to show sign out confirmation dialog
  Future<void> _showSignOutDialog() async {
    bool confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sign Out"),
        content: Text("Are you sure you want to sign out?"),
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
    ) ?? false;

    if (confirmed) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8FC),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/backgroundplsp.jpg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                buildHeader(),
                // Add space for logout button
                Expanded(
                  child: Center(
                    child: Swiper(
                      controller: _swiperController,
                      itemWidth: 750,
                      itemHeight: 350,
                      loop: true,
                      duration: 1200,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (cardOrder[index] == 'Manage Students') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ManageStudentsScreen()),
                              );
                            } else if (cardOrder[index] == 'Finalize Grades') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => FinalizeGradesScreen()),
                              );
                            } else if (cardOrder[index] == 'Teaching Loads') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => App()),
                              );
                            } else if (cardOrder[index] == 'Account') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AccountsScreen()),
                              );
                            }
                          },
                          child: Container(
                            width: 400,
                            height: 400,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: cardOrder[index] == 'Manage Students'
                                        ? Image.asset(
                                      'assets/image/audience.png',
                                      width: 200,
                                      height: 200,
                                    )
                                        : cardOrder[index] == 'Finalize Grades'
                                        ? Image.asset(
                                      'assets/image/good-mark.png',
                                      width: 200,
                                      height: 200,
                                    )
                                        : cardOrder[index] == 'Teaching Loads'
                                        ? Image.asset(
                                      'assets/image/blackboard.png',
                                      width: 200,
                                      height: 200,
                                    )
                                        : cardOrder[index] == 'Account'
                                        ? Image.asset(
                                      'assets/image/profile.png',
                                      width: 200,
                                      height: 200,
                                    )
                                        : Icon(
                                      Icons.person,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Text(
                                      cardOrder[index],
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: cardOrder.length,
                      layout: SwiperLayout.STACK,
                    ),
                  ),
                ),
              ],
            ),

            // Logout Button (Left side)
            Positioned(
              left: 16,
              top: 40,
              child: IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Colors.black,
                  size: logoutButtonSize,
                ),
                onPressed: _showSignOutDialog,
              ),
            ),

            // FloatingActionButton (Right side)
            Positioned(
              right: 16,
              top: MediaQuery.of(context).size.height / 2 - fabButtonSize / 2,
              child: FloatingActionButton(
                onPressed: () {
                  _swiperController.next();
                },
                backgroundColor: Colors.white,
                elevation: 10,
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.black,
                  size: fabButtonSize * 0.6,
                ),
              ),
            ),
          ],
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
}

void main() {
  runApp(const MaterialApp(home: HomePage()));
}
