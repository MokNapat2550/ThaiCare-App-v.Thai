import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MaterialApp(
    home: MotorPowerScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

// 🚩 หน้าหลัก: โครงร่างคนจำลอง (Body Map) และสรุปผล
class MotorPowerScreen extends StatefulWidget {
  const MotorPowerScreen({Key? key}) : super(key: key);

  @override
  State<MotorPowerScreen> createState() => _MotorPowerScreenState();
}

class _MotorPowerScreenState extends State<MotorPowerScreen> {
  // เก็บเกรด 0-5 ของแต่ละส่วน
  final Map<String, int?> _results = {
    "แขนขวา": null,
    "แขนซ้าย": null,
    "ขาขวา": null,
    "ขาซ้าย": null,
  };

  final Color primaryGreen = const Color(0xFF577460);

  // ฟังก์ชันหาเกรดที่น้อยที่สุด (Final Motor Power)
  int? get _finalGlobalGrade {
    List<int> completedGrades = _results.values.whereType<int>().toList();
    if (completedGrades.isEmpty) return null;
    return completedGrades.reduce(math.min);
  }

  @override
  Widget build(BuildContext context) {
    int doneCount = _results.values.where((v) => v != null).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text("ประเมิน Motor Power", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressHeader(doneCount),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Layer 1: รูปโครงร่างคนจำลอง (Body Map)
                Center(
                  child: Opacity(
                    opacity: 0.3,
                    child: Icon(Icons.accessibility_new_rounded, 
                      size: MediaQuery.of(context).size.height * 0.4, 
                      color: primaryGreen),
                  ),
                ),

                // Layer 2: จุดกดประเมิน
                _buildBodyPartPoint(label: "แขนขวา", top: 140, left: 45),
                _buildBodyPartPoint(label: "แขนซ้าย", top: 140, right: 45),
                _buildBodyPartPoint(label: "ขาขวา", bottom: 150, left: 80),
                _buildBodyPartPoint(label: "ขาซ้าย", bottom: 150, right: 80),
              ],
            ),
          ),
          if (doneCount == 4) _buildResultCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(int done) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text("ประเมินครบ $done จาก 4 ส่วน", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: done / 4,
            backgroundColor: Colors.grey.shade200,
            color: primaryGreen,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyPartPoint({required String label, double? top, double? left, double? right, double? bottom}) {
    bool isDone = _results[label] != null;

    return Positioned(
      top: top, left: left, right: right, bottom: bottom,
      child: GestureDetector(
        onTap: () async {
          final grade = await Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => MotorPowerLogicScreen(limbName: label)),
          );
          if (grade != null) setState(() => _results[label] = grade);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isDone ? primaryGreen : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            border: Border.all(color: primaryGreen.withOpacity(0.5)),
          ),
          child: Text(
            isDone ? "เกรด ${_results[label]}" : label, 
            style: TextStyle(
              color: isDone ? Colors.white : primaryGreen, 
              fontWeight: FontWeight.bold
            )
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
      ),
      child: Column(
        children: [
          const Text("สรุปผล Motor Power ต่ำที่สุด", style: TextStyle(color: Colors.grey)),
          Text("เกรด $_finalGlobalGrade", 
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () { 
              Navigator.pop(context, _finalGlobalGrade);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen, 
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
            ),
            child: const Text("บันทึกผลการประเมิน", 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}

// 🚩 หน้าคัดกรอง Step 1-2
class MotorPowerLogicScreen extends StatefulWidget {
  final String limbName;
  const MotorPowerLogicScreen({Key? key, required this.limbName}) : super(key: key);

  @override
  State<MotorPowerLogicScreen> createState() => _MotorPowerLogicScreenState();
}

class _MotorPowerLogicScreenState extends State<MotorPowerLogicScreen> {
  int _step = 1; 
  bool _isGravityEnabled = false;
  final Color primaryGreen = const Color(0xFF577460);

  // ตรวจสอบว่าเป็น "ขา" หรือไม่
  bool get _isLeg => widget.limbName.contains("ขา");

  // เลือกรูปภาพให้ตรงกับ Step คัดกรองและประเภทรยางค์
  String _getScreeningImage(int step) {
    if (step == 1) {
      return _isLeg 
          ? "assets/premotor/kub.gif"  
          : "assets/premotor/firstarm.png"; 
    } else {
      return _isLeg 
          ? "assets/premotor/second.gif"  
          : "assets/premotor/secondarm.gif"; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text("ประเมิน ${widget.limbName}"), 
        elevation: 0, 
        backgroundColor: Colors.white, 
        foregroundColor: Colors.black
      ),
      body: _buildStep(),
    );
  }

  Widget _buildStep() {
    if (_step == 1) {
      return _buildQuestionCard(
        text: "คนไข้สามารถยก ${widget.limbName} ขึ้นต้านแรงโน้มถ่วงโดยไม่มีคนจับ ได้หรือไม่?",
        imagePath: _getScreeningImage(1),
        onYes: () => setState(() { _isGravityEnabled = true; _step = 3; }), 
        onNo: () => setState(() { _isGravityEnabled = false; _step = 2; }),
      );
    } else if (_step == 2) {
      return _buildQuestionCard(
        text: "คนไข้สามารถขยับหรือใช้ ${widget.limbName} ปัดไปปัดมาในแนวราบได้ไหม?",
        imagePath: _getScreeningImage(2),
        onYes: () => Navigator.pop(context, 2), 
        onNo: () => setState(() { _step = 3; }), 
      );
    } else {
      return DetailedAssessmentScreen(limbName: widget.limbName, isGravity: _isGravityEnabled);
    }
  }

  Widget _buildQuestionCard({
    required String text, 
    required String imagePath,
    required VoidCallback onYes, 
    required VoidCallback onNo
  }) {
    // 🚩 ขยายขนาดภาพให้ใหญ่ขึ้นเป็น 300
    Widget imageWidget = Image.asset(
      imagePath,
      height: 300,
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 300, 
        color: Colors.grey[100], 
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image, color: Colors.grey, size: 40),
              SizedBox(height: 8),
              Text("ไม่พบไฟล์รูปภาพคัดกรอง", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        )
      ),
    );

    // 🚩 ตรวจสอบว่าถ้าเป็นรูป secondleg.gif ให้ทำการกลับซ้ายขวา (พลิกมาทางขวา)
    if (imagePath == "assets/premotor/second.gif") {
      imageWidget = Transform.flip(
        flipX: true, // พลิกรูปในแนวนอน
        // หากหมายถึงตีลังกาลง ให้ใช้ Transform.rotate(angle: math.pi, child: imageWidget) แทนครับ
        child: imageWidget,
      );
    }

    return Center(
      child: SingleChildScrollView( 
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(30),
            boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 15)]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // โซนแสดงรูปภาพประกอบในขั้นตอนการคัดกรอง
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: imageWidget, // 👈 นำวิดเจ็ตรูปที่ตั้งค่าไว้มาใส่ตรงนี้
              ),
              const SizedBox(height: 24),
              Text(text, textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.4)),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onNo, 
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryGreen), 
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      child: Text("ไม่ได้", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold))
                    )
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onYes, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen, 
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                      ),
                      child: const Text("ได้", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                    )
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 🚩 หน้าประเมินรายละเอียด
class DetailedAssessmentScreen extends StatefulWidget {
  final String limbName;
  final bool isGravity;
  const DetailedAssessmentScreen({Key? key, required this.limbName, required this.isGravity}) : super(key: key);

