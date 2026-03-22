import 'package:adhan_dart/adhan_dart.dart';

import 'geo_coordinates.dart';

class QiblaService {
  const QiblaService();

  double bearingFor(GeoCoordinates coordinates) {
    return Qibla.qibla(
      Coordinates(coordinates.latitude, coordinates.longitude),
    );
  }
}
