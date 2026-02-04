import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'optimized_storage_service.dart';

/// Service de maintenance automatique pour le stockage
/// 
/// Gère la compaction et le nettoyage en arrière-plan
class StorageMaintenanceService {
  final OptimizedStorageService _storageService;
  Timer? _maintenanceTimer;
  bool _isRunning = false;

  // Configuration
  static const Duration maintenanceInterval = Duration(hours: 24);
  static const int maxSizeBytes = 50 * 1024 * 1024; // 50MB
  static const int maxEntriesPerType = 1000;

  StorageMaintenanceService(this._storageService);

  /// Démarre la maintenance automatique périodique
  void startAutomaticMaintenance() {
    if (_maintenanceTimer != null) {
      return; // Déjà démarré
    }

    // Exécuter immédiatement au démarrage
    _runMaintenance();

    // Puis exécuter périodiquement
    _maintenanceTimer = Timer.periodic(maintenanceInterval, (_) {
      _runMaintenance();
    });
  }

  /// Arrête la maintenance automatique
  void stopAutomaticMaintenance() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = null;
  }

  /// Exécute une maintenance manuelle
  Future<MaintenanceResult> runManualMaintenance() async {
    return await _runMaintenance();
  }

  /// Exécute les opérations de maintenance
  Future<MaintenanceResult> _runMaintenance() async {
    if (_isRunning) {
      return MaintenanceResult(
        success: false,
        message: 'Maintenance déjà en cours',
      );
    }

    _isRunning = true;

    try {
      bool compactionPerformed = false;
      int entriesDeleted = 0;

      // Vérifier si la compaction est nécessaire
      final needsComp = await needsCompaction();
      if (needsComp) {
        compactionPerformed = await _storageService.compactDatabase(
          maxSizeBytes: maxSizeBytes,
        );
      }

      // Vérifier si le nettoyage est nécessaire
      final needsClean = await needsCleaning();
      if (needsClean) {
        entriesDeleted = await _storageService.cleanOldEntries(
          maxEntries: maxEntriesPerType,
        );
      }

      _isRunning = false;

      return MaintenanceResult(
        success: true,
        message: 'Maintenance effectuée avec succès',
        compactionPerformed: compactionPerformed,
        entriesDeleted: entriesDeleted,
      );
    } catch (e) {
      _isRunning = false;
      return MaintenanceResult(
        success: false,
        message: 'Erreur lors de la maintenance: $e',
      );
    }
  }

  /// Vérifie si la compaction est nécessaire
  Future<bool> needsCompaction() async {
    try {
      // Récupérer le chemin de la box principale
      final boxPath = await _getBoxPath();
      if (boxPath == null) return false;

      final file = File(boxPath);
      if (!await file.exists()) return false;

      final fileSize = await file.length();
      return fileSize > maxSizeBytes;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de compaction: $e');
      return false;
    }
  }

  /// Vérifie si le nettoyage est nécessaire
  Future<bool> needsCleaning() async {
    try {
      final totalEntries = _storageService.totalPricesCount;
      return totalEntries > maxEntriesPerType;
    } catch (e) {
      debugPrint('Erreur lors de la vérification de nettoyage: $e');
      return false;
    }
  }

  /// Effectue la compaction de la base de données
  Future<void> performCompaction() async {
    try {
      await _storageService.compactDatabase(maxSizeBytes: maxSizeBytes);
    } catch (e) {
      debugPrint('Erreur lors de la compaction: $e');
      rethrow;
    }
  }

  /// Effectue le nettoyage des anciennes entrées
  Future<int> performCleaning() async {
    try {
      final beforeCount = _storageService.totalPricesCount;
      await _storageService.cleanOldEntries(maxEntries: maxEntriesPerType);
      final afterCount = _storageService.totalPricesCount;
      return beforeCount - afterCount;
    } catch (e) {
      debugPrint('Erreur lors du nettoyage: $e');
      rethrow;
    }
  }

  /// Récupère le chemin de la box principale
  Future<String?> _getBoxPath() async {
    try {
      // Le chemin sera récupéré via la méthode getDatabaseSize
      // qui est publique
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Obtient des statistiques sur le stockage
  Future<StorageStats> getStorageStats() async {
    try {
      final totalEntries = _storageService.totalPricesCount;
      final sizeBytes = await _storageService.getDatabaseSize();

      return StorageStats(
        totalEntries: totalEntries,
        sizeBytes: sizeBytes,
        needsCompaction: sizeBytes > maxSizeBytes,
        needsCleaning: totalEntries > maxEntriesPerType,
      );
    } catch (e) {
      return StorageStats(
        totalEntries: 0,
        sizeBytes: 0,
        needsCompaction: false,
        needsCleaning: false,
      );
    }
  }

  /// Libère les ressources
  void dispose() {
    stopAutomaticMaintenance();
  }
}

/// Résultat d'une opération de maintenance
class MaintenanceResult {
  final bool success;
  final String message;
  final bool compactionPerformed;
  final int entriesDeleted;

  MaintenanceResult({
    required this.success,
    required this.message,
    this.compactionPerformed = false,
    this.entriesDeleted = 0,
  });

  @override
  String toString() {
    return 'MaintenanceResult(success: $success, message: $message, '
        'compactionPerformed: $compactionPerformed, entriesDeleted: $entriesDeleted)';
  }
}

/// Statistiques du stockage
class StorageStats {
  final int totalEntries;
  final int sizeBytes;
  final bool needsCompaction;
  final bool needsCleaning;

  StorageStats({
    required this.totalEntries,
    required this.sizeBytes,
    required this.needsCompaction,
    required this.needsCleaning,
  });

  /// Taille formatée en MB
  double get sizeMB => sizeBytes / (1024 * 1024);

  @override
  String toString() {
    return 'StorageStats(totalEntries: $totalEntries, '
        'sizeMB: ${sizeMB.toStringAsFixed(2)}, '
        'needsCompaction: $needsCompaction, needsCleaning: $needsCleaning)';
  }
}
