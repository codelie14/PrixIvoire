import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/cache_service.dart';
import '../models/product_price.dart';
import 'add_price_screen.dart';
import 'scan_screen.dart';
import 'price_comparison_screen.dart';
import 'trends_screen.dart';
import 'alerts_screen.dart';
import 'export_import_screen.dart';
import 'product_search_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storageService;
  final CacheService cacheService;

  const HomeScreen({
    super.key,
    required this.storageService,
    required this.cacheService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProductPrice> _recentPrices = [];

  @override
  void initState() {
    super.initState();
    _loadRecentPrices();
  }

  void _loadRecentPrices() {
    final allPrices = widget.storageService.getAllProductPrices();
    allPrices.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _recentPrices = allPrices.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PrixIvoire'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecentPrices,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadRecentPrices();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Boutons d'action principaux
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPriceScreen(
                              storageService: widget.storageService,
                            ),
                          ),
                        ).then((_) => _loadRecentPrices());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Saisir un prix'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScanScreen(
                              storageService: widget.storageService,
                            ),
                          ),
                        ).then((_) => _loadRecentPrices());
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scanner'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Graphique récapitulatif (si des prix existent)
              if (_recentPrices.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Prix récents',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._recentPrices.map((price) => ListTile(
                          title: Text(price.productName),
                          subtitle: Text('${price.shop} - ${DateFormat('dd/MM/yyyy').format(price.date)}'),
                          trailing: Text(
                            '${price.price.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Boutons de navigation
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PriceComparisonScreen(
                        storageService: widget.storageService,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Voir tous les prix'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrendsScreen(
                        storageService: widget.storageService,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.show_chart),
                label: const Text('Tendances des prix'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlertsScreen(
                        storageService: widget.storageService,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.notifications),
                label: const Text('Mes alertes'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductSearchScreen(
                        storageService: widget.storageService,
                        cacheService: widget.cacheService,
                      ),
                    ),
                  ).then((_) => _loadRecentPrices());
                },
                icon: const Icon(Icons.search),
                label: const Text('Rechercher en ligne'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExportImportScreen(
                        storageService: widget.storageService,
                      ),
                    ),
                  ).then((_) => _loadRecentPrices());
                },
                icon: const Icon(Icons.import_export),
                label: const Text('Export / Import'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
