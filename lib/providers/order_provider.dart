import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/order_remote_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider(this._orderRemoteService);

  static const Duration _confirmToShippingDelay = Duration(seconds: 30);
  static const Duration _shippingToDeliveredDelay = Duration(minutes: 1);

  final OrderRemoteService _orderRemoteService;
  final List<Order> _orders = [];
  final List<Order> _cachedOrders = [];
  final List<Order> _pendingOrders = [];
  Timer? _statusTicker;
  String? _activeUserId;
  bool _isLoading = false;
  String? _error;
  String? _placeOrderNotice;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get placeOrderNotice => _placeOrderNotice;
  bool get hasActiveUser => _activeUserId != null;
  List<Order> get receivedHistory => List.unmodifiable(
        _orders.where((order) => order.isReceivedConfirmed),
      );

  List<Order> byStatus(String status) {
    return _orders.where((order) => statusOf(order) == status).toList();
  }

  String statusOf(Order order, {DateTime? now}) {
    if (order.isCancelled) {
      return 'Đã hủy';
    }

    final currentTime = now ?? DateTime.now();
    final elapsed = currentTime.difference(order.createdAt);
    if (elapsed < _confirmToShippingDelay) {
      return 'Chờ xác nhận';
    }
    if (elapsed < _confirmToShippingDelay + _shippingToDeliveredDelay) {
      return 'Đang giao hàng';
    }
    return 'Đã giao';
  }

  bool canCancel(Order order) {
    return statusOf(order) == 'Chờ xác nhận' && !order.isCancelled;
  }

  bool canConfirmReceived(Order order) {
    return statusOf(order) == 'Đã giao' && !order.isReceivedConfirmed;
  }

  Future<void> reload() async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    await _loadOrders(userId);
    await _syncPendingOrders(userId);
    _updateStatusTicker();
  }

  void updateUser(String? userId) {
    if (_activeUserId == userId) {
      return;
    }

    _activeUserId = userId;
    _error = null;
    _placeOrderNotice = null;
    _orders.clear();
    _cachedOrders.clear();
    _pendingOrders.clear();
    _statusTicker?.cancel();
    _statusTicker = null;

    if (userId == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    unawaited(_bootstrapUserOrders(userId));
  }

  Future<void> _bootstrapUserOrders(String userId) async {
    await _loadCachedOrders(userId);
    await _loadPendingOrders(userId);
    await _loadOrders(userId);
    await _syncPendingOrders(userId);
    _updateStatusTicker();
  }

  Future<void> _loadOrders(String userId) async {
    try {
      if (_activeUserId != userId) {
        return;
      }

      final orders = await _orderRemoteService.fetchOrders(userId);
      if (_activeUserId != userId) {
        return;
      }

      _cachedOrders
        ..clear()
        ..addAll(orders);
      await _persistCachedOrders(userId);

      final merged = _mergeRemoteAndPending(orders, _pendingOrders);
      _orders
        ..clear()
        ..addAll(merged);
      _error = null;
    } on FirebaseException catch (exception) {
      if (_activeUserId != userId) {
        return;
      }
      _error = _friendlyFirestoreMessage(exception, action: 'tải');

      if (_orders.isEmpty && _cachedOrders.isNotEmpty) {
        _orders
          ..clear()
          ..addAll(_mergeRemoteAndPending(_cachedOrders, _pendingOrders));
      } else if (_orders.isEmpty && _pendingOrders.isNotEmpty) {
        _orders
          ..clear()
          ..addAll(_pendingOrders);
      }
    } catch (exception) {
      if (_activeUserId != userId) {
        return;
      }
      _error = 'Không tải được lịch sử mua hàng: $exception';

      if (_orders.isEmpty && _cachedOrders.isNotEmpty) {
        _orders
          ..clear()
          ..addAll(_mergeRemoteAndPending(_cachedOrders, _pendingOrders));
      } else if (_orders.isEmpty && _pendingOrders.isNotEmpty) {
        _orders
          ..clear()
          ..addAll(_pendingOrders);
      }
    } finally {
      if (_activeUserId == userId) {
        _isLoading = false;
        _updateStatusTicker();
        notifyListeners();
      }
    }
  }

  Future<bool> placeOrder({
    required List<CartItem> items,
    required double total,
    required String address,
    required String phoneNumber,
    required String paymentMethod,
  }) async {
    final userId = _activeUserId;
    if (userId == null) {
      _error = 'Vui lòng đăng nhập để lưu đơn hàng vào lịch sử mua hàng.';
      notifyListeners();
      return false;
    }

    _error = null;
    _placeOrderNotice = null;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      address: address,
      phoneNumber: phoneNumber,
      paymentMethod: paymentMethod,
      status: 'Chờ xác nhận',
      items: items,
      total: total,
    );

    _cachedOrders.removeWhere((cached) => cached.id == order.id);
    _cachedOrders.insert(0, order);
    await _persistCachedOrders(userId);

    _orders.insert(0, order);
    _updateStatusTicker();
    notifyListeners();

    try {
      await _orderRemoteService
          .saveOrder(userId: userId, order: order)
          .timeout(const Duration(seconds: 10));
      _pendingOrders.removeWhere((pendingOrder) => pendingOrder.id == order.id);
      await _persistPendingOrders(userId);
      _error = null;
      _placeOrderNotice = null;
      _updateStatusTicker();
      notifyListeners();
      return true;
    } on FirebaseException catch (exception) {
      await _upsertPendingOrder(userId, order);
      _placeOrderNotice =
          'Đơn hàng đã được lưu tạm trên thiết bị và sẽ tự đồng bộ khi mạng ổn định.';
      _error = _friendlyFirestoreMessage(exception, action: 'lưu');
      _updateStatusTicker();
      notifyListeners();
      return true;
    } on TimeoutException {
      await _upsertPendingOrder(userId, order);
      _placeOrderNotice =
          'Đơn hàng đã được lưu tạm trên thiết bị và sẽ tự đồng bộ khi có kết nối tốt hơn.';
      _error =
          'Lưu Firestore đang quá chậm, đơn hàng đã được giữ lại để đồng bộ sau.';
      _updateStatusTicker();
      notifyListeners();
      return true;
    } catch (exception) {
      await _upsertPendingOrder(userId, order);
      _placeOrderNotice =
          'Đơn hàng đã được lưu tạm trên thiết bị và sẽ tự đồng bộ khi mạng ổn định.';
      _error = 'Không lưu được đơn hàng lên Firestore ngay lúc này: $exception';
      _updateStatusTicker();
      notifyListeners();
      return true;
    }
  }

  Future<void> cancelOrder(String orderId) async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }

    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index < 0) {
      return;
    }

    final currentOrder = _orders[index];
    if (!canCancel(currentOrder)) {
      return;
    }

    final updatedOrder = currentOrder.copyWith(
      status: 'Đã hủy',
      isCancelled: true,
      cancelledAt: DateTime.now(),
    );
    await _applyOrderUpdate(userId, updatedOrder);
  }

  Future<void> confirmReceived(String orderId) async {
    final userId = _activeUserId;
    if (userId == null) {
      return;
    }

    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index < 0) {
      return;
    }

    final currentOrder = _orders[index];
    if (!canConfirmReceived(currentOrder)) {
      return;
    }

    final updatedOrder = currentOrder.copyWith(
      isReceivedConfirmed: true,
      receivedConfirmedAt: DateTime.now(),
    );
    await _applyOrderUpdate(userId, updatedOrder);
  }

  Future<void> _loadPendingOrders(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey(userId));

    _pendingOrders
      ..clear()
      ..addAll(
        raw == null
            ? const []
            : (jsonDecode(raw) as List<dynamic>)
                .map((e) => Order.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

    if (_orders.isEmpty && _cachedOrders.isNotEmpty) {
      _orders
        ..clear()
        ..addAll(_mergeRemoteAndPending(_cachedOrders, _pendingOrders));
    } else if (_orders.isEmpty && _pendingOrders.isNotEmpty) {
      _orders
        ..clear()
        ..addAll(_pendingOrders);
    }

    if (_activeUserId == userId && _orders.isNotEmpty) {
      _isLoading = false;
      _updateStatusTicker();
      notifyListeners();
    }
  }

  Future<void> _loadCachedOrders(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey(userId));

    _cachedOrders
      ..clear()
      ..addAll(
        raw == null
            ? const []
            : (jsonDecode(raw) as List<dynamic>)
                .map((e) => Order.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

    if (_orders.isEmpty && _cachedOrders.isNotEmpty) {
      _orders
        ..clear()
        ..addAll(_cachedOrders);
    }

    if (_activeUserId == userId && _orders.isNotEmpty) {
      _isLoading = false;
      _updateStatusTicker();
      notifyListeners();
    }
  }

  Future<void> _persistCachedOrders(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _cachedOrders.map((order) => order.toJson()).toList();
    await prefs.setString(_cacheKey(userId), jsonEncode(payload));
  }

  Future<void> _upsertPendingOrder(String userId, Order order) async {
    final index = _pendingOrders.indexWhere(
      (pendingOrder) => pendingOrder.id == order.id,
    );
    if (index >= 0) {
      _pendingOrders[index] = order;
    } else {
      _pendingOrders.insert(0, order);
    }
    await _persistPendingOrders(userId);
  }

  Future<void> _persistPendingOrders(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _pendingOrders.map((order) => order.toJson()).toList();
    await prefs.setString(_pendingKey(userId), jsonEncode(payload));
  }

  Future<void> _syncPendingOrders(String userId) async {
    if (_pendingOrders.isEmpty || _activeUserId != userId) {
      return;
    }

    final synced = <Order>[];
    for (final order in List<Order>.from(_pendingOrders)) {
      try {
        await _orderRemoteService
            .saveOrder(userId: userId, order: order)
            .timeout(const Duration(seconds: 10));
        synced.add(order);
      } catch (_) {
        break;
      }
    }

    if (synced.isNotEmpty) {
      _pendingOrders.removeWhere(
        (pendingOrder) => synced.any((item) => item.id == pendingOrder.id),
      );
      await _persistPendingOrders(userId);

      _orders
        ..clear()
        ..addAll(_mergeRemoteAndPending(_cachedOrders, _pendingOrders));

      _placeOrderNotice = _pendingOrders.isEmpty
          ? null
          : 'Một số đơn vẫn đang chờ đồng bộ lên Firestore.';
      _updateStatusTicker();
      notifyListeners();
    }
  }

  Future<void> _applyOrderUpdate(String userId, Order updatedOrder) async {
    _upsertOrderInList(_orders, updatedOrder);
    _upsertOrderInList(_cachedOrders, updatedOrder);
    await _persistCachedOrders(userId);

    _error = null;
    _placeOrderNotice = null;
    _updateStatusTicker();
    notifyListeners();

    try {
      await _orderRemoteService
          .saveOrder(userId: userId, order: updatedOrder)
          .timeout(const Duration(seconds: 10));
      _pendingOrders.removeWhere(
        (pendingOrder) => pendingOrder.id == updatedOrder.id,
      );
      await _persistPendingOrders(userId);
    } catch (_) {
      await _upsertPendingOrder(userId, updatedOrder);
      _placeOrderNotice =
          'Một số cập nhật đơn hàng đang chờ đồng bộ lên Firestore.';
    }

    _updateStatusTicker();
    notifyListeners();
  }

  List<Order> _mergeRemoteAndPending(
    List<Order> remoteOrders,
    List<Order> pendingOrders,
  ) {
    final mergedById = <String, Order>{
      for (final order in remoteOrders) order.id: order,
    };

    for (final order in pendingOrders) {
      mergedById[order.id] = order;
    }

    final merged = mergedById.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  void _upsertOrderInList(List<Order> target, Order order) {
    final index = target.indexWhere((item) => item.id == order.id);
    if (index >= 0) {
      target[index] = order;
    } else {
      target.insert(0, order);
    }
  }

  void _updateStatusTicker() {
    if (!_hasActiveTransitions()) {
      _statusTicker?.cancel();
      _statusTicker = null;
      return;
    }

    _statusTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_hasActiveTransitions()) {
        _statusTicker?.cancel();
        _statusTicker = null;
        return;
      }
      notifyListeners();
    });
  }

  bool _hasActiveTransitions() {
    final now = DateTime.now();
    return _orders.any(
      (order) => statusOf(order, now: now) == 'Chờ xác nhận' ||
          statusOf(order, now: now) == 'Đang giao hàng',
    );
  }

  String _pendingKey(String userId) => 'pending_orders_$userId';
  String _cacheKey(String userId) => 'orders_cache_$userId';

  String _friendlyFirestoreMessage(
    FirebaseException exception, {
    required String action,
  }) {
    final message = exception.message ?? exception.code;
    if (message.contains('Unable to establish connection on channel')) {
      return 'Không thể $action dữ liệu vì trình duyệt chưa kết nối được tới Firestore. Tôi đã bật chế độ tương thích mạng cho web, hãy tải lại trang rồi thử lại.';
    }

    switch (exception.code) {
      case 'permission-denied':
        return 'Không thể $action dữ liệu vì Firestore Rules chưa cho phép. Hãy publish lại rules trong Firebase Console.';
      case 'failed-precondition':
        return 'Không thể $action dữ liệu vì Firestore Database chưa được tạo. Hãy vào Firebase Console > Firestore Database > Create database.';
      case 'unavailable':
        return 'Không thể $action dữ liệu vì không kết nối được tới Firestore. Hãy kiểm tra mạng và thử lại.';
      case 'unauthenticated':
        return 'Bạn cần đăng nhập lại để $action lịch sử mua hàng.';
      default:
        return 'Không thể $action dữ liệu Firestore: $message';
    }
  }

  @override
  void dispose() {
    _statusTicker?.cancel();
    super.dispose();
  }
}
