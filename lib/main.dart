import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_mobile/ui/login.dart';
import 'package:sail_mobile/ui/tab.dart';
import 'package:sail_mobile/utils/auth.dart';
import 'package:sail_mobile/utils/db.dart';


void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    Future<bool> isReadyToStart() async {
        return (await hasAuth() && await hasPlanData());
    }

    // This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return MaterialApp(
            title: 'SailLogistics',
            theme: ThemeData(primarySwatch: Colors.blue),
            home: FutureBuilder<bool>(
                future: isReadyToStart(),
                builder: (buildContext, futureData) {
                    // Check if the future is complete.
                    if(futureData.hasData) {
                        // Check if the future's result is true.
                        if(futureData.data == true){
                            // Return your login here
                            return const TabPage();
                        }
                        // Return the start page here.
                        return const LoginScreen();
                    } else {
                        // Return loading screen while reading preferences
                        return const Center(child: CircularProgressIndicator());
                    }
                },
            )
        );
    }
}
