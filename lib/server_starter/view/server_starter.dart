import 'package:flutter/material.dart';

class ServerStarter extends StatelessWidget {
  const ServerStarter({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text('Run server',
                style: Theme.of(context).textTheme.headlineLarge),
            const ServerRunner(),
            const Flexible(
              child: ServerLogDisplay(),
            ),
          ],
        ),
      ),
    );
  }
}

class ServerRunner extends StatelessWidget {
  const ServerRunner({super.key});

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
                onPressed: () {},
                child: const Text('Run'),
              ),
              SizedBox(width: 16),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.orange.shade900.withAlpha(30),
                  foregroundColor: Colors.orange.shade500,
                ),
                onPressed: () {},
                child: const Text('Reload'),
              ),
              SizedBox(width: 16),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade900.withAlpha(30),
                  foregroundColor: Colors.red.shade500,
                ),
                onPressed: null,
                child: const Text('Stop'),
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
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16),
      child: SelectionArea(
        child: ListView(
          children: [
            const Text('Server log'),
            const Text('Server log'),
            const Text(
              'Server log, Server log, Server log, Server log, Server log',
            ),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text('Server log'),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
            const Text('Server log'),
            const Text(
              'Server log',
            ),
            const Text(
                'Server log, Server log, Server log, Server log, Server log'),
          ],
        ),
      ),
    );
  }
}
