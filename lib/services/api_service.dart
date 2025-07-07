import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/score_parameter.dart';
import '../utils/constants.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, dynamic>> submitForm(InspectionForm form) async {
    try {
      final response = await http.post(
        Uri.parse(Constants.httpbinEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(form.toJson()),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Form submitted successfully',
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to submit form. Status: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>> submitToWebhook(
      InspectionForm form,
      String webhookUrl
      ) async {
    try {
      final response = await http.post(
        Uri.parse(webhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(form.toJson()),
      ).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message': 'Form submitted to webhook successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': 'Webhook submission failed. Status: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to submit to webhook',
        'error': e.toString(),
      };
    }
  }

  static Future<bool> testConnection(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      return false;
    }
  }

  static Map<String, dynamic> createFormSummary(InspectionForm form) {
    return {
      'summary': {
        'stationName': form.stationName,
        'inspectionDate': form.inspectionDate.toIso8601String(),
        'inspectorName': form.inspectorName,
        'totalScore': form.calculateTotalScore(),
        'maxPossibleScore': form.calculateMaxPossibleScore(),
        'percentage': form.calculatePercentage(),
        'sectionsCount': form.sections.length,
        'parametersCount': form.sections.fold(0, (sum, section) => sum + section.parameters.length),
      },
      'sectionScores': form.sections.map((section) {
        int sectionScore = section.parameters.fold(0, (sum, param) => sum + (param.score ?? 0));
        int maxSectionScore = section.parameters.fold(0, (sum, param) => sum + param.maxScore);
        return {
          'sectionId': section.id,
          'sectionTitle': section.title,
          'score': sectionScore,
          'maxScore': maxSectionScore,
          'percentage': maxSectionScore > 0 ? (sectionScore / maxSectionScore) * 100 : 0,
        };
      }).toList(),
    };
  }
}