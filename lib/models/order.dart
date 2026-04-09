class Order {
  final int? id;
  final String orderId;
  final String customerName;
  final String phoneNumber;
  final String serviceType;
  final int numberOfItems;
  final double pricePerItem;
  final double totalPrice;
  final String status;

  Order({
    this.id,
    required this.orderId,
    required this.customerName,
    required this.phoneNumber,
    required this.serviceType,
    required this.numberOfItems,
    required this.pricePerItem,
    required this.totalPrice,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'customer_name': customerName,
      'phone_number': phoneNumber,
      'service_type': serviceType,
      'number_of_items': numberOfItems,
      'price_per_item': pricePerItem,
      'total_price': totalPrice,
      'status': status,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      orderId: map['order_id'],
      customerName: map['customer_name'],
      phoneNumber: map['phone_number'],
      serviceType: map['service_type'],
      numberOfItems: map['number_of_items'],
      pricePerItem: map['price_per_item'],
      totalPrice: map['total_price'],
      status: map['status'],
    );
  }
}