import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sail_mobile/ui/login.dart';
import 'package:sail_mobile/utils/CustomTableEvent.dart';
import 'package:sail_mobile/utils/auth.dart';
import 'package:sail_mobile/utils/custom_expansion_list.dart';
import 'package:sail_mobile/utils/custom_switch_button.dart';
import 'package:sail_mobile/utils/db.dart';
import 'package:timetable_view/timetable_view.dart';

// The stateful widget.
class MealPage extends StatefulWidget {
	const MealPage({Key? key}) : super(key: key);

	@override
	_MealPageState createState() => _MealPageState();
}

// The state.
class _MealPageState extends State<MealPage> with AutomaticKeepAliveClientMixin {
	// The username of the current user.
	late String userName;
	// The plan data of the current user.
	late Map<String, dynamic> planData;
	// The progress data of the current user.
	late Map<String, dynamic> mealProgress;

	// The progress states.
	final List<String> progressStates = ['Por fazer', 'Terminado'];

	final List<ValueNotifier<Color>> _colorNotifiers = [];

	// Obtain both the username and the plan data.
	Future<Map<String, dynamic>> getInfo() async {
		// Get the plan.
		var plan = await loadSelectedPlan();
		// Get the progress.
		var progress = await loadMealProgress();
		// Get the username.
		var user = await loadAuth();
		// Return both.
		return {
			"plan": plan,
			"user": user,
			"progress": progress
		};
	}

	@override
	bool get wantKeepAlive => true;

	@override
	Widget build(BuildContext context) {
		// Return the UI.
		return FutureBuilder<Map<String, dynamic>>(
			future: getInfo(),
			builder: (context, futureData) {
				// Check if running is not yet finished.
				if (futureData.connectionState != ConnectionState.done) {
					// Return loading screen while reading preferences
					return const Center(child: CircularProgressIndicator());
				}
				// Check the future data.
				if (!futureData.hasData) {
					// No data, launch login screen.
					Navigator.pushReplacement(context, MaterialPageRoute(
						// Builder for the next screen.
						builder: (_) => const LoginScreen()
					));
				}
				// Obtain the user.
				userName = futureData.data!["user"]["username"];
				// Obtain the time table.
				planData = futureData.data!["plan"];
				// Obtain the task progress.
				mealProgress = futureData.data!["progress"];

				// Obtain the schedule map.
				List<dynamic> schedule = planData["meals"]["schedule"];

				List<CustomExpansionPanel> panels = List.generate(
					planData["meals"]["schedule"].length,
						(index) {
						// Obtain the meal.
						Map<String, dynamic> meal = schedule[index];

						// Get the current string, if it exists.
						var currentState = mealProgress[index.toString()] ?? progressStates[0];

						// The color notifier.
						var notifyColor = ValueNotifier(
							(currentState == progressStates[0]) ? Colors.red : Colors.green
						);
						// Add the color notify.
						_colorNotifiers.add(notifyColor);

						// Return the row.
						return CustomExpansionPanelRadio(
							value: index,
							canTapOnHeader: true,
							headerBuilder: (context, isExpanded) {
								return ValueListenableBuilder(
									valueListenable: notifyColor,
									builder: (_, color, __) => Container(
										margin: EdgeInsets.all(5),
										padding: EdgeInsets.all(5.0),
										decoration: BoxDecoration(
											shape: BoxShape.rectangle,
											color: color,
											borderRadius: const BorderRadius.only(
												topLeft: Radius.circular(20.0),
												topRight: Radius.circular(20.0),
												bottomLeft: Radius.circular(20.0),
												bottomRight: Radius.circular(20.0),
											),
										),
										child: Container(
											decoration: const BoxDecoration(
												shape: BoxShape.rectangle,
												color: Colors.white,
												borderRadius: BorderRadius.only(
													topLeft: Radius.circular(20.0),
													topRight: Radius.circular(20.0),
													bottomLeft: Radius.circular(20.0),
													bottomRight: Radius.circular(20.0),
												),
											),
											child: Row(
												children: [
													Padding(padding: EdgeInsets.only(right: 5.0)),
													Text(
														"${index+1}",
														style: TextStyle(
															fontSize: 26
														),
													),
													Spacer(),
													Text(
														"${meal['name']}",
														style: TextStyle(
															fontSize: 28
														),
													),
													Spacer(),
												],
											),
										),
									)
								);
							},
							body: Container(
								child: Column(
									children: [
										Row(
											children: [
												Spacer(),
												Padding(
													padding: EdgeInsets.only(left: 5.0, right: 5.0),
													child: Text(
														"- - - Informação - - -",
														style: TextStyle(
															fontSize: 24
														),
													),
												),
												Spacer()
											],
										),
										Column(
											children: [
												Padding(
													padding: EdgeInsets.only(left: 10.0, right: 10.0),
													child: Expanded(
														child: Text(
															meal["description"],
															style: TextStyle(
																fontSize: 18
															),
														),
													),
												),
											],
										),
										Padding(padding: EdgeInsets.only(top: 15.0)),
										Row(
											children: [
												Spacer(),
												Padding(
													padding: EdgeInsets.only(left: 5.0, right: 5.0),
													child: Text(
														"- - - Lista de Ingredientes - - -",
														style: TextStyle(
															fontSize: 24
														),
													),
												),
												Spacer()
											],
										),
										Column(
											children: List.generate(
												meal["ingredients"].length,
													(index) => Row(
													children: [
														Spacer(),
														Padding(
															padding: EdgeInsets.all(5.0),
															child: Text(
																"${meal["ingredients"][index]}",
																style: TextStyle(
																	fontSize: 18
																),
															),
														),
														Spacer()
													],
												)
											),
										),
										Row(
											children: [
												Spacer(),
												AnimatedToggle(
													values: ['Por fazer', 'Terminado'],
													onToggleCallback: (value) {
														// Update the list.
														mealProgress[index.toString()] = progressStates[value];
														// Save the changes.
														storeMealProgress(mealProgress);
														// Update the visual state.
														notifyColor.value = (mealProgress[index.toString()] == progressStates[0]) ? Colors.red : Colors.green;
													},
													buttonColor: const Color(0xFF0B8DB4),
													backgroundColor: const Color(0xFFA0A0A0),
													textColor: const Color(0xFFFFFFFF),
												),
												Spacer()
											],
										)
									]
								),
							),
						);
					}
				);

				// Return the UI.
				return SingleChildScrollView(
					child: CustomExpansionPanelList.radio(
						children: panels
					)
				);
			}
		);
	}


	@override
  	void dispose() {
		_colorNotifiers.forEach((element) {element.dispose();});
		_colorNotifiers.clear();
		super.dispose();
  	}


}