import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../models/score_parameter.dart';
import '../providers/form_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../services/pdf_generator.dart';
import '../services/pdf_utils.dart';
import '../widgets/section_card.dart';
import '../utils/constants.dart';
import '../services/pdf_generator.dart';
import '../services/pdf_utils.dart';

class ScoreCardFormScreen extends StatefulWidget {
  @override
  _ScoreCardFormScreenState createState() => _ScoreCardFormScreenState();
}

class _ScoreCardFormScreenState extends State<ScoreCardFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  final _stationNameController = TextEditingController();
  final _inspectorNameController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final formProvider = Provider.of<FormProvider>(context, listen: false);
    _tabController = TabController(
      length: formProvider.sections.length + 1, // +1 for basic info tab
      vsync: this,
    );

    _stationNameController.text = formProvider.stationName;
    _inspectorNameController.text = formProvider.inspectorName;
    _remarksController.text = formProvider.additionalRemarks;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stationNameController.dispose();
    _inspectorNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FormProvider, ThemeProvider>(
      builder: (context, formProvider, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('CTS Inspector'),
            actions: [
              IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      _showClearConfirmationDialog(context, formProvider);
                      break;
                    case 'summary':
                      _showSummaryDialog(context, formProvider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'summary',
                    child: Text('View Summary'),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear Form'),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                const Tab(text: 'Basic Info'),
                ...formProvider.sections.map((section) => Tab(text: section.title)),
              ],
            ),
          ),
          body: Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(formProvider),
                ...formProvider.sections.map((section) => _buildSectionTab(section, formProvider)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: formProvider.isLoading ? null : () => _submitForm(formProvider),
            icon: formProvider.isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.send),
            label: Text(formProvider.isLoading ? 'Submitting...' : 'Submit'),
          ),
        );
      },
    );
  }

  Widget _buildBasicInfoTab(FormProvider formProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Progress',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Total Score: ${formProvider.getTotalScore()}/${formProvider.getMaxPossibleScore()}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getOverallColor(formProvider.getPercentage()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${formProvider.getPercentage().toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: formProvider.getPercentage() / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getOverallColor(formProvider.getPercentage()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Basic Information Form
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  // Station Name
                  TextFormField(
                    controller: _stationNameController,
                    decoration: const InputDecoration(
                      labelText: 'Station Name *',
                      prefixIcon: Icon(Icons.train),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Station name is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      formProvider.setStationName(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Inspector Name
                  TextFormField(
                    controller: _inspectorNameController,
                    decoration: const InputDecoration(
                      labelText: 'Inspector Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Inspector name is required';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      formProvider.setInspectorName(value);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Inspection Date
                  InkWell(
                    onTap: () => _selectDate(context, formProvider),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Inspection Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(formProvider.inspectionDate),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Additional Remarks
                  TextFormField(
                    controller: _remarksController,
                    decoration: const InputDecoration(
                      labelText: 'Additional Remarks (Optional)',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      formProvider.setAdditionalRemarks(value);
                    },
                  ),
                ],
              ),
            ),
          ),

          if (formProvider.error != null)
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formProvider.error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTab(FormSection section, FormProvider formProvider) {
    return SingleChildScrollView(
      child: SectionCard(
        section: section,
        onScoreChanged: (sectionId, parameterId, score) {
          formProvider.setParameterScore(sectionId, parameterId, score);
        },
        onRemarksChanged: (sectionId, parameterId, remarks) {
          formProvider.setParameterRemarks(sectionId, parameterId, remarks);
        },
        currentScore: formProvider.getSectionScore(section.id),
        maxScore: formProvider.getSectionMaxScore(section.id),
      ),
    );
  }

  Color _getOverallColor(double percentage) {
    if (percentage < 30) return Colors.red;
    if (percentage < 60) return Colors.orange;
    if (percentage < 80) return Colors.yellow.shade700;
    return Colors.green;
  }

  Future<void> _selectDate(BuildContext context, FormProvider formProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: formProvider.inspectionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != formProvider.inspectionDate) {
      formProvider.setInspectionDate(picked);
    }
  }

  Future<void> _submitForm(FormProvider formProvider) async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(
        msg: "Please fill all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    if (!formProvider.validateForm()) {
      Fluttertoast.showToast(
        msg: formProvider.error ?? "Please complete all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    formProvider.setLoading(true);

    try {
      final inspectionForm = formProvider.createInspectionForm();
      final result = await ApiService.submitForm(inspectionForm);

      if (result['success']) {
        Fluttertoast.showToast(
          msg: Constants.submissionSuccessMessage,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );

        _showSuccessDialog(context, formProvider, result);
      } else {
        Fluttertoast.showToast(
          msg: result['message'] ?? Constants.submissionErrorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Network error: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      formProvider.setLoading(false);
    }
  }

  void _showSuccessDialog(BuildContext context, FormProvider formProvider, Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Submitted Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Station: ${formProvider.stationName}'),
            Text('Inspector: ${formProvider.inspectorName}'),
            Text('Date: ${DateFormat('dd/MM/yyyy').format(formProvider.inspectionDate)}'),
            Text('Total Score: ${formProvider.getTotalScore()}/${formProvider.getMaxPossibleScore()}'),
            Text('Percentage: ${formProvider.getPercentage().toStringAsFixed(1)}%'),
            if (result['submissionId'] != null) ...[
              const SizedBox(height: 8),
              Text('Submission ID: ${result['submissionId']}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Form'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              formProvider.clearForm();
              _stationNameController.clear();
              _inspectorNameController.clear();
              _remarksController.clear();
            },
            child: const Text('New Form'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context, FormProvider formProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Form'),
        content: const Text('Are you sure you want to clear all form data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              formProvider.clearForm();
              _stationNameController.clear();
              _inspectorNameController.clear();
              _remarksController.clear();
              Fluttertoast.showToast(
                msg: "Form cleared successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog(BuildContext context, FormProvider formProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Form Summary'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSummaryCard(
                  'Basic Information',
                  [
                    'Station: ${formProvider.stationName.isEmpty ? 'Not specified' : formProvider.stationName}',
                    'Inspector: ${formProvider.inspectorName.isEmpty ? 'Not specified' : formProvider.inspectorName}',
                    'Date: ${DateFormat('dd/MM/yyyy').format(formProvider.inspectionDate)}',
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  'Overall Score',
                  [
                    'Total Score: ${formProvider.getTotalScore()}/${formProvider.getMaxPossibleScore()}',
                    'Percentage: ${formProvider.getPercentage().toStringAsFixed(1)}%',
                    'Grade: ${_getGrade(formProvider.getPercentage())}',
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  'Section Scores',
                  formProvider.sections.map((section) {
                    final score = formProvider.getSectionScore(section.id);
                    final maxScore = formProvider.getSectionMaxScore(section.id);
                    final percentage = maxScore > 0 ? (score / maxScore) * 100 : 0;
                    return '${section.title}: $score/$maxScore (${percentage.toStringAsFixed(1)}%)';
                  }).toList(),
                ),
                if (formProvider.additionalRemarks.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    'Additional Remarks',
                    [formProvider.additionalRemarks],
                  ),
                ],
                const SizedBox(height: 16),
                _buildSummaryCard(
                  'Form Status',
                  [
                    'Validation: ${formProvider.validateForm() ? 'Passed' : 'Failed'}',
                    'Ready for Submission: ${formProvider.validateForm() && formProvider.stationName.isNotEmpty && formProvider.inspectorName.isNotEmpty ? 'Yes' : 'No'}',
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (formProvider.validateForm() &&
              formProvider.stationName.isNotEmpty &&
              formProvider.inspectorName.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitForm(formProvider);
              },
              child: const Text('Submit Form'),
            ),
          if (formProvider.validateForm() &&
              formProvider.stationName.isNotEmpty &&
              formProvider.inspectorName.isNotEmpty)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final pdfBytes = await PdfGenerator.generateInspectionReport(formProvider);
                final filePath = await PdfUtils.savePdf(pdfBytes, 'inspection_report.pdf');
                Fluttertoast.showToast(msg: 'PDF saved to $filePath');
                await PdfUtils.openPdf(filePath);
              },
              child: const Text('Generate & Save PDF'),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            )),
          ],
        ),
      ),
    );
  }

  String _getGrade(double percentage) {
    if (percentage >= 90) return 'Excellent (A+)';
    if (percentage >= 80) return 'Good (A)';
    if (percentage >= 70) return 'Satisfactory (B)';
    if (percentage >= 60) return 'Needs Improvement (C)';
    if (percentage >= 50) return 'Poor (D)';
    return 'Critical (F)';
  }
}
