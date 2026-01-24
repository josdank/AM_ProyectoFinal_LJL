import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/injection_container.dart';
import '../../../listings/domain/entities/listing.dart';
import '../../domain/entities/visit.dart';
import '../bloc/visit_bloc.dart';
import '../widgets/calendar_widget.dart';

class ScheduleVisitPage extends StatefulWidget {
  final Listing listing;
  final String visitorId;

  const ScheduleVisitPage({
    super.key,
    required this.listing,
    required this.visitorId,
  });

  @override
  State<ScheduleVisitPage> createState() => _ScheduleVisitPageState();
}

class _ScheduleVisitPageState extends State<ScheduleVisitPage> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  TimeOfDay? _selectedTime;
  int _durationMinutes = 30;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _scheduleVisit(BuildContext context) {
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una hora')),
      );
      return;
    }

    final scheduledAt = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Validar que la fecha no sea en el pasado
    if (scheduledAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes agendar en el pasado')),
      );
      return;
    }

    final visit = Visit(
      id: const Uuid().v4(),
      listingId: widget.listing.id,
      visitorId: widget.visitorId,
      scheduledAt: scheduledAt,
      durationMinutes: _durationMinutes,
      status: 'pending',
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    context.read<VisitBloc>().add(VisitScheduleRequested(visit: visit));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VisitBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agendar Visita'),
        ),
        body: BlocConsumer<VisitBloc, VisitState>(
          listener: (context, state) {
            if (state is VisitScheduled) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Visita agendada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is VisitError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is VisitScheduling;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Información de la propiedad
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.listing.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.listing.city}, ${widget.listing.state}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${widget.listing.price.toStringAsFixed(0)}/mes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Calendario
                  Text(
                    'Selecciona una fecha',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seleccionar hora
                  Text(
                    'Selecciona una hora',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Seleccionar hora',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: isLoading ? null : () => _selectTime(context),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Duración
                  Text(
                    'Duración',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Column(
                      children: [
                        RadioListTile<int>(
                          title: const Text('30 minutos'),
                          value: 30,
                          groupValue: _durationMinutes,
                          onChanged: isLoading
                              ? null
                              : (value) =>
                                  setState(() => _durationMinutes = value!),
                        ),
                        RadioListTile<int>(
                          title: const Text('1 hora'),
                          value: 60,
                          groupValue: _durationMinutes,
                          onChanged: isLoading
                              ? null
                              : (value) =>
                                  setState(() => _durationMinutes = value!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notas
                  Text(
                    'Notas (opcional)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Agrega comentarios o preguntas...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Botón agendar
                  ElevatedButton(
                    onPressed: isLoading ? null : () => _scheduleVisit(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Agendar Visita'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}