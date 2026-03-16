import 'cart_item.dart';

class Order {
  final String id;
  final DateTime createdAt;
  final String address;
  final String phoneNumber;
  final String paymentMethod;
  final String status;
  final List<CartItem> items;
  final double total;
  final bool isCancelled;
  final DateTime? cancelledAt;
  final bool isReceivedConfirmed;
  final DateTime? receivedConfirmedAt;

  const Order({
    required this.id,
    required this.createdAt,
    required this.address,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.status,
    required this.items,
    required this.total,
    this.isCancelled = false,
    this.cancelledAt,
    this.isReceivedConfirmed = false,
    this.receivedConfirmedAt,
  });

  Order copyWith({
    String? id,
    DateTime? createdAt,
    String? address,
    String? phoneNumber,
    String? paymentMethod,
    String? status,
    List<CartItem>? items,
    double? total,
    bool? isCancelled,
    DateTime? cancelledAt,
    bool? isReceivedConfirmed,
    DateTime? receivedConfirmedAt,
    bool clearCancelledAt = false,
    bool clearReceivedConfirmedAt = false,
  }) {
    return Order(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      isCancelled: isCancelled ?? this.isCancelled,
      cancelledAt: clearCancelledAt
          ? null
          : (cancelledAt ?? this.cancelledAt),
      isReceivedConfirmed: isReceivedConfirmed ?? this.isReceivedConfirmed,
      receivedConfirmedAt: clearReceivedConfirmedAt
          ? null
          : (receivedConfirmedAt ?? this.receivedConfirmedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'address': address,
      'phoneNumber': phoneNumber,
      'paymentMethod': paymentMethod,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'isCancelled': isCancelled,
      'cancelledAt': cancelledAt?.millisecondsSinceEpoch,
      'isReceivedConfirmed': isReceivedConfirmed,
      'receivedConfirmedAt': receivedConfirmedAt?.millisecondsSinceEpoch,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];

    return Order(
      id: json['id'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      address: json['address'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? 'COD',
      status: json['status'] as String? ?? 'Chờ xác nhận',
      items: itemsJson
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      isCancelled: json['isCancelled'] as bool? ?? false,
      cancelledAt: (json['cancelledAt'] as num?) == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              (json['cancelledAt'] as num).toInt(),
            ),
      isReceivedConfirmed: json['isReceivedConfirmed'] as bool? ?? false,
      receivedConfirmedAt: (json['receivedConfirmedAt'] as num?) == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              (json['receivedConfirmedAt'] as num).toInt(),
            ),
    );
  }
}
