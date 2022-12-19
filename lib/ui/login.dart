import 'dart:convert';

import 'package:sail_mobile/ui/selection.dart';
import 'package:sail_mobile/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sail_mobile/utils/auth.dart';
import 'package:sail_mobile/utils/db.dart';
import 'package:sail_mobile/utils/ui_popups.dart';

// The stateful widget.
class LoginScreen extends StatefulWidget {
	const LoginScreen({Key? key}) : super(key: key);

	@override
	LoginScreenState createState() => LoginScreenState();
}

// The state.
class LoginScreenState extends State<LoginScreen> {

	// Input controllers for login.
	TextEditingController nameController = TextEditingController();
	TextEditingController passwordController = TextEditingController();

	// Function used to advance to the next screen.
	void makeRequest() async {
		// Obtain the username.
		var username = nameController.text;
		// Obtain the password.
		var password = passwordController.text;
		// Show a loading screen.
		showLoadingIcon(context);
		// Obtain the login and send it to the server.
		executeLogin(username, password).then((response) {
			// Remove the loading.
			Navigator.pop(context);
			// Check the response status.
			if (response.statusCode == 200) {
				// If the server did return a 200 OK response, parse the JSON.
				var jsonBody = jsonDecode(response.body);
				// Obtain the token.
				var token = jsonBody["token"];
				// Save the token.
				storeAuth(username, token);
				// Get all plans and launch the next page.
				getPlans(jsonBody["token"]).then((planResponse) {
					// Check the response status.
					if (response.statusCode == 200) {
						// If the server did return a 200 OK response, parse the JSON.
						var planJsonBody = jsonDecode(utf8.decode(planResponse.bodyBytes));
						// Launch the next activity.
						Navigator.pushReplacement(context, MaterialPageRoute(
							// Builder for the next screen.
							builder: (_) => PlanSelectionPage(allPlansData: planJsonBody["data"])
						));
					} else if(planResponse.statusCode == 408) {
						// Show the error.
						showError(context, "Erro a ligar ao servidor.");
						// Return immediately.
						return;
					} else {
						// Show the error.
						showError(context, planResponse.reasonPhrase);
					}
				});

			} else if(response.statusCode == 408) {
				// Show the error.
				showError(context, "Erro a ligar ao servidor.");
				// Return immediately.
				return;
			} else {
				// Show the error.
				showError(context, response.reasonPhrase);
			}
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.white,
			appBar: AppBar(),
			body: SingleChildScrollView(
				child: Column(
					children: <Widget>[
						Padding(
							padding: const EdgeInsets.only(top: 60.0, bottom: 80.0),
							child: Center(
								child: Column(children: const [
									Text(
										'Viagem à Vela',
										style: TextStyle(
											color: Colors.blue,
											fontSize: 30,
											fontWeight: FontWeight.bold
										),
									),
									Text(
										'Logistica',
										style: TextStyle(
											color: Color(0xFF64B3FF),
											fontSize: 24,
											fontWeight: FontWeight.bold
										),
									),
								]),
							),
						),
						Padding(
							padding: const EdgeInsets.symmetric(
								horizontal: 15,
							),
							child: TextField(
								controller: nameController,
								decoration: const InputDecoration(
									border: OutlineInputBorder(),
									labelText: 'Nome de usuario',
									hintText: 'Introduzir o nome de utilizador'
								),
							),
						),
						Padding(
							padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
							child: TextField(
								obscureText: true,
								controller: passwordController,
								decoration: const InputDecoration(
									border: OutlineInputBorder(),
									labelText: 'Palavra-passe',
									hintText: 'Introduzir a palavra-passe do utilizador'
								),
							),
						),
						Padding(
							padding: const EdgeInsets.only(top: 40.0),
							child: Center(
								child: Container(
									height: 50,
									width: 250,
									decoration: BoxDecoration(
										color: Colors.blue,
										borderRadius: BorderRadius.circular(20)
									),
									child: TextButton(
										onPressed: makeRequest,
										child: const Text(
											'Entrar',
											style: TextStyle(
												color: Colors.white,
												fontSize: 25
											),
										),
									),
								),
							),
						),
						const SizedBox(
							height: 130,
						),
					],
				),
			),
		);
	}
}
