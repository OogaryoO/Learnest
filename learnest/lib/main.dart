import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'Page View',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const PageViewCustom(),
      ),
    );
  }
}

class PageViewCustom extends StatefulWidget {
  const PageViewCustom({Key? key}) : super(key: key);

  @override
  State<PageViewCustom> createState() => _PageViewCustomState();
}

class _PageViewCustomState extends State<PageViewCustom> {
  final _pageController = PageController(
    initialPage: 2,
    viewportFraction: 1,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal, // or Axis.vertical
        children: [
          Container(
            color: Colors.white,
            child: const Center(
              child: Text(
                'RED PAGE',
                style: TextStyle(
                  fontSize: 45,
                  color: const Color(0xFF79cadb),
                ),
              ),
            ),
          ),
          Container(
            color: const Color(0xFF79cadb),
            child: const Center(
              child: Text(
                'BLUE PAGE',
                style: TextStyle(
                  fontSize: 45,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: Container(
              alignment: Alignment.topCenter,
              width: double.infinity, // Ensures the container takes the full width
              child: Text(
                'Top Center Text',
                textAlign: TextAlign.center,
              ),
            ),            
          ),
        ],
      ),
    );
  }
}