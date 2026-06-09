import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui'; 

class HerbScreen extends StatefulWidget {
  final int mpGrade;
  final double weight;  // น้ำหนักตัวจริง (กก.)
  final double height;  // ส่วนสูง (ซม.)
  final String gender;  // 'ชาย' | 'หญิง' | 'ไม่ระบุ'
  final double bmi;

  const HerbScreen({
    Key? key,
    required this.mpGrade,
    required this.weight,
    required this.height,
    required this.gender,
    required this.bmi,
  }) : super(key: key);

  @override
  State<HerbScreen> createState() => _HerbScreenState();
}

class _HerbScreenState extends State<HerbScreen> {
  String? _selectedSymptom;

  final Color primaryGreen = const Color(0xFF577460);
  final Color accentOrange = const Color(0xFFFFAB91);
  final Color bgLight = const Color(0xFFF8FAF8);

  String get _currentStage {
    if (widget.mpGrade == -1) return "ยังไม่ได้ประเมิน";
    if (widget.mpGrade <= 1) return "ช่วงต้น";
    if (widget.mpGrade <= 3) return "ช่วงกลาง";
    return "ช่วงปลาย";
  }

  // ──────────────────────────────────────────────────────────────────
  // Dosing Based on Body Weight
  // ──────────────────────────────────────────────────────────────────
  static const double _referenceWeight = 60.0; // กก. อ้างอิงมาตรฐาน

  double _calcIBW() {
    if (widget.height <= 0) return _referenceWeight;
    final bool isMale = widget.gender == 'ชาย';
    final base = isMale ? 50.0 : 45.5;
    return (base + 0.9 * (widget.height - 152.0)).clamp(30.0, 120.0);
  }

  double _calcDosingWeight() {
    final abw = widget.weight;
    final ibw = _calcIBW();
    if (abw > ibw * 1.2) {
      return ibw + 0.4 * (abw - ibw); // อ้วน: ใช้ Adjusted Body Weight
    }
    return abw; // ปกติ / น้ำหนักน้อย: ใช้ Actual Body Weight
  }

  String? _getPersonalizedAdvice() {
    if (widget.weight <= 0 || widget.height <= 0) return null;

    final ibw          = _calcIBW();
    final dosingWeight = _calcDosingWeight();
    final doseFactor   = dosingWeight / _referenceWeight;
    final bool isObese = widget.weight > ibw * 1.2;
    final bool isUnder = widget.weight < ibw * 0.85;

    String doseAdvice;
    if (doseFactor < 0.75) {
      final pct = ((1 - doseFactor) * 100).round();
      doseAdvice =
          "• ขนาดยาของคุณ: ควรลดลง ~$pct% จากขนาดมาตรฐาน\n"
          "  (น้ำหนักให้ยา ${dosingWeight.toStringAsFixed(1)} กก. "
          "≈ ${(doseFactor * 100).round()}% ของมาตรฐาน 60 กก.)";
    } else if (doseFactor <= 1.10) {
      doseAdvice =
          "• ขนาดยาของคุณ: ทานตามขนาดมาตรฐานได้เลย\n"
          "  (น้ำหนักให้ยา ${dosingWeight.toStringAsFixed(1)} กก. "
          "≈ ${(doseFactor * 100).round()}% ของมาตรฐาน 60 กก.)";
    } else {
      final pct = ((doseFactor - 1) * 100).round();
      doseAdvice =
          "• ขนาดยาของคุณ: ปรับเพิ่ม ~$pct% จากขนาดมาตรฐาน\n"
          "  (ใช้ Adjusted BW ${dosingWeight.toStringAsFixed(1)} กก. "
          "— ไม่ควรปรับตามน้ำหนักจริงในผู้อ้วน)";
    }

    if (isUnder) {
      doseAdvice += "\n  ⚠ น้ำหนักน้อยกว่าเกณฑ์ — ปรึกษาแพทย์แผนไทยก่อนใช้ยา";
    } else if (isObese) {
      doseAdvice += "\n  ℹ ใช้ Adjusted Body Weight (AdjBW) แทนน้ำหนักจริง";
    }

    final waterLiters = (widget.weight * 33) / 1000;
    final waterAdvice =
        "• การดื่มน้ำ: ควรได้ ${waterLiters.toStringAsFixed(1)} ลิตร/วัน "
        "(${widget.weight.toStringAsFixed(0)} กก. × 33 ml)";

    return "$doseAdvice\n$waterAdvice";
  }

