import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// TODO: เปลี่ยนเป็นหน้าจริงของคุณ
class CustomerHome extends StatelessWidget {
  const CustomerHome({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Customer Home')));
}

class CaregiverHome extends StatelessWidget {
  const CaregiverHome({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Caregiver Home')));
}

class RoleMissingPage extends StatelessWidget {
  const RoleMissingPage({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('ไม่พบ role ใน Firestore')));
}

// TODO: เปลี่ยนเป็นหน้า Login ของคุณ
class LoginPagePlaceholder extends StatelessWidget {
  const LoginPagePlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login Page')));
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snap) {
        final user = snap.data;

        if (user == null) {
          return const LoginPagePlaceholder(); // <- เปลี่ยนเป็น Loginuser() ของคุณ
        }

        return FutureBuilder<String?>(
          future: AuthService.getMyRole(),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState != ConnectionState.done) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final role = roleSnap.data;

            if (role == 'customer') return const CustomerHome();
            if (role == 'caregiver') return const CaregiverHome();

            return const RoleMissingPage();
          },
        );
      },
    );
  }
}