import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// Store the auth.
void storeSelectedPlan(Map<String, dynamic> plans) async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Turn the result into a string.
	var mappedString = jsonEncode(plans);
	// Save an String value to 'user_name' key.
	await prefs.setString('selected_plan', mappedString);
}

// Store the plans.
Future<Map<String, dynamic>> loadSelectedPlan() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Turn the result into a string.
	var mappedString = prefs.getString("selected_plan")!;
	// Transform it back into a map.
	Map<String, dynamic> mapFromString = jsonDecode(mappedString);
	// Return the string.
	return mapFromString;
}

// Clear the plans.
void clearSelectedPlan() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Remove all plans.
	await prefs.remove('selected_plan');
}


// Load the task progress.
void storeTaskProgress(Map<String, dynamic> taskProgress) async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Turn the result into a string.
	var mappedString = jsonEncode(taskProgress);
	// Save an String value to 'user_name' key.
	await prefs.setString('task_progress', mappedString);
}

// Load the task progress.
Future<Map<String, dynamic>> loadTaskProgress() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Turn the result into a string.
	var mappedString = prefs.getString("task_progress");
	// Check if nothing is currently stored.
	if (mappedString == null) {
		// Return an empty map.
		return {};
	}
	// Transform it back into a map.
	Map<String, dynamic> mapFromString = jsonDecode(mappedString);
	// Return the string.
	return mapFromString;
}

// Clear the plans.
void clearTaskProgress() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Remove all plans.
	await prefs.remove('task_progress');
}

// Load the task progress.
void storeMealProgress(Map<String, dynamic> taskProgress) async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Turn the result into a string.
	var mappedString = jsonEncode(taskProgress);
	// Save an String value to 'user_name' key.
	await prefs.setString('meal_progress', mappedString);
}

// Load the task progress.
Future<Map<String, dynamic>> loadMealProgress() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Turn the result into a string.
	var mappedString = prefs.getString("meal_progress");
	// Check if nothing is currently stored.
	if (mappedString == null) {
		// Return an empty map.
		return {};
	}
	// Transform it back into a map.
	Map<String, dynamic> mapFromString = jsonDecode(mappedString);
	// Return the string.
	return mapFromString;
}

// Clear the plans.
void clearMealProgress() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Remove all plans.
	await prefs.remove('meal_progress');
}

// Check if plan data exists.
Future<bool> hasPlanData() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Check if all prefs are in the database.
	return prefs.containsKey("selected_plan");
}

// Remove the entire plan data.
void fullClear() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Remove all plan data.
	await prefs.remove('meal_progress');
	await prefs.remove('task_progress');
	await prefs.remove('selected_plan');
}
