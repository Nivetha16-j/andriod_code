import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class Country {
  final dynamic id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? json['country_id'],
      // Added json['country'] here to match your API response key
      name: json['country'] ?? json['name'] ?? json['country_name'] ?? '',
    );
  }
}

class CountryService {
  static const String _baseUrl =
      'https://staging.junubullion.com/api/countries';

  static Future<List<Country>> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        log("CountryService: Fetched countries data: $data");

        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map<String, dynamic>) {
          list = data['data'] ?? data['country'] ?? [];
        }

        log("CountryService: Parsed countries list: $list");

        return list.map((item) => Country.fromJson(item)).toList();
      } else {
        throw Exception(
          'Failed to load countries (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      log("CountryService Error: $e");
      rethrow;
    }
  }
}
