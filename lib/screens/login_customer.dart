import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/screens/signup_customer_screen.dart';

import 'package:my_app/services/auth_service.dart';
import 'package:my_app/theme/app_colors.dart';
import 'package:my_app/widgets/login/auth_divider.dart';
import 'package:my_app/widgets/login/auth_primary_button.dart';
import 'package:my_app/widgets/login/login_text_field.dart';
import 'package:my_app/widgets/login/social_circle.dart';

class Loginuser extends StatefulWidget {
  const Loginuser({super.key});

  @override
  State<Loginuser> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Loginuser> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'กรุณากรอกอีเมล';

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
    if (!emailRegex.hasMatch(v)) return 'รูปแบบอีเมลไม่ถูกต้อง';

    return null;
  }

  String? validatePassword(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'กรุณากรอกรหัสผ่าน';
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

  Future<void> validateForm() async {
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isLoading = true);

    try {
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

      // ✅ แนะนำ: ถ้ามี AuthGate (authStateChanges) ไม่ต้อง Navigator
      // ถ้าอยาก push เองค่อยปลดคอมเมนต์
      // Navigator.pushReplacement(...);

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', _mapAuthErrorTH(e));
    } catch (_) {
      if (!mounted) return;
      _showErrorDialog('เกิดข้อผิดพลาด', 'ไม่สามารถเข้าสู่ระบบได้ กรุณาลองใหม่อีกครั้ง');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', _mapAuthErrorTH(e));
    } catch (_) {
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', 'ไม่สามารถเข้าสู่ระบบด้วย Google ได้');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithFacebook() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signInWithFacebook();
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', _mapAuthErrorTH(e));
    } catch (_) {
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', 'ไม่สามารถเข้าสู่ระบบด้วย Facebook ได้');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.signInWithApple();
    } on FirebaseAuthException catch (e) {
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', _mapAuthErrorTH(e));
    } catch (_) {
      _showErrorDialog('เข้าสู่ระบบไม่สำเร็จ', 'ไม่สามารถเข้าสู่ระบบด้วย Apple ได้');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 30),
                  const Text(
                    'เข้าสู่ระบบ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 20),

                  LoginTextField(
                    label: 'อีเมล',
                    hintText: 'กรอกอีเมล',
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  const SizedBox(height: 16),

                  LoginTextField(
                    label: 'รหัสผ่าน',
                    hintText: 'กรอกรหัสผ่าน',
                    controller: _passCtrl,
                    obscureText: _obscure,
                    validator: validatePassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.lightGrey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _isLoading ? null : () {
                        // TODO: ไปหน้า forgot password
                      },
                      child: const Text(
                        'ลืมรหัสผ่าน?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.pageIndicatorActive,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  AuthPrimaryButton(
                    text: _isLoading ? 'กำลังเข้าสู่ระบบ...' : 'เข้าสู่ระบบ',
                    onPressed: _isLoading ? null : validateForm,
                    isLoading: _isLoading,
                  ),

                  const SizedBox(height: 20),
                  const AuthDivider(),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialCircle(
                        onPressed: _isLoading ? null : _loginWithGoogle,
                        child: Text(
                          'G',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      SocialCircle(
                        onPressed: _isLoading ? null : _loginWithFacebook,
                        child: Text(
                          'f',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      SocialCircle(
                        onPressed: _isLoading ? null : _loginWithApple,
                        child: Icon(
                          Icons.apple,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'ยังไม่ได้เป็นสมาชิก?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: Colors.black),
                  ),
                  const SizedBox(height: 8),

                  Center(
                    child: TextButton(
                      onPressed: _isLoading ? null : () {
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignupCustomerScreen() ),
                  );
                        
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: AppColors.pageIndicatorActive,
                      ),
                      child: const Text(
                        'สมัครสมาชิกลูกค้า',
                        style: TextStyle(
                          fontSize: 12.5,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.pageIndicatorActive,
                          decorationThickness: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}