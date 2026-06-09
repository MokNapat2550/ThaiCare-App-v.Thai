import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth/intro_screen.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart'; // 🚩 นำเข้าแพ็กเกจเรียบร้อย


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ThaiCareApp());
}

class ThaiCareApp extends StatelessWidget {
  const ThaiCareApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThaiCare',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
      theme: ThemeData(
        // 🚩 แนะนำให้เปิด Material 3 เพื่อให้ดีไซน์ดูสะอาดตาและเข้ากับ Noto Sans มากขึ้นครับ
        useMaterial3: true, 
        
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        
        // กำหนดสีหลักและสีรองตามเดิมของคุณเอ็ม
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFA8E6CF),
          primary: const Color(0xFFA8E6CF),
          secondary: const Color(0xFFFFD3B6),
          surface: const Color(0xFFFDFBF7),
        ),

        // 🚩 1. เปลี่ยนฟอนต์หลักทั้งแอปเป็น Noto Sans Thai
        fontFamily: GoogleFonts.notoSansThai().fontFamily,

        // 🚩 2. ปรับ TextTheme เพื่อให้ฟอนต์มีผลกับ Text ทุกประเภท (Heading, Body, ฯลฯ)
        textTheme: GoogleFonts.notoSansThaiTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const IntroScreen(),
    );
  }
}