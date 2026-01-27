import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_text_field.dart';
import '../widgets/primary_button.dart';

class SignupCaregiverScreen extends StatefulWidget {
  const SignupCaregiverScreen ({super.key});

  @override
  State<SignupCaregiverScreen > createState() => _SignupCaregiverScreenState();
}

class _SignupCaregiverScreenState extends State<SignupCaregiverScreen > {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _hidePass = true;
  bool _hideConfirm = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) {
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(v.trim());
  }

   String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'อีเมลนี้ถูกใช้งานแล้ว';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      case 'weak-password':
        return 'รหัสผ่านอ่อนเกินไป (ควรยาวขึ้น)';
      case 'operation-not-allowed':
        return 'ยังไม่ได้เปิดการสมัครด้วย Email/Password ใน Firebase';
      default:
        return e.message ?? 'สมัครสมาชิกไม่สำเร็จ';
    }
  }

  Future<void> _onSubmit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    setState(() => _loading = true);

    try {
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text;

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user?.uid;
      debugPrint('created uid: $uid');

      if (uid == null) {
        throw Exception('สมัครสำเร็จแต่ uid เป็น null');
      }

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'role': 'caregiver',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สมัครสมาชิกสำเร็จ')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      debugPrint('AUTH ERROR: ${e.code} ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Auth (${e.code}): ${_friendlyAuthError(e)}')),
      );
    } on FirebaseException catch (e) {
      debugPrint('FIREBASE ERROR: ${e.code} ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firebase (${e.code}): ${e.message}')),
      );
    } catch (e) {
      debugPrint('UNKNOWN ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context), 
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  'สมัครสมาชิกผู้ดูแล',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 28),

                AppTextField(
                  label: 'อีเมล', 
                  hintText: 'กรอกอีเมล', 
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'กรุณากรอกอีเมล';
                    if (!_isValidEmail(value)) return 'รูปแบบอีเมลไม่ถูกต้อง';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'รหัสผ่าน', 
                  hintText: 'กรอกรหัสผ่าน', 
                  controller: _passCtrl,
                  obscureText: _hidePass,
                  validator: (v) {
                    final value = (v ?? '');
                    if (value.isEmpty) return 'กรุณากรอกรหัสผ่าน';
                    if (value.length < 6) {
                      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    onPressed: () => setState(()=> _hidePass = !_hidePass), 
                    icon: Icon(
                      _hidePass ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'ยืนยันรหัสผ่าน',
                  hintText: 'กรอกรหัสผ่าน',
                  controller: _confirmCtrl,
                  obscureText: _hideConfirm,
                  validator: (v) {
                    final value = (v ?? '');
                    if (value.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
                    if (value != _passCtrl.text) return 'รหัสผ่านไม่ตรงกัน';
                    return null;
                  },
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _hideConfirm = !_hideConfirm),
                    icon: Icon(
                      _hideConfirm ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 26),

                Center(
                  child: SizedBox(
                    width: 140,
                    child: PrimaryButton(
                      text: 'บันทึก',
                      loading: _loading,
                      onPressed: _loading ? null : _onSubmit,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}