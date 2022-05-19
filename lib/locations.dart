import 'package:latlong2/latlong.dart';

class Track {
  Track(this.name, this.locations);

  final String name;
  final List<LatLng> locations;
}
