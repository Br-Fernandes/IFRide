class DriverApplicationRequest {
  final String requesterId;
  final String cnhNumber;
  final String cnhCategory;
  final String expiration;

  DriverApplicationRequest({
    required this.requesterId,
    required this.cnhNumber,
    required this.cnhCategory,
    required this.expiration,
  });

  Map<String, dynamic> toJson() => {
        'requesterId': requesterId,
        'cnhNumber': cnhNumber,
        'cnhCategory': cnhCategory,
        'expiration': expiration,
      };
}

class DriverApplicationSummary {
  final String requesterId;
  final String applicationStatus;
  final String cnhNumber;
  final String cnhCategory;
  final String cnhExpiration;
  final String? rejectionReason;

  DriverApplicationSummary({
    required this.requesterId,
    required this.applicationStatus,
    required this.cnhNumber,
    required this.cnhCategory,
    required this.cnhExpiration,
    this.rejectionReason,
  });

  factory DriverApplicationSummary.fromJson(Map<String, dynamic> json) {
    final requester = json['requester'] as Map<String, dynamic>? ?? {};
    return DriverApplicationSummary(
      requesterId: requester['id']?.toString() ?? '',
      applicationStatus: json['applicationStatus'] ?? 'PENDING',
      cnhNumber: json['cnhNumber'] ?? '',
      cnhCategory: json['cnhCategory'] ?? '',
      cnhExpiration: json['cnhExpiration'] ?? '',
      rejectionReason: json['rejectionReason'],
    );
  }
}
