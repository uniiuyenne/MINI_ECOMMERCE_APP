import 'package:cloud_firestore/cloud_firestore.dart'
  show CollectionReference, FirebaseFirestore;

import '../models/order.dart';

class OrderRemoteService {
  OrderRemoteService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _ordersCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('orders');
  }

  Future<List<Order>> fetchOrders(String userId) async {
    final snapshot = await _ordersCollection(userId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => Order.fromJson({
            ...doc.data(),
            'id': (doc.data()['id'] as String?)?.isNotEmpty == true
                ? doc.data()['id']
                : doc.id,
          }),
        )
        .toList();
  }

  Future<void> saveOrder({
    required String userId,
    required Order order,
  }) async {
    await _ordersCollection(userId).doc(order.id).set(order.toJson());
  }
}