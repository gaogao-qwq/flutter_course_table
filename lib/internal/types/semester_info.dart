class SemesterInfo {
  final String value;
  final String index;
  final String semesterId1;
  final String semesterId2;

  const SemesterInfo({
    required this.value,
    required this.index,
    required this.semesterId1,
    required this.semesterId2,
  });

  factory SemesterInfo.fromJson(Map<String, dynamic> json) {
    return SemesterInfo(
      value: json['Value'].toString(),
      index: json['Index'].toString(),
      semesterId1: json['SemesterId1'].toString(),
      semesterId2: json['SemesterId2'].toString(),
    );
  }
}