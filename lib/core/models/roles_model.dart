class RolesModel {
  final String message;
  final List<RolesData> data;

  RolesModel({
    required this.message,
    required this.data,
  });

  factory RolesModel.fromJson(Map<String, dynamic> json) => RolesModel(
        message: json["message"],
        data: List<RolesData>.from(json["data"].map((x) => RolesData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class RolesData {
  final int id;
  final String name;

  RolesData({
    required this.id,
    required this.name,
  });

  factory RolesData.fromJson(Map<String, dynamic> json) => RolesData(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
