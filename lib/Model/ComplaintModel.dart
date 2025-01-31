class ComplaintModel {
  final String id;
  final String typeOfComplaint;
  final String description;
  final String category;
  final String status;
  final String location;
  final bool isAnonymus;
  final bool isCritical;
  final String statement;
  final String time;

  ComplaintModel({
    required this.id,
    required this.typeOfComplaint,
    required this.description,
    required this.category,
    required this.status,
    required this.location,
    required this.isAnonymus,
    required this.isCritical,
    required this.statement,
    required this.time,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['_id'],
      typeOfComplaint: json['typeOfComplaint'],
      description: json['description'],
      category: json['category'],
      status: json['status'],
      location: json['location'],
      isAnonymus: json['isAnonymus'],
      isCritical: json['isCritical'],
      statement: json['statement'],
      time: json['createdAt'],
    );
  }
}
