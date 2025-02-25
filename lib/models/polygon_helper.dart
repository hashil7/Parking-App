import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PolygonData {
  final String name;
  final List<LatLng> points;

  PolygonData({required this.name, required this.points});
}

class PolygonHelper {
  // Define your polygons with names here
  static final List<PolygonData> _polygonDataList = [
    PolygonData(
      name: 'Rajpath Road',
      points: [
          //  LatLng(11.321513736439675, 75.93395624023469),
          //  LatLng(11.321359880468309, 75.9338409052528),
          //  LatLng(11.321258624783919, 75.93375105125529),
          //  LatLng(11.321121863802661, 75.93362766964674),
          //  LatLng(11.320956172526284, 75.93347612484496),
          //  LatLng(11.3208904219932, 75.93340638741404),
          //  LatLng(11.320772070995572, 75.93354988558919),
          //  LatLng(11.32102455306467, 75.93379530770181),
          //  LatLng(11.321232324600281, 75.93397903901017),
          //  LatLng(11.321373030554565, 75.93410242061871),


          const LatLng(11.321483378084169, 75.93396891424509),
          const LatLng(11.321306452335504, 75.93380426567727),
          const LatLng(11.321026034712224, 75.9335284842235),
          const LatLng(11.320814028235777, 75.93333313359038),
          const LatLng(11.320499737644008, 75.93305812541757),
          const LatLng(11.320220781204508, 75.93283432565605),
          const LatLng(11.32004782807786, 75.93269018344132),
          const LatLng(11.320001335284063, 75.93286277477738),
          const LatLng(11.320879117956327, 75.93365935017451),
          const LatLng(11.32113947670583, 75.93390401261793),
          const LatLng(11.321362641163768, 75.93410505308307),

      ]
    ),
    // PolygonData(
    //   name: 'CCC',
    //   points: [
    //     LatLng(11.321459055935234, 75.93372890011145),
    //     LatLng(11.321575755567254, 75.9338810303001),
    //     LatLng(11.321812456848841, 75.9335591652047),
    //     LatLng(11.321671751110609, 75.93343444248022),
    //   ],
    // ),
    PolygonData(
      name: 'CS Dept.',
      points: [
        // LatLng(11.322124957093873, 75.93408438540133),
        // LatLng(11.32247355948798, 75.93445693782247),
        // LatLng(11.322425548408633, 75.93449099975435),
        // LatLng(11.32208529572251, 75.93411631845814),
       
          const LatLng(11.322090664530034, 75.93403833286679),
          const LatLng(11.322191262417626, 75.9341476328787),
          const LatLng(11.322332625407562, 75.9343119181809),
          const LatLng(11.322482535845465, 75.93447754457932),
          const LatLng(11.322445715745188, 75.93450838998146),
          const LatLng(11.322296462790161, 75.93433874026971),
          const LatLng(11.32217679736913, 75.93421133534787),
          const LatLng(11.322057131898049, 75.93408460097822),

      ]
    ),
    PolygonData(
      name: 'Beach Road 1.',
      points: [
         const LatLng(11.264169447010023, 75.7675876527726),
         const LatLng(11.263660248303863, 75.76774562060913),
         const LatLng(11.26308675568571, 75.76793175887941),
         const LatLng(11.262461595765597, 75.76812140920043),
       
          const LatLng(11.262010377564762, 75.76823906264896),
          const LatLng(11.26136282654917, 75.76840764071432),
          const LatLng(11.260760051684015, 75.76855690254689),
          const LatLng(11.260787607133356, 75.76874304080962),
          const LatLng(11.261039050486646, 75.76868684812653),
          const LatLng(11.26162288044817, 75.76854987845965),
          const LatLng(11.262408207377781, 75.76832686373615),
          const LatLng(11.263028200812768, 75.76815652965881),

          const LatLng(11.263569305450435, 75.7679675709319),
          const LatLng(11.263719078457488, 75.76791260826961),
          const LatLng(11.263970953103092, 75.76783616531738),
          const LatLng(11.264236570128606, 75.76773937018238),


      ]
    ),
    PolygonData(
      name: 'Beach Road - Customs Road.',
      points: [
         const LatLng(11.260745693237523, 75.76857873695648),
         const LatLng(11.26034845714269, 75.76869343663826),
         const LatLng(11.26000629464106, 75.76879499364395),
         const LatLng(11.259657100981546, 75.76888699234827),
       
          const LatLng(11.259176046770119, 75.76905387877908),
          const LatLng(11.258736914980954, 75.76920710250046),
          const LatLng(11.258291745432679, 75.76929540151028),
          const LatLng(11.258138902083312, 75.76931604338955),
          const LatLng(11.258154687524796, 75.76947009697383),
          const LatLng(11.258489564192633, 75.76944020597716),
          const LatLng(11.258798507303897, 75.7693585805657),
          const LatLng(11.259132255697198, 75.76923901657621),

          const LatLng(11.259467573752872, 75.76910369661005),
          const LatLng(11.259971685044265, 75.76897672985005),
          const LatLng(11.260625713122689, 75.76879909988011),
          const LatLng(11.260790058025995, 75.7687190846176),


      ]
    ),
    PolygonData(
      name: 'Beach Road - Red Cross Road.',
      points: [
         const LatLng(11.258141165828807, 75.76931422696322),
         const LatLng(11.257871111600858, 75.76935544133359),
         const LatLng(11.257458522941839, 75.76946752492336),
         const LatLng(11.256945890718034, 75.76962324892808),
       
          const LatLng(11.256468224596334, 75.76974385558714),
          const LatLng(11.256114291900891, 75.76982362103296),
          const LatLng(11.255914717338728, 75.7698742057953),
          const LatLng(11.256034393050331, 75.77007670675975),
          const LatLng(11.256531715574727, 75.769902502393),
          const LatLng(11.25683420090878, 75.76982220408127),
          const LatLng(11.257069566496202, 75.76975285554043),
          const LatLng(11.257614575808237, 75.76959955875337),

          const LatLng(11.257973440160283, 75.76949553593305),
          const LatLng(11.258180167302472, 75.76945994918175),



      ]
    ),
    PolygonData(
      name: 'Beach Road - Corporation Road.',
      points: [
         const LatLng(11.255886733324404, 75.76988156775501),
         const LatLng(11.255671979418516, 75.76993909529719),
         const LatLng(11.255477313524286, 75.76999408057993),
         const LatLng(11.255198132764322, 75.77007615023405),
       
          const LatLng(11.254856178128112, 75.77017576797577),
          const LatLng(11.254560613504676, 75.77026133877672),
          const LatLng(11.254257761291692, 75.77035014719421),
          const LatLng(11.254301259208523, 75.77048942301306),
          const LatLng(11.254685752345097, 75.77038020591455),
          const LatLng(11.255113091623308, 75.7702606419368),
          const LatLng(11.255673580993491, 75.77010784948706),
          const LatLng(11.255952511658528, 75.77003032205275),

      ]
    ),
    PolygonData(
      name: 'Beach Road - Corporation Road 2.',
      points: [
         const LatLng(11.254211764637377, 75.77033101386132),
         const LatLng(11.253464664010554, 75.77056436603425),
         const LatLng(11.252968393160723, 75.77071563574651),
         const LatLng(11.252342299218542, 75.77093289466613),
       
          const LatLng(11.252394912207242, 75.77109919161695),
          const LatLng(11.252734252854157, 75.7710160512532),
          const LatLng(11.253068344714439, 75.77093022056891),
          const LatLng(11.253444526436294, 75.77079879233017),
          const LatLng(11.254028527854611, 75.77060835548775),
          const LatLng(11.254315266849963, 75.77053057142996),

      ]
    )
    // Add more polygons as needed
  ];

  static List<Polygon> createPolygons() {
    return _polygonDataList.map((polygonData) => Polygon(
      points: polygonData.points,
      borderColor: Colors.red,
      borderStrokeWidth: 3,
      color: const Color.fromARGB(255, 234, 105, 105).withOpacity(0.2),
      label: polygonData.name, // You can store the name as a label or as metadata
    )).toList();
  }

  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int n = polygon.length;
    bool inside = false;

    double px = point.latitude;
    double py = point.longitude;

    double p1x = polygon[0].latitude;
    double p1y = polygon[0].longitude;
    for (int i = 1; i <= n; i++) {
      double p2x = polygon[i % n].latitude;
      double p2y = polygon[i % n].longitude;
      if (py > p1y && py <= p2y || py > p2y && py <= p1y) {
        if (px <= (p2x - p1x) * (py - p1y) / (p2y - p1y) + p1x) {
          inside = !inside;
        }
      }
      p1x = p2x;
      p1y = p2y;
    }

    return inside;
  }

  static String? getPolygonName(LatLng point) {
    for (PolygonData polygonData in _polygonDataList) {
      if (isPointInPolygon(point, polygonData.points)) {
        return polygonData.name;
      }
    }
    return null; // Return null if the point is not inside any polygon
  }
}