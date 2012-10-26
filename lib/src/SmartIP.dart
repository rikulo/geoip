//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Wed, Jun 20, 2012  05:22:36 PM
// Author: hernichen

/** Singleton SmartIP service */
SmartIP smartip = new SmartIP._internal();

/**
 * Bridge Dart to Smart-IP.net Geo IP API; see <http://smart-ip.net/geoip-api>
 *  for details. Retrieve Geo IP information per the provided host/IP address.
 */
class SmartIP {
  const String _BASE_URI = "http://smart-ip.net/geoip-json?";
  const String _GEO_IP = "geoip";
  static int _fnnum = 0;

  factory SmartIP() => smartip;

  SmartIP._internal() {}

  /** Load geo information per the specified host/IP in a Map via
   * returned Future.then((Map result) {...}) method.
   *
   * + [host] the IP address or host name to look for geo information; default
   * to the IP of the calling client. See section "Building Queries" of
   * <http://smart-ip.net/geoip-api> for details.
   * + [type] network type; default to "auto". Meaning for if host is a name.
   * See section "Building Queries" of <http://smart-ip.net/geoip-api> for
   * details.
   * + [lang] language of a query; default to auto-detection. See section
   * "Building Queries" of <http://smart-ip.net/geoip-api> for details.
   */
  Future<Map> loadIPGeoInfo({String host, String type, String lang}) {
    StringBuffer params = new StringBuffer();
    _fnnum = ++_fnnum & 0xffffffff;
    String nm = "${_GEO_IP}${_fnnum}";
    params.add("callback=${nm}");
    if (host != null && !host.isEmpty()) {
      params.add("&host=").add(host);
    }
    if (type != null && !type.isEmpty()) {
      params.add("&type=").add(type);
    }
    if (lang != null && !lang.isEmpty()) {
      params.add("&lang=").add(lang);
    }
    //JSONP
    String url = "${_BASE_URI}${params}";
    Completer cmpl = new Completer();
    js.scoped(() {
      js.context['$nm'] =
          new js.Callback.once((jsmap) {
            try {
              cmpl.complete(_toDartMap(jsmap));
            } finally {
              JSUtil.removeJavaScriptSrc(url);
            }
          });
    });
    JSUtil.injectJavaScriptSrc(url);
    return cmpl.future;
  }

  Map _toDartMap(var jsmap) {
    String json = js.context.JSON.stringify(jsmap);
    return JSON.parse(json);
  }
}