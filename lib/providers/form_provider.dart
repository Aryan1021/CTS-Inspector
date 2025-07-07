import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/score_parameter.dart';
import '../utils/constants.dart';

class FormProvider extends ChangeNotifier {
  InspectionForm? _currentForm;
  List<FormSection> _sections = [];
  bool _isLoading = false;
  String? _error;

  // Form basic info
  String _stationName = '';
  DateTime _inspectionDate = DateTime.now();
  String _inspectorName = '';
  String _additionalRemarks = '';

  // Getters
  InspectionForm? get currentForm => _currentForm;
  List<FormSection> get sections => _sections;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get stationName => _stationName;
  DateTime get inspectionDate => _inspectionDate;
  String get inspectorName => _inspectorName;
  String get additionalRemarks => _additionalRemarks;

  FormProvider() {
    _initializeForm();
  }

  void _initializeForm() {
    _sections = Constants.getFormSections();
    _loadAutoSavedData();
    notifyListeners();
  }

  // Basic form info setters
  void setStationName(String value) {
    _stationName = value;
    _autoSave();
    notifyListeners();
  }

  void setInspectionDate(DateTime value) {
    _inspectionDate = value;
    _autoSave();
    notifyListeners();
  }

  void setInspectorName(String value) {
    _inspectorName = value;
    _autoSave();
    notifyListeners();
  }

  void setAdditionalRemarks(String value) {
    _additionalRemarks = value;
    _autoSave();
    notifyListeners();
  }

  // Parameter scoring
  void setParameterScore(String sectionId, String parameterId, int score) {
    for (var section in _sections) {
      if (section.id == sectionId) {
        for (var param in section.parameters) {
          if (param.id == parameterId) {
            param.score = score;
            _autoSave();
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  void setParameterRemarks(String sectionId, String parameterId, String remarks) {
    for (var section in _sections) {
      if (section.id == sectionId) {
        for (var param in section.parameters) {
          if (param.id == parameterId) {
            param.remarks = remarks;
            _autoSave();
            notifyListeners();
            return;
          }
        }
      }
    }
  }

  // Get parameter by IDs
  ScoreParameter? getParameter(String sectionId, String parameterId) {
    for (var section in _sections) {
      if (section.id == sectionId) {
        for (var param in section.parameters) {
          if (param.id == parameterId) {
            return param;
          }
        }
      }
    }
    return null;
  }

  // Validation
  bool validateForm() {
    if (_stationName.isEmpty || _inspectorName.isEmpty) {
      _error = 'Station name and inspector name are required';
      notifyListeners();
      return false;
    }

    for (var section in _sections) {
      for (var param in section.parameters) {
        if (param.isRequired && param.score == null) {
          _error = 'Please provide scores for all required parameters';
          notifyListeners();
          return false;
        }
      }
    }

    _error = null;
    notifyListeners();
    return true;
  }

  // Create form object
  InspectionForm createInspectionForm() {
    return InspectionForm(
      stationName: _stationName,
      inspectionDate: _inspectionDate,
      inspectorName: _inspectorName,
      sections: _sections,
      additionalRemarks: _additionalRemarks.isNotEmpty ? _additionalRemarks : null,
    );
  }

  // Calculate totals
  int getTotalScore() {
    int total = 0;
    for (var section in _sections) {
      for (var param in section.parameters) {
        total += param.score ?? 0;
      }
    }
    return total;
  }

  int getMaxPossibleScore() {
    int total = 0;
    for (var section in _sections) {
      for (var param in section.parameters) {
        total += param.maxScore;
      }
    }
    return total;
  }

  double getPercentage() {
    int total = getTotalScore();
    int max = getMaxPossibleScore();
    return max > 0 ? (total / max) * 100 : 0;
  }

  // Section-wise totals
  int getSectionScore(String sectionId) {
    for (var section in _sections) {
      if (section.id == sectionId) {
        int total = 0;
        for (var param in section.parameters) {
          total += param.score ?? 0;
        }
        return total;
      }
    }
    return 0;
  }

  int getSectionMaxScore(String sectionId) {
    for (var section in _sections) {
      if (section.id == sectionId) {
        int total = 0;
        for (var param in section.parameters) {
          total += param.maxScore;
        }
        return total;
      }
    }
    return 0;
  }

  // Auto-save functionality
  void _autoSave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final formData = {
        'stationName': _stationName,
        'inspectionDate': _inspectionDate.toIso8601String(),
        'inspectorName': _inspectorName,
        'additionalRemarks': _additionalRemarks,
        'sections': _sections.map((s) => s.toJson()).toList(),
      };
      await prefs.setString(Constants.autoSaveKey, json.encode(formData));
    } catch (e) {
      print('Auto-save failed: $e');
    }
  }

  void _loadAutoSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(Constants.autoSaveKey);
      if (savedData != null) {
        final data = json.decode(savedData);
        _stationName = data['stationName'] ?? '';
        _inspectorName = data['inspectorName'] ?? '';
        _additionalRemarks = data['additionalRemarks'] ?? '';

        if (data['inspectionDate'] != null) {
          _inspectionDate = DateTime.parse(data['inspectionDate']);
        }

        if (data['sections'] != null) {
          _sections = (data['sections'] as List)
              .map((s) => FormSection.fromJson(s))
              .toList();
        }

        notifyListeners();
      }
    } catch (e) {
      print('Failed to load auto-saved data: $e');
    }
  }

  // Clear form
  void clearForm() async {
    _stationName = '';
    _inspectorName = '';
    _additionalRemarks = '';
    _inspectionDate = DateTime.now();
    _sections = Constants.getFormSections();
    _error = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(Constants.autoSaveKey);
    } catch (e) {
      print('Failed to clear auto-saved data: $e');
    }

    notifyListeners();
  }

  // Loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error handling
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}