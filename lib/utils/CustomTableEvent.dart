import 'package:timetable_view/timetable_view.dart';

class CustomTableEvent extends TableEvent {

	// The shift index.
	late final int shiftIdx;
	// The task name
	late final List<String> taskNames;

	// The custom table event.
	CustomTableEvent({
		required super.title,
		required super.eventId,
		required super.laneIndex,
		required super.startTime,
		required super.endTime,
		super.margin,
		super.backgroundColor,
		super.textStyle,
  	});

	// Function to add extra data.
	CustomTableEvent storeExtraData({
		required int shiftIdx,
		required List<String> taskNames
	}) {
		// Assign the values.
		this.shiftIdx = shiftIdx;
		this.taskNames = taskNames;
		// Return this element.
		return this;
	}


}