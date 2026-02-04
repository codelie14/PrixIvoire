## **Cahier des Charges : PrixIvoire**
**Version 1.0**
**Date : 03/02/2026**
**Rédigé pour : IndraLabs**

---

### **1. Contexte et Objectifs**
#### **1.1. Contexte**
En Côte d’Ivoire, les consommateurs manquent souvent d’outils pour comparer facilement les prix des produits de base (riz, huile, sucre, etc.) entre les différents marchés et supermarchés. **PrixIvoire** vise à répondre à ce besoin en permettant aux utilisateurs de **saisir, stocker et comparer les prix localement**, sans dépendre d’une connexion internet ou d’un serveur externe.

#### **1.2. Objectifs**
- Permettre aux utilisateurs de **saisir manuellement** les prix des produits dans leur environnement.
- **Stocker les données localement** pour une consultation hors ligne.
- **Comparer les prix** entre différents magasins/marchés.
- **Visualiser les tendances** des prix sur une période donnée.
- **Alertes personnalisées** pour les baisses ou hausses de prix.
- **Importer/Exporter** des données depuis des fichiers (CSV, images de prospectus).

---

### **2. Périmètre du Projet**
#### **2.1. Fonctionnalités Incluses**
| Fonctionnalité                | Description                                                                                     |
|-------------------------------|-------------------------------------------------------------------------------------------------|
| **Saisie manuelle des prix**  | Formulaire pour entrer le nom du produit, le prix, le magasin et la date.                     |
| **OCR pour extraire les prix**| Utilisation de l’OCR pour scanner des images de prospectus ou tickets de caisse.              |
| **Stockage local**            | Sauvegarde des données avec `hive` ou `sqflite`.                                               |
| **Comparaison des prix**      | Affichage des prix par produit et par magasin sous forme de liste ou de graphique.              |
| **Alertes personnalisées**    | Notifications locales si un prix atteint un seuil défini par l’utilisateur.                   |
| **Visualisation des tendances** | Graphiques (`fl_chart`) pour montrer l’évolution des prix sur 1 mois.                       |
| **Export/Import**             | Export des données en CSV et import depuis un fichier CSV ou une image (via OCR).              |

#### **2.2. Fonctionnalités Exclues**
- **Base de données externe** : Pas de stockage cloud ou de synchronisation.
- **Authentification** : Pas de système de connexion.
- **Scraping automatisé de sites web** : Seule la saisie manuelle ou l’OCR local est incluse.

---

### **3. Spécifications Techniques**
#### **3.1. Environnement de Développement**
- **Langage** : Dart (Flutter).
- **Framework** : Flutter (pour une application cross-platform).
- **IDE** : Android Studio ou Visual Studio Code.
- **Plateforme cible** : Android (prioritaire).

