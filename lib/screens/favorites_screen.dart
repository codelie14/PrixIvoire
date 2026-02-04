import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_price.dart';
import '../services/favorites_manager.dart';

/// Écran affichant la liste des produits favoris
/// 
/// Cet écran permet de visualiser tous les produits marqués comme favoris
/// avec leur dernier prix connu et de gérer les favoris (retirer des favoris)
class FavoritesScreen extends StatefulWidget {
  final FavoritesManager favoritesManager;
  
  const FavoritesScreen({
    super.key,
    required this.favoritesManager,
  });
  
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ProductPrice> _favoriteProducts = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  
  /// Charge la liste des produits favoris
  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Nettoyer les favoris orphelins avant de charger
      await widget.favoritesManager.cleanOrphanedFavorites();
      
      final favorites = widget.favoritesManager.getFavoriteProducts();
      
      setState(() {
        _favoriteProducts = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des favoris: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Retire un produit des favoris
  Future<void> _removeFavorite(String productName) async {
    try {
      final removed = await widget.favoritesManager.removeFavorite(productName);
      
      if (removed) {
        // Recharger la liste
        await _loadFavorites();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$productName retiré des favoris'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Annuler',
                textColor: Colors.white,
                onPressed: () async {
                  // Remettre dans les favoris
                  await widget.favoritesManager.addFavorite(productName);
                  await _loadFavorites();
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Affiche une boîte de dialogue de confirmation avant de retirer un favori
  Future<void> _confirmRemoveFavorite(String productName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer des favoris'),
        content: Text('Voulez-vous retirer "$productName" de vos favoris ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Retirer'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      await _removeFavorite(productName);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Favoris'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          Semantics(
            label: 'Actualiser la liste des favoris',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadFavorites,
              tooltip: 'Actualiser',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favoriteProducts.isEmpty
                ? _buildEmptyState()
                : _buildFavoritesList(),
      ),
    );
  }
  
  /// Construit l'état vide (aucun favori)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_border,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun favori',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ajoutez des produits à vos favoris pour les retrouver facilement ici.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Construit la liste des favoris
  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = _favoriteProducts[index];
        return _buildFavoriteCard(product);
      },
    );
  }
  
  /// Construit une carte pour un produit favori
  Widget _buildFavoriteCard(ProductPrice product) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Semantics(
        label: '${product.productName}, dernier prix ${product.price.toStringAsFixed(0)} francs CFA chez ${product.shop}, enregistré le ${dateFormatter.format(product.date)}',
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icône étoile (favori)
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 32,
                semanticLabel: 'Produit favori',
              ),
              const SizedBox(width: 16),
              
              // Informations du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dernier prix: ${product.price.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.shop} - ${dateFormatter.format(product.date)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Bouton pour retirer des favoris
              Semantics(
                label: 'Retirer ${product.productName} des favoris',
                button: true,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                  onPressed: () => _confirmRemoveFavorite(product.productName),
                  tooltip: 'Retirer des favoris',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
