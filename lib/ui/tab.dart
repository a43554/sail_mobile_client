import 'package:flutter/material.dart';
import 'package:sail_mobile/ui/login.dart';
import 'package:sail_mobile/ui/plan/meals.dart';
import 'package:sail_mobile/ui/plan/tasks.dart';
import 'package:sail_mobile/utils/db.dart';

class TabPage extends StatefulWidget {
	const TabPage({Key? key}) : super(key: key);

	@override
	TabPageState createState() => TabPageState();
}

class TabPageState extends State<TabPage> {


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
				"Terminar Viagem",
				style: TextStyle(
					fontSize: 24,
					color: Colors.red
				),
			),
			content: Text("Se escolher terminar a viagem todos os dados associados ao plano e à sessão serão removidos do telemóvel.\n\nPara escolher um plano após terminar, será necessário acesso à internet para realizar novamente o login."),
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

	@override
	Widget build(BuildContext context) {
		return DefaultTabController(
			length: 2,
			child: Scaffold(
				appBar: AppBar(
					title: const Text("Informações do Plano"),
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
				body: const TabBarView(
					physics: NeverScrollableScrollPhysics(),
					children: [
						TimeTablePage(),
						MealPage()
					],
				),
				bottomNavigationBar: Container(
					color: Colors.blueAccent,
					child: const TabBar(
						indicatorColor: Colors.white,
						tabs: [
							Tab(
								icon: Icon(Icons.event)
							),
							Tab(
								icon: Icon(Icons.restaurant_menu)
							)
						],
					),
				),
			),
		);
	}
}