/// Modèle représentant les statistiques calculées pour un ensemble de prix
class Statistics {
  final double mean; // Moyenne
  final double median; // Médiane
  final double standardDeviation; // Écart-type
  final double min; // Prix minimum
  final double max; // Prix maximum
  final String minStore; // Magasin avec le prix minimum
  final String maxStore; // Magasin avec le prix maximum
  final int sampleSize; // Nombre de prix dans l'échantillon
  final double potentialSavings; // Économie potentielle (max - min)

  const Statistics({
    required this.mean,
    required this.median,
    required this.standardDeviation,
    required this.min,
    required this.max,
    required this.minStore,
    required this.maxStore,
    required this.sampleSize,
    required this.potentialSavings,
  });

  /// Crée une instance de Statistics vide (pour les cas sans données)
  factory Statistics.empty() {
    return const Statistics(
      mean: 0.0,
      median: 0.0,
      standardDeviation: 0.0,
      min: 0.0,
      max: 0.0,
      minStore: '',
      maxStore: '',
      sampleSize: 0,
      potentialSavings: 0.0,
    );
  }

  /// Vérifie si les statistiques sont valides (au moins 1 échantillon)
  bool get isValid => sampleSize > 0;

  /// Vérifie si l'écart-type est disponible (nécessite au moins 2 échantillons)
  bool get hasStandardDeviation => sampleSize >= 2;

  /// Retourne le pourcentage d'économie potentielle par rapport au prix maximum
  double get savingsPercentage {
    if (max == 0) return 0.0;
    return (potentialSavings / max) * 100;
  }

  /// Crée une copie avec des modifications
  Statistics copyWith({
    double? mean,
    double? median,
    double? standardDeviation,
    double? min,
    double? max,
    String? minStore,
    String? maxStore,
    int? sampleSize,
    double? potentialSavings,
  }) {
    return Statistics(
      mean: mean ?? this.mean,
      median: median ?? this.median,
      standardDeviation: standardDeviation ?? this.standardDeviation,
      min: min ?? this.min,
      max: max ?? this.max,
      minStore: minStore ?? this.minStore,
      maxStore: maxStore ?? this.maxStore,
      sampleSize: sampleSize ?? this.sampleSize,
      potentialSavings: potentialSavings ?? this.potentialSavings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mean': mean,
      'median': median,
      'standardDeviation': standardDeviation,
      'min': min,
      'max': max,
      'minStore': minStore,
      'maxStore': maxStore,
      'sampleSize': sampleSize,
      'potentialSavings': potentialSavings,
    };
  }

  factory Statistics.fromMap(Map<String, dynamic> map) {
    return Statistics(
      mean: (map['mean'] ?? 0.0).toDouble(),
      median: (map['median'] ?? 0.0).toDouble(),
      standardDeviation: (map['standardDeviation'] ?? 0.0).toDouble(),
      min: (map['min'] ?? 0.0).toDouble(),
      max: (map['max'] ?? 0.0).toDouble(),
      minStore: map['minStore'] ?? '',
      maxStore: map['maxStore'] ?? '',
      sampleSize: map['sampleSize'] ?? 0,
      potentialSavings: (map['potentialSavings'] ?? 0.0).toDouble(),
    );
  }

  @override
  String toString() {
    return 'Statistics(mean: $mean, median: $median, stdDev: $standardDeviation, '
        'min: $min, max: $max, samples: $sampleSize)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Statistics &&
          runtimeType == other.runtimeType &&
          mean == other.mean &&
          median == other.median &&
          standardDeviation == other.standardDeviation &&
          min == other.min &&
          max == other.max &&
          minStore == other.minStore &&
          maxStore == other.maxStore &&
          sampleSize == other.sampleSize &&
          potentialSavings == other.potentialSavings;

  @override
  int get hashCode =>
      mean.hashCode ^
      median.hashCode ^
      standardDeviation.hashCode ^
      min.hashCode ^
      max.hashCode ^
      minStore.hashCode ^
      maxStore.hashCode ^
      sampleSize.hashCode ^
      potentialSavings.hashCode;
}
