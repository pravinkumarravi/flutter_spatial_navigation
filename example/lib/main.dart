import 'package:flutter/material.dart';
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';

void main() => runApp(const MaterialApp(home: HomePage()));

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusTraversalGroup(
        policy: TVSpatialTraversalPolicy(),
        child: ListView(
          children: [
            for (var row = 0; row < 5; row++)
              TVFocusGroup(
                child: SizedBox(
                  height: 200,
                  child: TVLazyList(
                    itemCount: 1000,
                    itemExtent: 180,
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    itemBuilder: (context, i, focused) => AnimatedScale(
                      scale: focused ? 1.08 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.primaries[i % Colors.primaries.length],
                          border: focused
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                        child: Center(child: Text('$row · $i')),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}