import 'package:feather/feather.dart';
import 'package:flutter/material.dart';

Widget imageOrPlaceholder(BuildContext context, Map event) {
  final String photo = getIn(event, ['featured_photo', 'photo_link']);

  return new AspectRatio(
      //TODO get from app OR state. what happens if landscape?
      aspectRatio: 16.0 / 9.0,
      child: ifVal(
          photo,
          (_) => Image.network(
                photo,
                fit: BoxFit.cover,
              ),
          (_) => Container(
              color: Colors.grey.withOpacity(0.3),
              child: new Icon(
                Icons.image,
                size: 44.0,
              ))));
}
