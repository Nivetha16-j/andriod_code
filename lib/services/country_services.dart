import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

class Country {
  final dynamic id;
  final String name;
  final String dialCode;

  Country({required this.id, required this.name, required this.dialCode});

  factory Country.fromJson(Map<String, dynamic> json) {
    final String countryName =
        json['country'] ?? json['name'] ?? json['country_name'] ?? '';

    // Static country code mapping
    const Map<String, String> countryCodes = {
      'Canada': '+1',
      'China': '+86',
      'Dubai': '+971',
      'India': '+91',
      'Singapore': '+65',
      'Taiwan': '+886',
    };

    return Country(
      id: json['id'] ?? json['country_id'],
      name: countryName,
      dialCode: countryCodes[countryName] ?? '',
    );
  }
}

class CountryService {
  static const String _baseUrl = 'https://junubullion.com/api/countries';

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

        final countries = list.map((item) => Country.fromJson(item)).toList();

        for (final country in countries) {
          log(
            "Country: ${country.name}, "
            "ID: ${country.id}, "
            "Dial Code: ${country.dialCode}",
          );
        }

        return countries;
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      log("CountryService Error: $e");
      rethrow;
    }
  }
}