  @override
  State<DetailedAssessmentScreen> createState() => _DetailedAssessmentScreenState();
}

class _DetailedAssessmentScreenState extends State<DetailedAssessmentScreen> {
  final Map<int, int> _answers = {};
  final Color primaryGreen = const Color(0xFF577460);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache images เพื่อให้แสดงผลได้ทันทีเมื่อเปิดหน้า
    bool isLeg = widget.limbName.contains("ขา");
    List<Map<String, String>> questions = _getQuestions(isLeg, widget.isGravity);
    
    for (var q in questions) {
      if (q['image'] != null) {
        precacheImage(AssetImage(q['image']!), context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLeg = widget.limbName.contains("ขา");
    List<Map<String, String>> questions = _getQuestions(isLeg, widget.isGravity);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: questions.length,
            itemBuilder: (c, i) => _buildQuestionItem(i, questions[i]),
          ),
        ),
        _buildSubmitButton(questions.length),
      ],
    );
  }

  List<Map<String, String>> _getQuestions(bool isLeg, bool isGravity) {
    if (isGravity) {
      return isLeg ? _legGravityQs : _armGravityQs;
    } else {
      return isLeg ? _legFlickerQs : _armFlickerQs;
    }
  }

  Widget _buildQuestionItem(int index, Map<String, String> data) {
    List<String> options = widget.isGravity 
        ? ["ต้านไม่ได้", "ต้านได้ปานกลาง", "ต้านได้ปกติ"] 
        : ["กล้ามเนื้อไม่ขยับ", "กล้ามเนื้อขยับ"];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: data['image'] != null 
              ? Image.asset(
                  data['image']!,
                  height: 280, // 🚩 ขยายขนาดภาพให้ใหญ่ขึ้นเป็น 280
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 280, color: Colors.grey[100], 
                    child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))
                  ),
                )
              : Container(height: 280, color: Colors.grey[100], child: const Center(child: Icon(Icons.image, color: Colors.grey))),
          ),
          const SizedBox(height: 15),
          Text(data['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.5)),
          Text("คนไข้: ${data['patient']!}", style: const TextStyle(fontSize: 13, color: Colors.blue)),
          Text("ผู้ทดสอบ: ${data['tester']!}", style: const TextStyle(fontSize: 13, color: Colors.orange)),
          const SizedBox(height: 15),
          
          Row(
            children: List.generate(options.length, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    label: Center(
                      child: FittedBox(
                        child: Text(
                          options[i], 
                          style: TextStyle(
                            fontSize: 12,
                            color: _answers[index] == i ? Colors.white : Colors.black87
                          ),
                        ),
                      ),
                    ),
                    selected: _answers[index] == i,
                    onSelected: (s) => setState(() => _answers[index] = i),
                    selectedColor: primaryGreen,
                    backgroundColor: Colors.grey[200],
                    showCheckmark: false,
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildSubmitButton(int total) {
    bool isComplete = _answers.length == total;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isComplete ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen, 
            disabledBackgroundColor: Colors.grey[300], 
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          ),
          child: Text(
            isComplete ? "ประมวลผลเกรด" : "กรุณาตอบให้ครบ ($total ข้อ)", 
            style: TextStyle(
              color: isComplete ? Colors.white : Colors.grey[600], 
              fontWeight: FontWeight.bold, 
              fontSize: 16
            )
          ),
        ),
      ),
    );
  }

  void _submit() {
    int grade;
    if (widget.isGravity) {
      if (_answers.values.any((v) => v == 0)) grade = 3;
      else if (_answers.values.any((v) => v == 1)) grade = 4;
      else grade = 5;
    } else {
      grade = _answers.values.any((v) => v == 1) ? 1 : 0;
    }
    Navigator.pop(context, grade);
  }

  // --- ข้อมูลรูปภาพประกอบภายในแบบประเมินรายละเอียด ---
  final List<Map<String, String>> _armFlickerQs = [
    {"title": "1) C5 - Deltoid", "patient": "กางแขนท่า 'ไก่ย่าง'", "tester": "คลำหัวไหล่", "image": "assets/motorpower/C5Deltoid.JPG"},
    {"title": "2) C6 - Biceps", "patient": "เบ่งกล้าม", "tester": "ดึงสู้", "image": "assets/motorpower/C6Bicep.JPG"},
    {"title": "3) C7 - Triceps", "patient": "ยันแขนออก", "tester": "คลำ Triceps", "image": "assets/motorpower/C7Triceps.JPG"},
    {"title": "4) C8 - Finger flexor", "patient": "งอนิ้ว 4 นิ้ว", "tester": "คลำ Flexors", "image": "assets/motorpower/C8Finger.JPG"},
  ];

  final List<Map<String, String>> _legFlickerQs = [
    {"title": "1) L4 - Ankle dorsiflexor", "patient": "กระดกปลายเท้าขึ้น", "tester": "คลำหน้าแข้ง", "image": "assets/motorpower/L4Ankle.JPG"},
    {"title": "2) L5 - Great toe dorsiflexor", "patient": "งัดนิ้วหัวแม่เท้าขึ้น", "tester": "คลำโคนนิ้วโป้ง", "image": "assets/motorpower/L5Great.JPG"},
  ];

  final List<Map<String, String>> _armGravityQs = [
    {"title": "1) C5 - Deltoid", "patient": "กางแขน", "tester": "คลำหัวไหล่", "image": "assets/motorpower/C5Deltoid.JPG"},
    {"title": "2) C6 - Biceps", "patient": "เบ่งกล้าม", "tester": "ดึงสู้", "image": "assets/motorpower/C6Bicep.JPG"},
    {"title": "3) C7 - Triceps", "patient": "ยันแขน", "tester": "ดันมือคนไข้", "image": "assets/motorpower/C7Triceps.JPG"},
    {"title": "4) C6 - Wrist extensor", "patient": "กำหมัดกระดกข้อมือ", "tester": "กดข้อมือลง", "image": "assets/motorpower/C6Wrist.JPG"},
    {"title": "5) C7 - Wrist flexor", "patient": "กำหมัดหักข้อมือ", "tester": "งัดข้อมือขึ้น", "image": "assets/motorpower/C7Wrist.JPG"},
    {"title": "6) C7 - Finger extensor", "patient": "เหยียดนิ้วตรง", "tester": "กดนิ้วให้งอ", "image": "assets/motorpower/C7Finger.JPG"},
    {"title": "7) C8 - Finger flexor", "patient": "งอนิ้วตะขอ", "tester": "เกี่ยวและดึงนิ้วให้กาง", "image": "assets/motorpower/C8Finger.JPG"},
    {"title": "8) T1 - Finger abduction", "patient": "กางนิ้วออก", "tester": "บีบนิ้วให้ชิด", "image": "assets/motorpower/T1Finger.JPG"},
  ];

  final List<Map<String, String>> _legGravityQs = [
    {"title": "1) L1, 2, 3 - Hip flexor", "patient": "ยกเข่าหาอก", "tester": "กดหน้าขา", "image": "assets/motorpower/L123Hip.JPG"},
    {"title": "2) L5, S1 - Hip extensor", "patient": "เหยียดขาไปหลัง", "tester": "ดันขามาหน้า", "image": "assets/motorpower/L5S1Hip.JPG"},
    {"title": "3) L4, 5, S1 - Hip abductor", "patient": "กางขาขึ้น", "tester": "กดขาลง", "image": "assets/motorpower/L45S1Hip.JPG"}, // แก้ไขคำว่า parent ให้เป็น patient ตรงนี้ให้ด้วยเพื่อป้องกันบั๊ก
    {"title": "4) L3, 4 - Knee extensor", "patient": "เตะขาขึ้น", "tester": "กดหน้าแข้งลง", "image": "assets/motorpower/L34Knee.JPG"},
    {"title": "5) L4, 5 - Knee flexor", "patient": "งอเข่า", "tester": "ดึงขาเหยียดออก", "image": "assets/motorpower/L45Knee.JPG"},
    {"title": "6) L4 - Ankle dorsiflexor", "patient": "กระดกปลายเท้า", "tester": "กดหลังเท้าลง", "image": "assets/motorpower/L4Ankle.JPG"},
    {"title": "7) L5 - Ankle plantarflexor", "patient": "กดปลายเท้าลง", "tester": "ดันฝ่าเท้าสวน", "image": "assets/motorpower/L5Ankle.JPG"},
    {"title": "8) L5 - Great toe dorsiflexor", "patient": "งัดนิ้วโป้งขึ้น", "tester": "ดันนิ้วโป้งลง", "image": "assets/motorpower/L5Great.JPG"},
    {"title": "9) S1 - Great toe plantarflexor", "patient": "จิกนิ้วโป้งลง", "tester": "งัดนิ้วโป้งขึ้น", "image": "assets/motorpower/S1Great.JPG"},
  ];
}