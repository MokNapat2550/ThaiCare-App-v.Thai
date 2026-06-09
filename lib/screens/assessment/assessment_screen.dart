import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui'; // สำหรับใช้ ImageFilter.blur
import 'adl_screen.dart';
import 'motor_power_screen.dart';

class AssessmentScreen extends StatefulWidget {
  final Function(int) onMpUpdate;
  const AssessmentScreen({Key? key, required this.onMpUpdate}) : super(key: key);

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _adlScore = -1;
  Map<String, String>? _mpGrades;

  final Color primaryGreen = const Color(0xFF577460);
  final Color accentOrange = const Color(0xFFFFAB91);
  final Color bgLight = const Color(0xFFF8FAF8);

  Map<String, dynamic> _getAdlCategory(int score) {
    if (score >= 12) {
      return {"label": "ติดสังคม", "bgColor": const Color(0xFFFFF9C4), "textColor": const Color(0xFFF9A825), "Top": 20.0};
    } else if (score >= 5) {
      return {"label": "ติดบ้าน", "bgColor": const Color(0xFFFCE4EC), "textColor": const Color(0xFFD81B60), "Top": 20.0};
    } else {
      return {"label": "ติดเตียง", "bgColor": const Color(0xFFE1F5FE), "textColor": const Color(0xFF0288D1), "Top": 20.0};
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        "ตรวจสอบความพร้อมของร่างกายวันนี้",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 30),

                      // --- ADL ---
                      _buildModernCard(
                        title: "ADL",
                        subtitle: "ประเมินความสามารถพื้นฐาน",
                        icon: Icons.accessibility_new_rounded,
                        isCompleted: _adlScore != -1,
                        child: _adlScore == -1 
                          ? _buildStartAction("เริ่มทำแบบประเมิน ADL", () async {
                              final score = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AdlScreen()));
                              if (score != null) setState(() => _adlScore = score);
                            })
                          : _buildAdlScoreView(),
                      ),

                      const SizedBox(height: 24),

                      // --- Motor Power ---
                      _buildModernCard(
                        title: "Motor Power",
                        subtitle: "เช็กกำลังกล้ามเนื้อ 4 ส่วน",
                        icon: Icons.fitness_center_rounded,
                        isCompleted: _mpGrades != null,
                        child: _mpGrades == null 
                          ? _buildStartAction("เริ่มทำแบบประเมิน Motor Power", () async {
                              // 🚩 รับผลการประเมิน
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const MotorPowerScreen()));
                              if (result != null) {
                                setState(() {
                                  _mpGrades = result;
                                  // ดึงเกรดสรุปรวม (เช่น "G3") แปลงเป็นตัวเลข (3) แล้วส่ง Callback
                                  String? rawGrade = _mpGrades!["สรุปรวม"]?.replaceAll("G", "");
                                  int finalGrade = int.tryParse(rawGrade ?? "5") ?? 5;
                                  widget.onMpUpdate(finalGrade); 
                                });
                              }
                            })
                          : _buildMpScoreView(),
                      ),
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

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 90,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 24, bottom: 10),
            background: Container(color: bgLight.withOpacity(0.6)),
            title: Text(
              "ประเมินสุขภาพ",
              style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard({required String title, required String subtitle, required IconData icon, required bool isCompleted, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted ? primaryGreen.withOpacity(0.1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: isCompleted ? primaryGreen : Colors.grey, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ),
                const Spacer(),
                if (isCompleted) const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(24), child: child),
        ],
      ),
    );
  }

  Widget _buildStartAction(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAdlScoreView() {
    final category = _getAdlCategory(_adlScore);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("คะแนน", style: TextStyle(color: Colors.grey, fontSize: 15)),
                Text("$_adlScore", style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: accentOrange)),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: EdgeInsets.only(top: category["Top"] ?? 0.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                decoration: BoxDecoration(
                  color: category["bgColor"],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category["label"],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: category["textColor"]),
                ),
              ),
            ),
          ],
        ),
        _buildSmallButton("ทำใหม่", () async {
          final score = await Navigator.push(context, MaterialPageRoute(builder: (c) => const AdlScreen()));
          if (score != null) setState(() => _adlScore = score);
        }),
      ],
    );
  }

  Widget _buildMpScoreView() {
    String? finalScoreStr = _mpGrades!["สรุปรวม"];
    var limbGrades = _mpGrades!.entries.where((e) => e.key != "สรุปรวม").toList();

    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: limbGrades.map((e) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: bgLight.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                Text(e.value, style: TextStyle(color: accentOrange, fontWeight: FontWeight.bold)),
              ],
            ),
          )).toList(),
        ),
        const SizedBox(height: 15),
        if (finalScoreStr != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("เกรดสรุปรวม", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
                Text(finalScoreStr, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryGreen)),
              ],
            ),
          ),
        const SizedBox(height: 12),
        // 🚩 ปุ่มทำใหม่ พร้อมส่งค่า Callback
        _buildSmallButton("ทำใหม่", () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (c) => const MotorPowerScreen()));
          if (result != null) {
            setState(() {
              _mpGrades = result;
              String? rawGrade = _mpGrades!["สรุปรวม"]?.replaceAll("G", "");
              int finalGrade = int.tryParse(rawGrade ?? "5") ?? 5;
              widget.onMpUpdate(finalGrade); // ส่ง Callback อัปเดตยา
            });
          }
        }),
      ],
    );
  }

  Widget _buildSmallButton(String label, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }
}

// วิดเจ็ตพื้นหลังและ Blob (เหมือนเดิม)
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