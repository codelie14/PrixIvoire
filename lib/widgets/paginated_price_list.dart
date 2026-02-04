import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_price.dart';
import '../services/optimized_storage_service.dart';

/// Widget de liste paginée avec lazy loading pour les prix
class PaginatedPriceList extends StatefulWidget {
  final OptimizedStorageService storageService;
  final int pageSize;
  final Widget Function(BuildContext, ProductPrice)? itemBuilder;
  final String? emptyMessage;

  const PaginatedPriceList({
    super.key,
    required this.storageService,
    this.pageSize = 50,
    this.itemBuilder,
    this.emptyMessage,
  });

  @override
  State<PaginatedPriceList> createState() => _PaginatedPriceListState();
}

class _PaginatedPriceListState extends State<PaginatedPriceList> {
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
      // Charger la page suivante quand on atteint 80% du scroll
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
      final newPrices = await widget.storageService.getPricesPaginated(
        _currentPage,
        pageSize: widget.pageSize,
      );

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
          child: Text(
            widget.emptyMessage ?? 'Aucun prix enregistré',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
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
            // Indicateur de chargement à la fin de la liste
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final price = _prices[index];

          if (widget.itemBuilder != null) {
            return widget.itemBuilder!(context, price);
          }

          // Widget par défaut
          return _buildDefaultPriceItem(context, price);
        },
      ),
    );
  }

  Widget _buildDefaultPriceItem(BuildContext context, ProductPrice price) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(
          price.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${price.shop} - ${DateFormat('dd/MM/yyyy').format(price.date)}',
        ),
        trailing: Text(
          '${price.price.toStringAsFixed(0)} FCFA',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
