# Plan d'Implémentation : PrixIvoire - Implémentation Complète

## Vue d'Ensemble

Ce plan d'implémentation décompose les améliorations de PrixIvoire en tâches incrémentales et testables. L'approche suit une architecture en couches, en commençant par les fondations (modèles, services de base) puis en construisant progressivement les fonctionnalités avancées et l'interface utilisateur.

## Tâches

### Phase 1 : Fondations et Infrastructure

- [x] 1. Mettre à jour les modèles de données et la structure du projet
  - [x] 1.1 Étendre le modèle ProductPrice avec les nouveaux champs
    - Ajouter les champs `categoryId`, `isFavorite`, `notes`, `imageUrl`
    - Mettre à jour l'adaptateur Hive avec les nouveaux HiveField
    - Créer des méthodes de migration pour les données existantes
    - _Exigences: 4.1, 8.1_
  
  - [x] 1.2 Créer le modèle Category
    - Définir la classe Category avec id, name, icon, color
    - Créer la liste des catégories prédéfinies (Alimentaire, Électronique, etc.)
    - Implémenter les méthodes de recherche et filtrage
    - _Exigences: 4.1_
  
  - [x] 1.3 Créer le modèle AppSettings
    - Définir la classe AppSettings avec HiveType
    - Ajouter les champs: themeMode, onboardingCompleted, viewedTooltips, etc.
    - Créer l'adaptateur Hive pour AppSettings
    - _Exigences: 2.1, 16.1_
  
  - [x] 1.4 Créer le modèle Statistics
    - Définir la classe Statistics avec tous les champs statistiques
    - Implémenter les constructeurs et méthodes utilitaires
    - _Exigences: 6.1, 6.2, 6.3_


  - [ ]* 1.5 Écrire les tests de propriété pour les modèles de données
    - **Propriété 20: Persistance des Favoris (Round-Trip)**
    - **Propriété 48: Marquage de Complétion de l'Onboarding**
    - **Valide: Exigences 8.2, 16.3**

- [x] 2. Implémenter le système de gestion d'erreurs
  - [x] 2.1 Créer la hiérarchie d'exceptions personnalisées
    - Définir AppException comme classe de base
    - Créer StorageException, OCRException, ValidationException, NetworkException, ExportException
    - Ajouter les champs message, code, originalError
    - _Exigences: 11.1, 11.2_
  
  - [x] 2.2 Implémenter ErrorHandler
    - Créer la méthode getUserFriendlyMessage() pour traduire les erreurs
    - Implémenter logError() pour le logging avec contexte
    - Ajouter les messages d'erreur en français pour chaque type
    - _Exigences: 11.1, 11.2, 11.3, 11.4_
  
  - [x] 2.3 Créer SafeExecutor pour l'encapsulation des opérations
    - Implémenter la méthode execute() avec try-catch
    - Ajouter la gestion du loading indicator
    - Intégrer l'affichage des SnackBar de succès/erreur
    - _Exigences: 11.6_
  
  - [ ]* 2.4 Écrire les tests de propriété pour la gestion d'erreurs
    - **Propriété 30: Messages d'Erreur en Français**
    - **Propriété 31: Logging des Erreurs**
    - **Valide: Exigences 11.1, 11.2**


- [x] 3. Implémenter le système de validation
  - [x] 3.1 Créer ValidationService
    - Implémenter validatePrice() avec règles (positif, numérique, max 10M)
    - Implémenter validateProductName() (min 2 caractères, max 100)
    - Implémenter validateStoreName() (non vide, max 50)
    - Retourner ValidationResult avec isValid et errorMessage
    - _Exigences: 19.1, 19.2, 19.3_
  
  - [ ]* 3.2 Écrire les tests de propriété pour la validation
    - **Propriété 51: Validation des Prix**
    - **Propriété 52: Validation des Noms de Produits**
    - **Propriété 53: Validation des Noms de Magasins**
    - **Propriété 54: Blocage de Soumission avec Erreurs**
    - **Valide: Exigences 19.1, 19.2, 19.3, 19.6**
  
  - [ ]* 3.3 Écrire les tests unitaires pour les cas limites de validation
    - Tester le cas limite: prix > 10 000 000 FCFA (avertissement)
    - Tester les caractères spéciaux dans les noms
    - Tester les valeurs nulles et vides
    - _Exigences: 19.7_

- [ ] 4. Checkpoint - Vérifier les fondations
  - Assurer que tous les tests passent
  - Vérifier que les modèles sont correctement persistés dans Hive
  - Demander à l'utilisateur si des questions se posent


### Phase 2 : Système de Thèmes et Accessibilité

