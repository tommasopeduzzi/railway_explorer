import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class Response {
  double? version;
  String? generator;
  Osm3s? osm3s;
  List<Elements>? elements;

  Response({this.version, this.generator, this.osm3s, this.elements});

  Response.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    generator = json['generator'];
    osm3s = json['osm3s'] != null ? new Osm3s.fromJson(json['osm3s']) : null;
    if (json['elements'] != null) {
      elements = <Elements>[];
      json['elements'].forEach((v) {
        elements!.add(new Elements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['version'] = this.version;
    data['generator'] = this.generator;
    if (this.osm3s != null) {
      data['osm3s'] = this.osm3s!.toJson();
    }
    if (this.elements != null) {
      data['elements'] = this.elements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Osm3s {
  String? timestampOsmBase;
  String? copyright;

  Osm3s({this.timestampOsmBase, this.copyright});

  Osm3s.fromJson(Map<String, dynamic> json) {
    timestampOsmBase = json['timestamp_osm_base'];
    copyright = json['copyright'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['timestamp_osm_base'] = this.timestampOsmBase;
    data['copyright'] = this.copyright;
    return data;
  }
}

class Elements {
  String? type;
  int? id;
  Bounds? bounds;
  List<int>? nodes;
  List<Geometry>? geometry;
  Tags? tags;

  Elements(
      {this.type, this.id, this.bounds, this.nodes, this.geometry, this.tags});

  Elements.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    bounds =
        json['bounds'] != null ? new Bounds.fromJson(json['bounds']) : null;
    if (json['nodes'] != null) {
      nodes = json['nodes'].cast<int>();
    }
    if (json['geometry'] != null) {
      geometry = <Geometry>[];
      json['geometry'].forEach((v) {
        geometry!.add(new Geometry.fromJson(v));
      });
    }
    tags = json['tags'] != null ? new Tags.fromJson(json['tags']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['id'] = this.id;
    if (this.bounds != null) {
      data['bounds'] = this.bounds!.toJson();
    }
    data['nodes'] = this.nodes;
    if (this.geometry != null) {
      data['geometry'] = this.geometry!.map((v) => v.toJson()).toList();
    }
    if (this.tags != null) {
      data['tags'] = this.tags!.toJson();
    }
    return data;
  }
}

class Bounds {
  double? minlat;
  double? minlon;
  double? maxlat;
  double? maxlon;

  Bounds({this.minlat, this.minlon, this.maxlat, this.maxlon});

  Bounds.fromJson(Map<String, dynamic> json) {
    minlat = json['minlat'];
    minlon = json['minlon'];
    maxlat = json['maxlat'];
    maxlon = json['maxlon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['minlat'] = this.minlat;
    data['minlon'] = this.minlon;
    data['maxlat'] = this.maxlat;
    data['maxlon'] = this.maxlon;
    return data;
  }
}

class Geometry {
  double? lat;
  double? lon;

  Geometry({this.lat, this.lon});

  Geometry.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lon'] = this.lon;
    return data;
  }
}

class Tags {
  String? electrified;
  String? frequency;
  String? gauge;
  String? layer;
  String? maxspeed;
  String? oneway;
  String? operator;
  String? railway;
  String? tracks;
  String? tunnel;
  String? voltage;
  String? owner;
  String? passengerLines;
  String? railwayEtcs;
  String? railwayPzb;
  String? railwayTrafficMode;
  String? service;
  String? ref;
  String? usage;
  String? railwayTrackRef;

  Tags(
      {this.electrified,
      this.frequency,
      this.gauge,
      this.layer,
      this.maxspeed,
      this.oneway,
      this.operator,
      this.railway,
      this.tracks,
      this.tunnel,
      this.voltage,
      this.owner,
      this.passengerLines,
      this.railwayEtcs,
      this.railwayPzb,
      this.railwayTrafficMode,
      this.service,
      this.ref,
      this.usage,
      this.railwayTrackRef});

  Tags.fromJson(Map<String, dynamic> json) {
    electrified = json['electrified'];
    frequency = json['frequency'];
    gauge = json['gauge'];
    layer = json['layer'];
    maxspeed = json['maxspeed'];
    oneway = json['oneway'];
    operator = json['operator'];
    railway = json['railway'];
    tracks = json['tracks'];
    tunnel = json['tunnel'];
    voltage = json['voltage'];
    owner = json['owner'];
    passengerLines = json['passenger_lines'];
    railwayEtcs = json['railway:etcs'];
    railwayPzb = json['railway:pzb'];
    railwayTrafficMode = json['railway:traffic_mode'];
    service = json['service'];
    ref = json['ref'];
    usage = json['usage'];
    railwayTrackRef = json['railway:track_ref'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['electrified'] = this.electrified;
    data['frequency'] = this.frequency;
    data['gauge'] = this.gauge;
    data['layer'] = this.layer;
    data['maxspeed'] = this.maxspeed;
    data['oneway'] = this.oneway;
    data['operator'] = this.operator;
    data['railway'] = this.railway;
    data['tracks'] = this.tracks;
    data['tunnel'] = this.tunnel;
    data['voltage'] = this.voltage;
    data['owner'] = this.owner;
    data['passenger_lines'] = this.passengerLines;
    data['railway:etcs'] = this.railwayEtcs;
    data['railway:pzb'] = this.railwayPzb;
    data['railway:traffic_mode'] = this.railwayTrafficMode;
    data['service'] = this.service;
    data['ref'] = this.ref;
    data['usage'] = this.usage;
    data['railway:track_ref'] = this.railwayTrackRef;
    return data;
  }
}

Future<Elements> fetchElements(LatLng location) async {
  final coordStr =
      location.latitude.toString() + ',' + location.longitude.toString();
  final response = await http.get(Uri.parse(
      'https://overpass-api.de/api/interpreter?data=[out:json];(node["railway"="rail"](around:5,$coordStr);way["railway"="rail"](around:5,$coordStr);node["railway"="tram"](around:5,$coordStr);way["railway"="tram"](around:5,$coordStr););out geom;'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Elements.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('C\'est l\'erreur');
  }
}
