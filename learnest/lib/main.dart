import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'node_model.dart';
import 'package:url_launcher/url_launcher.dart';

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

  List<Resource> resourceList = [];

  @override
  void initState(){
    super.initState();

    getResource();
  }

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Centers children vertically
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Pending Resource',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      color: const Color(0xFF79cadb),
                    ),
                  ),
                  if (resourceList.isEmpty)
                    const Center(
                      child: Text(
                        "No Resource yet",
                        style: TextStyle(color: Color(0xFF79cadb), fontSize: 20),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: resourceList.length,
                        itemBuilder: (context, index) {
                          final resource = resourceList[index];
                          return 
                            LayoutBuilder(
                              builder: (context, constraints) => Draggable(
                                data: resource,
                                feedback: SizedBox(
                                  // use LayoutBuilder to set the width to be the same as child
                                  // avoid using GlobalKey for dynamic list because it may be inefficient 
                                  width: constraints.maxWidth,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Card(
                                      // Child widget inside Row or Column widget often requires proper height and width definition
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          // Use Flexible so that the width and height of ListTile can be automatically determined
                                          // https://openhome.cc/Gossip/Flutter/Expanded.html
                                          Flexible(
                                            child: ListTile(
                                              title: Text("Title"),
                                              subtitle: Text("Youtube"),
                                              trailing: RichText(
                                                text: TextSpan(
                                                  text: 'link',
                                                  style: const TextStyle(color: Colors.blue),
                                                  recognizer: TapGestureRecognizer()
                                                    ..onTap = () {
                                                      launchUrl(Uri.parse(resource.url));
                                                    } 
                                                )
                                              )
                                            ),
                                          ),
                                          
                                        ]
                                      ),
                                    ),
                                  ),
                                ), 
                                
                                child: Card(
                                  // Child widget inside Row or Column widget often requires proper height and width definition
                                  child: Row(
                                    children: <Widget>[
                                      // Use Flexible so that the width and height of ListTile can be automatically determined
                                      // https://openhome.cc/Gossip/Flutter/Expanded.html
                                      Flexible(
                                        child: ListTile(
                                          title: Text("Title"),
                                          subtitle: Text("Youtube"),
                                          trailing: RichText(
                                            text: TextSpan(
                                              text: 'link',
                                              style: const TextStyle(color: Colors.blue),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  launchUrl(Uri.parse(resource.url));
                                                } 
                                            )
                                          )
                                        ),
                                      ),
                                      
                                    ]
                                    ),
                                ),
                                
                              )
                              
                            );
                             
                        },
                      ),
                    ),
                  DragTarget(
                    builder: buildTarget
                  ),
                ],
              )
            ),  
          ),
        ],
      ),
    );
  }

  Widget buildTarget(context, candidateData, rejecteData) => Container(
    width: 40.0,
    height: 40.0,
    decoration: BoxDecoration(color: const Color(0xFF79cadb), shape: BoxShape.circle),
  );

  getResource() async {
    final snapshot = await FirebaseFirestore.instance.collection("users").get();

    resourceList.clear();
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      // adapt to your schema; here we read the pendingResource array
      resourceList.addAll(Resource.fromPendingList(data["pendingResource"] as List<dynamic>?));
    }

    setState(() {});
  }
}