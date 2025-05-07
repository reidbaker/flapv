import 'package:flutter/material.dart';

import 'platform_view_holder.dart';
import 'platform_view_type.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // TODO kick off hcpp state fetch early.


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Android Platform View Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          },
        ),
      ),
      home: const StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('APV Debug Demo')),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
                child: const Text('Basic'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlatformViewHolder(
                            viewType: PlatformViewType.kBasic)),
                  );
                }),
            ElevatedButton(
                child: const Text('Input'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlatformViewHolder(
                            viewType: PlatformViewType.kInput)),
                  );
                }),
            ElevatedButton(
                child: const Text('Input (Flutter)'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlatformViewHolder(
                            viewType: PlatformViewType.kInputPureFlutter)),
                  );
                }),
            ElevatedButton(
              child: const Text('Animated Surface View'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PlatformViewHolder(
                          viewType: PlatformViewType.kAnimatedSurfaceView)),
                );
              },
            ),
            ElevatedButton(
              child: const Text('HCPP'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PlatformViewHolder(
                          viewType: PlatformViewType.kHcpp)),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Gen4'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PlatformViewHolder(
                          viewType: PlatformViewType.kGen4)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
