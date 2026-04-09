import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/order.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('laundry.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL UNIQUE,
        customer_name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        service_type TEXT NOT NULL,
        number_of_items INTEGER NOT NULL,
        price_per_item REAL NOT NULL,
        total_price REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertOrder(Order order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final result = await db.query('orders', orderBy: 'id DESC');
    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<int> updateOrderStatus(int id, String newStatus) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Order>> searchOrders(String query) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'customer_name LIKE ? OR order_id LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'id DESC',
    );
    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<List<Order>> filterByStatus(String status) async {
    final db = await database;
    final result = await db.query(
      'orders',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'id DESC',
    );
    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    final totalOrdersResult = await db.rawQuery('SELECT COUNT(*) as count FROM orders');
    final totalOrders = totalOrdersResult.first['count'] as int;
    
    final revenueResult = await db.rawQuery(
      'SELECT SUM(total_price) as total FROM orders WHERE status = "Delivered"'
    );
    final totalRevenue = revenueResult.first['total'] as double? ?? 0.0;
    
    final pendingOrdersResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM orders WHERE status != "Delivered"'
    );
    final pendingOrders = pendingOrdersResult.first['count'] as int;
    
    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'pendingOrders': pendingOrders,
    };
  }

  Future<int> deleteOrder(int id) async {
    final db = await database;
    return await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }
}