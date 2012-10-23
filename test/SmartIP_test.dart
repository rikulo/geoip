import 'package:rikulo_geoip/rikulo_geoip.dart';

void main() {

  smartip.loadIPGeoInfo()
    .then((Map result) {print("-----------1"); print(result);});

  smartip.loadIPGeoInfo()
    .then((Map result) {print("-----------2"); print(result);});
}
