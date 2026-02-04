import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/scraped_product.dart';

class PriceComparisonVisualScreen extends StatelessWidget {
  final List<ScrapedProduct> products;

  const PriceComparisonVisualScreen({
    super.key,
    required this.products,
  });

  List<ScrapedProduct> get _productsWithPrice {
    return products.where((p) => p.price != null).toList()
      ..sort((a, b) => a.price!.compareTo(b.price!));
  }

  double? get _minPrice {
    if (_productsWithPrice.isEmpty) return null;
    return _productsWithPrice.first.price;
  }

  double? get _maxPrice {
    if (_productsWithPrice.isEmpty) return null;
    return _productsWithPrice.last.price;
  }

  double? get _averagePrice {
    if (_productsWithPrice.isEmpty) return null;
    final sum = _productsWithPrice.fold<double>(
      0,
      (sum, product) => sum + (product.price ?? 0),
    );
    return sum / _productsWithPrice.length;
  }

  @override
  Widget build(BuildContext context) {
    final productsWithPrice = _productsWithPrice;

    if (productsWithPrice.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Comparaison visuelle'),
        ),
        body: const Center(
          child: Text('Aucun produit avec prix disponible'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparaison visuelle des prix'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistiques
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard(
                          'Prix min',
                          _minPrice != null
                              ? '${NumberFormat('#,##0').format(_minPrice)} FCFA'
                              : 'N/A',
                          Colors.green,
                        ),
                        _buildStatCard(
                          'Prix max',
                          _maxPrice != null
                              ? '${NumberFormat('#,##0').format(_maxPrice)} FCFA'
                              : 'N/A',
                          Colors.red,
                        ),
                        _buildStatCard(
                          'Moyenne',
                          _averagePrice != null
                              ? '${NumberFormat('#,##0').format(_averagePrice)} FCFA'
                              : 'N/A',
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Graphique en barres
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comparaison par site',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      label: 'Graphique de comparaison des prix par site marchand',
                      child: SizedBox(
                        height: 300,
                        child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: _maxPrice != null ? _maxPrice! * 1.2 : 100000,
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => Colors.grey.shade800,
                              tooltipRoundedRadius: 8,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < productsWithPrice.length) {
                                    final product = productsWithPrice[value.toInt()];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        product.shop.length > 10
                                            ? '${product.shop.substring(0, 10)}...'
                                            : product.shop,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }
                                  return const Text('');
                                },
                                reservedSize: 40,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 60,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    NumberFormat('#,##0').format(value.toInt()),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade300,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: productsWithPrice.asMap().entries.map((entry) {
                            final index = entry.key;
                            final product = entry.value;
                            final isMin = product.price == _minPrice;
                            final isMax = product.price == _maxPrice;

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: product.price ?? 0,
                                  color: isMin
                                      ? Colors.green
                                      : isMax
                                          ? Colors.red
                                          : Theme.of(context).colorScheme.primary,
                                  width: 20,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Liste détaillée
            const Text(
              'Détails par site',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...productsWithPrice.map((product) {
              final isMin = product.price == _minPrice;
              final isMax = product.price == _maxPrice;

              return Semantics(
                label: '${product.shop}, ${NumberFormat('#,##0').format(product.price)} francs CFA${isMin ? ', meilleur prix' : isMax ? ', prix le plus élevé' : ''}',
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isMin
                      ? Colors.green.shade50
                      : isMax
                          ? Colors.red.shade50
                          : null,
                  child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isMin
                          ? Colors.green
                          : isMax
                              ? Colors.red
                              : Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        product.shop.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    product.shop,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (isMin || isMax) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isMin ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isMin ? 'MEILLEUR PRIX' : 'PRIX LE PLUS ÉLEVÉ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${NumberFormat('#,##0').format(product.price)} FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isMin
                              ? Colors.green.shade700
                              : isMax
                                  ? Colors.red.shade700
                                  : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (_averagePrice != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _getPriceDifference(product.price!, _averagePrice!),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.attach_money, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getPriceDifference(double price, double average) {
    final diff = price - average;
    final percent = ((diff / average) * 100).abs();
    if (diff > 0) {
      return '+${NumberFormat('#,##0').format(diff)} (+${percent.toStringAsFixed(1)}%)';
    } else {
      return '${NumberFormat('#,##0').format(diff)} (${percent.toStringAsFixed(1)}%)';
    }
  }
}
