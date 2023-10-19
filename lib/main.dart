import 'package:flutter/material.dart';

import 'flutter_image/creative_stitching_view.dart' as flutter_image;
import 'image_image/creative_stitching_view.dart' as image_image;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      routes: {
        'image_image': (context) => const image_image.CreativeStitchingView(),
        'flutter_image': (context) => const flutter_image.CreativeStitchingView(),
      },
      home: const CreativeStitchingChoose(),
    );
  }
}

class CreativeStitchingChoose extends StatelessWidget {
  const CreativeStitchingChoose({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: ['image_image', 'flutter_image'].map((e) {
          return Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.maybeOf(context)?.pushNamed(e);
                },
                child: Text(e.toUpperCase()),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
