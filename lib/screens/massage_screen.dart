import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui';

class MassageScreen extends StatefulWidget {
  const MassageScreen({Key? key}) : super(key: key);

  @override
  State<MassageScreen> createState() => _MassageScreenState();
}

class _MassageScreenState extends State<MassageScreen> with TickerProviderStateMixin {
  bool _isStarted = false;
  final PageController _pageController = PageController();
  int _currentStep = 0;

  late AnimationController _floatingController;
  late Animation<double> _floatingAnimation;

  final Color primaryGreen = const Color(0xFF577460);
  final Color accentOrange = const Color(0xFFFFAB91);
  final Color bgLight = const Color(0xFFF8FAF8);

  final List<Map<String, dynamic>> massageSteps = [
    {"title": "ท่าที่ 1 นวดคลายกล้ามเนื้อฝ่ามือ", "patient": "หงายฝ่ามือ", "masseur": "ใช้นิ้วหัวแม่มือข้างใดข้างหนึ่งวางทับหัวแม่มืออีกข้างหนึ่ง\nจุดนวดที่ ๑: เนินใหญ่ของฝ่ามือแนวนิ้วโป้ง\nจุดนวดที่ ๒: กึ่งกลางฝ่ามือตรงบริเวณนิ้วกลาง\nจุดนวดที่ ๓: เนินเล็กของฝ่ามือตรงบริเวณนิ้วก้อย","image": "assets/massage/1.png"},
    {"title": "ท่าที่ 2 นวดคลายแขนด้านใน (เส้น ๑-๒)", "patient": "หงายมือ", "masseur": "ใช้นิ้วหัวแม่มือคู่\nเส้น ๑: นวดแนวนิ้วกลางจากเหนือมือถึงต้นแขนด้านใน\nเส้น ๒: นวดแนวนิ้วก้อยจากเหนือข้อมือถึงต้นแขน\n*เว้นการนวดบริเวณข้อพับ*","image": "assets/massage/2.png"},
    {"title": "ท่าที่ 3 นวดคลายกล้ามเนื้อหลังมือ", "patient": "คว่ำมือ", "masseur": "ใช้นิ้วหัวแม่มือทั้งสองข้างวางซ้อนกัน กดเบาๆ บริเวณร่องระหว่างนิ้วต่างๆ (นิ้วโป้งกับชี้, ชี้กับกลาง, กลางกับนาง, นางกับก้อย)","image": "assets/massage/3.png"},
    {"title": "ท่าที่ 4 นวดคลายแขนด้านนอก (เส้น ๑-๒)", "patient": "คว่ำมือ", "masseur": "ใช้นิ้วหัวแม่มือคู่\nเส้น ๑: นวดแนวนิ้วกลางจากเหนือข้อมือถึงต้นแขน\nเส้น ๒: นวดแนวนิ้วก้อยจากเหนือข้อมือถึงต้นแขน\n*เว้นบริเวณข้อศอก*","image": "assets/massage/4.png"},
    {"title": "ท่าที่ 5 ลูบเอาใจ", "patient": "นอนท่าคว่ำมือ", "masseur": "ชโลมน้ำมัน ใช้อุ้งมือลูบเบาๆ จากหลังมือถึงต้นแขน หมุนฝ่ามือโอบข้างต้นแขนรูดลงมาถึงข้อมือ","image": "assets/massage/5.gif"},
    {"title": "ท่าที่ 6 การนวดวนก้นหอย (แขน)", "patient": "หงายมือ", "masseur": "ใช้นิ้วหัวแม่มือเดี่ยว กดหมุนทวนเข็มนาฬิกา แนวนิ้วกลางและแนวนิ้วก้อย ไล่ไปจนถึงต้นแขน *เว้นข้อศอก*","image": "assets/massage/6.gif"},
    {"title": "ท่าที่ 7 รีดกล้ามเนื้อแขนด้านใน", "patient": "หงายมือ", "masseur": "ใช้นิ้วหัวแม่มือเดี่ยว กดรีดแนวนิ้วกลางและแนวนิ้วก้อย ไล่ไปจนถึงต้นแขน (รีดขึ้นอย่างเดียว *เว้นข้อพับ*)","image": "assets/massage/7.gif"},
    {
      "title": "ท่าที่ 8 นวดสัมผัสขาด้านนอก (3 เส้น)", 
      "patient": "นอนหงาย", 
      "images": ["assets/massage/8(1).gif", "assets/massage/8(2).gif"], 
      "masseurs": [
        "ส่วนที่ 1: ใช้นิ้วหัวแม่มือคู่ วางชิดกระดูกสันหน้าแข้ง เหนือข้อเท้า แล้วกดไล่ไปจนถึงชิดกระดูกข้อเข่า\nและใช้นิ้วหัวแม่มือคู่ คว่ำมือวางห่างจากแนวตาตุ่มประมาณ ๒ นิ้วมือกดเบาๆ จากตาตุ่มไล่ไปจนถึงชิดกระดูกข้อเข่า (ห่างเข่าประมาณ ๒ นิ้วมือ)",
        "ส่วนที่ 2: ใช้นิ้วหัวแม่มือคู่คว่ำมือวางห่างจากแนวใต้ตาตุ่มประมาณ ๒ นิ้วมือกดเบาๆ จากสันใต้ตาตุ่มไล่ไปจนถึงชิดกระดูกข้อเข่า (ห่างเข่าประมาณ ๒ นิ้วมือ)"
      ]
    },
    {"title": "ท่าที่ 9 ท่าลูบเอาใจ (ขา)", "patient": "นอนหงาย", "masseur": "ชโลมน้ำมัน ใช้อุ้งมือลูบขึ้นจากข้อเท้าถึงต้นขา หมุนฝ่ามือโอบข้างต้นขารูดลงมาถึงข้อเท้า","image": "assets/massage/9.gif"},
    {
      "title": "ท่าที่ 10 นวดวนก้นหอยกล้ามเนื้อขา", 
      "patient": "นอนหงาย", 
      "images": ["assets/massage/10(1).gif", "assets/massage/10(2).gif"],
      "masseurs": [
        "ส่วนที่ 1: นวดวนก้นหอยขาด้านในเริ่มตั้งแต่แนวตาตุ่มด้านในกดวนก้นหอยไล่ขึ้นไปจนถึงข้อเข่า (ด้านใน) และนวดต่อแนวขาท่อนบน (ด้านใน)จนไปถึงขาหนีบ", 
        "ส่วนที่ 2: ใช้นิ้วหัวแม่มือเดี่ยว ไล่ไปจนถึงข้อเข่าและขาหนีบ นวดวนกันหอย\nขาด้านนอก กดวนกันหอยไล่ขึ้นไปจนถึงข้อเข่า (ด้านนอก) และนวดต่อแนวขาท่อนบน (ด้านนอก) จนไปถึงแนวกระดูกเชิงกราน"
      ]
    },
    {
      "title": "ท่าที่ 11 รีดกล้ามเนื้อขาด้านใน", 
      "patient": "นอนหงาย", 
      "images": ["assets/massage/11(1).gif", "assets/massage/11(2).gif"],
      "masseurs": [
        "ส่วนที่ 1: ใช้นิ้วหัวแม่มือเดี่ยว รีดขาด้านใน เริ่มตั้งแต่แนวตาตุ่มด้านใน รีดไล่ขึ้นไปจนถึงหัวเข่า และกดรีดต่อแนวขาท่อนบน จนไปถึงขาหนีบ", 
        "ส่วนที่ 2: นวดขาด้านนอก เริ่มตั้งแต่แนวตาตุ่มด้านนอก รีดไล่ขึ้นไปจนถึงข้อเข่า และรีดต่อแนวขาท่อนบน จนไปถึงแนวกระดูกเชิงกราน"
      ]
    },
    {"title": "ท่าที่ 12 รีดกล้ามเนื้อขาด้านนอก", "patient": "นอนตะแคงข้าง", "masseur": "ใช้นิ้วหัวแม่มือคู่ รีดแนวชิดกระดูกสันหน้าแข้ง และแนวตาตุ่ม ไล่ไปข้ามหัวเข่าจนถึงขาหนีบ","image": "assets/massage/12.gif"},
    {"title": "ท่าที่ 13 นวดคลายกล้ามเนื้อหลัง (๒ เส้น)", "patient": "นอนตะแคงข้าง", "masseur": "ใช้สันมือกดเบาๆ ชิดกระดูกสันหลัง เริ่มจากบั้นเอวกดไล่ขึ้นเรื่อยๆ จนถึงบริเวณต้นคอ (นวดขึ้นอย่างเดียว)","image": "assets/massage/13.gif"},
    {"title": "ท่าที่ 14 นวดวนก้นหอยหลัง", "patient": "นอนตะแคงข้าง", "masseur": "ใช้นิ้วหัวแม่มือทั้ง ๒ ข้างกดวนเป็นก้นหอย ชิดกระดูกสันหลัง กดไล่ขึ้นไปเรื่อยๆ จนถึงต้นคอ","image": "assets/massage/14.gif"},
    {"title": "ท่าที่ 15 ท่านวดเอาใจ (จบ)", "patient": "นอนคว่ำ หรือ นอนตะแคง", "masseur": "ใช้อุ้งมือลูบขึ้นจากเอวไปถึงบ่าไหล่ จากนั้นหมุนฝ่ามือแล้วลูบลงด้านข้างลำตัวลงมาจนถึงเอว","image": "assets/massage/15.gif"},
  ];

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showBloodPressureWarning() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Icon(Icons.report_problem_rounded, size: 60, color: accentOrange),
        content: Text(
          "ความดันโลหิตสูงเกิน 140/90 mmHg หรือไม่?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: primaryGreen, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("เกินเกณฑ์", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
            ),
            onPressed: () { 
              Navigator.pop(context); 
              setState(() => _isStarted = true); 
            },
            child: const Text("ปกติ", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isStarted) {
      return Scaffold(
        backgroundColor: bgLight,
        body: Stack(
          children: [
            const FloatingBackground(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingAnimation.value),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        height: 200,
                        width: 200,
                        child: Center(
                          child: Image.asset(
                            'assets/onBoarding/gg.png', 
                            height: 150,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.back_hand_rounded, size: 80, color: primaryGreen),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "การนวดแผนไทย",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryGreen),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "ทักษะการนวดพื้นฐาน 15 ท่า\nสำหรับฟื้นฟูร่างกาย",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
                    ),
                    const SizedBox(height: 48),
                    ElevatedButton(
                      onPressed: _showBloodPressureWarning,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text("เริ่มการนวด", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          const FloatingBackground(),
          Column(
            children: [
              _buildModernAppBar(),
              LinearProgressIndicator(
                value: (_currentStep + 1) / 15, 
                backgroundColor: Colors.white.withOpacity(0.5), 
                color: primaryGreen,
                minHeight: 6,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: massageSteps.length,
                  itemBuilder: (context, index) {
                    var step = massageSteps[index];
                    List<String> displayImages = step.containsKey('images') ? List<String>.from(step['images']) : [step['image'] ?? 'assets/massage/f.png'];
                    List<String> displayMasseurs = step.containsKey('masseurs') ? List<String>.from(step['masseurs']) : [step['masseur'] ?? 'ไม่มีคำอธิบาย'];

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            step["title"]!, 
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryGreen),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(height: 24),
                          
                          for (int i = 0; i < displayImages.length; i++) ...[
                            _buildImageCard(displayImages[i]),
                            const SizedBox(height: 16),
                            _buildInstructionCard(
                              icon: Icons.front_hand_rounded,
                              title: displayImages.length > 1 ? "วิธีนวด (ส่วนที่ ${i+1})" : "วิธีนวดสำหรับผู้นวด",
                              text: displayMasseurs[i],
                              color: primaryGreen,
                            ),
                            const SizedBox(height: 16),
                          ],

                          _buildInstructionCard(
                            icon: Icons.person_rounded,
                            title: "ท่าทางของผู้ป่วย",
                            text: step["patient"]!,
                            color: accentOrange,
                          ),
                          
                          const SizedBox(height: 16),

                          Builder(builder: (context) {
                            String warning = "โปรดนวดด้วยความระมัดระวัง";
                            if (index >= 0 && index <= 6) {
                              warning += "\n(เมื่อนวดเสร็จ ให้สลับทำซ้ำแบบเดียวกัน ทั้งแขนซ้ายและแขนขวา)";
                            } else if (index >= 7 && index <= 11) {
                              warning += "\n(เมื่อนวดเสร็จ ให้สลับทำซ้ำแบบเดียวกัน ทั้งขาซ้ายและขาขวา)";
                            }
                            
                            return _buildInstructionCard(
                              icon: Icons.warning_amber_rounded,
                              title: "คำเตือน & คำแนะนำ",
                              text: warning,
                              color: Colors.red.shade600,
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          
          Positioned(
            bottom: 30, left: 24, right: 24,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentStep == 0
                        ? null
                        : () {
                            _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                            setState(() => _currentStep--);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentStep == 0 ? Colors.grey.shade300 : Colors.grey.shade200,
                      foregroundColor: _currentStep == 0 ? Colors.grey : primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: const Text("ย้อนกลับ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentStep == massageSteps.length - 1) {
                        _finishMassage();
                      } else {
                        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                        setState(() => _currentStep++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      shadowColor: primaryGreen.withOpacity(0.4),
                    ),
                    child: Text(_currentStep == massageSteps.length - 1 ? 'เสร็จสิ้น' : 'ท่าถัดไป', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          color: bgLight.withOpacity(0.6),
          child: AppBar(
            title: Text('ท่าที่ ${_currentStep + 1} จาก 15', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 18)),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded), 
              onPressed: () => setState(() => _isStarted = false)
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildInstructionCard({required IconData icon, required String title, required String text, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                const SizedBox(height: 4),
                Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _finishMassage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: Text("ยินดีด้วย!", textAlign: TextAlign.center, style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
        content: const Text("คุณได้เรียนรู้และฝึกทำครบ\nทั้ง 15 ท่าเรียบร้อยแล้ว", textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              onPressed: () { 
                Navigator.pop(context); 
                setState(() { _isStarted = false; _currentStep = 0; }); 
              },
              child: const Text("กลับหน้าหลัก", style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class FloatingBackground extends StatelessWidget {
  const FloatingBackground({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const FloatingBlob(top: 50, left: -20, size: 150, color: Color(0xFFE8F5E9)),
        const FloatingBlob(top: 250, right: -40, size: 200, color: Color(0xFFFFF3E0)),
        const FloatingBlob(bottom: 150, left: 20, size: 80, color: Color(0xFFC8E6C9)),
        const FloatingBlob(top: 100, right: 40, size: 60, color: Color(0xFFFFE0B2)),
      ],
    );
  }
}

class FloatingBlob extends StatefulWidget {
  final double? top, left, right, bottom;
  final double size;
  final Color color;
  const FloatingBlob({Key? key, this.top, this.left, this.right, this.bottom, required this.size, required this.color}) : super(key: key);
  @override
  State<FloatingBlob> createState() => _FloatingBlobState();
}

class _FloatingBlobState extends State<FloatingBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 4 + math.Random().nextInt(4)))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top, left: widget.left, right: widget.right, bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(10 * math.sin(_controller.value * 2 * math.pi), 20 * math.cos(_controller.value * 2 * math.pi)),
            child: child,
          );
        },
        child: Container(width: widget.size, height: widget.size, decoration: BoxDecoration(color: widget.color.withOpacity(0.6), borderRadius: BorderRadius.circular(widget.size / 2.5))),
      ),
    );
  }
}