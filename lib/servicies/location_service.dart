import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Functia principala care se ocupa de tot: permisiuni + obtinere pozitie
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