- [x] 5. Implémenter le système de thèmes
  - [x] 5.1 Créer ThemeManager
    - Implémenter loadTheme() pour charger depuis Hive
    - Implémenter setTheme() pour sauvegarder le choix
    - Créer getLightTheme() avec Material Design 3
    - Créer getDarkTheme() avec Material Design 3
    - _Exigences: 2.1, 2.2, 2.3_
  
  - [x] 5.2 Définir les ColorScheme personnalisés
    - Créer un ColorScheme clair avec contrastes WCAG AA
    - Créer un ColorScheme sombre avec contrastes WCAG AA
    - Définir les couleurs pour tous les composants Material
    - _Exigences: 1.1, 1.5_
  
  - [x] 5.3 Intégrer ThemeManager dans l'application
    - Utiliser Provider ou Riverpod pour la gestion d'état du thème
    - Appliquer le thème au MaterialApp
    - Implémenter le changement de thème en temps réel
    - _Exigences: 1.3, 2.5_
  
  - [ ]* 5.4 Écrire les tests de propriété pour le système de thèmes
    - **Propriété 1: Persistance du Thème (Round-Trip)**
    - **Propriété 3: Application Complète du Thème**
    - **Propriété 4: Conformité WCAG pour les Contrastes**
    - **Propriété 6: Performance du Changement de Thème**
    - **Valide: Exigences 2.2, 2.3, 1.3, 1.5, 2.5**
  
  - [ ]* 5.5 Écrire les tests unitaires pour le thème
    - Tester le cas: thème système par défaut au premier lancement
    - Tester le calcul des ratios de contraste
    - _Exigences: 2.4_


- [ ] 6. Améliorer l'accessibilité de l'interface
  - [ ] 6.1 Ajouter les labels sémantiques aux widgets interactifs
    - Parcourir tous les écrans existants
    - Ajouter semanticsLabel à tous les boutons, champs, liens
    - Tester avec TalkBack (Android) et VoiceOver (iOS)
    - _Exigences: 1.6_
  
  - [ ] 6.2 Implémenter les animations de transition
    - Créer des PageRoute personnalisés avec animations
    - Limiter la durée des transitions à 300ms maximum
    - Appliquer aux navigations entre écrans
    - _Exigences: 1.2_
  
  - [ ]* 6.3 Écrire les tests de propriété pour l'accessibilité
    - **Propriété 5: Labels Sémantiques pour l'Accessibilité**
    - **Propriété 2: Performance des Transitions**
    - **Valide: Exigences 1.6, 1.2**

- [ ] 7. Checkpoint - Vérifier le système de thèmes
  - Tester le changement de thème sur tous les écrans
  - Vérifier les contrastes avec un outil WCAG
  - Tester avec un lecteur d'écran
  - Demander à l'utilisateur si des questions se posent


### Phase 3 : Optimisation du Stockage et Performance

- [ ] 8. Optimiser le service de stockage Hive
  - [ ] 8.1 Créer OptimizedStorageService
    - Implémenter initialize() avec ouverture des boxes
    - Créer des index sur productName, storeName, date
    - Implémenter getPricesPaginated() avec skip/take
    - Implémenter searchProducts() optimisé
    - _Exigences: 10.1, 10.2, 10.3_
  
  - [ ] 8.2 Implémenter le lazy loading et la pagination
    - Créer une méthode pour charger par lots de 50 éléments
    - Implémenter le chargement à la demande dans les listes
    - Optimiser l'écran d'accueil pour charger uniquement les données nécessaires
    - _Exigences: 10.3, 10.4_
  
  - [ ] 8.3 Implémenter la compaction et le nettoyage
    - Créer compactDatabase() pour compacter quand taille > 50MB
    - Implémenter cleanOldEntries() pour limiter à 1000 entrées par type
    - Exécuter en arrière-plan avec compute()
    - _Exigences: 10.5, 10.6_
  
  - [ ]* 8.4 Écrire les tests de propriété pour le stockage
    - **Propriété 26: Performance de Recherche**
    - **Propriété 27: Pagination des Listes**
    - **Propriété 28: Lazy Loading au Démarrage**
    - **Propriété 29: Limite de l'Historique**
    - **Valide: Exigences 10.2, 10.3, 10.4, 10.6**
  
  - [ ]* 8.5 Écrire les tests unitaires pour le stockage
    - Tester le cas: compaction quand taille > 50MB
    - Tester la migration des données existantes
    - _Exigences: 10.5_


- [ ] 9. Implémenter le système de cache
  - [ ] 9.1 Créer CacheManager avec politique LRU
    - Définir la structure CacheEntry avec métadonnées
    - Implémenter get(), set(), invalidate(), clear()
    - Implémenter evictLRU() pour supprimer les entrées anciennes
    - Limiter la taille à 10MB
    - _Exigences: 12.1, 12.4_
  
  - [ ] 9.2 Implémenter le TTL et l'invalidation
    - Ajouter la gestion du Time To Live (5 minutes pour recherches)
    - Implémenter invalidatePattern() pour invalidation par motif
    - Invalider automatiquement lors des modifications de données
    - _Exigences: 12.2, 12.5_
  
  - [ ] 9.3 Intégrer le cache dans les services
    - Mettre en cache les 50 produits les plus consultés
    - Mettre en cache les résultats de recherche
    - Ajouter une option de vidage manuel dans les paramètres
    - _Exigences: 12.1, 12.6_
  
  - [ ]* 9.4 Écrire les tests de propriété pour le cache
    - **Propriété 32: Cache des Produits Populaires**
    - **Propriété 33: TTL du Cache de Recherche**
    - **Propriété 34: Performance du Cache**
    - **Propriété 35: Éviction LRU du Cache**
    - **Propriété 36: Invalidation du Cache lors de Modifications**
    - **Propriété 37: Vidage Manuel du Cache**
    - **Valide: Exigences 12.1, 12.2, 12.3, 12.4, 12.5, 12.6**

