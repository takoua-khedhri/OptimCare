import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Important pour QueryDocumentSnapshot

// Fonction pour formater le timestamp Firestore en String
String formatTimestamp(dynamic timestamp) {
  if (timestamp is Timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }
  return '';
}

void generateAllSoinsPdf(List<QueryDocumentSnapshot> docs) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) {
        List<pw.Widget> content = [];

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final soinsList = data['soins'] as List<dynamic>? ?? [];

          content.add(
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Date : ${formatTimestamp(data['date'])}',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('Infirmier : ${data['infirmier'] ?? ''}'),
                if (data['observation'] != null)
                  pw.Text('Observation : ${data['observation']}'),
                  pw.Text('transmisA : ${data['transmisA']}'),
                pw.Text('Soins effectués :'),
                ...soinsList.map((soin) => pw.Text('- $soin')).toList(),
                pw.Divider(),
                pw.SizedBox(height: 10),
              ],
            ),
          );
        }

        return content;
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
