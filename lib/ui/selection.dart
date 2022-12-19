import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sail_mobile/ui/login.dart';
import 'package:sail_mobile/ui/tab.dart';
import 'package:sail_mobile/utils/api.dart';
import 'package:sail_mobile/utils/auth.dart';

import 'package:sail_mobile/utils/db.dart';
import 'package:sail_mobile/utils/ui_popups.dart';

class PlanSelectionPage extends StatefulWidget {

	final List<dynamic> allPlansData;

	const PlanSelectionPage({
		Key? key,
		required this.allPlansData
	}) : super(key: key);

	@override
	PlanSelectionPageState createState() => PlanSelectionPageState();
}

class PlanSelectionPageState extends State<PlanSelectionPage> {

	// Show a loading icon.
	void showLogoutDialog(){
		// Set up the buttons
		Widget cancelButton = TextButton(
			child: const Text(
				"Cancelar",
				style: TextStyle(
					fontSize: 20,
					color: Colors.black
				),
			),
			onPressed:  () {
				// Remove the loading.
				Navigator.pop(context);
			},
		);
		Widget continueButton = TextButton(
			child: const Text(
				"Terminar",
				style: TextStyle(
					fontSize: 20,
					color: Colors.red
				),
			),
			onPressed:  () {
				// Remove the loading.
				Navigator.pop(context);
				// Clear the entire data.
				fullClear();
				// Launch the next activity.
				Navigator.pushReplacement(context, MaterialPageRoute(
					// Builder for the next screen.
					builder: (_) => const LoginScreen()
				));
			},
		);
		// set up the AlertDialog
		AlertDialog alert = AlertDialog(
			title: Text(
				"Terminar Sessão?",
				style: TextStyle(
					fontSize: 24,
					color: Colors.red
				),
			),
			content: Text("Deseja terminar a sessão e regressar ao menu de início de sessão?"),
			actions: [
				cancelButton,
				continueButton,
			],
		);
		// show the dialog
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return alert;
			},
		);
	}


	// Function used to advance to the next screen.
	void makeRequest(int planId) async {
		// Show a loading screen.
		showLoadingIcon(context);
		// Get the token.
		Map<String, dynamic> auth = await loadAuth();
		// Get the token.
		String token = auth["token"]!;
		// Obtain the login and send it to the server.
		getPlan(token, planId).then((response) {
			// Remove the loading.
			Navigator.pop(context);
			// Check the response status.
			if (response.statusCode == 200) {
				// If the server did return a 200 OK response, parse the JSON.
				var jsonBody = jsonDecode(utf8.decode(response.bodyBytes));
				// Save the token.
				storeSelectedPlan(jsonBody["data"]);
				// Launch the next activity.
				Navigator.pushReplacement(context, MaterialPageRoute(
					// Builder for the next screen.
					builder: (_) => const TabPage()
				));
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
		// Obtain the data.
		var plans = widget.allPlansData;
		// Return the UI.
		return Scaffold(
			appBar: AppBar(
				title: const Text('Selecionar um plano'),
				actions: <Widget>[
					Padding(
						padding: const EdgeInsets.only(right: 20.0),
						child: GestureDetector(
							onTap: () {
								// Display the logout dialog.
								showLogoutDialog();
							},
							child: const Icon(
								Icons.close,
								size: 26.0,
							),
						)
					),
				]
			),
			body: GridView.builder(
				padding: const EdgeInsets.all(10),
				gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
					maxCrossAxisExtent: 200,
					childAspectRatio: 2 / 3,
					crossAxisSpacing: 20,
					mainAxisSpacing: 20),
				itemCount: plans.length,
				itemBuilder: (BuildContext ctx, index) {
					return GridTile(
						key: ValueKey(plans[index]['id']),
						footer: GridTileBar(
							backgroundColor: Colors.black54,
							title: Text(
								plans[index]['title'],
								style: const TextStyle(
									fontSize: 18,
									fontWeight:
									FontWeight.bold
								),
							),
							subtitle: Text(plans[index]['description'].toString()),
							// trailing: const Icon(Icons.shopping_cart),
						),
						child: GestureDetector(
							onTap: () {
								// Make the request.
								makeRequest(plans[index]['id']);
							},
							child: Image.asset(
								"assets/images/sail_${(plans[index]['id'] % 8) + 1}.png",
								fit: BoxFit.cover,
							)
						),
					);
				}
			),
		);
	}
}