import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sail_mobile/ui/login.dart';
import 'package:sail_mobile/utils/CustomTableEvent.dart';
import 'package:sail_mobile/utils/auth.dart';
import 'package:sail_mobile/utils/db.dart';
import 'package:timetable_view/timetable_view.dart';

// The stateful widget.
class TimeTablePage extends StatefulWidget {
	const TimeTablePage({Key? key}) : super(key: key);

	@override
	_TimeTableState createState() => _TimeTableState();
}

// The state.
class _TimeTableState extends State<TimeTablePage> with AutomaticKeepAliveClientMixin {

	// The username of the current user.
	late String userName;
	// The plan data of the current user.
	late Map<String, dynamic> planData;
	// The progress data of the current user.
	late Map<String, dynamic> taskProgress;

	// Obtain both the username and the plan data.
	Future<Map<String, dynamic>> getInfo() async {
		// Get the plan.
		var plan = await loadSelectedPlan();
		// Get the progress.
		var progress = await loadTaskProgress();
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
				taskProgress = futureData.data!["progress"];

				// Return the UI.
				return TimetableView(
					laneEventsList: _buildLaneEvents(),
					onEventTap: onEventTapCallBack,
					timetableStyle: const TimetableStyle(
						timeItemHeight: 55,
						timeItemWidth: 50,
						laneWidth: 250,
						timelineColor: Colors.black,
						timelineBorderColor: Colors.black,
						decorationLineBorderColor: Colors.black
					),
					onEmptySlotTap: onTimeSlotTappedCallBack,
				);
			}
		);
	}

	// Build the events.
	List<LaneEvents> _buildLaneEvents() {
		// Obtain the shifts per day.
		int shiftsPerDay = planData["shifts_per_day"];
		// Obtain all tasks.
		List<dynamic> fullTaskList = planData["tasks"].values.toList();
		// Obtain the schedule.
		List<dynamic> schedule = planData["schedule"].values.toList();
		// The event list.
		List<LaneEvents> lanes = [];
		// Obtain the name of the tasks.
		List<String> tasks = planData["tasks"].keys.toList();
		// Iterate through each shift.
		for (int idx = 0; idx < schedule.length; idx += shiftsPerDay) {
			// Obtain the day.
			int day = (idx / shiftsPerDay).floor() + 1;
			// Obtain the list of all tasks for this shift.
			List<TableEvent> events = [];
			// Iterate through the schedule.
			for (int shiftIdx = 0; shiftIdx < shiftsPerDay; shiftIdx++) {
				// Obtain the task.
				Map<String, dynamic> shift = schedule[idx + shiftIdx];
				// Obtain the interval.
				double interval = 24 / shiftsPerDay;
				// Obtain the hour time.
				int startHour = (shiftIdx * interval).floor();
				// Obtain the minute.
				int startMinute = (((shiftIdx * interval) - startHour) * 60).floor();
				// Obtain the hour time.
				int endHour = ((shiftIdx + 1) * interval).floor();
				// Obtain the minute.
				int endMinute = ((((shiftIdx + 1) * interval) - endHour) * 60).floor();
				// The list of all tasks this user participates in.
				List<String> participatingTasks = [];
				// Iterate through each task.
				for (int taskIdx = 0; taskIdx < tasks.length; taskIdx++) {
					// Obtain the task name.
					String taskName = tasks[taskIdx];
					// Check if user is contained within.
					if (shift[taskName].any((user) => user == userName)) {
						// Append it to the list.
						participatingTasks.add(taskName);
					}
				}
				// Check if any tasks contain participation.
				if (participatingTasks.isNotEmpty) {
					// Compute the hue.
					double hue = participatingTasks.map(
							(taskName) => 360.0 * (tasks.indexOf(taskName) / tasks.length)
					).map(
							(soloHue) => soloHue / participatingTasks.length
					).reduce(
							(value, element) => value+element
					);
					// Create the event.
					var event = CustomTableEvent(
						title: participatingTasks.map(
								(taskName) => fullTaskList.firstWhere(
									(taskData) => taskData["name"] == taskName
							)["display"] + getAdequateEmote(idx + shiftIdx, taskName)
						).join("\n"),
						eventId: idx + shiftIdx,
						margin: EdgeInsets.all(5.0),
						startTime: TableEventTime(hour: startHour, minute: startMinute),
						endTime: TableEventTime(hour: endHour, minute: endMinute),
						laneIndex: day,
						backgroundColor: HSVColor.fromAHSV(
							0.5, hue, 1.0, 1.0
						).toColor(),
						textStyle: const TextStyle(
							color: Colors.black,
							fontSize: 30.0,
						)
					);

					// Add the sensitive data to the event.
					event.storeExtraData(
						shiftIdx: idx + shiftIdx,
						taskNames: participatingTasks
					);

					// Add the event.
					events.add(event);
				}
			}
			// Construct the lane.
			lanes.add(LaneEvents(
				lane: Lane(name: 'Day ${day}', laneIndex: day),
				events: events
			));
		}
		// Return the lanes.
		return lanes;
	}

	// The selection of states.
	final selectionStates = ["TODO", "EXECUTING", "DONE"];

	String getAdequateEmote(index, taskName) {
		// The task progress.
		var currentTaskProgress = taskProgress["$index.$taskName"] ?? selectionStates.first;
		if (currentTaskProgress == selectionStates[2]) {
			return " [ X ]";
		} else if(currentTaskProgress == selectionStates[1]) {
			return " [...]";
		} else {
			return " [   ]";
		}
	}


	// Callback for event interaction.
	void onEventTapCallBack(TableEvent baseEvent) {
		// Cast it as a custom table event.
		CustomTableEvent event = baseEvent as CustomTableEvent;
		// The outer state.
		var outerState = this;
		// Launch a dialog.
		showDialog(
			context: context,
			barrierDismissible: true,
			builder: (BuildContext context) {
				return Dialog(
					backgroundColor: Colors.transparent,
					child: GestureDetector(
						onTap: (){
							// Remove the dialog.
							Navigator.pop(context);
						},
						child: StatefulBuilder(
							builder: (BuildContext innerContext, StateSetter setState) {
								return Container(
									color: Colors.transparent,
									alignment: AlignmentDirectional.center,
									child: ListView.separated(
										itemCount: event.taskNames.length,
										separatorBuilder: (BuildContext innerInnerContext, int index) => const Divider(),
										itemBuilder: ((context, index) {
											// Obtain the task name.
											String taskName = event.taskNames[index];
											// Obtain all the task data.
											Map<String, dynamic> task = planData["tasks"][taskName];
											// Extract the color.
											Color color = extractHueColor([task["name"]]);
											// Obtain the current progress of this task in this shift.
											String currentProgress = taskProgress["${event.shiftIdx}.$taskName"] ?? selectionStates.first;
											// The numeric state of the current progress.
											int currentPosition = selectionStates.indexOf(currentProgress);
											// Return the row.
											return Container(
												margin: EdgeInsets.all(5),
												padding: EdgeInsets.all(5.0),
												decoration: BoxDecoration(
													shape: BoxShape.rectangle,
													color: color,
													borderRadius: BorderRadius.only(
														topLeft: Radius.circular(20.0),
														topRight: Radius.circular(20.0),
														bottomLeft: Radius.circular(20.0),
														bottomRight: Radius.circular(20.0),
													),
												),
												child: Container(
													decoration: BoxDecoration(
														shape: BoxShape.rectangle,
														color: Colors.white,
														borderRadius: BorderRadius.only(
															topLeft: Radius.circular(20.0),
															topRight: Radius.circular(20.0),
															bottomLeft: Radius.circular(20.0),
															bottomRight: Radius.circular(20.0),
														),
													),
													child: Column(children: [
														Text(
															task["display"],
															textAlign: TextAlign.center,
															style: TextStyle(
																fontSize: 26,
																decoration: TextDecoration.underline
															),
														),
														Container(
															margin: EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 15),
															color: Colors.white,
															child: Text(
																task["description"],
																textAlign: TextAlign.center,
															),

														),
														ToggleButtons(
															color: Colors.black,
															selectedColor: Color(0xFF000000),
															selectedBorderColor: Color(0xFF000000),
															fillColor: color.withOpacity(0.28),
															splashColor: Color(0xFF000000).withOpacity(0.12),
															hoverColor: Color(0xFFFFFFFF).withOpacity(0.04),
															borderRadius: BorderRadius.circular(4.0),
															constraints: BoxConstraints(minHeight: 36.0),
															isSelected: [
																currentPosition == 0,
																currentPosition == 1,
																currentPosition == 2,
															],
															onPressed: (index) {
																// Respond to button selection
																setState(() {
																	outerState.setState(() {
																		// Update the progress.
																		taskProgress["${event.shiftIdx}.$taskName"] = selectionStates[index];
																		// Save the changes.
																		storeTaskProgress(taskProgress);
																	});
																});
															},
															children: [
																Padding(
																	padding: EdgeInsets.symmetric(horizontal: 12.0),
																	child: Text('Por fazer'),
																),
																Padding(
																	padding: EdgeInsets.symmetric(horizontal: 12.0),
																	child: Text('Em progresso'),
																),
																Padding(
																	padding: EdgeInsets.symmetric(horizontal: 12.0),
																	child: Text('Concluida'),
																),
															],
														)
													]),
												),
											);
										})
									)
								);
							}
						)
					),
				);
			},
		);
	}

	// Extract a color from a task.
	Color extractHueColor(List<dynamic> participatingTasks) {
		// Obtain the tasks.
		var tasks = planData["tasks"].keys.toList();
		// Compute the hue.
		double hue = participatingTasks.map(
				(taskName) => 360.0 * (tasks.indexOf(taskName) / tasks.length)
		).map(
				(soloHue) => soloHue / participatingTasks.length
		).reduce(
				(value, element) => value+element
		);
		// Return the color
		return HSVColor.fromAHSV(
			0.5, hue, 1.0, 1.0
		).toColor();
	}


	void onTimeSlotTappedCallBack(
		int laneIndex, TableEventTime start, TableEventTime end) {
		print(
			"Empty Slot Clicked !! LaneIndex: $laneIndex StartHour: ${start.hour} EndHour: ${end.hour}");
	}
}