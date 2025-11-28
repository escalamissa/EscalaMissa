
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  Future<void> generateEscalasPdf(List<Map<String, dynamic>> escalas) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text('Relatório de Escalas', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Evento', 'Data/Hora', 'Pastoral', 'Função', 'Voluntário', 'Status'],
              data: escalas.map((escala) {
                final String? dataHora = escala['eventos']?['data_hora'];
                final DateTime? eventDateTime = dataHora != null && dataHora.isNotEmpty ? DateTime.parse(dataHora) : null;
                return [
                  escala['eventos']?['titulo'] ?? 'N/A',
                  eventDateTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(eventDateTime) : 'N/A',
                  escala['pastorais']?['nome'] ?? 'N/A',
                  escala['funcoes']?['nome'] ?? 'N/A',
                  escala['users']?['nome'] ?? 'N/A',
                  escala['status'] ?? 'N/A',
                ];
              }).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(5),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'escalas_report.pdf');
  }

  Future<void> generateAvisosPdf(List<Map<String, dynamic>> avisos) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text('Mural de Avisos', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Título', 'Mensagem', 'Paróquia', 'Pastoral', 'Criado Por', 'Data'],
              data: avisos.map((aviso) {
                final DateTime criadoEm = DateTime.parse(aviso['criado_em']);
                return [
                  aviso['titulo'] ?? 'N/A',
                  aviso['mensagem'] ?? 'N/A',
                  aviso['paroquias']?['nome'] ?? 'N/A',
                  aviso['pastorais']?['nome'] ?? 'N/A',
                  aviso['users']?['nome'] ?? 'N/A',
                  DateFormat('dd/MM/yyyy HH:mm').format(criadoEm),
                ];
              }).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(5),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'avisos_report.pdf');
  }

  Future<void> generateEventsPdf(List<Map<String, dynamic>> events) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Center(
              child: pw.Text('Relatório de Eventos', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Título', 'Data/Hora'],
              data: events.map((event) {
                final String? dataHora = event['data_hora'];
                final DateTime? eventDateTime = dataHora != null ? DateTime.parse(dataHora) : null;
                return [
                  event['titulo'] ?? 'N/A',
                  eventDateTime != null ? DateFormat('dd/MM/yyyy HH:mm').format(eventDateTime) : 'N/A',
                ];
              }).toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(5),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'events_report.pdf');
  }

}
