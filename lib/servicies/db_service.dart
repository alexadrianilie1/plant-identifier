import 'dart:convert'; // Necesar pentru Base64
import 'dart:io';      // Necesar pentru File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

/**
 * Clasa [DBService] reprezintă stratul de acces la date (Data Access Layer) al aplicației.
 * Gestionează interacțiunea cu baza de date NoSQL [Cloud Firestore], oferind operațiuni 
 * de tip CRUD pentru colecția personală de flori (Ierbarul Digital).
 */
class DBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

/**
 * Salvează o nouă identificare botanică în baza de date.
 * 
 * Implementează arhitectura de stocare unificată: imaginea fizică este convertită 
 * într-un șir de caractere [Base64] direct pe dispozitiv. Această abordare atomică 
 * salvează imaginea și metadatele într-un singur document Firestore, permițând 
 * mecanismului nativ de cache să le stocheze la pachet pentru un acces complet offline.
 * 
 * Parametri:
 * - [name]: Denumirea populară a plantei.
 * - [scientificName]: Denumirea științifică a plantei.
 * - [description]: Descrierea preluată asincron via Wikipedia API.
 * - [confidence]: Scorul de încredere (precizia) generat de modelul TFLite local.
 * - [imageFile]: Fișierul local al imaginii capturate.
 * - [isFavorite]: Starea inițială de marcaj (favorit sau nu).
 * - [careTips]: Sfaturile de îngrijire generate de Groq API, formatate ca JSON (Map).
 * - [latitude] și [longitude]: Coordonatele geografice ale capturii.
 */
  Future<void> addFlower({
    required String name,
    required String scientificName,
    required String description,
    required double confidence,
    required File imageFile,
    required bool isFavorite,
    required Map<String, dynamic> careTips,
    required double latitude,
    required double longitude,
  }) async {
    String userId = _authService.userId;

    try {
      // 1. Transformam poza in bytes
      List<int> imageBytes = await imageFile.readAsBytes();
      
      // 2. Transformam bytes in text (Base64)
      String base64Image = base64Encode(imageBytes);

      // 3. Salvam totul in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('flowers')
          .add({
            'name': name,
            'scientific_name': scientificName,
            'description': description,
            'confidence': confidence,
            'image_base64': base64Image,
            'timestamp': FieldValue.serverTimestamp(),
            'is_favorite': isFavorite,
            'care_tips': careTips,
            'latitude': latitude,
            'longitude': longitude,
          });
          
      print("Flower added successfully for user $userId (Base64 mode).");
    } catch (e) {
      print("Error adding flower for user $userId: $e");
      throw e;
    }
  }

  /**
   * Returnează un flux continuu ([Stream]) cu documentele din Ierbarul utilizatorului.
   * 
   * Datele sunt ordonate descrescător după marcajul de timp (cele mai noi primele).
   * Utilizarea unui Stream permite interfeței (Flutter UI) să reacționeze automat
   * la modificările din baza de date, fără a necesita reîncărcări manuale.
   */
  Stream<QuerySnapshot> getFlowersStream() {
    String userId = _authService.userId;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('flowers')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /**
   * Elimină o înregistrare specifică din colecția utilizatorului.
   * 
   * [flowerId] reprezintă identificatorul unic al documentului din Firestore.
   */
  Future<void> deleteFlower(String flowerId) async {
    String userId = _authService.userId;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('flowers')
          .doc(flowerId)
          .delete();
      print("Flower $flowerId deleted successfully for user $userId.");
    } catch(e) {
      print("Error deleting flower $flowerId for user $userId: $e");
      throw e;
    }
  }

  /**
   * Actualizează starea de marcaj (favorit) a unei plante din Ierbar.
   * 
   * Folosește actualizarea parțială (`update`) pentru a modifica doar câmpul boolean `is_favorite`,
   * o abordare optimizată care minimizează consumul de lățime de bandă.
   */
  Future<void> updateFavoriteStatus(String flowerId, bool isFavorite) async {
    String userId = _authService.userId;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('flowers')
          .doc(flowerId)
          .update({
            'is_favorite': isFavorite,
          });
    } catch(e) {
      print("Error updating favorite status for flower $flowerId: $e");
      throw e;
    }
  }

  /**
   * Calculează și returnează numărul total de flori salvate de utilizator.
   * 
   * Extrage mărimea snapshot-ului curent, utilă pentru afișarea statisticilor în ecranul Profil.
   */
  Stream<int> getFlowerCount() {
    String userId = _authService.userId;

    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('flowers')
          .snapshots()
          .map((snapshot) => snapshot.size);
    } catch (e) {
      print("Error getting flower count for user $userId: $e");
      throw e;
    }
  }

  /**
   * Calculează și returnează numărul de flori marcate ca favorite.
   * 
   * Aplică un filtru `where` direct la nivelul interogării bazei de date, 
   * respectând bunele practici de evitare a filtrării datelor pe partea de client.
   */
  Stream<int> getFavoriteFlowerCount() {
    String userId = _authService.userId;

    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('flowers')
          .where('is_favorite', isEqualTo: true)
          .snapshots()
          .map((snapshot) => snapshot.size);
    } catch (e) {
      print("Error getting favorite flower count for user $userId: $e");
      throw e;
    }
  }

  /**
   * Determină numărul de specii unice (distincte) descoperite de utilizator.
   * 
   * Iterând prin snapshot-ul documentelor, utilizează o structură de date de tip [Set] 
   * pentru a garanta stocarea exclusivă a numelor unice, eliminând duplicatele.
   */
  Stream<int> getDistinctPlantCount() {
    String userId = _authService.userId;

    try {
      return _firestore
          .collection('users')
          .doc(userId)
          .collection('flowers')
          .snapshots()
          .map((snapshot) {
        Set<String> distinctNames = {};
        for (var doc in snapshot.docs) {
          String name = doc['name'] ?? '';
        if (name.isNotEmpty) {
          distinctNames.add(name);
        }
      }

        return distinctNames.length;
      });
    } catch (e) {
      print("Error getting distinct plant count for user $userId: $e");
      throw e;
    }
  }
}