- [ ] 10. Checkpoint - Vérifier les optimisations
  - Mesurer les performances de recherche (< 200ms)
  - Vérifier le lazy loading au démarrage
  - Tester le cache avec de grandes quantités de données
  - Demander à l'utilisateur si des questions se posent


### Phase 4 : Fonctionnalités Avancées

- [ ] 11. Implémenter le système d'autocomplétion
  - [ ] 11.1 Créer AutocompleteService
    - Implémenter getSuggestions() avec filtrage par requête
    - Implémenter recordUsage() pour enregistrer la fréquence
    - Implémenter getFrequencyMap() pour le tri
    - Limiter à 10 suggestions maximum
    - _Exigences: 3.1, 3.3, 3.5_
  
  - [ ] 11.2 Créer les widgets d'autocomplétion
    - Créer AutocompleteTextField pour produits
    - Créer AutocompleteTextField pour magasins
    - Gérer la sélection et le remplissage automatique
    - Permettre la saisie libre si aucune suggestion
    - _Exigences: 3.2, 3.4_
  
  - [ ]* 11.3 Écrire les tests de propriété pour l'autocomplétion
    - **Propriété 7: Suggestions d'Autocomplétion**
    - **Propriété 8: Remplissage Automatique par Suggestion**
    - **Propriété 9: Tri des Suggestions par Fréquence**
    - **Propriété 10: Limite des Suggestions**
    - **Valide: Exigences 3.1, 3.2, 3.3, 3.5**
  
  - [ ]* 11.4 Écrire les tests unitaires pour l'autocomplétion
    - Tester le cas: aucune suggestion ne correspond
    - Tester avec historique vide
    - _Exigences: 3.4_


- [ ] 12. Implémenter le système de catégories
  - [ ] 12.1 Créer CategoryManager
    - Définir les catégories prédéfinies avec icônes et couleurs
    - Implémenter getCategoryById()
    - Implémenter filterByCategory()
    - Implémenter getCategoryCounts()
    - _Exigences: 4.1, 4.3, 4.5_
  
  - [ ] 12.2 Intégrer les catégories dans l'interface
    - Ajouter un sélecteur de catégorie dans AddPriceScreen
    - Créer un écran de filtrage par catégorie
    - Afficher les comptages par catégorie
    - Gérer la catégorie "Autres" par défaut
    - _Exigences: 4.2, 4.4_
  
  - [ ]* 12.3 Écrire les tests de propriété pour les catégories
    - **Propriété 11: Filtrage par Catégorie**
    - **Propriété 12: Comptage par Catégorie**
    - **Valide: Exigences 4.3, 4.5**
  
  - [ ]* 12.4 Écrire les tests unitaires pour les catégories
    - Tester le cas: produit sans catégorie → "Autres"
    - Tester l'affichage des icônes de catégories
    - _Exigences: 4.4_


- [ ] 13. Implémenter le système de favoris
  - [ ] 13.1 Créer FavoritesManager
    - Implémenter addFavorite() et removeFavorite()
    - Implémenter isFavorite() pour vérifier le statut
    - Implémenter getFavoriteProducts()
    - Persister dans Hive avec loadFavorites() et saveFavorites()
    - _Exigences: 8.2, 8.4, 8.5_
  
  - [ ] 13.2 Créer l'écran des favoris
    - Créer FavoritesScreen avec liste des produits favoris
    - Afficher le dernier prix connu pour chaque favori
    - Ajouter un bouton pour retirer des favoris
    - Intégrer dans la navigation principale
    - _Exigences: 8.3, 8.5_
  
  - [ ] 13.3 Ajouter l'icône favori dans les écrans de produits
    - Ajouter une icône étoile dans les listes de produits
    - Ajouter une icône étoile dans les détails de produit
    - Gérer le toggle favori/non-favori
    - _Exigences: 8.1_
  
  - [ ]* 13.4 Écrire les tests de propriété pour les favoris
    - **Propriété 20: Persistance des Favoris (Round-Trip)**
    - **Propriété 21: Suppression des Favoris**
    - **Propriété 22: Récupération du Dernier Prix pour les Favoris**
    - **Valide: Exigences 8.2, 8.4, 8.5**

- [ ] 14. Checkpoint - Vérifier les fonctionnalités avancées
  - Tester l'autocomplétion avec différentes requêtes
  - Vérifier le filtrage par catégorie
  - Tester l'ajout/suppression de favoris
  - Demander à l'utilisateur si des questions se posent


### Phase 5 : Statistiques et Visualisations

