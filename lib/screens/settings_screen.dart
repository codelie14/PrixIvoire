import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/theme_provider.dart';

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
