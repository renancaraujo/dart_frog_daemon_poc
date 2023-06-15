import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dfdaemonclient/daemon_client/daemon_client.dart';
import 'package:dfdaemonclient/daemon_client/view/protocol.dart';
import 'package:flutter/material.dart';

class RouteList extends StatefulWidget {
  const RouteList({super.key});

  @override
  State<RouteList> createState() => _RouteListState();
}

class _RouteListState extends State<RouteList> {
  int counter = 0;

  late Future<DaemonResponse> response;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final client = DartFrogDaemonClient.of(context);

    response = Future.delayed(
      Duration(seconds: 1),
      () {
        return client.sendRequest(
          (id) => DaemonRequest(
            id: id,
            method: 'routeConfig.monitorStart',
            params: {
              'workingDirectory':
                  '/Users/renanaraujo/devhome/vgv/dart_frog/examples/todos',
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final client = DartFrogDaemonClient.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: FutureBuilder<DaemonResponse>(
            future: response,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final response = snapshot.data!;
                if (response.isSuccess) {
                  final analyzerId = response.result!['monitorId'] as String;
                  return RouteListInner(
                    events: client.events,
                    analyzerId: analyzerId,
                  );
                } else {
                  return Text('Error: ${response.error}');
                }
              } else {
                return const Text('Starting route monitor...');
              }
            },
          ),
        ),
      ),
    );
  }
}

class RouteListInner extends StatefulWidget {
  const RouteListInner({
    super.key,
    required this.events,
    required this.analyzerId,
  });

  final Stream<DaemonEvent> events;
  final String analyzerId;

  @override
  State<RouteListInner> createState() => _RouteListInnerState();
}

class _RouteListInnerState extends State<RouteListInner> {
  Stream<DaemonEvent> get analyzeEvents {
    return widget.events.where(
      (event) => event.event == 'routeConfigurationChanged',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    DartFrogDaemonClient.of(context).sendRequest(
      (id) => DaemonRequest(
        id: id,
        method: 'routeConfig.monitorRegenerateRouteConfig',
        params: {
          'monitorId': widget.analyzerId,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Routes', style: Theme.of(context).textTheme.headlineLarge),
        AddStuffBar(),
        Flexible(
          child: StreamBuilder(
            stream: analyzeEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final event = snapshot.data as DaemonEvent;
                final routeConfigRaw =
                    event.params['routeConfiguration'] as Map<String, dynamic>;

                final endpoints =
                    routeConfigRaw['endpoints'] as Map<String, dynamic>;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListView.builder(
                    itemCount: endpoints.length,
                    itemBuilder: (context, index) {
                      final endpoint = endpoints.keys.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          endpoint,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Center(
                  child: Text('Loading routes...'),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}

class AddStuffBar extends StatefulWidget {
  const AddStuffBar({
    super.key,
  });

  @override
  State<AddStuffBar> createState() => _AddStuffBarState();
}

class _AddStuffBarState extends State<AddStuffBar> {
  void handleAddRoute() async {

    final routePath = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter new route path'),
          content: TextField(
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        );
      },
    );

    if(routePath == null || routePath.isEmpty) {
      return;
    }

    DartFrogDaemonClient.of(context).sendRequest((id) {
      return DaemonRequest(
        id: id,
        method: 'routeConfig.newRoute',
        params: {
          'routePath': routePath,
          'workingDirectory':
              '/Users/renanaraujo/devhome/vgv/dart_frog/examples/todos',
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButtonTheme(
      data: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange.shade50.withAlpha(65),
                ),
                onPressed: handleAddRoute,
                child: const Text('Add route'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
