import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../providers/form_provider.dart';

class PdfGenerator {
  static Future<Uint8List> generateInspectionReport(FormProvider formProvider) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Inspection Report')),
          pw.Text('Station: ${formProvider.stationName}'),
          pw.Text('Inspector: ${formProvider.inspectorName}'),
          pw.Text('Date: ${formProvider.inspectionDate.toLocal().toString().split(' ')[0]}'),
          pw.SizedBox(height: 20),
          pw.Text('Overall Score: ${formProvider.getTotalScore()}/${formProvider.getMaxPossibleScore()}'),
          pw.Text('Percentage: ${formProvider.getPercentage().toStringAsFixed(1)}%'),
          pw.SizedBox(height: 20),
          pw.Text('Section Scores:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...formProvider.sections.map((section) {
            final score = formProvider.getSectionScore(section.id);
            final maxScore = formProvider.getSectionMaxScore(section.id);
            final percent = maxScore > 0 ? (score / maxScore) * 100 : 0;
            return pw.Text('${section.title}: $score/$maxScore (${percent.toStringAsFixed(1)}%)');
          }).toList(),
          if (formProvider.additionalRemarks.isNotEmpty)
            pw.Column(children: [
              pw.SizedBox(height: 20),
              pw.Text('Additional Remarks:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(formProvider.additionalRemarks),
            ]),
        ],
      ),
    );

    return pdf.save();
  }
}
