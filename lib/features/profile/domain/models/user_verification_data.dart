class UserVerificationData {
  final bool isVerified;
  final String? userName;
  final double? creditLimit;
  final DateTime? limitExpiryDate;

  UserVerificationData({
    this.isVerified = false,
    this.userName,
    this.creditLimit,
    this.limitExpiryDate,
  });

  bool get hasActiveLimit {
    if (creditLimit == null || limitExpiryDate == null) return false;
    return limitExpiryDate!.isAfter(DateTime.now());
  }

  UserVerificationData copyWith({
    bool? isVerified,
    String? userName,
    double? creditLimit,
    DateTime? limitExpiryDate,
  }) {
    return UserVerificationData(
      isVerified: isVerified ?? this.isVerified,
      userName: userName ?? this.userName,
      creditLimit: creditLimit ?? this.creditLimit,
      limitExpiryDate: limitExpiryDate ?? this.limitExpiryDate,
    );
  }
}
