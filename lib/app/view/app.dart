import 'package:dfdaemonclient/route_list/route_list.dart';
import 'package:dfdaemonclient/server_starter/server_starter.dart';
import 'package:flutter/material.dart';

import '../../daemon_client/view/daemon_client.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orange,
        ),
      ),
      home: const Scaffold(
        body: DaemonClientProvider(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.symmetric( horizontal: 8),
                    child: RouteList(),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: ServerStarter(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