  // 🚩 แก้ไขจุดที่ 1: ข้อมูลยาหลักจัดโครงสร้างให้เป็น List<String> ภายใต้คีย์ "images" ทั้งหมด
  Map<String, dynamic> get _mainHerbData {
    if (_currentStage == "ช่วงต้น") {
      return {
        "name": "ยาหอมทิพโอสถ และ ยาหอมเทพจิตร",
        "usage": "ครั้งละ 1-1.4 กรัม ทุก 3-4 ชม. เมื่อมีอาการ (ไม่เกินวันละ 3 ครั้ง)",
        "caution": "ระวังการใช้ร่วมกับยาต้านการแข็งตัวของเลือด และผู้ป่วยโรคตับ/ไต",
        "taste": "รสสุขุมร้อน / สุขุมเย็น",
        "images": [
          "assets/drunk/hom.JPG",     
          "assets/drunk/tep.JPG"  
        ]
      };
    } else if (_currentStage == "ช่วงกลาง") {
      return {
        "name": "ยาหอมนวโกฐ",
        "usage": "ครั้งละ 1-2 กรัม ทุก 3-4 ชม. เมื่อมีอาการ (ไม่เกินวันละ 3 ครั้ง)",
        "caution": "ห้ามใช้ในหญิงตั้งครรภ์และผู้ที่มีไข้ ระวังการใช้ร่วมกับยาต้านการแข็งตัวของเลือด",
        "taste": "รสสุขุมร้อน",
        "images": [
          "assets/drunk/nava.JPG" 
        ]
      };
    } else {
      return {
        "name": "ยาแก้ลมอัมพฤกษ์ และ ยาสหัศธารา",
        "usage": "แก้ลมอัมพฤกษ์: ครั้งละ 1 กรัม ชงน้ำร้อน วันละ 3 ครั้ง ก่อนอาหาร",
        "caution": "ห้ามใช้ในหญิงตั้งครรภ์ ผู้ที่มีไข้ และเด็ก ระวังในผู้ป่วยโรคตับ/ไต",
        "taste": "รสร้อน",
        "images": [
          "assets/drunk/lom.JPG",     
          "assets/drunk/sahus.JPG"  
        ]
      };
    }
  }

  // 🚩 แก้ไขจุดที่ 2: เปลี่ยนกลุ่มข้อมูลยาตามอาการร่วมให้เป็น List<String> ภายใต้คีย์ "images" ด้วย เพื่อไม่ให้ระบบ UI ตีกัน
  final Map<String, Map<String, dynamic>> _symptomHerbs = {
    "ปวดตามร่างกาย": {
      "herb": "ยาเถาวัลย์เปรียง", "usage": "ครั้งละ 500 มก. วันละ 3 ครั้ง หลังอาหาร", "caution": "ห้ามใช้ในหญิงตั้งครรภ์",
      "images": ["assets/drunk/t.JPG"]
    },
    "ท้องผูก": {
      "herb": "ยาธรณีสัณฑะฆาต", "usage": "500 มก. - 1 กรัม วันละ 1 ครั้ง ก่อนนอน", "caution": "ห้ามใช้ในหญิงตั้งครรภ์",
      "images": ["assets/drunk/tora.JPG"]
    },
    "ความดันสูง": {
      "herb": "ชาชงกระเจี๊ยบแดง", "usage": "ครั้งละ 2-3 กรัม ชงน้ำร้อน วันละ 3 ครั้ง", "caution": "ห้ามใช้ในผู้ที่ไตบกพร่อง",
      "images": ["assets/drunk/ka.JPG"]
    },
    "บำรุงธาตุ": {
      "herb": "เบญจกูล", "usage": "ครั้งละ 1 กรัม วันละ 3 ครั้ง หลังอาหาร", "caution": "ไม่ควรใช้ในฤดูร้อน",
      "images": ["assets/drunk/bum.jpg"]
    }
  };

