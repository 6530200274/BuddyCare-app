class EmergencyContact {
  final String firstName;
  final String lastName;
  final String phone;

  const EmergencyContact({
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
  };

  factory EmergencyContact.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const EmergencyContact(firstName: '', lastName: '', phone: '');
    }
    return EmergencyContact(
      firstName: (map['firstName'] ?? '') as String,
      lastName: (map['lastName'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
    );
  }
}

class RecipientProfile {
  final String firstName;
  final String lastName;
  final String phone;
  final DateTime? dob;

  final String nationality;
  final String religion;
  final String language;

  final double? weightKg;
  final double? heightCm;

  final String gender;
  final String relationship;

  final EmergencyContact emergencyContact;

  const RecipientProfile({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.dob,
    required this.nationality,
    required this.religion,
    required this.language,
    required this.weightKg,
    required this.heightCm,
    required this.gender,
    required this.relationship,
    required this.emergencyContact,
  });

  Map<String, dynamic> toMap() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'dob': dob, // Firestore รองรับ DateTime เป็น Timestamp อัตโนมัติ
    'nationality': nationality,
    'religion': religion,
    'language': language,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'gender': gender,
    'relationship': relationship,
    'emergencyContact': emergencyContact.toMap(),
  };

  factory RecipientProfile.empty() => const RecipientProfile(
    firstName: '',
    lastName: '',
    phone: '',
    dob: null,
    nationality: '',
    religion: '',
    language: '',
    weightKg: null,
    heightCm: null,
    gender: '',
    relationship: '',
    emergencyContact: EmergencyContact(firstName: '', lastName: '', phone: ''),
  );
}
