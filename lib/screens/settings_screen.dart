import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';
import '../services/cached_storage_service.dart';
import '../services/optimized_storage_service.dart';
import '../services/enhanced_cache_service.dart';

/// Écran des paramètres de l'application
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          const _ThemeSection(),
          const Divider(),
          const _CacheSection(),
          const Divider(),
          // D'autres sections de paramètres seront ajoutées ici
        ],
      ),
    );
  }
}

/// Section pour la sélection du thème
class _ThemeSection extends StatelessWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Apparence',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.brightness_auto,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Thème'),
          subtitle: Text(_getThemeModeName(themeProvider.themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context, themeProvider),
        ),
      ],
    );
  }

  /// Affiche un dialog pour sélectionner le thème
  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              title: 'Clair',
              icon: Icons.light_mode,
              mode: ThemeMode.light,
              currentMode: themeProvider.themeMode,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              title: 'Sombre',
              icon: Icons.dark_mode,
              mode: ThemeMode.dark,
              currentMode: themeProvider.themeMode,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              title: 'Système',
              icon: Icons.brightness_auto,
              mode: ThemeMode.system,
              currentMode: themeProvider.themeMode,
              onTap: () {
                themeProvider.setThemeMode(ThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  /// Retourne le nom du mode de thème
  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Clair';
      case ThemeMode.dark:
        return 'Sombre';
      case ThemeMode.system:
        return 'Système';
    }
  }
}

/// Widget pour une option de thème dans le dialog
class _ThemeOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeMode mode;
  final ThemeMode currentMode;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.icon,
    required this.mode,
    required this.currentMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = mode == currentMode;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected 
          ? Theme.of(context).colorScheme.primary 
          : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected 
            ? Theme.of(context).colorScheme.primary 
            : null,
        ),
      ),
      trailing: isSelected
        ? Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.primary,
          )
        : null,
      onTap: onTap,
    );
  }
}


/// Section pour la gestion du cache
class _CacheSection extends StatefulWidget {
  const _CacheSection();

  @override
  State<_CacheSection> createState() => _CacheSectionState();
}

class _CacheSectionState extends State<_CacheSection> {
  Map<String, dynamic>? _cacheStats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCacheStats();
  }

  Future<void> _loadCacheStats() async {
    try {
      // Create a temporary cache service to get stats
      final storageService = OptimizedStorageService();
      await storageService.initialize();
      final cacheService = EnhancedCacheService();
      final cachedStorage = CachedStorageService(
        storageService: storageService,
        cacheService: cacheService,
      );

      setState(() {
        _cacheStats = cachedStorage.getCacheStats();
      });
    } catch (e) {
      // Silently fail if cache stats can't be loaded
      setState(() {
        _cacheStats = null;
      });
    }
  }

  Future<void> _clearCache() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create a temporary cache service to clear cache
      final storageService = OptimizedStorageService();
      await storageService.initialize();
      final cacheService = EnhancedCacheService();
      final cachedStorage = CachedStorageService(
        storageService: storageService,
        cacheService: cacheService,
      );

      cachedStorage.clearCache();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache vidé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Reload stats
        await _loadCacheStats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du vidage du cache: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vider le cache'),
        content: const Text(
          'Êtes-vous sûr de vouloir vider le cache ? '
          'Cela supprimera les données temporaires et pourrait ralentir '
          'temporairement l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCache();
            },
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Cache',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_cacheStats != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taille: ${_formatBytes(_cacheStats!['currentSizeBytes'] as int)} / ${_formatBytes(_cacheStats!['maxSizeBytes'] as int)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Utilisation: ${_cacheStats!['usagePercentage']}%',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Entrées: ${_cacheStats!['entryCount']}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        ListTile(
          leading: Icon(
            Icons.delete_sweep,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Vider le cache'),
          subtitle: const Text('Supprime les données temporaires'),
          trailing: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right),
          onTap: _isLoading ? null : _showClearCacheDialog,
        ),
      ],
    );
  }
}
