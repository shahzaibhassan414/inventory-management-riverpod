import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String? phone;
  final DateTime lastVisit;

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    required this.lastVisit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'lastVisit': Timestamp.fromDate(lastVisit),
    };
  }

  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'],
      lastVisit: (data['lastVisit'] as Timestamp).toDate(),
    );
  }
}
