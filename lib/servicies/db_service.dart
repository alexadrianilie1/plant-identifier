import 'dart:convert'; // Necesar pentru Base64
import 'dart:io';      // Necesar pentru File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';

class DBService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

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
      // 1. Transformam poza în bytes
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

  Stream<QuerySnapshot> getFlowersStream() {
    String userId = _authService.userId;

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('flowers')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

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