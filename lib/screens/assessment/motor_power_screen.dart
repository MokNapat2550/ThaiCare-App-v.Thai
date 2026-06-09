import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'motor_power_logic_screen.dart';

class MotorPowerScreen extends StatefulWidget {
  const MotorPowerScreen({Key? key}) : super(key: key);

  @override
  State<MotorPowerScreen> createState() => _MotorPowerScreenState();
}

class _MotorPowerScreenState extends State<MotorPowerScreen> {
  final Map<String, int?> _results = {
    "แขนขวา": null,
    "แขนซ้าย": null,
    "ขาขวา": null,
    "ขาซ้าย": null,
  };

  final Color primaryGreen = const Color(0xFF577460);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Stack(
        children: [
          const SmoothFloatingBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double figureSize = MediaQuery.of(context).size.height * 0.35;
                        return SizedBox(
                          width: constraints.maxWidth,
                          height: figureSize + 150,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.accessibility_new_rounded,
                                size: figureSize,
                                color: primaryGreen.withOpacity(0.35),
                              ),
                              // 🚩 เรียกใช้ปุ่มแบบใหม่ที่ขยับได้
                              _buildBodyButton(label: "แขนขวา", top: 40, left: constraints.maxWidth * 0.05),
                              _buildBodyButton(label: "แขนซ้าย", top: 40, right: constraints.maxWidth * 0.05),
                              _buildBodyButton(label: "ขาขวา", bottom: 40, left: constraints.maxWidth * 0.15),
                              _buildBodyButton(label: "ขาซ้าย", bottom: 40, right: constraints.maxWidth * 0.15),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
          ),
          Positioned(
            top: 50, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    int doneCount = _results.values.where((v) => v != null).length;
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text("ประเมิน Motor Power", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text("ประเมินแล้ว $doneCount จาก 4 ส่วน", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: doneCount / 4,
              backgroundColor: Colors.grey.shade200,
              color: primaryGreen,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // 🚩 ปรับจูนให้เรียกใช้ FloatingActionButton แทน Container ธรรมดา
  Widget _buildBodyButton({required String label, double? top, double? left, double? right, double? bottom}) {
    return FloatingBodyButton(
      label: label,
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      result: _results[label],
      primaryGreen: primaryGreen,
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => MotorPowerLogicScreen(limbName: label)),
        );
        if (result != null) setState(() => _results[label] = result);
      },
    );
  }

  Widget _buildSaveButton() {
    bool isAllDone = !_results.containsValue(null);
    if (!isAllDone) return const SizedBox(height: 20);
    List<int> grades = _results.values.whereType<int>().toList();
    int finalGrade = grades.reduce(math.min);

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
        border: Border.all(color: primaryGreen.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("เกรด Motor Power รวมของผู้ป่วย", style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("เกรด $finalGrade", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFFFAB91))),
          const Text("(อ้างอิงจากเกรดที่น้อยที่สุด)", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, 
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                Map<String, String> finalData = _results.map((k, v) => MapEntry(k, "G$v"));
                finalData["สรุปรวม"] = "G$finalGrade"; 
                Navigator.pop(context, finalData);
              },
              style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text("บันทึกผลการประเมิน", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}

// 🚩 Widget ใหม่สำหรับทำปุ่มที่ "กึ่งกลาง" และ "ขยับขึ้นลง"
class FloatingBodyButton extends StatefulWidget {
  final String label;
  final double? top, left, right, bottom;
  final int? result;
  final Color primaryGreen;
  final VoidCallback onTap;

  const FloatingBodyButton({
    Key? key,
    required this.label,
    this.top, this.left, this.right, this.bottom,
    this.result,
    required this.primaryGreen,
    required this.onTap,
  }) : super(key: key);

  @override
  State<FloatingBodyButton> createState() => _FloatingBodyButtonState();
}

class _FloatingBodyButtonState extends State<FloatingBodyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // สุ่มความเร็ว 1.5 - 2.5 วินาที เพื่อให้แต่ละปุ่มพริ้วไม่พร้อมกัน
      duration: Duration(milliseconds: 1500 + math.Random().nextInt(1000)),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDone = widget.result != null;

    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value), // 🚩 ขยับขึ้นลง
            child: child,
          );
        },
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            constraints: const BoxConstraints(minWidth: 100), // ล็อกความกว้างขั้นต่ำ
            decoration: BoxDecoration(
              color: isDone ? widget.primaryGreen : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
              ],
              border: Border.all(color: widget.primaryGreen.withOpacity(0.5)),
            ),
            child: Center( // 🚩 ทำให้ตัวอักษรอยู่ตรงกลางเป๊ะ
              child: Text(
                isDone ? "เกรด ${widget.result}" : widget.label,
                style: TextStyle(
                  color: isDone ? Colors.white : widget.primaryGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SmoothFloatingBackground extends StatelessWidget {
  const SmoothFloatingBackground({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(top: 200, left: -40, child: Container(width: 180, height: 180, decoration: BoxDecoration(color: const Color(0xFFE8F5E9).withOpacity(0.4), shape: BoxShape.circle))),
      Positioned(bottom: 100, right: -40, child: Container(width: 240, height: 240, decoration: BoxDecoration(color: const Color(0xFFFFF3E0).withOpacity(0.4), shape: BoxShape.circle))),
    ]);
  }
}