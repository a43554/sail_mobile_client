import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// Store the auth.
void storeAuth(String username, String token) async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Store the data as a string.
	Map<String,String> mapToString = {
		"username": username,
		"token": token,
	};
	// Turn the result into a string.
	var mappedString = jsonEncode(mapToString);
	// Save an String value to 'user_name' key.
	await prefs.setString('auth', mappedString);
}

// Store the auth.
Future<Map<String, dynamic>> loadAuth() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Turn the result into a string.
	var mappedString = prefs.getString("auth")!;
	// Transform it back into a map.
	Map<String,dynamic> mapFromString = jsonDecode(mappedString);
	// Return the string.
	return mapFromString;
}

// Check if user is authenticated.
Future<bool> hasAuth() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Turn the result into a string.
	return prefs.containsKey("auth");
}

// Clear the auth.
void clearAuth() async {
	// Obtain shared preferences.
	final prefs = await SharedPreferences.getInstance();
	// Remove a String from 'user_name' key.
	await prefs.remove('auth');
}