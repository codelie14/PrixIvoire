import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/product_price.dart';

class TrendsScreen extends StatefulWidget {
  final StorageService storageService;

  const TrendsScreen({super.key, required this.storageService});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  String? _selectedProduct;

  @override
  void initState() {
    super.initState();
    final products = widget.storageService.getAllProductNames();
    if (products.isNotEmpty) {
      _selectedProduct = products.first;
    }
  }

  List<ProductPrice> _getProductPrices(String productName) {
    final prices = widget.storageService.getProductPricesByProduct(productName);
    prices.sort((a, b) => a.date.compareTo(b.date));
    
    // Limiter aux 30 derniers jours
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return prices.where((p) => p.date.isAfter(thirtyDaysAgo)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.storageService.getAllProductNames();

    if (products.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tendances des prix'),
        ),
        body: const Center(
          child: Text('Aucun produit enregistré'),
        ),
      );
    }

    if (_selectedProduct == null) {
      _selectedProduct = products.first;
    }

    final prices = _getProductPrices(_selectedProduct!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tendances des prix'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: _selectedProduct,
              decoration: const InputDecoration(
                labelText: 'Sélectionner un produit',
                border: OutlineInputBorder(),
              ),
              items: products.map((product) {
                return DropdownMenuItem(
                  value: product,
                  child: Text(product),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                });
              },
            ),
          ),
          Expanded(
            child: prices.isEmpty
                ? const Center(
                    child: Text('Aucune donnée pour ce produit'),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < prices.length) {
                                  final date = prices[value.toInt()].date;
                                  return Text(
                                    DateFormat('dd/MM').format(date),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: prices.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                entry.value.price,
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(show: false),
                          ),
                        ],
                        minY: prices.isEmpty
                            ? 0
                            : prices.map((p) => p.price).reduce((a, b) => a < b ? a : b) * 0.9,
                        maxY: prices.isEmpty
                            ? 1000
                            : prices.map((p) => p.price).reduce((a, b) => a > b ? a : b) * 1.1,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
