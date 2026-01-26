class AuthService {
  // ⭐ จำลองการเรียก API
  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    const mockUsers = {
      'test@example.com': 'Password123',
      'admin@buddycare.com': 'Admin@2024',
      'user@gmail.com': 'User1234',
    };

    return mockUsers[email.trim()] == password;
  }
}