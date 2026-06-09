import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb; 
// 🚩 ตรวจสอบ Path ไฟล์ในโปรเจกต์ของคุณให้ถูกต้องนะครับ
import '../main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final Color primaryGreen = const Color(0xFF577460);

  // 🚩 Client ID สำหรับ Web
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '570786529381-1m7c2l8sji1rqrc8tvl6dk8j4jv50ilq.apps.googleusercontent.com',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔥 1. ระบบ Login ด้วย Email/Password
  Future<void> _signInWithEmailPassword() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("กรุณากรอกอีเมลและรหัสผ่าน", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _navigateToMain();
    } on FirebaseAuthException catch (e) {
      String message = "เข้าสู่ระบบไม่สำเร็จ";
      if (e.code == 'user-not-found') message = "ไม่พบผู้ใช้งานอีเมลนี้";
      else if (e.code == 'wrong-password') message = "รหัสผ่านไม่ถูกต้อง";
      _showSnackBar(message, Colors.red.shade400);
    } catch (e) {
      _showSnackBar("เกิดข้อผิดพลาด: $e", Colors.red.shade400);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔥 2. ระบบ Login ด้วย Google (เวอร์ชันแก้ปัญหา Web COOP)
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        // --- สำหรับ WEB (ใช้วิธี Popup เพื่อเลี่ยงปัญหา Security ของ Browser) ---
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // --- สำหรับ MOBILE ---
        await _googleSignIn.signOut();
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          setState(() => _isLoading = false);
          return;
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      _navigateToMain();
    } catch (e) {
      debugPrint("Google Login Error: $e");
      _showSnackBar("Google Login ล้มเหลว", Colors.red.shade400);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToMain() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => const MainScreen()),
        (route) => false,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // โลโก้
                    Image.asset(
                      'assets/logo/logo2.png',
                      height: 80, 
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.eco, size: 80, color: primaryGreen),
                    ),
                    const SizedBox(height: 30),
                    const Text("ยินดีต้อนรับ", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    const Text("เข้าสู่ระบบเพื่อเริ่มการดูแลสุขภาพ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(height: 35),
                    
                    // ช่องกรอกข้อมูล
                    _buildTextField(hint: "อีเมล", controller: _emailController, icon: Icons.email_outlined),
                    const SizedBox(height: 15),
                    _buildTextField(hint: "รหัสผ่าน", isPassword: true, controller: _passwordController, icon: Icons.lock_outline),
                    
                    const SizedBox(height: 30),
                    // ปุ่มเข้าสู่ระบบ
                    _buildPrimaryButton(
                      text: "เข้าสู่ระบบ", 
                      onPressed: _isLoading ? null : _signInWithEmailPassword
                    ),
                    
                    const SizedBox(height: 20),
                    const Text("หรือ", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 20),
                    
                    // ปุ่ม Google
                    _buildGoogleButton(),
                    
                    const SizedBox(height: 40),
                    // สมัครสมาชิก
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("ยังไม่มีบัญชีใช่ไหม? ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RegisterScreen())),
                          child: Text("ลงทะเบียนที่นี่", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          
          // 🚩 ปุ่มข้าม (วางไว้ที่มุมขวาบนสุด)
          Positioned(
            top: 50, // ระยะห่างจากขอบบน (ปรับได้ตามความเหมาะสมของหน้าจอมือถือ)
            right: 20, // ระยะห่างจากขอบขวา
            child: TextButton(
              onPressed: _navigateToMain, // กดแล้วพาเข้าหน้า MainScreen ทันทีโดยไม่ต้องล็อกอิน
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                "ข้าม", 
                style: TextStyle(
                  color: Colors.grey.shade600, 
                  fontSize: 16, 
                  fontWeight: FontWeight.bold
                )
              ),
            ),
          ),

          // Loading Overlay
          if (_isLoading) 
            Container(
              color: Colors.black.withOpacity(0.3), 
              child: const Center(child: CircularProgressIndicator(color: Colors.white))
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hint, bool isPassword = false, required TextEditingController controller, required IconData icon}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          side: BorderSide(color: Colors.grey.shade300),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png', 
              height: 24,
              errorBuilder: (c,e,s) => const Icon(Icons.login, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            const Text("เข้าสู่ระบบด้วย Google", style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}