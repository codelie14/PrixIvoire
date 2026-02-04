import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../services/cache_service.dart';
import '../models/product_price.dart';
import '../core/utils/page_transitions.dart';
import 'add_price_screen.dart';
import 'scan_screen.dart';
import 'price_comparison_screen.dart';
import 'trends_screen.dart';
import 'alerts_screen.dart';
import 'export_import_screen.dart';
import 'product_search_screen.dart';
import 'settings_screen.dart';

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
          Semantics(
            label: 'Ouvrir les paramètres',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  FadeSlidePageRoute(
                    page: const SettingsScreen(),
                  ),
                );
              },
              tooltip: 'Paramètres',
            ),
          ),
          Semantics(
            label: 'Actualiser la liste des prix',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRecentPrices,
              tooltip: 'Actualiser',
            ),
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
                          SlideUpPageRoute(
                            page: AddPriceScreen(
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
                    child: Semantics(
                      label: 'Scanner un ticket de caisse',
                      button: true,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            SlideUpPageRoute(
                              page: ScanScreen(
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
                        ..._recentPrices.map((price) => Semantics(
                          label: '${price.productName}, ${price.price.toStringAsFixed(0)} francs CFA, ${price.shop}, ${DateFormat('dd MMMM yyyy', 'fr_FR').format(price.date)}',
                          child: ListTile(
                            title: Text(price.productName),
                            subtitle: Text('${price.shop} - ${DateFormat('dd/MM/yyyy').format(price.date)}'),
                            trailing: Text(
                              '${price.price.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
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
              Semantics(
                label: 'Voir tous les prix enregistrés',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeSlidePageRoute(
                        page: PriceComparisonScreen(
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
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Voir les tendances des prix',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeSlidePageRoute(
                        page: TrendsScreen(
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
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Gérer mes alertes de prix',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeSlidePageRoute(
                        page: AlertsScreen(
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
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Rechercher des produits en ligne',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeSlidePageRoute(
                        page: ProductSearchScreen(
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
              ),
              const SizedBox(height: 8),
              Semantics(
                label: 'Exporter ou importer des données',
                button: true,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      FadeSlidePageRoute(
                        page: ExportImportScreen(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
