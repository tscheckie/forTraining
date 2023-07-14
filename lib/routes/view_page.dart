import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:four_training/widgets/loading_animation.dart';
import 'package:four_training/widgets/main_drawer.dart';
import 'package:four_training/data/globals.dart';
import 'package:four_training/widgets/settings_button.dart';

/// The standard view of this app:
/// Show a page (worksheet)
class ViewPage extends StatefulWidget {
  const ViewPage({super.key});
  @override
  State<ViewPage> createState() => _ViewPageState();
}

/// Scrollable display of HTML content, filling most of the screen.
/// Uses the flutter_html package.
class MainHtmlView extends StatelessWidget {
  /// HTML code to display
  final String content;
  const MainHtmlView(this.content, {super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        Html(
          data: content,
          onAnchorTap: (url, _, __) {
            debugPrint("Link tapped: $url");
            if (url != null) {
              int? newIndex = currentLanguage!.getIndexByTitle(url);
              if (newIndex != null) {
                currentIndex = newIndex;
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const ViewPage()));
              } else {
                debugPrint("TODO Error couldn't find link destination");
              }
            }
          },
        )
      ],
    ));
  }
}

class _ViewPageState extends State<ViewPage> {
  static const title = "4training";
  late Future<dynamic> _htmlData;

  @override
  void initState() {
    super.initState();
    _htmlData = currentLanguage!.getPageContent(currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(title),
            actions: [settingsButton(context)],
          ),
          drawer: const MainDrawer(),
          body: FutureBuilder(
            future: _htmlData,
            initialData: "Loading",
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              debugPrint(snapshot.connectionState.toString());

              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return loadingAnimation(
                      "Loading content\nState: ${snapshot.connectionState}");
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Text(
                        "Couldn't find the content you are looking for.\nLanguage: ${currentLanguage?.languageCode}");
                  } else if (snapshot.hasData) {
                    return MainHtmlView(snapshot.data);
                  } else {
                    return loadingAnimation("Empty Data");
                  }
                default:
                  return Text("State: ${snapshot.connectionState}");
              }
            },
          ),
        ));
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