- [ ] 15. Implémenter le moteur de statistiques
  - [ ] 15.1 Créer StatisticsEngine
    - Implémenter calculateMean() pour la moyenne
    - Implémenter calculateMedian() pour la médiane
    - Implémenter calculateStandardDeviation() pour l'écart-type
    - Implémenter findPriceRange() pour min/max
    - Implémenter calculatePotentialSavings()
    - _Exigences: 6.1, 6.2, 6.3, 6.4, 6.6_
  
  - [ ] 15.2 Implémenter compareStores()
    - Calculer les moyennes par magasin
    - Identifier le magasin le moins cher et le plus cher
    - Retourner un objet StoreComparison
    - _Exigences: 6.4_
  
  - [ ]* 15.3 Écrire les tests de propriété pour les statistiques
    - **Propriété 13: Correction des Calculs Statistiques**
    - **Valide: Exigences 6.1, 6.2, 6.3, 6.4, 6.6**


- [ ] 16. Améliorer les graphiques et visualisations
  - [ ] 16.1 Intégrer la bibliothèque de graphiques
    - Ajouter fl_chart ou syncfusion_flutter_charts au projet
    - Créer des widgets réutilisables pour les graphiques
    - Configurer les thèmes des graphiques
    - _Exigences: 5.1_
  
  - [ ] 16.2 Créer le graphique linéaire des tendances
    - Implémenter LineChartWidget avec prix sur Y et dates sur X
    - Ajouter les infobulles interactives au toucher
    - Implémenter le zoom et défilement pour > 10 points
    - Ajouter une légende claire
    - _Exigences: 5.1, 5.2, 5.3, 5.5_
  
  - [ ] 16.3 Créer le graphique en barres de comparaison
    - Implémenter BarChartWidget pour comparer les magasins
    - Utiliser des couleurs distinctes par magasin
    - Ajouter une légende
    - _Exigences: 5.4, 5.5_
  
  - [ ] 16.4 Gérer les cas de données insuffisantes
    - Afficher un message explicatif si < 2 points de données
    - Créer un widget EmptyChartPlaceholder
    - _Exigences: 5.6_
  
  - [ ]* 16.5 Écrire les tests unitaires pour les graphiques
    - Tester le cas limite: moins de 2 points de données
    - Tester la génération des données de graphique
    - _Exigences: 5.6_


- [ ] 17. Implémenter le système de filtrage avancé
  - [ ] 17.1 Créer FilterManager
    - Définir la classe PriceFilter avec tous les critères
    - Implémenter applyFilters() avec logique ET
    - Créer les méthodes setDateRange(), setPriceRange(), setCategory(), setStore()
    - Implémenter clearFilters()
    - _Exigences: 7.1, 7.2, 7.4, 7.5_
  
  - [ ] 17.2 Créer DateRange avec méthodes utilitaires
    - Implémenter lastWeek(), lastMonth(), last3Months()
    - Implémenter custom() pour plages personnalisées
    - _Exigences: 7.1_
  
  - [ ] 17.3 Créer l'interface de filtrage
    - Créer FilterSheet (bottom sheet) avec tous les filtres
    - Afficher le nombre de résultats en temps réel
    - Ajouter un bouton "Appliquer" et "Réinitialiser"
    - _Exigences: 7.7_
  
  - [ ]* 17.4 Écrire les tests de propriété pour le filtrage
    - **Propriété 14: Filtrage par Période**
    - **Propriété 15: Filtrage par Fourchette de Prix**
    - **Propriété 16: Filtrage par Magasin**
    - **Propriété 17: Combinaison de Filtres (ET Logique)**
    - **Propriété 18: Performance du Filtrage**
    - **Propriété 19: Comptage des Résultats Filtrés**
    - **Valide: Exigences 7.1, 7.2, 7.4, 7.5, 7.6, 7.7**

- [ ] 18. Intégrer les statistiques dans l'interface
  - [ ] 18.1 Améliorer l'écran de détails de produit
    - Afficher les statistiques (moyenne, médiane, écart-type)
    - Afficher le magasin le moins cher et le plus cher
    - Afficher l'économie potentielle
    - Ajouter un sélecteur de période
    - _Exigences: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  
  - [ ]* 18.2 Écrire les tests de propriété pour le filtrage par période
    - **Propriété 13: Correction des Calculs Statistiques** (avec filtrage par période)
    - **Valide: Exigences 6.5**

- [ ] 19. Checkpoint - Vérifier les statistiques et visualisations
  - Tester les calculs statistiques avec différents ensembles de données
  - Vérifier les graphiques interactifs
  - Tester les filtres combinés
  - Demander à l'utilisateur si des questions se posent


### Phase 6 : Optimisation OCR

