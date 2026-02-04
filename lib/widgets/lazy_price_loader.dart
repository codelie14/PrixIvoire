import 'package:flutter/material.dart';
import '../models/product_price.dart';
import '../services/optimized_storage_service.dart';

/// Mixin pour ajouter le lazy loading à n'importe quel widget
mixin LazyPriceLoader<T extends StatefulWidget> on State<T> {
  final List<ProductPrice> loadedPrices = [];
  int currentPage = 0;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  final int pageSize = 50;

  OptimizedStorageService get storageService;

  /// Charge la page initiale
  Future<void> loadInitialPrices() async {
    loadedPrices.clear();
    currentPage = 0;
    hasMoreData = true;
    await loadMorePrices();
  }

  /// Charge la page suivante
  Future<void> loadMorePrices() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final newPrices = await storageService.getPricesPaginated(
        currentPage,
        pageSize: pageSize,
      );

      setState(() {
        if (newPrices.isEmpty) {
          hasMoreData = false;
        } else {
          loadedPrices.addAll(newPrices);
          currentPage++;
        }
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      rethrow;
    }
  }

  /// Crée un ScrollController avec détection de fin de scroll
  ScrollController createLazyScrollController() {
    final controller = ScrollController();
    controller.addListener(() {
      if (controller.position.pixels >=
          controller.position.maxScrollExtent * 0.8) {
        loadMorePrices();
      }
    });
    return controller;
  }

  /// Widget d'indicateur de chargement pour la fin de liste
  Widget buildLoadingIndicator() {
    if (!hasMoreData) {
      return const SizedBox.shrink();
    }

    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Widget réutilisable pour afficher une liste paginée avec un builder personnalisé
class LazyLoadedList extends StatefulWidget {
  final OptimizedStorageService storageService;
  final Widget Function(BuildContext, ProductPrice, int) itemBuilder;
  final int pageSize;
  final Future<List<ProductPrice>> Function(int page, int pageSize)? customLoader;
  final String? emptyMessage;

  const LazyLoadedList({
    super.key,
    required this.storageService,
    required this.itemBuilder,
    this.pageSize = 50,
    this.customLoader,
    this.emptyMessage,
  });

  @override
  State<LazyLoadedList> createState() => _LazyLoadedListState();
}

class _LazyLoadedListState extends State<LazyLoadedList> {
  final List<ProductPrice> _prices = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadNextPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoading && _hasMore) {
        _loadNextPage();
      }
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final List<ProductPrice> newPrices;
      
      if (widget.customLoader != null) {
        newPrices = await widget.customLoader!(_currentPage, widget.pageSize);
      } else {
        newPrices = await widget.storageService.getPricesPaginated(
          _currentPage,
          pageSize: widget.pageSize,
        );
      }

      setState(() {
        if (newPrices.isEmpty) {
          _hasMore = false;
        } else {
          _prices.addAll(newPrices);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _prices.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    if (_prices.isEmpty && !_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                widget.emptyMessage ?? 'Aucune donnée disponible',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _prices.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _prices.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          return widget.itemBuilder(context, _prices[index], index);
        },
      ),
    );
  }
}
