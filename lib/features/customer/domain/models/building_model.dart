class BuildingModel {
  final String id;
  final String buildingName;

  const BuildingModel({required this.id, required this.buildingName});

  factory BuildingModel.fromMap(Map<String, dynamic> map) {
    final id = map['_id']?.toString() ?? map['id']?.toString() ?? '';
    final buildingName = map['buildingName']?.toString() ?? map['name']?.toString() ?? '';
    return BuildingModel(id: id, buildingName: buildingName);
  }

  Map<String, dynamic> toMap() {
    return {'_id': id, 'buildingName': buildingName};
  }
}
