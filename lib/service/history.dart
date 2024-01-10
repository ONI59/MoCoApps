
class History {
  String id;
  String userId;
  List<OrderDetails> orders;

  History({
    required this.id,
    required this.userId,
    required this.orders
  });
}

class OrderDetails {
  String name;
  int quantity;
  double total;

  OrderDetails({
    required this.name,
    required this.quantity,
    required this.total
  });
}