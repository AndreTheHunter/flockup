import 'dart:async';

import 'package:feather/feather.dart';
import 'package:flockup/actions.dart';
import 'package:flockup/event_details.dart';
import 'package:flockup/ui.dart';
import 'package:flutter/material.dart';

void main() => runApp(new FlockupApp());

class FlockupApp extends StatelessWidget {
  final AppDbStream stateStream = new AppDbStream(AppDb.onUpdate);

  @override
  Widget build(BuildContext context) {
    var appDb = AppDb.init({}).store;
    AppDb.dispatch((Map store) => {'title': 'Flockup'});
    fetchEvents();
    return new MaterialApp(
        title: get(appDb, 'title'),
        theme: new ThemeData(primarySwatch: Colors.red),
        home: new StreamBuilder<Map>(
            stream: stateStream,
            initialData: appDb,
            builder: (context, snapshot) => buildHome(context, snapshot.data)));
  }
}

Widget buildHome(BuildContext context, Map appDb) {
  final List<Map> events = asMaps(get(appDb, 'events', []));
  return Scaffold(
      appBar: AppBar(title: new Text(get(appDb, 'title', ''))),
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[new EventListWidget(events)])));
}

class EventListWidget extends StatelessWidget {
  final List<Map> events;
  final ScrollController scrollController;

  EventListWidget(this.events) : scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return events.length == 0
        ? new CircularProgressIndicator(value: null)
        : new Expanded(
            child: new RefreshIndicator(
                child: new ListView.builder(
                    itemCount: events.length,
                    controller: scrollController,
                    itemBuilder: (BuildContext context, int itemIndex) {
                      if (itemIndex <= events.length) {
                        return buildEventListItem(context, events[itemIndex]);
                      }
                    }),
                //TODO use loading from RefreshIndicator
                onRefresh: () => new Future<Null>(refresh)));
  }
}

Null refresh() {
  fetchEvents();
  return null;
}

Widget buildEventListItem(BuildContext context, Map event) {
  final String time = get(event, 'local_time', '');
  final bool isPublic = get(event, 'visibility') == 'public';
  final IconData visibilityIcon = isPublic ? Icons.lock_open : Icons.lock;
  final TextTheme theme = Theme.of(context).accentTextTheme;

  final String group = getIn(event, ['group', 'name'], '');
  final String name = get(event, 'name', '');

  Widget inkwellIfPublic(Widget child) {
    if (!isPublic) {
      return child;
    }
    return new InkWell(
      onTap: () => navTo(context, new EventDetails(event)),
      child: child,
    );
  }

  var header = new Container(
      decoration: new BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Text(
                  name,
                  style: theme.body2,
                  overflow: TextOverflow.ellipsis,
                ),
                new Padding(padding: const EdgeInsets.symmetric(vertical: 4.0)),
                new Text(
                  group,
                  style: theme.body1,
                  overflow: TextOverflow.ellipsis,
                )
              ])));

  var footer = new Container(
      decoration: new BoxDecoration(color: Colors.black.withOpacity(0.6)),
      child: new Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: nonNullWidgets([
                Icon(
                  visibilityIcon,
                  color: theme.body2?.color,
                  size: theme.body2?.fontSize,
                ),
                Expanded(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                      Text(
                        time,
                        style: theme.body2,
                      )
                    ]))
              ]))));
  return new Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: inkwellIfPublic(Column(children: <Widget>[
        header,
        imageOrPlaceholder(context, event),
        footer,
      ])));
}
