class ScoreParameter {
  final String id;
  final String name;
  final String description;
  int? score;
  String? remarks;
  final bool isRequired;
  final int maxScore;

  ScoreParameter({
    required this.id,
    required this.name,
    required this.description,
    this.score,
    this.remarks,
    this.isRequired = true,
    this.maxScore = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'score': score,
      'remarks': remarks,
      'isRequired': isRequired,
      'maxScore': maxScore,
    };
  }

  factory ScoreParameter.fromJson(Map<String, dynamic> json) {
    return ScoreParameter(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      score: json['score'],
      remarks: json['remarks'],
      isRequired: json['isRequired'] ?? true,
      maxScore: json['maxScore'] ?? 10,
    );
  }

  ScoreParameter copyWith({
    String? id,
    String? name,
    String? description,
    int? score,
    String? remarks,
    bool? isRequired,
    int? maxScore,
  }) {
    return ScoreParameter(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      score: score ?? this.score,
      remarks: remarks ?? this.remarks,
      isRequired: isRequired ?? this.isRequired,
      maxScore: maxScore ?? this.maxScore,
    );
  }
}

class FormSection {
  final String id;
  final String title;
  final List<ScoreParameter> parameters;

  FormSection({
    required this.id,
    required this.title,
    required this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'parameters': parameters.map((p) => p.toJson()).toList(),
    };
  }

  factory FormSection.fromJson(Map<String, dynamic> json) {
    return FormSection(
      id: json['id'],
      title: json['title'],
      parameters: (json['parameters'] as List)
          .map((p) => ScoreParameter.fromJson(p))
          .toList(),
    );
  }
}

class InspectionForm {
  final String stationName;
  final DateTime inspectionDate;
  final String inspectorName;
  final List<FormSection> sections;
  final String? additionalRemarks;

  InspectionForm({
    required this.stationName,
    required this.inspectionDate,
    required this.inspectorName,
    required this.sections,
    this.additionalRemarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'stationName': stationName,
      'inspectionDate': inspectionDate.toIso8601String(),
      'inspectorName': inspectorName,
      'sections': sections.map((s) => s.toJson()).toList(),
      'additionalRemarks': additionalRemarks,
      'totalScore': calculateTotalScore(),
      'maxPossibleScore': calculateMaxPossibleScore(),
    };
  }

  int calculateTotalScore() {
    int total = 0;
    for (var section in sections) {
      for (var param in section.parameters) {
        total += param.score ?? 0;
      }
    }
    return total;
  }

  int calculateMaxPossibleScore() {
    int total = 0;
    for (var section in sections) {
      for (var param in section.parameters) {
        total += param.maxScore;
      }
    }
    return total;
  }

  double calculatePercentage() {
    int total = calculateTotalScore();
    int max = calculateMaxPossibleScore();
    return max > 0 ? (total / max) * 100 : 0;
  }
}