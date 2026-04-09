import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../database/database_helper.dart';

class OrderProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Order> _orders = [];
  List<Order> _filteredOrders = [];
  String _currentFilter = 'All';
  String _searchQuery = '';

  List<Order> get orders => _searchQuery.isNotEmpty || _currentFilter != 'All' 
      ? _filteredOrders 
      : _orders;
  
  String get currentFilter => _currentFilter;
  bool get hasOrders => _orders.isNotEmpty;

  OrderProvider() {
    loadOrders();
  }

  Future<void> loadOrders() async {
    try {
      _orders = await _dbHelper.getOrders();
      _applyFilterAndSearch();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }
  }

  Future<bool> addOrder({
    required String customerName,
    required String phoneNumber,
    required String serviceType,
    required int numberOfItems,
    required double pricePerItem,
  }) async {
    try {
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';
      final totalPrice = numberOfItems * pricePerItem;
      
      final order = Order(
        orderId: orderId,
        customerName: customerName,
        phoneNumber: phoneNumber,
        serviceType: serviceType,
        numberOfItems: numberOfItems,
        pricePerItem: pricePerItem,
        totalPrice: totalPrice,
        status: 'Received',
      );
      
      await _dbHelper.insertOrder(order);
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error adding order: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(int id, String currentStatus) async {
    try {
      String nextStatus = _getNextStatus(currentStatus);
      await _dbHelper.updateOrderStatus(id, nextStatus);
      await loadOrders();
      return true;
    } catch (e) {
      debugPrint('Error updating status: $e');
      return false;
    }
  }

  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Received': return 'Washing';
      case 'Washing': return 'Ready';
      case 'Ready': return 'Delivered';
      default: return 'Delivered';
    }
  }

  void searchOrders(String query) {
    _searchQuery = query;
    _applyFilterAndSearch();
    notifyListeners();
  }

  void filterByStatus(String status) {
    _currentFilter = status;
    _applyFilterAndSearch();
    notifyListeners();
  }

  void _applyFilterAndSearch() {
    List<Order> result = List.from(_orders);
    
    if (_currentFilter != 'All') {
      result = result.where((order) => order.status == _currentFilter).toList();
    }
    
    if (_searchQuery.isNotEmpty) {
      result = result.where((order) => 
        order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        order.orderId.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    _filteredOrders = result;
  }

  void clearFilters() {
    _searchQuery = '';
    _currentFilter = 'All';
    _applyFilterAndSearch();
    notifyListeners();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    return await _dbHelper.getStatistics();
  }
}