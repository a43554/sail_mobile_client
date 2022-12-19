import 'dart:convert';
import 'package:http/http.dart' as http;

// The API host.
const API_HOST = "http://10.0.2.2:8080";

// Obtain the token from the server.
Future<http.Response> executeLogin(String username, String password) {
	// Obtain the response.
	return http.post(
		Uri.parse('$API_HOST/mobile-api/login/'),
		headers: {"Content-Type": "application/json"},
		body: json.encode({
			"username": username,
			"password": password
		})
	).timeout(const Duration(seconds: 5), onTimeout: () {
		return http.Response('Timeout error', 408);
	});
}

// Obtain the plans from the server.
Future<http.Response> getPlans(String token) {
	return http.get(
		Uri.parse('$API_HOST/mobile-api/plans'),
		// Set the headers.
		headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
	).timeout(const Duration(seconds: 5), onTimeout: () {
		return http.Response('Timeout error', 408);
	});
}

// Obtain the plans from the server.
Future<http.Response> getPlan(String token, int planId) {
	return http.get(
		Uri.parse('$API_HOST/mobile-api/plans/$planId'),
		// Set the headers.
		headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
	).timeout(const Duration(seconds: 5), onTimeout: () {
		return http.Response('Timeout error', 408);
	});
}