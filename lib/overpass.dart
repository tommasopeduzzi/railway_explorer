// auto-generated response classes. generated with tool: https://javiercbk.github.io/json_to_dart/

class Response {
  double? version;
  String? generator;
  Osm3s? osm3s;
  List<Elements>? elements;

  Response({version, generator, osm3s, elements});

  Response.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    generator = json['generator'];
    osm3s = json['osm3s'] != null ? Osm3s.fromJson(json['osm3s']) : null;
    if (json['elements'] != null) {
      elements = <Elements>[];
      json['elements'].forEach((v) {
        elements!.add(Elements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version'] = version;
    data['generator'] = generator;
    if (osm3s != null) {
      data['osm3s'] = osm3s!.toJson();
    }
    if (elements != null) {
      data['elements'] = elements!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Osm3s {
  String? timestampOsmBase;
  String? copyright;

  Osm3s({timestampOsmBase, copyright});

  Osm3s.fromJson(Map<String, dynamic> json) {
    timestampOsmBase = json['timestamp_osm_base'];
    copyright = json['copyright'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['timestamp_osm_base'] = timestampOsmBase;
    data['copyright'] = copyright;
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

  Elements({type, id, bounds, nodes, geometry, tags});

  Elements.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    bounds = json['bounds'] != null ? Bounds.fromJson(json['bounds']) : null;
    if (json['nodes'] != null) {
      nodes = json['nodes'].cast<int>();
    }
    if (json['geometry'] != null) {
      geometry = <Geometry>[];
      json['geometry'].forEach((v) {
        geometry!.add(Geometry.fromJson(v));
      });
    }
    tags = json['tags'] != null ? Tags.fromJson(json['tags']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['id'] = id;
    if (bounds != null) {
      data['bounds'] = bounds!.toJson();
    }
    data['nodes'] = nodes;
    if (geometry != null) {
      data['geometry'] = geometry!.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags!.toJson();
    }
    return data;
  }
}

class Bounds {
  double? minlat;
  double? minlon;
  double? maxlat;
  double? maxlon;

  Bounds({minlat, minlon, maxlat, maxlon});

  Bounds.fromJson(Map<String, dynamic> json) {
    minlat = json['minlat'];
    minlon = json['minlon'];
    maxlat = json['maxlat'];
    maxlon = json['maxlon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['minlat'] = minlat;
    data['minlon'] = minlon;
    data['maxlat'] = maxlat;
    data['maxlon'] = maxlon;
    return data;
  }
}

class Geometry {
  double? lat;
  double? lon;

  Geometry({lat, lon});

  Geometry.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lon'] = lon;
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
      {electrified,
      frequency,
      gauge,
      layer,
      maxspeed,
      oneway,
      operator,
      railway,
      tracks,
      tunnel,
      voltage,
      owner,
      passengerLines,
      railwayEtcs,
      railwayPzb,
      railwayTrafficMode,
      service,
      ref,
      usage,
      railwayTrackRef});

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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['electrified'] = electrified;
    data['frequency'] = frequency;
    data['gauge'] = gauge;
    data['layer'] = layer;
    data['maxspeed'] = maxspeed;
    data['oneway'] = oneway;
    data['operator'] = operator;
    data['railway'] = railway;
    data['tracks'] = tracks;
    data['tunnel'] = tunnel;
    data['voltage'] = voltage;
    data['owner'] = owner;
    data['passenger_lines'] = passengerLines;
    data['railway:etcs'] = railwayEtcs;
    data['railway:pzb'] = railwayPzb;
    data['railway:traffic_mode'] = railwayTrafficMode;
    data['service'] = service;
    data['ref'] = ref;
    data['usage'] = usage;
    data['railway:track_ref'] = railwayTrackRef;
    return data;
  }
}