- [ ] 20. Améliorer le service OCR
  - [ ] 20.1 Implémenter le prétraitement d'image
    - Créer preprocessImage() avec conversion en niveaux de gris
    - Ajouter l'ajustement du contraste (CLAHE)
    - Ajouter la correction de luminosité
    - Ajouter la détection et correction de rotation
    - Ajouter la réduction du bruit (Gaussian Blur)
    - _Exigences: 9.1_
  
  - [ ] 20.2 Optimiser le processus OCR
    - Intégrer google_ml_kit TextRecognizer
    - Configurer pour le français
    - Ajouter un indicateur de progression
    - Optimiser pour compléter en < 5 secondes
    - _Exigences: 9.2, 9.3_
  
  - [ ] 20.3 Implémenter l'extraction de paires produit-prix
    - Créer extractPrices() avec expression régulière
    - Parser ligne par ligne
    - Nettoyer les espaces et caractères spéciaux
    - Valider que les prix sont positifs
    - Retourner une liste de PriceEntry
    - _Exigences: 9.4_
  
  - [ ] 20.4 Améliorer la gestion d'erreurs OCR
    - Gérer le cas: aucun texte détecté
    - Afficher des suggestions d'amélioration (éclairage, recadrage)
    - Permettre la correction manuelle des résultats
    - _Exigences: 9.5, 9.6_
  
  - [ ]* 20.5 Écrire les tests de propriété pour l'OCR
    - **Propriété 23: Prétraitement d'Image OCR**
    - **Propriété 24: Performance de l'OCR**
    - **Propriété 25: Extraction de Paires Produit-Prix**
    - **Valide: Exigences 9.1, 9.3, 9.4**
  
  - [ ]* 20.6 Écrire les tests unitaires pour l'OCR
    - Tester le cas: OCR échoue (aucun texte)
    - Tester avec différentes qualités d'image
    - Tester l'expression régulière avec divers formats
    - _Exigences: 9.5_

- [ ] 21. Checkpoint - Vérifier l'OCR optimisé
  - Tester avec différents types de tickets
  - Mesurer les performances (< 5 secondes)
  - Vérifier la qualité de l'extraction
  - Demander à l'utilisateur si des questions se posent


### Phase 7 : Export et Partage

- [ ] 22. Implémenter le système d'export multi-formats
  - [ ] 22.1 Créer ExportService
    - Implémenter exportToCSV() avec encodage UTF-8
    - Implémenter exportToPDF() avec mise en page formatée
    - Implémenter exportToExcel() avec syncfusion_flutter_xlsio
    - Ajouter la sélection de période et catégories
    - _Exigences: 13.1, 13.2, 13.3, 13.4_
  
  - [ ] 22.2 Implémenter l'export CSV
    - Créer les colonnes: Date, Produit, Magasin, Prix, Catégorie
    - Utiliser UTF-8 avec BOM
    - Utiliser la virgule comme séparateur
    - Inclure les métadonnées (date d'export, nombre d'entrées)
    - _Exigences: 13.1, 13.6_
  
  - [ ] 22.3 Implémenter l'export PDF
    - Créer un en-tête avec titre
    - Ajouter un tableau formaté avec les données
    - Inclure les graphiques si option activée
    - Inclure les statistiques si option activée
    - Ajouter un pied de page avec date de génération
    - _Exigences: 13.2, 13.6_
  
  - [ ] 22.4 Implémenter l'export Excel
    - Créer une feuille "Données" avec tableau
    - Créer une feuille "Statistiques" avec résumés
    - Créer une feuille "Graphiques" avec visualisations
    - Ajouter le formatage conditionnel (min vert, max rouge)
    - _Exigences: 13.3_
  
  - [ ]* 22.5 Écrire les tests de propriété pour l'export
    - **Propriété 38: Export CSV Valide**
    - **Propriété 39: Export PDF Valide**
    - **Propriété 40: Export Excel Valide**
    - **Propriété 41: Métadonnées dans les Exports**
    - **Valide: Exigences 13.1, 13.2, 13.3, 13.6**


- [ ] 23. Implémenter le système de partage
  - [ ] 23.1 Implémenter le partage de données
    - Créer generateShareableJSON() pour générer un JSON valide
    - Intégrer avec le système de partage natif (Share API)
    - Ajouter un bouton de partage dans les écrans pertinents
    - _Exigences: 14.1, 14.2_
  
  - [ ] 23.2 Implémenter l'import de données partagées
    - Créer un écran d'import avec prévisualisation
    - Détecter et signaler les doublons
    - Permettre de choisir entre fusionner ou remplacer
    - _Exigences: 14.3, 14.4, 14.5_
  
  - [ ]* 23.3 Écrire les tests de propriété pour le partage
    - **Propriété 42: Génération de JSON pour Partage**
    - **Propriété 43: Détection de Doublons à l'Import**
    - **Valide: Exigences 14.2, 14.4**


- [ ] 24. Implémenter le générateur de rapports
  - [ ] 24.1 Créer ReportGenerator
    - Implémenter generateComparisonReport() avec ReportConfig
    - Créer buildPDFDocument() pour construire le PDF
    - Créer buildChartData() pour les graphiques
    - _Exigences: 15.1_
  
  - [ ] 24.2 Structurer le rapport PDF
    - Créer la page de garde avec titre et métadonnées
    - Créer le résumé exécutif avec économies totales
    - Ajouter les détails par produit avec tableaux et graphiques
    - Ajouter les graphiques globaux (barres, circulaire)
    - _Exigences: 15.1, 15.2_
  
  - [ ] 24.3 Calculer les métriques du rapport
    - Calculer l'économie totale potentielle
    - Identifier le magasin le plus économique
    - Calculer les statistiques par produit
    - _Exigences: 15.3, 15.5_
  
  - [ ] 24.4 Ajouter le partage de rapport
    - Permettre le partage direct via email ou autres apps
    - Sauvegarder le rapport dans le stockage
    - _Exigences: 15.6_
  
  - [ ]* 24.5 Écrire les tests de propriété pour les rapports
    - **Propriété 44: Génération de Rapport PDF**
    - **Propriété 45: Inclusion de Graphiques dans le Rapport**
    - **Propriété 46: Calcul de l'Économie Totale dans le Rapport**
    - **Propriété 47: Inclusion des Statistiques dans le Rapport**
    - **Valide: Exigences 15.1, 15.2, 15.3, 15.5**

