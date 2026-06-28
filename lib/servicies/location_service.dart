import 'package:geolocator/geolocator.dart';

/**
 * Serviciu dedicat gestionării datelor de geolocație ale dispozitivului mobil.
 * 
 * Este utilizat pentru a asocia coordonatele geografice (latitudine și longitudine)
 * cu fiecare exemplar de floare salvat în Ierbarul Digital, oferind astfel
 * un context spațial descoperirilor botanice ale utilizatorului.
 */
class LocationService {
  /**
   * Obține coordonatele GPS curente ale dispozitivului.
   * 
   * Metoda implementează un flux complet și sigur pentru gestionarea permisiunilor
   * la nivel de sistem de operare (Android/iOS). Verifică starea curentă a permisiunii
   * și solicită accesul interactiv dacă acesta nu a fost acordat anterior.
   * 
   * Returnează un obiect de tip [Position] care conține latitudinea, longitudinea
   * și alte metadate spațiale, sau aruncă o excepție în cazul în care utilizatorul
   * refuză accesul la senzorul GPS (hardware).
   */
  Future<Position?> getCurrentLocation() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission(); // Aceasta deschide dialogul pe ecran
    if (permission == LocationPermission.denied) {
      return Future.error('Permisiunea a fost respinsă de utilizator.');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    return Future.error('Permisiunea este blocată definitiv din setări.');
  }

  return await Geolocator.getCurrentPosition();
}
}