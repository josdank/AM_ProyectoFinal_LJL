import 'package:flutter/material.dart';

/// Widget de formulario para reportar usuarios
class ReportFormWidget extends StatefulWidget {
  final String reporterId;
  final String reportedId;
  final String reportedName;
  final Function(String reason, String? details) onSubmit;

  const ReportFormWidget({
    super.key,
    required this.reporterId,
    required this.reportedId,
    required this.reportedName,
    required this.onSubmit,
  });

  @override
  State<ReportFormWidget> createState() => _ReportFormWidgetState();
}

class _ReportFormWidgetState extends State<ReportFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _detailsController = TextEditingController();
  String _selectedReason = 'comportamiento_inapropiado';

  static const Map<String, String> _reasons = {
    'comportamiento_inapropiado': '🚫 Comportamiento inapropiado',
    'informacion_falsa': '📝 Información falsa',
    'acoso': '⚠️ Acoso o intimidación',
    'spam': '📧 Spam o publicidad',
    'fraude': '💳 Intento de fraude',
    'otro': '❓ Otro motivo',
  };

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.flag, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reportar usuario',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Reportando a ${widget.reportedName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Advertencia
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Los reportes son revisados por nuestro equipo. El uso indebido de esta función puede resultar en restricciones.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Selector de motivo
              Text(
                'Motivo del reporte *',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              
              ..._reasons.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _selectedReason,
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value!;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),

              const SizedBox(height: 16),

              // Campo de detalles
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Detalles (opcional)',
                  hintText: 'Proporciona más información sobre el motivo...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 500,
              ),

              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final details = _detailsController.text.trim();
                          widget.onSubmit(
                            _selectedReason,
                            details.isEmpty ? null : details,
                          );
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Enviar reporte'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Función helper para mostrar el diálogo de reporte
Future<void> showReportDialog({
  required BuildContext context,
  required String reporterId,
  required String reportedId,
  required String reportedName,
  required Function(String reason, String? details) onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ReportFormWidget(
      reporterId: reporterId,
      reportedId: reportedId,
      reportedName: reportedName,
      onSubmit: onSubmit,
    ),
  );
}