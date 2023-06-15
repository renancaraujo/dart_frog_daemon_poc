import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dfdaemonclient/daemon_client/view/protocol.dart';
import 'package:flutter/material.dart';

class DaemonClientProvider extends StatefulWidget {
  const DaemonClientProvider({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<DaemonClientProvider> createState() => _DaemonClientProviderState();
}

class _DaemonClientProviderState extends State<DaemonClientProvider> {
  final client = DartFrogDaemonClient();

  late Future<void> _future;

  @override
  void initState() {
    super.initState();

    _future = client.start();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _DaemonClientInheritedWidget(
            client: client,
            child: widget.child,
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class _DaemonClientInheritedWidget extends InheritedWidget {
  const _DaemonClientInheritedWidget({
    super.key,
    required super.child,
    required this.client,
  });

  final DartFrogDaemonClient client;

  @override
  bool updateShouldNotify(_DaemonClientInheritedWidget old) {
    return false;
  }
}

class DartFrogDaemonClient {
  Process? process;

  int _counter = 0;

  String get _requestId => '${_counter++}';

  static DartFrogDaemonClient of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<_DaemonClientInheritedWidget>();
    assert(result != null, 'No DaemonClientInheritedWidget found in context');
    return result!.client;
  }

  Future<void> start() async {
    final process = this.process = await Process.start('dart_frog', ['daemon']);
    process.stdout.transform(utf8.decoder).listen((ev) {
      ev.split('\n').where((element) => element.isNotEmpty).forEach((event) {
        try {
          print('out: ${event}');
          // todo: this is a hack, fix this please
          final json = jsonDecode(event);

          _outputStreamController.add(DaemonMessage.fromJson(json));
        } catch (e) {
          // todo: handle invalid json
          print('ops');
          rethrow;
        }
      });
    });

    _inputStreamController.stream.listen((message) {
      try {
        final json = jsonEncode(message.toJson());
        print('in: [${json}]');

        process.stdin.add(utf8.encode('[${json}]\n'));
      } catch (e) {
        print('ops: ${message}');
      }
    });
  }

  late final StreamController<DaemonMessage> _inputStreamController =
      StreamController<DaemonMessage>();

  late final StreamController<DaemonMessage> _outputStreamController =
      StreamController<DaemonMessage>.broadcast();

  Stream<DaemonResponse> get responses => _outputStreamController.stream
      .where((event) => event is DaemonResponse)
      .cast<DaemonResponse>();

  Stream<DaemonEvent> get events => _outputStreamController.stream
      .where((event) => event is DaemonEvent)
      .cast<DaemonEvent>();

  Future<DaemonResponse> sendRequest(
    DaemonRequest Function(String id) requestBuilder,
  ) {
    final completer = Completer<DaemonResponse>();
    final request = requestBuilder(_requestId);
    final callId = request.id;
    _inputStreamController.add(request);
    responses
        .firstWhere((element) => element.id == callId)
        .then((value) => completer.complete(value));

    return completer.future;
  }
}
