import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../Models/customer_model.dart';

class CustomerNotifier extends StateNotifier<List<CustomerModel>> {
  CustomerNotifier() : super([]) {
    fetchCustomers();
  }

  final _db = FirebaseFirestore.instance;
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> fetchCustomers() async {
    if (_userId == null) return;
    try {
      final snapshot = await _db
          .collection('users')
          .doc(_userId)
          .collection('customers')
          .get();
      state = snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching customers: $e");
    }
  }

  Future<void> addOrUpdateCustomer(String name) async {
    if (_userId == null || name.isEmpty) return;

    final customerRef = _db.collection('users').doc(_userId).collection('customers');
    
    final existingIndex = state.indexWhere(
      (c) => c.name.toLowerCase() == name.trim().toLowerCase()
    );

    try {
      if (existingIndex == -1) {
        await customerRef.add({
          'name': name.trim(),
          'lastVisit': Timestamp.now(),
        });
      } else {
        await customerRef.doc(state[existingIndex].id).update({
          'lastVisit': Timestamp.now(),
        });
      }
      fetchCustomers();
    } catch (e) {
      print("Error adding/updating customer: $e");
    }
  }

  Future<void> updateCustomerName(String id, String newName) async {
    if (_userId == null || newName.isEmpty) return;

    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('customers')
          .doc(id)
          .update({'name': newName.trim()});
      fetchCustomers();
    } catch (e) {
      print("Error updating customer name: $e");
    }
  }
}

final customerProvider = StateNotifierProvider<CustomerNotifier, List<CustomerModel>>((ref) {
  return CustomerNotifier();
});
