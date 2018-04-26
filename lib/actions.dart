import 'dart:convert' show json;

import 'package:feather/feather.dart';
import 'package:flockup/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String EVENTS_URL = "https://api.meetup.com/find/upcoming_events";

void fetchEvents() {
  final String url = EVENTS_URL +
      mapToQueryParam({
        "fields": "featured_photo,plain_text_description",
        "key": MEETUP_API_KEY,
        //TODO get coordinates from GPS
        "lat": -19.26639,
        "lon": 146.80569,
        "radius": "smart",
        "sign": "true",
      });
  http.get(url).then((response) {
    var body = json.decode(response.body);
    var events = get(body, 'events');
    AppDb.dispatch((Map store) => merge(store, {"events": events}));
  });
}

String mapToQueryParam(Map<String, Object> params) {
  return "?" + params.entries.map((e) => '${e.key}=${e.value}').join("&");
}

void navTo(context, view) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => view));
}
