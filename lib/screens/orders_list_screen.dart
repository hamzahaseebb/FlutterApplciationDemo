import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../widgets/status_badge.dart';
import 'add_order_screen.dart';
import 'dashboard_screen.dart';

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry Orders'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
            tooltip: 'Dashboard',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<OrderProvider>(context, listen: false);
              provider.loadOrders();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing orders...')),
              );
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (!orderProvider.hasOrders && orderProvider.orders.isEmpty) {
            return _buildEmptyState();
          }
          
          if (orderProvider.orders.isEmpty) {
            return _buildNoResultsState(context);
          }
          
          return RefreshIndicator(
            onRefresh: () => orderProvider.loadOrders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orderProvider.orders.length,
              itemBuilder: (ctx, index) {
                final order = orderProvider.orders[index];
                return _buildOrderCard(ctx, order, orderProvider);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddOrderScreen()),
          );
          if (result == true && context.mounted) {
            final provider = Provider.of<OrderProvider>(context, listen: false);
            await provider.loadOrders();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order added successfully!')),
              );
            }
          }
        },
        tooltip: 'Add New Order',
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_laundry_service, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Orders Yet',
            style: TextStyle(fontSize: 20, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first order',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoResultsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No matching orders found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              final provider = Provider.of<OrderProvider>(context, listen: false);
              provider.clearFilters();
              provider.loadOrders();
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderCard(BuildContext context, order, OrderProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showOrderDetails(context, order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderId,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.phone, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(order.phoneNumber),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.local_laundry_service, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(order.serviceType),
                  const Spacer(),
                  Text(
                    '${order.totalPrice.toStringAsFixed(3)} KWD',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              if (order.status != 'Delivered') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await provider.updateOrderStatus(order.id!, order.status);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order status updated!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Mark as ${_getNextStatus(order.status)}'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  String _getNextStatus(String currentStatus) {
    switch (currentStatus) {
      case 'Received': return 'Washing';
      case 'Washing': return 'Ready';
      case 'Ready': return 'Delivered';
      default: return 'Delivered';
    }
  }
  
  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Search Orders'),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Customer Name or Order ID',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Provider.of<OrderProvider>(context, listen: false).searchOrders(value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              final provider = Provider.of<OrderProvider>(context, listen: false);
              provider.clearFilters();
              provider.loadOrders();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<OrderProvider>(context, listen: false)
                  .searchOrders(searchController.text);
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    final provider = Provider.of<OrderProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by Status',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildFilterOption(context, provider, 'All'),
              _buildFilterOption(context, provider, 'Received'),
              _buildFilterOption(context, provider, 'Washing'),
              _buildFilterOption(context, provider, 'Ready'),
              _buildFilterOption(context, provider, 'Delivered'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.clearFilters();
                    provider.loadOrders();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Clear All Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFilterOption(BuildContext context, OrderProvider provider, String status) {
    final isSelected = provider.currentFilter == status;
    
    return GestureDetector(
      onTap: () {
        provider.filterByStatus(status);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (isSelected)
              const Icon(Icons.check, color: Colors.white, size: 20),
            if (isSelected) const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showOrderDetails(BuildContext context, order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Order Details - ${order.orderId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Customer:', order.customerName),
            _buildDetailRow('Phone:', order.phoneNumber),
            _buildDetailRow('Service:', order.serviceType),
            _buildDetailRow('Items:', order.numberOfItems.toString()),
            _buildDetailRow('Price per item:', '${order.pricePerItem.toStringAsFixed(3)} KWD'),
            _buildDetailRow('Total:', '${order.totalPrice.toStringAsFixed(3)} KWD'),
            _buildDetailRow('Status:', order.status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}