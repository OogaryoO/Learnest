import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
              width: double.infinity,
              margin: const EdgeInsets.all(40), // Ensures the container takes the full width
              padding: const EdgeInsets.all(30), 
              child: Text(
                // 12/26 to get data from firebase: https://medium.com/@abdulAwalArif/fetching-a-list-of-data-from-firebase-cloud-firestore-with-flutter-6017f6bec815
                'Pending Resource',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: const Color(0xFF79cadb),
                ),
              ),
            ),            
          ),
        ],
      ),
    );
  }
}