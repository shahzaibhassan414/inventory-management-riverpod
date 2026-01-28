import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../Models/generate_invoice_model.dart';

class InvoiceHistoryNotifier extends StateNotifier<List<GenerateInvoiceModel>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  InvoiceHistoryNotifier() : super([]) {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('invoices')
          .orderBy('dateTime', descending: true)
          .get();
      state = snapshot.docs.map((doc) => GenerateInvoiceModel.fromFirestore(doc)).toList();
    }
  }

  Future<void> addInvoice(GenerateInvoiceModel invoice) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('invoices')
            .doc(invoice.id)
            .set(invoice.toMap());
        state = [invoice, ...state];
      }
    } catch (e) {
      debugPrint("Error saving invoice: $e");
    }
  }

  Future<void> updateInvoicesCustomerName(String oldName, String newName) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('invoices')
          .where('customerName', isEqualTo: oldName)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'customerName': newName});
      }
      await batch.commit();
      
      // Update local state as well
      state = state.map((invoice) {
        if (invoice.customerName == oldName) {
          return GenerateInvoiceModel(
            id: invoice.id,
            customerName: newName,
            dateTime: invoice.dateTime,
            items: invoice.items,
            total: invoice.total,
          );
        }
        return invoice;
      }).toList();
      
    } catch (e) {
      debugPrint("Error updating invoices customer name: $e");
    }
  }
}

final invoiceHistoryProvider =
    StateNotifierProvider<InvoiceHistoryNotifier, List<GenerateInvoiceModel>>((ref) {
  return InvoiceHistoryNotifier();
});

final totalSalesProvider = Provider<double>((ref) {
  final invoices = ref.watch(invoiceHistoryProvider);
  return invoices.fold(0.0, (sum, invoice) => sum + invoice.total);
});
