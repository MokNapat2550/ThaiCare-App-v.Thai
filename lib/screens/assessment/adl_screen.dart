import 'package:flutter/material.dart';

const Color primaryGreen = Color(0xFF577460);

class AdlScreen extends StatefulWidget {
  const AdlScreen({Key? key}) : super(key: key);

  @override
  State<AdlScreen> createState() => _AdlScreenState();
}

class _AdlScreenState extends State<AdlScreen> {
  int _currentIndex = 0;
  int _totalScore = 0;
  List<int?> _answers = List<int?>.filled(10, null);

  final List<Map<String, dynamic>> _questions = [
    {"q": "1. Feeding (รับประทานอาหาร)", "opt": [{"t": "ต้องมีคนป้อน", "s": 0}, {"t": "ช่วยตัวเองได้บ้าง", "s": 5}, {"t": "ปกติ", "s": 10}]},
    {"q": "2. Grooming (ล้างหน้า หวีผม)", "opt": [{"t": "ต้องช่วย", "s": 0}, {"t": "ทำเองได้", "s": 5}]},
    {"q": "3. Transfer (ลุกนั่งจากที่นอน)", "opt": [{"t": "ทำไม่ได้", "s": 0}, {"t": "ต้องช่วยมาก", "s": 5}, {"t": "ช่วยเล็กน้อย", "s": 10}, {"t": "ปกติ", "s": 15}]},
    {"q": "4. Toilet use (การใช้ห้องน้ำ)", "opt": [{"t": "ต้องช่วยหมด", "s": 0}, {"t": "ช่วยบ้าง", "s": 5}, {"t": "ปกติ", "s": 10}]},
    {"q": "5. Mobility (การเดินภายในห้อง)", "opt": [{"t": "เดินไม่ได้", "s": 0}, {"t": "ใช้รถเข็น", "s": 5}, {"t": "ช่วยเดิน", "s": 10}, {"t": "ปกติ", "s": 15}]},
    {"q": "6. Dressing (การแต่งตัว)", "opt": [{"t": "ต้องช่วย", "s": 0}, {"t": "ช่วยบ้าง", "s": 5}, {"t": "ปกติ", "s": 10}]},
    {"q": "7. Stairs (การขึ้นลงบันได)", "opt": [{"t": "ไม่ได้", "s": 0}, {"t": "ต้องช่วย", "s": 5}, {"t": "ปกติ", "s": 10}]},
    {"q": "8. Bathing (การอาบน้ำ)", "opt": [{"t": "ต้องช่วย", "s": 0}, {"t": "ทำเองได้", "s": 5}]},
    {"q": "9. Bowel (การกลั้นอุจจาระ)", "opt": [{"t": "กลั้นไม่ได้", "s": 0}, {"t": "บางครั้ง", "s": 5}, {"t": "ปกติ", "s": 10}]},
    {"q": "10. Bladder (การกลั้นปัสสาวะ)", "opt": [{"t": "กลั้นไม่ได้", "s": 0}, {"t": "บางครั้ง", "s": 5}, {"t": "ปกติ", "s": 10}]},
  ];

  void _finish() {
    int sum = 0;
    for (var s in _answers) { sum += s ?? 0; }
    Navigator.pop(context, sum); // ส่งคะแนนกลับไปหน้า Assessment
  }

  @override
  Widget build(BuildContext context) {
    var current = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("แบบประเมิน ADL", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryGreen),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: (_currentIndex + 1) / 10,
              backgroundColor: Colors.grey.shade200,
              color: primaryGreen,
            ),
            const SizedBox(height: 30),
            Text("ข้อที่ ${_currentIndex + 1} / 10", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Text(current['q'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryGreen)),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                itemCount: current['opt'].length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  var o = current['opt'][index];
                  bool isSelected = _answers[_currentIndex] == o['s'];
                  return OptionTile(
                    text: o['t'],
                    isSelected: isSelected,
                    onTap: () => setState(() => _answers[_currentIndex] = o['s']),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentIndex > 0
                    ? TextButton(onPressed: () => setState(() => _currentIndex--), child: const Text("ย้อนกลับ", style: TextStyle(color: Colors.grey)))
                    : const SizedBox(),
                ElevatedButton(
                  onPressed: _answers[_currentIndex] == null ? null : () {
                    if (_currentIndex < 9) setState(() => _currentIndex++);
                    else _finish();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: Text(_currentIndex == 9 ? "ส่งคำตอบ" : "ถัดไป", style: const TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}


  // ----------------------------------------------------------------
  // Lightweight option tile widget used in the ADL assessment screen.
  // Placed here to avoid extra rebuilds and keep UI fast.
  // ----------------------------------------------------------------
  class OptionTile extends StatelessWidget {
    final String text;
    final bool isSelected;
    final VoidCallback onTap;

    const OptionTile({
      Key? key,
      required this.text,
      required this.isSelected,
      required this.onTap,
    }) : super(key: key);

    @override
    Widget build(BuildContext context) {
      // Re‑use the primary green defined at file top.
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? primaryGreen : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: primaryGreen),
              const SizedBox(width: 15),
              Text(text, style: TextStyle(fontSize: 16, color: isSelected ? primaryGreen : Colors.black87)),
            ],
          ),
        ),
      );
    }
  }