#### **3.2. Bibliothèques et Outils**
| Besoin                  | Bibliothèque/Outils Flutter                                                                 |
|-------------------------|--------------------------------------------------------------------------------------------|
| Stockage local          | [`hive`](https://pub.dev/packages/hive) ou [`sqflite`](https://pub.dev/packages/sqflite)    |
| OCR                     | [`google_mlkit_text_recognition`](https://pub.dev/packages/google_mlkit_text_recognition)  |
| Graphiques              | [`fl_chart`](https://pub.dev/packages/fl_chart)                                            |
| Notifications locales   | [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications)      |
| Gestion des fichiers    | [`path_provider`](https://pub.dev/packages/path_provider)                                   |
| Export/Import CSV       | [`csv`](https://pub.dev/packages/csv)                                                       |

#### **3.3. Architecture Logicielle**
- **Frontend** : Interface utilisateur en Flutter (écrans de saisie, liste des prix, graphiques).
- **Backend local** : Gestion des données avec `hive` ou `sqflite`.
- **Traitement des données** :
  - Extraction des prix via OCR.
  - Calcul des tendances et déclenchement des alertes.

---

### **4. Maquettes et Interface Utilisateur**
#### **4.1. Écrans Principaux**
1. **Écran d’accueil** :
   - Boutons pour "Saisir un prix", "Scanner un prospectus", "Voir les prix", "Alertes".
   - Graphique récapitulatif des tendances récentes.

2. **Écran de saisie manuelle** :
   - Champs : Nom du produit, Prix, Magasin, Date.
   - Bouton "Enregistrer".

3. **Écran de scan OCR** :
   - Bouton pour prendre une photo ou importer une image.
   - Affichage des prix extraits et validation par l’utilisateur.

4. **Écran de comparaison des prix** :
   - Liste des produits avec prix par magasin.
   - Filtres par produit ou magasin.

5. **Écran des tendances** :
   - Graphiques (`fl_chart`) pour chaque produit.

6. **Écran des alertes** :
   - Liste des alertes actives et historique des notifications.

#### **4.2. Exemple de Maquette (Description Textuelle)**
- **Écran d’accueil** :
  ```
  +-------------------------------------+
  | PrixIvoire                          |
  |                                     |
  | [Saisir un prix]    [Scanner]       |
  |                                     |
  | Graphique : Évolution du prix du riz|
  |                                     |
  | [Voir tous les prix] [Mes alertes]  |
  +-------------------------------------+
  ```

---

### **5. Données et Stockage**
#### **5.1. Modèle de Données**
```dart
@HiveType(typeId: 0)
class ProductPrice {
  @HiveField(0)
  final String productName; // Nom du produit (ex: "Riz 25kg")

  @HiveField(1)
  final double price; // Prix en FCFA

  @HiveField(2)
  final String shop; // Magasin ou marché (ex: "Carrefour", "Marché d’Adjamé")

  @HiveField(3)
  final DateTime date; // Date de la saisie

  ProductPrice(this.productName, this.price, this.shop, this.date);
}

@HiveType(typeId: 1)
class PriceAlert {
  @HiveField(0)
  final String productName;

  @HiveField(1)
  final double threshold; // Seuil de prix (ex: 12000 FCFA)

  @HiveField(2)
  final bool isAbove; // True = alerte si prix > seuil, False = alerte si prix < seuil

  PriceAlert(this.productName, this.threshold, this.isAbove);
}
```

#### **5.2. Stockage**
- **`hive`** : Pour stocker les objets `ProductPrice` et `PriceAlert`.
- **Fichiers CSV** : Pour l’export/import des données.
- **Images** : Stockées localement après scan OCR.

---

### **6. Contraintes Techniques**
- **Pas de connexion internet requise** : Toutes les données sont locales.
- **Compatibilité** : Android 6.0 (API 23) et versions ultérieures.
- **Performances** : Temps de réponse < 2 secondes pour les opérations de base (saisie, affichage, recherche).
- **Sécurité** : Pas de transmission de données en dehors de l’appareil.

---

### **7. Planning Prévisionnel**
| Phase               | Durée estimée | Livrables                                                                 |
|---------------------|---------------|---------------------------------------------------------------------------|
| **Conception**      | 3 jours        | Cahier des charges, maquettes, modèle de données.                        |
| **Développement**   | 10 jours       | Code Flutter, intégration des bibliothèques, tests unitaires.            |
| **Tests**           | 3 jours        | Tests utilisateur, corrections de bugs.                                  |
| **Déploiement**     | 1 jour         | Génération de l’APK, documentation technique.                           |

---

### **8. Livrables**
1. **Code source** : Projet Flutter complet sur GitHub (ou autre dépôt).
2. **APK** : Fichier installable pour Android.
3. **Documentation** :
   - Guide d’installation et d’utilisation.
   - Explications techniques (architecture, choix des bibliothèques).
4. **Tests** : Scénarios de test et résultats.

---

### **9. Risques et Solutions**
| Risque                          | Solution Proposée                                                                 |
|---------------------------------|-----------------------------------------------------------------------------------|
| Difficulté avec l’OCR           | Utiliser une bibliothèque éprouvée (`google_mlkit_text_recognition`).          |
| Stockage local trop volumineux  | Limiter la durée de conservation des données (ex: 6 mois).                     |
| Performances lentes             | Optimiser les requêtes locales et éviter les traitements lourds en arrière-plan. |

---

### **10. Budget (Estimation)**
- **Coût de développement** : 0 FCFA (projet personnel, pas de coûts externes).
- **Ressources** : Temps estimé à 2 semaines (à temps partiel).

---

### **11. Perspectives d’Évolution**
- **Version 2.0** :
  - Ajout d’un système de **scraping local** (si l’utilisateur importe des fichiers HTML).
  - **Partage local** (via Bluetooth ou Wi-Fi Direct) entre utilisateurs proches.
  - **Intégration avec des capteurs** (ex: prix du carburant via API locale si disponible hors ligne).

---

### **12. Annexes**
- **Exemple de code** : Voir section 3.3 pour les modèles de données.
- **Ressources utiles** :
  - [Documentation Flutter](https://flutter.dev/docs)
  - [Tutoriel Hive](https://docs.hivedb.dev/#/)
  - [Tutoriel OCR avec ML Kit](https://developers.google.com/ml-kit/vision/text-recognition)

---
**Prochaine étape** :
Ce cahier des charges te convient-il ? Veux-tu que je détaille une section spécifique (ex : architecture technique, design des écrans) ou que j’ajoute des précisions sur un point particulier ? 😊