- [ ] 25. Checkpoint - Vérifier l'export et le partage
  - Tester tous les formats d'export (CSV, PDF, Excel)
  - Vérifier la génération de rapports
  - Tester le partage et l'import de données
  - Demander à l'utilisateur si des questions se posent


### Phase 8 : Expérience Utilisateur

- [ ] 26. Implémenter le système d'onboarding
  - [ ] 26.1 Créer OnboardingManager
    - Implémenter shouldShowOnboarding() pour vérifier le premier lancement
    - Implémenter markOnboardingComplete() pour persister
    - Implémenter shouldShowTooltip() et markTooltipViewed()
    - _Exigences: 16.1, 16.3, 16.4_
  
  - [ ] 26.2 Créer OnboardingScreen
    - Créer 3-5 pages d'onboarding avec PageView
    - Page 1: Bienvenue et présentation
    - Page 2: Ajout de prix (manuel et scan)
    - Page 3: Analyse et économies
    - Page 4: Partage et export
    - Ajouter un bouton "Passer" sur chaque page
    - _Exigences: 16.1, 16.2_
  
  - [ ] 26.3 Créer les illustrations d'onboarding
    - Créer ou intégrer des illustrations pour chaque page
    - Utiliser Lottie pour des animations si possible
    - Appliquer les couleurs du thème
    - _Exigences: 16.1_
  
  - [ ] 26.4 Intégrer l'onboarding dans le flux de démarrage
    - Afficher l'onboarding au premier lancement
    - Rediriger vers l'écran principal après complétion
    - Ajouter un accès aux tutoriels dans les paramètres
    - _Exigences: 16.5_
  
  - [ ]* 26.5 Écrire les tests de propriété pour l'onboarding
    - **Propriété 48: Marquage de Complétion de l'Onboarding**
    - **Valide: Exigences 16.3**
  
  - [ ]* 26.6 Écrire les tests unitaires pour l'onboarding
    - Tester le cas: premier lancement affiche l'onboarding
    - Tester le cas: lancement suivant ne l'affiche pas
    - _Exigences: 16.1_


- [ ] 27. Implémenter l'aide contextuelle
  - [ ] 27.1 Créer le système d'aide contextuelle
    - Créer HelpDialog widget réutilisable
    - Ajouter une icône d'aide (?) sur chaque écran principal
    - Créer le contenu d'aide pour chaque écran
    - Inclure des exemples d'utilisation
    - _Exigences: 17.1, 17.2, 17.3_
  
  - [ ] 27.2 Implémenter la persistance de l'état "aide vue"
    - Sauvegarder les aides consultées dans AppSettings
    - Ne plus afficher automatiquement les aides déjà vues
    - Permettre de réafficher l'aide manuellement
    - _Exigences: 17.5_
  
  - [ ]* 27.3 Écrire les tests de propriété pour l'aide contextuelle
    - **Propriété 49: Persistance de l'État "Aide Vue"**
    - **Valide: Exigences 17.5**


- [ ] 28. Améliorer le feedback utilisateur
  - [ ] 28.1 Implémenter les SnackBar de confirmation
    - Afficher un SnackBar après chaque action (création, modification, suppression)
    - Utiliser des couleurs appropriées (vert pour succès, rouge pour erreur)
    - Ajouter des icônes distinctives
    - _Exigences: 18.1, 18.5_
  
  - [ ] 28.2 Ajouter les indicateurs de progression
    - Afficher un CircularProgressIndicator pour les opérations > 1 seconde
    - Utiliser LinearProgressIndicator pour les opérations avec progression
    - Intégrer dans SafeExecutor
    - _Exigences: 18.2_
  
  - [ ] 28.3 Implémenter les confirmations pour actions destructives
    - Créer ConfirmDialog widget
    - Afficher avant toute suppression
    - Permettre d'annuler
    - _Exigences: 18.3_
  
  - [ ] 28.4 Ajouter les animations de succès
    - Utiliser Lottie pour des animations de checkmark
    - Afficher après les opérations réussies
    - _Exigences: 18.4_
  
  - [ ] 28.5 Implémenter la fonctionnalité d'annulation
    - Ajouter un bouton "Annuler" dans les SnackBar
    - Permettre d'annuler dans les 5 secondes
    - Implémenter pour les actions principales (ajout, modification, suppression)
    - _Exigences: 18.6_
  
  - [ ]* 28.6 Écrire les tests de propriété pour le feedback
    - **Propriété 50: Fonctionnalité d'Annulation**
    - **Valide: Exigences 18.6**

- [ ] 29. Checkpoint - Vérifier l'expérience utilisateur
  - Tester l'onboarding complet
  - Vérifier l'aide contextuelle sur tous les écrans
  - Tester les confirmations et annulations
  - Demander à l'utilisateur si des questions se posent


