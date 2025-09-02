class OrderManager {
  static int _orderCounter = 0;

  static int newOrder() {
    _orderCounter++;
    return _orderCounter;
  }

  static int get currentOrder => _orderCounter;
}
