import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/screens/caregiver/home_schedule_screen.dart';
import 'package:my_app/screens/signup_caregiver_screen.dart';

import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/services/auth_service.dart';
import 'package:my_app/widgets/login/auth_divider.dart';
import 'package:my_app/widgets/login/auth_primary_button.dart';
import 'package:my_app/widgets/login/login_text_field.dart';
import 'package:my_app/widgets/login/social_circle.dart';

class CaregiverLoginScreen extends StatefulWidget {
  const CaregiverLoginScreen({super.key});

  @override
  State<CaregiverLoginScreen> createState() => _CaregiverLoginScreenState();
}

class _CaregiverLoginScreenState extends State<CaregiverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'กรุณากรอกอีเมล';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) return 'รูปแบบอีเมลไม่ถูกต้อง';
    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
    return null;
  }

  String _mapAuthErrorTH(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'ไม่พบบัญชีผู้ใช้นี้';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      case 'user-disabled':
        return 'บัญชีนี้ถูกปิดใช้งาน';
      case 'too-many-requests':
        return 'มีการพยายามหลายครั้งเกินไป กรุณาลองใหม่ภายหลัง';
      case 'network-request-failed':
        return 'เครือข่ายมีปัญหา กรุณาตรวจสอบอินเทอร์เน็ต';
      default:
        return e.message ?? 'เข้าสู่ระบบไม่สำเร็จ';
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Future<void> _loginEmail() async {
    FocusScope.of(context).unfocus();
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isLoading = true);
    try {
      // ✅ Web: ให้ AuthService ของคุณเป็นตัวเรียก Firebase จริง
      await AuthService.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เข้าสู่ระบบสำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScheduleScreen()),
        (route) => false, // ❌ ลบทุกหน้าก่อนหน้า (ย้อนกลับไม่ได้)
      );

      // TODO: ถ้าคุณมี AuthGate ก็ไม่ต้อง push หน้า
      // Navigator.pushReplacement(...);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', _mapAuthErrorTH(e));
    } catch (_) {
      if (!mounted) return;
      _showErrorDialog(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถเข้าสู่ระบบได้ กรุณาลองใหม่',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _isLoading = true);
    try {
      // ✅ สำหรับ Chrome Web แนะนำให้ AuthService ใช้ signInWithPopup
      await AuthService.signInWithGoogleWeb();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เข้าสู่ระบบด้วย Google สำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', _mapAuthErrorTH(e));
    } catch (_) {
      _showErrorDialog(
        'เข้าสู่ระบบไม่สำเร็จ',
        'ไม่สามารถเข้าสู่ระบบด้วย Google ได้',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginFacebook() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signInWithFacebookWeb();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เข้าสู่ระบบด้วย Facebook สำเร็จ'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', _mapAuthErrorTH(e));
    } catch (_) {
      _showErrorDialog(
        'เข้าสู่ระบบไม่สำเร็จ',
        'ไม่สามารถเข้าสู่ระบบด้วย Facebook ได้',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginApple() async {
    // ⚠️ Apple บน Web ต้องตั้งค่าเยอะ (clientId/redirect, Apple Developer)
    _showErrorDialog(
      'ยังไม่พร้อมใช้งาน',
      'Apple Sign-in บน Web ต้องตั้งค่าเพิ่มเติม',
    );
  }

  @override
  Widget build(BuildContext context) {
    // สีส้มของปุ่ม/ลิงก์ในภาพ (คุณใช้ AppColors.primary/pageIndicatorActive ได้)
    const accent = AppColors.pageIndicatorActive;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // Title ตามภาพ
                  const Text(
                    'เข้าสู่ระบบผู้ดูแล',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBlack,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Email
                  LoginTextField(
                    label: 'อีเมล์',
                    hintText: 'กรอกอีเมล์',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 18),

                  // Password
                  LoginTextField(
                    label: 'รหัสผ่าน',
                    hintText: 'กรอกรหัสผ่าน',
                    controller: _passCtrl,
                    obscureText: _obscure,
                    validator: _validatePassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Forgot password (ขวา, สีส้ม)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CaregiverLoginScreen(),
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: accent,
                      ),
                      child: const Text(
                        'ลืมรหัสผ่าน?',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: accent,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Primary button (เม็ดยา ส้ม)
                  AuthPrimaryButton(
                    text: _isLoading ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ',
                    onPressed: _isLoading ? null : _loginEmail,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 18),

                  // Divider "หรือ" (เส้นซ้ายขวา)
                  const AuthDivider(),

                  const SizedBox(height: 18),

                  // Social icons (3 วงกลม)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialCircle(
                        onPressed: _isLoading ? null : _loginGoogle,
                        child: const Text(
                          'G',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      SocialCircle(
                        onPressed: _isLoading ? null : _loginFacebook,
                        child: const Text(
                          'f',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      SocialCircle(
                        onPressed: _isLoading ? null : _loginApple,
                        child: const Icon(
                          Icons.apple,
                          color: AppColors.white,
                          size: 26,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'ยังไม่ได้เป็นสมาชิก?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // สมัครสมาชิกผู้ดูแล (สีส้ม + เส้นใต้สีเดียวกับข้อความ)
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupCaregiverScreen(),
                                ),
                              );
                            },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: accent,
                      ),
                      child: const Text(
                        'สมัครสมาชิกผู้ดูแล',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: accent,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
