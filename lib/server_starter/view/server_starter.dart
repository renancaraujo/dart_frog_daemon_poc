import 'dart:collection';

import 'package:dfdaemonclient/daemon_client/daemon_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:rxdart/rxdart.dart';

class ServerStarter extends StatefulWidget {
  const ServerStarter({super.key});

  @override
  State<ServerStarter> createState() => _ServerStarterState();
}

class _ServerStarterState extends State<ServerStarter> {
  String? applicationId;

  ReplaySubject<List<DaemonEvent>>? eventsSubject;

  final eventsQueue = Queue<DaemonEvent>();

  @override
  void didChangeDependencies() {
    DartFrogDaemonClient.of(context).events.where((event) {
      return event.event == 'applicationExit';
    }).listen((event) {
      if(event.params['applicationId'] == applicationId){
        handleApplicationStop();
      }

    });
  }

  Stream<List<DaemonEvent>> serverEvents(String applicationId) async* {
    await for (final event in DartFrogDaemonClient.of(context).events) {
      if (event.params['applicationId'] == applicationId) {
        eventsQueue.addLast(event);
        if (eventsQueue.length > 400) {
          eventsQueue.removeFirst();
        }
        yield eventsQueue.toList();
      }
    }
  }

  void handleApplicationStart(String id) {
    eventsQueue.clear();
    eventsSubject = ReplaySubject();

    eventsSubject!.addStream(serverEvents(id));
    setState(() {
      applicationId = id;
    });
  }

  void handleApplicationStop() {
    setState(() {
      applicationId = null;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Run server',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            ServerRunner(
              applicationId: applicationId,
              client: client,
              onApplicationStart: handleApplicationStart,
              onApplicationStop: handleApplicationStop,
              onClearLogs: () {
                setState(() {
                  eventsQueue.clear();
                  eventsSubject = null;
                });
              },
            ),
            Flexible(
              child: ServerLogDisplay(
                events: eventsSubject?.stream,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ServerRunner extends StatefulWidget {
  const ServerRunner({
    super.key,
    required this.client,
    required this.applicationId,
    required this.onApplicationStart,
    required this.onApplicationStop, required this.onClearLogs,
  });

  final DartFrogDaemonClient client;
  final String? applicationId;
  final ValueChanged<String> onApplicationStart;
  final VoidCallback onApplicationStop;
  final VoidCallback onClearLogs;

  @override
  State<ServerRunner> createState() => _ServerRunnerState();
}

class _ServerRunnerState extends State<ServerRunner> {
  void handleRun() async {
    if (widget.applicationId != null) {
      return;
    }

    final port = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter port'),
          content: TextField(
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              Navigator.of(context).pop(value);
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        );
      },
    );

    late String requestId;
    final responseFuture = widget.client.sendRequest(
      (id) {
        requestId = id;
        return DaemonRequest(
          id: id,
          method: 'application.start',
          params: {
            'port': port,
            'workingDirectory':
                '/Users/renanaraujo/devhome/vgv/dart_frog/examples/todos',
          },
        );
      },
    );

    widget.client.events.where((event) {
      return event.event == 'applicationStarting' &&
          event.params['requestId'] == requestId;
    }).listen((event) {
      widget.onApplicationStart(event.params['applicationId'] as String);
    });

    final response = await responseFuture;

    if (!response.isSuccess) {
      widget.onApplicationStop();
    }
  }

  void handleStop() async {
    if (widget.applicationId == null) {
      return;
    }
    final response = await widget.client.sendRequest((id) {
      return DaemonRequest(
        id: id,
        method: 'application.stop',
        params: {
          'applicationId': widget.applicationId!,
        },
      );
    });

    if (response.isSuccess) {
      widget.onApplicationStop();
    }
  }


  void handleReload() async {
    if (widget.applicationId == null) {
      return;
    }

    await widget.client.sendRequest((id) {
      return DaemonRequest(
        id: id,
        method: 'application.reload',
        params: {
          'applicationId': widget.applicationId!,
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
                  backgroundColor: Colors.green.shade900.withAlpha(30),
                  foregroundColor: Colors.green.shade500,
                ),
                onPressed: widget.applicationId == null ? handleRun : null,
                child: const Text('Run'),
              ),
              const SizedBox(width: 16),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange.shade900.withAlpha(30),
                  foregroundColor: Colors.orange.shade500,
                ),
                onPressed: widget.applicationId == null ? null : handleReload,
                child: const Text('Reload'),
              ),
              const SizedBox(width: 16),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade900.withAlpha(30),
                  foregroundColor: Colors.red.shade500,
                ),
                onPressed: widget.applicationId == null
                    ? null
                    : handleStop,
                child: const Text('Stop'),
              ),
              const SizedBox(width: 16),
              TextButton(
                style: TextButton.styleFrom(

                  foregroundColor: Colors.white,
                ),
                onPressed: widget.onClearLogs,
                child: const Text('Clear logs'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServerLogDisplay extends StatelessWidget {
  const ServerLogDisplay({
    super.key,
    required this.events,
  });

  final Stream<List<DaemonEvent>>? events;

  @override
  Widget build(BuildContext context) {
    final events = this.events;
    if (events == null) {
      return const Center(
        child: Text('No application running'),
      );
    }

    return ServerLogBuffer(
      events: events,
    );
  }
}

class ServerLogBuffer extends StatefulWidget {
  const ServerLogBuffer({
    super.key,
    required this.events,
  });

  final Stream<List<DaemonEvent>> events;

  @override
  State<ServerLogBuffer> createState() => _ServerLogBufferState();
}

class _ServerLogBufferState extends State<ServerLogBuffer> {

  final  _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ServerLogBuffer oldWidget) {

    super.didUpdateWidget(oldWidget);


  }

  void scrollToEnd(){

    if(!_scrollController.hasClients){
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.events,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        WidgetsBinding.instance!.addPostFrameCallback((_) => scrollToEnd());

        return Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16),
          child: SelectionArea(
            child: ListView(
              controller: _scrollController,
              children: [
                for (final event in snapshot.data!) LogEntry(event: event)
              ],
            ),
          ),
        );
      },
    );
  }
}

class LogEntry extends StatelessWidget {
  const LogEntry({
    super.key,
    required this.event,
  });

  final DaemonEvent event;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle;
    final eventName = event.event;
    switch (eventName) {
      case 'loggerAlert':
        textStyle = TextStyle(
          color: Colors.white,
          backgroundColor: Colors.red,
          fontWeight: FontWeight.bold,
        );
      case 'loggerError':
        textStyle = TextStyle(color: Colors.red);
      case 'loggerWarning':
        textStyle = TextStyle(
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
        );
      case 'loggerDetail':
        textStyle = TextStyle(color: Colors.grey.shade600);
      case 'loggerSuccess':
        textStyle = TextStyle(color: Colors.green);
      default:
        textStyle = TextStyle(color: Colors.white);
    }

    return Text(
      event.params['message'] as String? ?? '',
      style: textStyle,
    );
  }
}
