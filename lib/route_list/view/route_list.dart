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

    response = Future.delayed(Duration(seconds: 1), () {
      return client.sendRequest(
        DaemonRequest(
          id: '${counter++}',
          method: 'routeConfig.monitorStart',
          params: {
            'workingDirectory':
                '/Users/renanaraujo/devhome/vgv/dart_frog/examples/todos',
          },
        ),
      );
    });
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
      DaemonRequest(
        id: '60',
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
        Flexible(
          child: StreamBuilder(
            stream: analyzeEvents,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final event = snapshot.data as DaemonEvent;
                final routeConfigRaw = event.params['routeConfiguration']
                    as Map<String, dynamic>;

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
