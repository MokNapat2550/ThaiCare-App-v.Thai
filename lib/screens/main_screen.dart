import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

// 🚩 ตรวจสอบ Path ไฟล์ในโปรเจกต์ของคุณให้ถูกต้อง
import 'auth/login_screen.dart';
import 'assessment/assessment_screen.dart';
import 'herb_screen.dart';
import 'massage_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  User? get user => FirebaseAuth.instance.currentUser;
  final Color primaryGreen = const Color(0xFF577460);

  int _currentMpGrade = -1;

  // ตัวแปรเก็บข้อมูลสุขภาพ
  String _gender = 'ไม่ระบุ';
  int _age = 0;
  double _weight = 0.0;
  double _height = 0.0;
  double _bmi = 0.0;
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  // โหลดข้อมูลจาก SharedPreferences
  Future<void> _loadHealthData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _gender = prefs.getString('gender') ?? 'ไม่ระบุ';
      _age = prefs.getInt('age') ?? 0;
      _weight = prefs.getDouble('weight') ?? 0.0;
      _height = prefs.getDouble('height') ?? 0.0;
      _bmi = prefs.getDouble('bmi') ?? 0.0;
      _isLoadingData = false;
    });

    // 🚩 แก้ไขตรงนี้: ลบ if (_weight == 0.0) ออก เพื่อให้แสดง Popup ทุกครั้งที่เปิดหน้านี้
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showHealthDataDialog();
      });
    }
  }

  // คำนวณและบันทึกข้อมูล
  Future<void> _saveHealthData(
    String gender,
    int age,
    double weight,
    double height,
  ) async {
    double bmi = 0.0;
    if (height > 0) {
      double heightInMeter = height / 100;
      bmi = weight / (heightInMeter * heightInMeter);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', gender);
    await prefs.setInt('age', age);
    await prefs.setDouble('weight', weight);
    await prefs.setDouble('height', height);
    await prefs.setDouble('bmi', bmi);

    setState(() {
      _gender = gender;
      _age = age;
      _weight = weight;
      _height = height;
      _bmi = bmi;
    });
  }

  // Popup กรอกข้อมูลสุขภาพ
  void _showHealthDataDialog() {
    String tempGender = _gender == 'ไม่ระบุ' ? 'ชาย' : _gender;
    TextEditingController ageController = TextEditingController(
      text: _age > 0 ? _age.toString() : '',
    );
    TextEditingController weightController = TextEditingController(
      text: _weight > 0 ? _weight.toString() : '',
    );
    TextEditingController heightController = TextEditingController(
      text: _height > 0 ? _height.toString() : '',
    );

    showDialog(
      context: context,
      barrierDismissible: false, // บังคับให้กรอกข้อมูล
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.health_and_safety, color: primaryGreen),
                  const SizedBox(width: 10),
                  const Text(
                    'ข้อมูลสุขภาพของคุณ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ข้อมูลนี้จะใช้เพื่อคำนวณการแนะนำยาสมุนไพรและปริมาณน้ำที่เหมาะสมครับ',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: tempGender,
                      decoration: InputDecoration(
                        labelText: 'เพศ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items: ['ชาย', 'หญิง', 'ไม่ระบุ']
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => tempGender = val!),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'อายุ (ปี)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'น้ำหนัก (กก.)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'ส่วนสูง (ซม.)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    int age = int.tryParse(ageController.text) ?? 0;
                    double weight =
                        double.tryParse(weightController.text) ?? 0.0;
                    double height =
                        double.tryParse(heightController.text) ?? 0.0;

                    if (age > 0 && weight > 0 && height > 0) {
                      _saveHealthData(tempGender, age, weight, height);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                  ),
                  child: const Text(
                    'บันทึกข้อมูล',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateMpGrade(int grade) {
    setState(() => _currentMpGrade = grade);
  }

  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // ล้างข้อมูลสุขภาพตอนออกจากระบบ

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (c) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }

  // ส่งข้อมูลทั้งหมดไปให้หน้าต่างๆ
  List<Widget> get _screens => [
    AssessmentScreen(onMpUpdate: _updateMpGrade),
    HerbScreen(
      mpGrade: _currentMpGrade,
      weight: _weight,
      height: _height,
      gender: _gender,
      bmi: _bmi,
    ),
    const MassageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Image.asset(
          'assets/logo/logo2.png',
          height: 50,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Text(
            "🌿 ThaiCare",
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [_buildProfileMenu(), const SizedBox(width: 10)],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.assignment_outlined, 'ประเมิน', 'checkPop'),
          _buildNavItem(1, Icons.eco_outlined, 'สมุนไพร', 'sway'),
          _buildNavItem(2, Icons.back_hand_outlined, 'นวดแผนไทย', 'wave'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    String animType,
  ) {
    bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnimatedNavIcon(
              icon: icon,
              isSelected: isSelected,
              animationType: animType,
              activeColor: primaryGreen,
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? primaryGreen : Colors.grey.shade400,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMenu() {
    String displayName = user?.email != null
        ? user!.email!.split('@')[0]
        : "ผู้ใช้งาน";

    String bmiStatus = "";
    Color bmiColor = Colors.grey;

    if (_bmi > 0) {
      if (_bmi < 18.5) {
        bmiStatus = "น้ำหนักน้อย";
        bmiColor = Colors.orange;
      } else if (_bmi <= 22.9) {
        bmiStatus = "ปกติ";
        bmiColor = Colors.green;
      } else if (_bmi <= 24.9) {
        bmiStatus = "ท้วม";
        bmiColor = Colors.amber;
      } else {
        bmiStatus = "อ้วน";
        bmiColor = Colors.red;
      }
    }

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFFA8E6CF),
        backgroundImage: (user?.photoURL != null)
            ? NetworkImage(user!.photoURL!)
            : null,
        child: (user?.photoURL == null)
            ? const Icon(Icons.person, color: Colors.white, size: 20)
            : null,
      ),
      itemBuilder: (c) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              Text(
                user?.email ?? "",
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              if (_bmi > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: bmiColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'BMI: ${_bmi.toStringAsFixed(1)} ($bmiStatus)',
                    style: TextStyle(
                      color: bmiColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'นน. $_weight กก. | สส. $_height ซม.',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'edit_profile',
          child: Row(
            children: [
              Icon(Icons.edit_note, color: primaryGreen, size: 20),
              const SizedBox(width: 10),
              const Text("แก้ไขข้อมูลสุขภาพ"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 20),
              const SizedBox(width: 10),
              const Text("ออกจากระบบ", style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      onSelected: (v) {
        if (v == 'logout') _signOut();
        if (v == 'edit_profile') _showHealthDataDialog();
      },
    );
  }
}

class _AnimatedNavIcon extends StatefulWidget {
  final IconData icon;
  final bool isSelected;
  final String animationType;
  final Color activeColor;

  const _AnimatedNavIcon({
    required this.icon,
    required this.isSelected,
    required this.animationType,
    required this.activeColor,
  });

  @override
  State<_AnimatedNavIcon> createState() => _AnimatedNavIconState();
}

class _AnimatedNavIconState extends State<_AnimatedNavIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    if (widget.isSelected) _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedNavIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        Color iconColor = Color.lerp(
          Colors.grey.shade400,
          widget.activeColor,
          _controller.value,
        )!;

        if (widget.animationType == "checkPop") {
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Transform.translate(
                offset: Offset(0, -3 * _animation.value),
                child: Icon(widget.icon, color: iconColor, size: 28),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Transform.scale(
                  scale: _animation.value,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: widget.activeColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else if (widget.animationType == "sway") {
          return Transform.rotate(
            angle: math.sin(_controller.value * math.pi) * 0.15,
            child: Icon(widget.icon, color: iconColor, size: 28),
          );
        } else if (widget.animationType == "wave") {
          return Transform.rotate(
            angle: math.sin(_controller.value * math.pi * 2) * 0.2,
            alignment: Alignment.bottomCenter,
            child: Icon(widget.icon, color: iconColor, size: 28),
          );
        }
        return Icon(widget.icon, color: iconColor, size: 28);
      },
    );
  }
}