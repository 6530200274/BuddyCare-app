import 'package:flutter/material.dart';
import 'package:my_app/screens/officer/schedule_officer_screen.dart';
import 'package:my_app/screens/officer/schedule_page_officer.dart';

class HomeScheduleScreen extends StatefulWidget {
  const HomeScheduleScreen({super.key});

  @override
  State<HomeScheduleScreen> createState() => _HomeScheduleScreenState();
}

class _HomeScheduleScreenState extends State<HomeScheduleScreen> {

  int myIndex = 0;

  List<Widget> widgetList = const [
    ScheduleHomeScreen(), //Text('หน้าแรก', style: TextStyle(fontSize: 40)),
    Text('ข้อความ', style: TextStyle(fontSize: 40)),
    ScheduleOfficerScreen(), //Text('เพิ่มตารางงาน', style: TextStyle(fontSize: 40)),
    Text('แจ้งเตือน', style: TextStyle(fontSize: 40)),
    Text('โปรไฟล์', style: TextStyle(fontSize: 40)),
  ];

  Widget _buildCircleIcon(IconData icon, bool isActive) {
    const orange = Color(0xFFFF7A00);
    const grey = Color(0xFF9E9E9E);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isActive ? orange : Colors.white, // วงกลมส้มเมื่อ active
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 24,
        color: isActive ? Colors.white : orange, //  ไอคอนขาวเมื่อ active
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    const orange = Color(0xFFFF7A00);
    const bg = Color(0xFFFFF7EF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(left: 2, top: 6),
          child: Row(
            // -------- Image profile --------
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFFEAEAEA),
              ),
              const SizedBox(width: 12),
              // -------- User name --------
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "สวัสดี!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "ชลธิชา รัตนกุล",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      body: IndexedStack(
        children: widgetList,
        index: myIndex,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFCECDD),
        selectedItemColor: const Color(0xFFFF7A00),
        unselectedItemColor: const Color(0xFFFF7A00),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        items: [
          BottomNavigationBarItem(
            icon: _buildCircleIcon(Icons.home_filled, false),
            activeIcon: _buildCircleIcon(Icons.home_filled, true),
            label: "หน้าแรก",
          ),
          BottomNavigationBarItem(
            icon: _buildCircleIcon(Icons.message_rounded, false),
            activeIcon: _buildCircleIcon(Icons.message_rounded, true),
            label: "ข้อความ",
          ),
          BottomNavigationBarItem(
            icon: _buildCircleIcon(Icons.add, false),
            activeIcon: _buildCircleIcon(Icons.add, true),
            label: "เพิ่มตารางงาน",
          ),
          BottomNavigationBarItem(
            icon: _buildCircleIcon(Icons.notifications_none_rounded, false),
            activeIcon: _buildCircleIcon(
              Icons.notifications_none_rounded,
              true,
            ),
            label: "แจ้งเตือน",
          ),
          BottomNavigationBarItem(
            icon: _buildCircleIcon(Icons.person, false),
            activeIcon: _buildCircleIcon(Icons.person, true),
            label: "โปรไฟล์",
          ),
        ],
      ),
    );
  }
}