import 'package:flutter/material.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> introData = [
    {
      "title": "ยินดีต้อนรับเข้าสู่ ThaiCare",
      "subtitle": "ผู้ช่วยดูแลผู้ป่วยระยะกลางที่บ้าน\nด้วยศาสตร์แพทย์แผนไทย",
      "type": "png", 
      "value": "assets/logo/logo2.png", 
      "heightFactor": 0.25, // ใช้ 25% ของความสูงจอ
    },
    {
      "title": "ประเมินและติดตาม",
      "subtitle": "ระบบประเมิน ADL และ Motor Power\nที่เข้าใจง่ายและแม่นยำ",
      "type": "gif", 
      "value": "assets/onBoarding/assessment.gif",
      "heightFactor": 0.45, // ใช้ 45% ของความสูงจอ
    },
    {
      "title": "แนะนำยาสมุนไพร",
      "subtitle": "คำแนะนำยาสมุนไพรตามอาการ\nของผู้ป่วยแต่ละบุคคล",
      "type": "gif", 
      "value": "assets/onBoarding/herbs.gif",
      "heightFactor": 0.40,
    },
    {
      "title": "ท่านวดพื้นฐาน",
      "subtitle": "ท่าทางการนวด 15 ท่าพื้นฐาน",
      "type": "png", 
      "value": "assets/onBoarding/gg.png", 
      "heightFactor": 0.35,
    }
  ];

  @override
  Widget build(BuildContext context) {
    // คำนวณความสูงหน้าจอทั้งหมด
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, 
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (v) => setState(() => _currentPage = v),
                itemCount: introData.length,
                itemBuilder: (context, i) {
                  var data = introData[i];
                  return SingleChildScrollView( // 🚩 เพิ่มกันเหนียวกรณีจอเล็กจิ๋วหรือเปิดแนวนอน
                    child: Column(
                      children: [
                        // 🚩 ปรับพื้นที่รูปภาพให้ยืดหยุ่นตามความสูงจอ
                        Container(
                          height: screenHeight * 0.55, // จองที่ให้รูปสูงสุด 55% ของจอ
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: _buildIntroMedia(data, screenHeight),
                        ),
                        
                        const SizedBox(height: 20), 

                        // ส่วนข้อความ Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            data["title"]!, 
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold, 
                              color: Color(0xFF577460)
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // ส่วนข้อความ Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            data["subtitle"]!, 
                            textAlign: TextAlign.center, 
                            style: const TextStyle(
                              fontSize: 15, 
                              color: Colors.grey, 
                              height: 1.4
                            ),
                          ),
                        ),
                        const SizedBox(height: 20), // เพิ่มระยะห่างล่างสุด
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // ส่วนควบคุมด้านล่าง (Dots + Next Button)
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 40, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(introData.length, (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 8),
              height: 8,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? const Color(0xFF577460) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            )),
          ),
          
          InkWell(
            onTap: () {
              if (_currentPage == introData.length - 1) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const LoginScreen()));
              } else {
                _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
              }
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                color: Color(0xFF577460),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  // ฟังก์ชันจัดการสื่อ (ปรับปรุงให้ใช้สัดส่วนหน้าจอ)
  Widget _buildIntroMedia(Map<String, dynamic> data, double screenHeight) {
    // คำนวณความสูงจากสัดส่วน (Factor)
    double targetHeight = screenHeight * (data['heightFactor'] ?? 0.3);

    if (data['type'] == 'gif' || data['type'] == 'png') {
      return Image.asset(
        data['value'], 
        height: targetHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => 
          Icon(Icons.image_outlined, size: 100, color: Colors.grey.withOpacity(0.5)),
      );
    } 
    return Icon(Icons.image, size: targetHeight * 0.5, color: const Color(0xFF577460));
  }
}