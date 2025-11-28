import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:escala_missa/services/liturgical_calendar_service.dart';

class LiturgyScreen extends StatefulWidget {
  const LiturgyScreen({super.key});

  @override
  State<LiturgyScreen> createState() => _LiturgyScreenState();
}

class _LiturgyScreenState extends State<LiturgyScreen> {
  final LiturgicalCalendarService _liturgicalCalendarService = LiturgicalCalendarService();
  DateTime _selectedDate = DateTime.now();
  Map<String, dynamic>? _liturgicalData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLiturgyData();
  }

  Future<void> _fetchLiturgyData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _liturgicalData = await _liturgicalCalendarService.getLiturgicalData(_selectedDate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao carregar dados litúrgicos: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _fetchLiturgyData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Liturgia Diária', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDateSelector(context, theme),
                  const SizedBox(height: 24),
                  if (_liturgicalData == null)
                    _buildEmptyState(context)
                  else
                    _buildLiturgyDetails(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildDateSelector(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text('Data Selecionada', style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[600])),
                   const SizedBox(height: 4),
                   Text(DateFormat("EEEE, dd 'de' MMMM 'de' yyyy", 'pt_BR').format(_selectedDate), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Icon(Icons.calendar_month_outlined, color: theme.colorScheme.primary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Nenhum dado litúrgico encontrado para esta data.', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLiturgyDetails(ThemeData theme) {
    final solenidade = _liturgicalData!['solenidade'];
    final solenidadeNome = solenidade is Map ? solenidade['nome']?.toString() : solenidade?.toString();
    
    return Column(
      children: [
        _LiturgyHeaderCard(
          liturgicalTime: _liturgicalData!['liturgia']?.toString() ?? 'N/A',
          solenity: solenidadeNome,
          colorName: _liturgicalData!['cor']?.toString() ?? 'N/A',
        ),
        const SizedBox(height: 16),
        _ReadingsCard(readings: _liturgicalData!['leituras'] as Map<String, dynamic>?),
      ],
    );
  }
}

class _LiturgyHeaderCard extends StatelessWidget {
  final String liturgicalTime;
  final String? solenity;
  final String colorName;
  
  const _LiturgyHeaderCard({required this.liturgicalTime, this.solenity, required this.colorName});

  Color _getLiturgicalColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'verde': return Colors.green;
      case 'vermelho': return Colors.red;
      case 'branco': return Colors.white;
      case 'roxo': return Colors.purple;
      case 'rosa': return Colors.pink;
      case 'preto': return Colors.black;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayColor = _getLiturgicalColor(colorName);
    
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(solenity != null && solenity!.isNotEmpty)
              Text(solenity!, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            if(solenity != null && solenity!.isNotEmpty) const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: displayColor,
                    radius: 8,
                  ),
                ),
                const SizedBox(width: 8),
                Text(liturgicalTime, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingsCard extends StatelessWidget {
  final Map<String, dynamic>? readings;
  const _ReadingsCard({this.readings});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (readings == null || readings!.isEmpty) {
      return const SizedBox.shrink();
    }

    String allReadingsText = '';
    final List<Widget> readingWidgets = [];

    readings!.forEach((key, value) {
      if (value is List) {
        for (var readingMap in value) {
          if (readingMap is Map) {
            final title = (readingMap['referencia'] ?? key).toString();
            final text = (readingMap['texto'] ?? '').toString();
            
            allReadingsText += '$title\n$text\n\n';

            readingWidgets.add(
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                    const SizedBox(height: 12),
                    Text(text, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, fontSize: 16)),
                  ],
                ),
              ),
            );
          }
        }
      }
    });

    return Card(
       elevation: 1,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Leituras do Dia', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.copy_outlined),
                  tooltip: 'Copiar Leituras',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: allReadingsText.trim()));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leituras copiadas!')));
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            ...readingWidgets,
          ],
        ),
      ),
    );
  }
}