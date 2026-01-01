// models/service_types.dart
class ServiceTypes {
  final String id;
  final String name;
  final String displayName;

  

  ServiceTypes({
    required this.id,
    required this.name,
    required this.displayName,
   
  });

  factory ServiceTypes.fromJson(Map<String, dynamic> json) {
    return ServiceTypes(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
     
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'displayName': displayName,
   
  };
}
