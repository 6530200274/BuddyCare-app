class BookingSelection {
  final DateTime? serviceDate; // วันที่รับบริการ
  final String? serviceTime;   // เวลา

  const BookingSelection({
    this.serviceDate,
    this.serviceTime,
  });

  BookingSelection copyWith({
    DateTime? serviceDate,
    String? serviceTime, required String address, required String postcode, String? province,
  }) {
    return BookingSelection(
      serviceDate: serviceDate ?? this.serviceDate,
      serviceTime: serviceTime ?? this.serviceTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceDate': serviceDate?.toIso8601String(),
      'serviceTime': serviceTime,
    };
  }
}
