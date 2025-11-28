
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class LiturgicalCalendarService {
  final String _baseUrl = 'https://liturgia.up.railway.app/v2/';

  Future<Map<String, dynamic>?> getLiturgicalData(DateTime date) async {
    final String formattedDay = DateFormat('dd').format(date);
    final String formattedMonth = DateFormat('MM').format(date);
    final String formattedYear = DateFormat('yyyy').format(date);

    final uri = Uri.parse(
        '$_baseUrl?dia=$formattedDay&mes=$formattedMonth&ano=$formattedYear');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        // No liturgy found for this date
        return null;
      } else {
        throw Exception(
            'Failed to load liturgical data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to liturgical API: $e');
    }
  }
}