### Phase 9 : Intégration et Tests Finaux

- [ ] 30. Intégrer tous les composants dans l'interface
  - [ ] 30.1 Mettre à jour l'écran d'accueil (HomeScreen)
    - Intégrer le système de thèmes
    - Ajouter les filtres rapides (catégories, favoris)
    - Afficher les statistiques globales
    - Optimiser avec lazy loading
    - _Exigences: 1.1, 4.3, 8.1_
  
  - [ ] 30.2 Améliorer l'écran d'ajout de prix (AddPriceScreen)
    - Intégrer l'autocomplétion pour produits et magasins
    - Ajouter le sélecteur de catégorie
    - Intégrer la validation en temps réel
    - Ajouter le bouton favori
    - _Exigences: 3.1, 4.2, 19.1, 19.2, 19.3_
  
  - [ ] 30.3 Améliorer l'écran de scan (ScanScreen)
    - Intégrer l'OCR optimisé
    - Afficher l'indicateur de progression
    - Permettre la correction manuelle
    - Afficher les erreurs avec suggestions
    - _Exigences: 9.1, 9.2, 9.5, 9.6_
  
  - [ ] 30.4 Améliorer l'écran de comparaison (ComparisonScreen)
    - Intégrer les graphiques améliorés
    - Afficher les statistiques détaillées
    - Ajouter les filtres avancés
    - _Exigences: 5.1, 6.1, 7.1_
  
  - [ ] 30.5 Améliorer l'écran des tendances (TrendsScreen)
    - Intégrer les graphiques linéaires interactifs
    - Ajouter le sélecteur de période
    - Afficher les statistiques par période
    - _Exigences: 5.1, 5.2, 6.5_
  
  - [ ] 30.6 Créer l'écran d'export/import
    - Ajouter les boutons pour chaque format (CSV, PDF, Excel)
    - Intégrer le sélecteur de période et catégories
    - Ajouter le bouton de partage
    - Intégrer l'import avec prévisualisation
    - _Exigences: 13.1, 13.2, 13.3, 14.1, 14.3_
  
  - [ ] 30.7 Créer l'écran de paramètres
    - Ajouter le sélecteur de thème
    - Ajouter le bouton de vidage du cache
    - Ajouter l'accès aux tutoriels
    - Ajouter les informations de l'application
    - _Exigences: 2.1, 12.6, 16.5_


- [ ] 31. Écrire les tests d'intégration pour les flux critiques
  - [ ]* 31.1 Test d'intégration: Flux d'ajout de prix manuel
    - Ouvrir AddPriceScreen
    - Saisir un produit avec autocomplétion
    - Sélectionner une catégorie
    - Saisir un prix valide
    - Sauvegarder
    - Vérifier la persistance dans Hive
    - _Exigences: 3.1, 4.2, 19.1_
  
  - [ ]* 31.2 Test d'intégration: Flux de scan OCR
    - Ouvrir ScanScreen
    - Charger une image de test
    - Attendre le traitement OCR
    - Vérifier l'extraction des prix
    - Corriger manuellement si nécessaire
    - Sauvegarder
    - _Exigences: 9.1, 9.4, 9.6_
  
  - [ ]* 31.3 Test d'intégration: Flux d'export CSV
    - Sélectionner des données à exporter
    - Choisir le format CSV
    - Générer le fichier
    - Vérifier la validité du CSV
    - Vérifier les métadonnées
    - _Exigences: 13.1, 13.6_
  
  - [ ]* 31.4 Test d'intégration: Flux de changement de thème
    - Ouvrir les paramètres
    - Changer le thème (clair → sombre)
    - Vérifier l'application immédiate
    - Redémarrer l'application
    - Vérifier la persistance du thème
    - _Exigences: 2.2, 2.3, 2.5_
  
  - [ ]* 31.5 Test d'intégration: Flux de filtrage multi-critères
    - Ouvrir l'écran de comparaison
    - Appliquer un filtre par catégorie
    - Appliquer un filtre par période
    - Appliquer un filtre par fourchette de prix
    - Vérifier que les résultats respectent tous les filtres
    - Vérifier le comptage des résultats
    - _Exigences: 7.1, 7.2, 7.5, 7.7_


- [ ] 32. Écrire les tests de widgets pour les écrans principaux
  - [ ]* 32.1 Tests de widgets pour HomeScreen
    - Tester l'affichage de la liste de produits
    - Tester la navigation vers les autres écrans
    - Tester les filtres rapides
    - _Exigences: 1.1_
  
  - [ ]* 32.2 Tests de widgets pour AddPriceScreen
    - Tester l'affichage du formulaire
    - Tester la validation des champs
    - Tester l'autocomplétion
    - Tester le sélecteur de catégorie
    - _Exigences: 3.1, 4.2, 19.1_
  
  - [ ]* 32.3 Tests de widgets pour ComparisonScreen
    - Tester l'affichage des graphiques
    - Tester l'affichage des statistiques
    - Tester les filtres
    - _Exigences: 5.1, 6.1, 7.1_
  
  - [ ]* 32.4 Tests de widgets pour TrendsScreen
    - Tester l'affichage du graphique linéaire
    - Tester les infobulles interactives
    - Tester le sélecteur de période
    - _Exigences: 5.1, 5.2, 6.5_
  
  - [ ]* 32.5 Tests de widgets pour FavoritesScreen
    - Tester l'affichage de la liste des favoris
    - Tester la suppression d'un favori
    - Tester l'affichage du dernier prix
    - _Exigences: 8.3, 8.4, 8.5_


