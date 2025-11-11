class BuildingModel {
  final String id;
  final String buildingName;

  const BuildingModel({required this.id, required this.buildingName});

  factory BuildingModel.fromMap(Map<String, dynamic> map) {
    return BuildingModel(
      id: map['_id'] as String,
      buildingName: map['buildingName'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {'_id': id, 'buildingName': buildingName};
  }
}
