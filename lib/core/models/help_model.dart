class HelpModel {
  final String message;
  final HelpData ?data;

  HelpModel({required this.message, required this.data});

  factory HelpModel.fromJson(Map<String, dynamic> json) => HelpModel(
        message: json["message"],
        data: json["data"] == null ? null : HelpData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
      };
}

class HelpData {
  final int id;
  final String category;
  final dynamic status;
  final dynamic mobileNumber;
  final dynamic note;
  final dynamic userId;

  HelpData({
    required this.id,
    required this.category,
    required this.status,
    required this.mobileNumber,
    required this.note,
    required this.userId,
  });

  factory HelpData.fromJson(Map<String, dynamic> json) => HelpData(
    id: json["id"] ?? 0,
    category: json["category"] ?? '',
    status: json["status"] ?? '',
    mobileNumber: json["mobile_number"] ?? '',
    note: json["note"] ?? '',
    userId: json["user_id"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category": category,
    "status": status,
    "mobile_number": mobileNumber,
    "note": note,
    "user_id": userId,
  };
}