  @override
  Widget build(BuildContext context) {
    if (widget.mpGrade == -1) return _buildNoDataScreen();
    
    var mainHerb = _mainHerbData;
    String? pAdvice = _getPersonalizedAdvice();

    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          const FloatingBackground(), 
          CustomScrollView(
            slivers: [
              _buildModernAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(),
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle("ยาสมุนไพรหลักตามระยะ", Icons.medication_liquid_rounded),
                      const SizedBox(height: 12),
                      
                      // 🚩 แก้ไขจุดที่ 3: ส่งตัวแปรเป็น `imagePaths` แบบดึงค่าจาก List['images'] แทนของเดิม
                      _buildHerbCard(
                        title: mainHerb['name'],
                        subtitle: "รสยา: ${mainHerb['taste']}",
                        usage: mainHerb['usage'],
                        personalizedAdvice: pAdvice, 
                        caution: mainHerb['caution'],
                        imagePaths: mainHerb['images'] != null ? List<String>.from(mainHerb['images']) : null, 
                        cardColor: Colors.white.withOpacity(0.9),
                        accentColor: primaryGreen,
                        useGlow: true, // ตัวหลัก รูปภาพจะขนาดปกติ (เต็มใบ)
                      ),
                      
                      const SizedBox(height: 32),
                      _buildSectionTitle("เลือกอาการร่วมอื่นๆ", Icons.manage_search_rounded),
                      const SizedBox(height: 12),
                      _buildSymptomSelector(),
                      
                      if (_selectedSymptom != null) ...[
                        const SizedBox(height: 16),
                        // 🚩 แก้ไขจุดที่ 4: สำหรับยาตามอาการร่วม ส่งเป็น `imagePaths` และตั้งค่า useGlow เป็น false เพื่อให้รูปย่อเล็กลง
                        _buildHerbCard(
                          title: _symptomHerbs[_selectedSymptom]!['herb']!,
                          subtitle: "สำหรับอาการ: $_selectedSymptom",
                          usage: _symptomHerbs[_selectedSymptom]!['usage']!,
                          personalizedAdvice: pAdvice, 
                          caution: _symptomHerbs[_selectedSymptom]!['caution']!,
                          imagePaths: _symptomHerbs[_selectedSymptom]!['images'] != null 
                              ? List<String>.from(_symptomHerbs[_selectedSymptom]!['images']) 
                              : null, 
                          cardColor: Colors.white.withOpacity(0.9),
                          accentColor: accentOrange,
                          useGlow: false, // 🌟 รูปภาพยาตามอาการจะเล็กลงกะทัดรัดโดยอัตโนมัติ
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🚩 แก้ไขจุดที่ 5: ปรับปรุงโครงสร้าง UI ภายใน _buildHerbCard ใหม่ทั้งหมด เพื่อแกะ List รูปภาพออกมาวาดซ้าย-ขวา เคียงคู่กันอย่างลงตัว
  Widget _buildHerbCard({
    required String title, 
    required String subtitle, 
    required String usage, 
    String? personalizedAdvice, 
    required String caution, 
    List<String>? imagePaths, // 👈 เปลี่ยนมารับค่าในรูปแบบ List อย่างสมบูรณ์
    required Color cardColor, 
    required Color accentColor,
    required bool useGlow,
  }) {
    // 🌟 ตั้งค่าความสูงรูป: ถ้ายาหลัก (useGlow: true) สูง 150 ถ้ายาตามอาการ (useGlow: false) เล็กลงเหลือ 110 ตามสั่ง
    final double imgHeight = useGlow ? 150 : 110;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: accentColor.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🚩 โซนประมวลผลรูปภาพอัจฉริยะ (รองรับทั้ง 1 รูปเดี่ยว และ 2 รูปเคียงข้างกัน)
          if (imagePaths != null && imagePaths.isNotEmpty) ...[
            Center(
              child: Container(
                // บีบหน้ากว้างของรูปภาพไม่ให้บานออกข้างมากเกินไปในกรณียาตามอาการร่วม
                constraints: BoxConstraints(
                  maxWidth: useGlow ? double.infinity : 150,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: imagePaths.map((path) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0), // ช่องว่างระหว่างรูป
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            path,
                            height: imgHeight, // ปรับตามความสูงเฉพาะกลุ่ม 
                            fit: BoxFit.cover, 
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: imgHeight, 
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16)
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: useGlow ? 26 : 18),
                                    const SizedBox(height: 4),
                                    Text("ไม่มีรูปภาพ", style: TextStyle(color: Colors.grey.shade500, fontSize: useGlow ? 11 : 9)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: accentColor)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
          
          _buildHerbDetailItem(Icons.menu_book_rounded, "วิธีใช้:", usage, Colors.black87),
          
          if (personalizedAdvice != null) ...[
            const SizedBox(height: 12),
            useGlow 
              ? _buildGlowAdviceBox(personalizedAdvice)
              : _buildSimpleAdviceBox(personalizedAdvice),
          ],

          const SizedBox(height: 16),
          _buildHerbDetailItem(Icons.warning_amber_rounded, "ข้อควรระวัง:", caution, Colors.red.shade700),
        ],
      ),
    );
  }

  Widget _buildGlowAdviceBox(String advice) {
    return Container(
      margin: const EdgeInsets.only(left: 28),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: Colors.teal.shade600, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("คำแนะนำเฉพาะคุณ (Dosing by Body Weight)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.teal.shade800)),
                const SizedBox(height: 6),
                Text(advice, style: TextStyle(fontSize: 12, color: Colors.teal.shade900, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleAdviceBox(String advice) {
    return Container(
      margin: const EdgeInsets.only(left: 28),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("คำแนะนำเพิ่มเติมตามน้ำหนักตัว:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade700)),
          const SizedBox(height: 4),
          Text(advice, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildHerbDetailItem(IconData icon, String label, String text, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: label.contains("ควรระวัง") ? Colors.red.shade300 : primaryGreen.withOpacity(0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(text, style: TextStyle(fontSize: 13, color: textColor, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 90, pinned: true, elevation: 0,
      backgroundColor: Colors.transparent, surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            centerTitle: false, titlePadding: const EdgeInsets.only(left: 24, bottom: 10),
            background: Container(color: bgLight.withOpacity(0.6)),
            title: Text("แนะนำยาสมุนไพร", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(children: [
        Icon(icon, color: primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
    ]);
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryGreen, borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("ผลประเมินร่างกาย", style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Text("เกรด : ${widget.mpGrade}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: Text(_currentStage, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }

  Widget _buildSymptomSelector() {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: _symptomHerbs.keys.map((symptom) {
        bool isSelected = _selectedSymptom == symptom;
        return GestureDetector(
          onTap: () => setState(() => _selectedSymptom = isSelected ? null : symptom),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? accentOrange : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? accentOrange : Colors.grey.shade200),
            ),
            child: Text(symptom, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoDataScreen() {
    return Scaffold(
      backgroundColor: bgLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 80, color: primaryGreen.withOpacity(0.3)),
            const SizedBox(height: 20),
            Text("กรุณาประเมินร่างกายก่อน", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryGreen)),
          ],
        ),
      ),
    );
  }
}

// --- Background Widgets ---
class FloatingBackground extends StatelessWidget {
  const FloatingBackground({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
        const FloatingBlob(top: 50, left: -20, size: 150, color: Color(0xFFE8F5E9)),
        const FloatingBlob(bottom: 150, left: 20, size: 80, color: Color(0xFFC8E6C9)),
    ]);
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
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top, left: widget.left,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, 15 * math.sin(_controller.value * 2 * math.pi)),
          child: child,
        ),
        child: Container(width: widget.size, height: widget.size, decoration: BoxDecoration(color: widget.color.withOpacity(0.6), shape: BoxShape.circle)),
      ),
    );
  }
}