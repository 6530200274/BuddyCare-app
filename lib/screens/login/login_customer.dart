import 'package:flutter/material.dart';
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
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    return null;
  }

  Future<void> validateForm() async {
    // ✅ ปิดคีย์บอร์ดก่อน
    FocusScope.of(context).unfocus();

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _isLoading = true);

    try {
      final success = await AuthService.login(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เข้าสู่ระบบสำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );

        // TODO: ไปหน้าหลัก
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomePage()),
        // );
      } else {
        _showErrorDialog(
          'อีเมลหรือรหัสผ่านไม่ถูกต้อง',
          'กรุณาตรวจสอบข้อมูลและลองใหม่อีกครั้ง',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      _showErrorDialog(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาลองใหม่อีกครั้ง',
      );
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
            child: const Text('ตกลง'), // ✅ แก้จาก "ตลอด"
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
              key: _formKey, // ✅ ใช้งานจริงแล้ว
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
                    validator: validateEmail, // ✅
                  ),

                  const SizedBox(height: 16),

                  LoginTextField(
                    label: 'รหัสผ่าน',
                    hintText: 'กรอกรหัสผ่าน',
                    controller: _passCtrl,
                    obscureText: _obscure, // ✅ ใช้ชื่อถูกแล้ว
                    validator: validatePassword, // ✅
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
                      onPressed: _isLoading ? null : () {},
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
                    onPressed: _isLoading ? null : validateForm, // ✅ disable ตอนโหลด
                    isLoading: _isLoading, // ✅ โชว์ spinner
                  ),

                  const SizedBox(height: 20),
                  const AuthDivider(),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialCircle(
                        onPressed: _isLoading ? null : () {},
                        child: const Text(
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
                        onPressed: _isLoading ? null : () {},
                        child: const Text(
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
                        onPressed: _isLoading ? null : () {},
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
                      onPressed: _isLoading ? null : () {},
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