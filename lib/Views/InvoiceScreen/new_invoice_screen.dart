import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../Models/generate_invoice_model.dart';
import '../../Models/inventory_item.dart';
import '../../Models/invoice_item.dart';
import '../../Providers/inventory_provider.dart';
import '../../Providers/invoice_history_provider.dart';
import '../../Providers/invoice_provider.dart';
import '../../Providers/customer_provider.dart';
import '../../Widgets/selected_item_row.dart';

class NewInvoice extends ConsumerStatefulWidget {
  const NewInvoice({super.key});

  @override
  ConsumerState<NewInvoice> createState() => _NewInvoiceScreenState();
}

class _NewInvoiceScreenState extends ConsumerState<NewInvoice> {
  final customerNameController = TextEditingController();
  bool _initialized = false;
  String? _selectedCustomerId;

  @override
  void dispose() {
    customerNameController.dispose();
    super.dispose();
  }

  void _showEditCustomerDialog(String id, String currentName) {
    final editController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Customer Name'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: 'New Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = editController.text.trim();
              if (newName.isNotEmpty && newName != currentName) {
                // 1. Update Customer Name
                await ref.read(customerProvider.notifier).updateCustomerName(id, newName);
                
                // 2. Update all invoices associated with the old name
                await ref.read(invoiceHistoryProvider.notifier).updateInvoicesCustomerName(currentName, newName);

                setState(() {
                  customerNameController.text = newName;
                });
                
                if (mounted) Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer and all related invoices updated')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inventoryItems = ref.watch(inventoryProvider);
    final selectedItems = ref.watch(invoiceProvider);
    final customers = ref.watch(customerProvider);
    final theme = Theme.of(context);
    final subTotal = ref.watch(invoiceProvider.notifier).subTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Invoice')),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Selection Row with Edit Icon
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCustomerId,
                    decoration: const InputDecoration(
                      labelText: 'Select Customer',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: 'new',
                        child: Text('+ Create New Customer',
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                      ...customers.map((customer) => DropdownMenuItem(
                            value: customer.id,
                            child: Text(customer.name),
                          )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCustomerId = value;
                        if (value == 'new') {
                          customerNameController.clear();
                        } else {
                          final customer = customers.firstWhere((c) => c.id == value);
                          customerNameController.text = customer.name;
                        }
                      });
                    },
                  ),
                ),
                if (_selectedCustomerId != null && _selectedCustomerId != 'new')
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditCustomerDialog(
                      _selectedCustomerId!,
                      customerNameController.text,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Only show manual input if "New" is selected or no customer chosen
            if (_selectedCustomerId == 'new' || _selectedCustomerId == null)
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  hintText: 'Enter name for new customer',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),

            const SizedBox(height: 12),

            DropdownButtonFormField<InventoryItem>(
              value: null,
              items: inventoryItems.isNotEmpty
                  ? inventoryItems
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${item.name} '),
                                Text(item.qty.toString()),
                              ],
                            ),
                          ))
                      .toList()
                  : [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          'Inventory is empty. Please add items.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
              onChanged: inventoryItems.isNotEmpty
                  ? (value) {
                      if (value != null) {
                        ref.read(invoiceProvider.notifier).addOrUpdate(
                              InvoiceItem(
                                name: value.name,
                                price: value.price,
                                qty: value.qty,
                              ),
                              context,
                              ref,
                            );
                      }
                    }
                  : null,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Select Item',
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: selectedItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No items added yet.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedItems.length,
                      itemBuilder: (context, index) {
                        final item = selectedItems[index];
                        return SelectedItemRow(item: item);
                      },
                    ),
            ),

            const Divider(thickness: 1),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: theme.textTheme.titleMedium),
                Text(
                  'Rs ${subTotal.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => generateInvoice(subTotal),
                child: const Text('Generate Invoice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(invoiceProvider.notifier).clear();
      });
    }
  }

  void generateInvoice(double subTotal) {
    final customerName = customerNameController.text.trim();
    final selectedItems = ref.read(invoiceProvider);

    if (customerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer name cannot be empty')),
      );
      return;
    }

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    try {
      final invoice = GenerateInvoiceModel(
        customerName: customerName,
        dateTime: DateTime.now(),
        items: [...selectedItems],
        total: subTotal,
      );

      ref.read(invoiceHistoryProvider.notifier).addInvoice(invoice);
      ref.read(customerProvider.notifier).addOrUpdateCustomer(customerName);

      for (var soldItem in invoice.items) {
        ref.read(inventoryProvider.notifier).updateItemQuantityAfterSale(soldItem.name, soldItem.qty);
      }

      ref.read(invoiceProvider.notifier).clear();
      customerNameController.clear();
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    }
  }
}
