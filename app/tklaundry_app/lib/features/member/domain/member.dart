class Member {
  const Member({
    required this.userId,
    required this.userName,
    required this.useYn,
  });

  final String userId;
  final String userName;
  final String useYn;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? '',
      useYn: json['useYn'] as String? ?? '',
    );
  }
}
