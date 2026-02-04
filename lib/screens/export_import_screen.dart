import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../services/storage_service.dart';
import '../services/csv_service.dart';

class ExportImportScreen extends StatefulWidget {
  final StorageService storageService;

  const ExportImportScreen({super.key, required this.storageService});

  @override
  State<ExportImportScreen> createState() => _ExportImportScreenState();
}

class _ExportImportScreenState extends State<ExportImportScreen> {
  final CSVService _csvService = CSVService();
  bool _isExporting = false;
  String? _exportedFilePath;

  Future<void> _exportPrices() async {
    setState(() {
      _isExporting = true;
      _exportedFilePath = null;
    });

    try {
      final prices = widget.storageService.getAllProductPrices();
      if (prices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun prix à exporter')),
          );
        }
        return;
      }

      final file = await _csvService.exportProductPricesToCSV(prices);
      
      if (mounted) {
        setState(() {
          _exportedFilePath = file.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export réussi ! Fichier: ${file.path}'),
            action: SnackBarAction(
              label: 'Ouvrir',
              onPressed: () async {
                await OpenFile.open(file.path);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export: $e')),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _exportAlerts() async {
    setState(() {
      _isExporting = true;
      _exportedFilePath = null;
    });

    try {
      final alerts = widget.storageService.getAllPriceAlerts();
      if (alerts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucune alerte à exporter')),
          );
        }
        return;
      }

      final file = await _csvService.exportPriceAlertsToCSV(alerts);
      
      if (mounted) {
        setState(() {
          _exportedFilePath = file.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export réussi ! Fichier: ${file.path}'),
            action: SnackBarAction(
              label: 'Ouvrir',
              onPressed: () async {
                await OpenFile.open(file.path);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'export: $e')),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Export / Import'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Export',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Exporter tous les prix en format CSV',
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportPrices,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_download),
                      label: const Text('Exporter les prix'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: 'Exporter toutes les alertes en format CSV',
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportAlerts,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.file_download),
                      label: const Text('Exporter les alertes'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 0),
                      ),
                    ),
                  ),
                  if (_exportedFilePath != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Fichier exporté:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _exportedFilePath!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Import',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pour importer des données, placez un fichier CSV dans le répertoire de l\'application et contactez le support.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