- [ ] 33. Optimisations finales et polish
  - [ ] 33.1 Optimiser les performances
    - Utiliser const constructors pour les widgets statiques
    - Optimiser les requêtes Hive avec des index
    - Utiliser compute() pour les opérations lourdes (OCR, statistiques)
    - Profiler l'application avec Flutter DevTools
    - _Exigences: 10.1, 10.2_
  
  - [ ] 33.2 Améliorer l'accessibilité
    - Vérifier tous les semanticsLabel
    - Tester avec TalkBack et VoiceOver
    - Vérifier les tailles de police système
    - Vérifier la navigation au clavier
    - _Exigences: 1.6_
  
  - [ ] 33.3 Finaliser les animations et transitions
    - Vérifier que toutes les transitions sont fluides
    - Mesurer les durées (< 300ms)
    - Ajouter des micro-interactions (ripple effects)
    - _Exigences: 1.2, 1.4_
  
  - [ ] 33.4 Nettoyer le code
    - Supprimer le code mort
    - Formater avec dart format
    - Exécuter dart analyze et corriger les warnings
    - Ajouter la documentation pour les fonctions complexes
    - _Exigences: 20.1, 20.2_

- [ ] 34. Checkpoint final - Validation complète
  - Exécuter tous les tests (unitaires, propriétés, widgets, intégration)
  - Vérifier la couverture de tests (objectif: 80%)
  - Tester manuellement tous les flux utilisateur
  - Vérifier les performances sur différents appareils
  - Demander à l'utilisateur si des questions se posent


### Phase 10 : Documentation et Livraison

- [ ] 35. Créer la documentation technique
  - [ ] 35.1 Documenter l'architecture
    - Créer un diagramme d'architecture
    - Documenter les couches et leurs responsabilités
    - Documenter les flux de données
    - _Exigences: Toutes_
  
  - [ ] 35.2 Documenter les API et services
    - Documenter tous les services publics
    - Ajouter des exemples d'utilisation
    - Documenter les modèles de données
    - _Exigences: Toutes_
  
  - [ ] 35.3 Créer un guide de contribution
    - Documenter les conventions de code
    - Expliquer comment ajouter de nouvelles fonctionnalités
    - Expliquer comment exécuter les tests
    - _Exigences: 20.1, 20.2_

- [ ] 36. Créer la documentation utilisateur
  - [ ] 36.1 Créer un guide utilisateur
    - Documenter toutes les fonctionnalités principales
    - Ajouter des captures d'écran
    - Créer des tutoriels pas à pas
    - _Exigences: 16.1, 17.1_
  
  - [ ] 36.2 Créer une FAQ
    - Répondre aux questions fréquentes
    - Documenter les problèmes courants et leurs solutions
    - _Exigences: 17.1_

- [ ] 37. Préparer la livraison
  - [ ] 37.1 Vérifier la configuration de production
    - Configurer les clés de signature
    - Vérifier les permissions dans AndroidManifest.xml et Info.plist
    - Configurer ProGuard/R8 pour Android
    - _Exigences: Toutes_
  
  - [ ] 37.2 Générer les builds de production
    - Générer l'APK/AAB pour Android
    - Générer l'IPA pour iOS
    - Tester les builds sur des appareils réels
    - _Exigences: Toutes_
  
  - [ ] 37.3 Créer les assets pour les stores
    - Créer les captures d'écran pour Play Store et App Store
    - Rédiger la description de l'application
    - Créer l'icône de l'application
    - _Exigences: 1.1_

- [ ] 38. Checkpoint final - Prêt pour la livraison
  - Vérifier que tous les tests passent
  - Vérifier que la documentation est complète
  - Tester les builds de production
  - Demander à l'utilisateur la validation finale

## Notes

- Les tâches marquées avec `*` sont optionnelles et peuvent être sautées pour un MVP plus rapide
- Chaque tâche référence les exigences spécifiques qu'elle implémente
- Les checkpoints permettent une validation incrémentale
- Les tests de propriétés valident les invariants universels
- Les tests unitaires valident les cas spécifiques et les cas limites
- Les tests d'intégration valident les flux utilisateur complets

## Dépendances Principales

- `hive` et `hive_flutter` : Stockage local
- `google_ml_kit` ou `tesseract_ocr` : OCR
- `fl_chart` ou `syncfusion_flutter_charts` : Graphiques
- `provider` ou `riverpod` : Gestion d'état
- `pdf` : Génération de PDF
- `csv` : Export CSV
- `syncfusion_flutter_xlsio` : Export Excel
- `share_plus` : Partage natif
- `lottie` : Animations
- `mockito` : Mocks pour les tests
- `faker` : Génération de données de test

