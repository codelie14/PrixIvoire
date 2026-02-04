import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/price_alert.dart';
import '../core/utils/page_transitions.dart';
import 'add_alert_screen.dart';

class AlertsScreen extends StatefulWidget {
  final StorageService storageService;

  const AlertsScreen({super.key, required this.storageService});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<PriceAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    setState(() {
      _alerts = widget.storageService.getAllPriceAlerts();
    });
  }

  Future<void> _deleteAlert(PriceAlert alert) async {
    await widget.storageService.deletePriceAlert(alert);
    _loadAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes alertes'),
        actions: [
          Semantics(
            label: 'Créer une nouvelle alerte de prix',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  SlideUpPageRoute(
                    page: AddAlertScreen(
                      storageService: widget.storageService,
                    ),
                  ),
                );
                _loadAlerts();
              },
              tooltip: 'Ajouter une alerte',
            ),
          ),
        ],
      ),
      body: _alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune alerte configurée',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    label: 'Créer une alerte',
                    button: true,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          SlideUpPageRoute(
                            page: AddAlertScreen(
                              storageService: widget.storageService,
                            ),
                          ),
                        );
                        _loadAlerts();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Créer une alerte'),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Semantics(
                    label: 'Alerte pour ${alert.productName}, notification si prix ${alert.isAbove ? 'supérieur' : 'inférieur'} à ${alert.threshold.toStringAsFixed(0)} francs CFA',
                    child: ListTile(
                      title: Text(
                        alert.productName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Alerte si prix ${alert.isAbove ? '>' : '<'} ${alert.threshold.toStringAsFixed(0)} FCFA',
                      ),
                      trailing: Semantics(
                        label: 'Supprimer l\'alerte',
                        button: true,
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Supprimer l\'alerte'),
                                content: const Text(
                                  'Êtes-vous sûr de vouloir supprimer cette alerte ?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Annuler'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteAlert(alert);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Supprimer'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
