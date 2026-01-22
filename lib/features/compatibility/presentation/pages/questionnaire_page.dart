import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/habits.dart';

class QuestionnairePage extends StatefulWidget {
  final String userId;
  final Habits? existingHabits; // Para editar hábitos existentes

  const QuestionnairePage({
    super.key,
    required this.userId,
    this.existingHabits,
  });

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Respuestas del cuestionario
  String _sleepSchedule = 'flexible';
  int _noiseToleranceLevel = 3;
  int _cleanlinessLevel = 3;
  String _cleaningFrequency = 'weekly';
  String _socialPreference = 'moderate';
  bool _guestsAllowed = true;
  String _guestFrequency = 'occasionally';
  bool _smoker = false;
  bool _drinker = false;
  bool _hasPets = false;
  String? _petType;
  String _workSchedule = 'flexible';
  bool _worksFromHome = false;
  bool _sharedCommonAreas = true;
  bool _sharedKitchenware = true;
  String _temperaturePreference = 'moderate';
  List<String> _hobbies = [];
  int _musicVolume = 3;

  @override
  void initState() {
    super.initState();
    // Cargar hábitos existentes si hay
    if (widget.existingHabits != null) {
      _loadExistingHabits(widget.existingHabits!);
    }
  }

  void _loadExistingHabits(Habits habits) {
    setState(() {
      _sleepSchedule = habits.sleepSchedule;
      _noiseToleranceLevel = habits.noiseToleranceLevel;
      _cleanlinessLevel = habits.cleanlinessLevel;
      _cleaningFrequency = habits.cleaningFrequency;
      _socialPreference = habits.socialPreference;
      _guestsAllowed = habits.guestsAllowed;
      _guestFrequency = habits.guestFrequency;
      _smoker = habits.smoker;
      _drinker = habits.drinker;
      _hasPets = habits.hasPets;
      _petType = habits.petType;
      _workSchedule = habits.workSchedule;
      _worksFromHome = habits.worksFromHome;
      _sharedCommonAreas = habits.sharedCommonAreas;
      _sharedKitchenware = habits.sharedKitchenware;
      _temperaturePreference = habits.temperaturePreference;
      _hobbies = List.from(habits.hobbies);
      _musicVolume = habits.musicVolume;
    });
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _saveHabits() {
    // Validar que si tiene mascotas, especificó el tipo
    if (_hasPets && (_petType == null || _petType!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor especifica el tipo de mascota')),
      );
      return;
    }

    final habits = Habits(
      id: widget.existingHabits?.id ?? const Uuid().v4(),
      userId: widget.userId,
      sleepSchedule: _sleepSchedule,
      noiseToleranceLevel: _noiseToleranceLevel,
      cleanlinessLevel: _cleanlinessLevel,
      cleaningFrequency: _cleaningFrequency,
      socialPreference: _socialPreference,
      guestsAllowed: _guestsAllowed,
      guestFrequency: _guestFrequency,
      smoker: _smoker,
      drinker: _drinker,
      hasPets: _hasPets,
      petType: _hasPets ? _petType : null,
      workSchedule: _workSchedule,
      worksFromHome: _worksFromHome,
      sharedCommonAreas: _sharedCommonAreas,
      sharedKitchenware: _sharedKitchenware,
      temperaturePreference: _temperaturePreference,
      hobbies: _hobbies,
      musicVolume: _musicVolume,
      createdAt: widget.existingHabits?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(habits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuestionario de Compatibilidad'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 6,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildSleepPage(),
          _buildCleanlinessPage(),
          _buildSocialPage(),
          _buildLifestylePage(),
          _buildWorkPage(),
          _buildPreferencesPage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    child: const Text('Anterior'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentPage == 5 ? _saveHabits : _nextPage,
                  child: Text(_currentPage == 5 ? 'Guardar' : 'Siguiente'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSleepPage() {
    return _QuestionSection(
      title: '😴 Hábitos de Sueño',
      children: [
        _QuestionCard(
          question: '¿Cuál es tu horario de sueño?',
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('🌅 Madrugador (duermo y despierto temprano)'),
                value: 'early_bird',
                groupValue: _sleepSchedule,
                onChanged: (value) => setState(() => _sleepSchedule = value!),
              ),
              RadioListTile<String>(
                title: const Text('🦉 Nocturno (duermo y despierto tarde)'),
                value: 'night_owl',
                groupValue: _sleepSchedule,
                onChanged: (value) => setState(() => _sleepSchedule = value!),
              ),
              RadioListTile<String>(
                title: const Text('⏰ Flexible (me adapto fácilmente)'),
                value: 'flexible',
                groupValue: _sleepSchedule,
                onChanged: (value) => setState(() => _sleepSchedule = value!),
              ),
            ],
          ),
        ),
        _QuestionCard(
          question: '¿Qué tan tolerante eres al ruido mientras duermes?',
          child: _SliderQuestion(
            value: _noiseToleranceLevel,
            min: 1,
            max: 5,
            labels: const ['Muy sensible', 'Sensible', 'Normal', 'Tolerante', 'Muy tolerante'],
            onChanged: (value) => setState(() => _noiseToleranceLevel = value.round()),
          ),
        ),
      ],
    );
  }

  Widget _buildCleanlinessPage() {
    return _QuestionSection(
      title: '🧹 Limpieza y Orden',
      children: [
        _QuestionCard(
          question: '¿Qué tan ordenado/limpio eres?',
          child: _SliderQuestion(
            value: _cleanlinessLevel,
            min: 1,
            max: 5,
            labels: const ['No me importa', 'Poco', 'Normal', 'Bastante', 'Muy ordenado'],
            onChanged: (value) => setState(() => _cleanlinessLevel = value.round()),
          ),
        ),
        _QuestionCard(
          question: '¿Con qué frecuencia limpias?',
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Diariamente'),
                value: 'daily',
                groupValue: _cleaningFrequency,
                onChanged: (value) => setState(() => _cleaningFrequency = value!),
              ),
              RadioListTile<String>(
                title: const Text('Semanalmente'),
                value: 'weekly',
                groupValue: _cleaningFrequency,
                onChanged: (value) => setState(() => _cleaningFrequency = value!),
              ),
              RadioListTile<String>(
                title: const Text('Cuando sea necesario'),
                value: 'as_needed',
                groupValue: _cleaningFrequency,
                onChanged: (value) => setState(() => _cleaningFrequency = value!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialPage() {
    return _QuestionSection(
      title: '👥 Vida Social',
      children: [
        _QuestionCard(
          question: '¿Cómo te describes socialmente?',
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Muy social (me encanta tener gente en casa)'),
                value: 'very_social',
                groupValue: _socialPreference,
                onChanged: (value) => setState(() => _socialPreference = value!),
              ),
              RadioListTile<String>(
                title: const Text('Moderado (ocasionalmente me gusta socializar)'),
                value: 'moderate',
                groupValue: _socialPreference,
                onChanged: (value) => setState(() => _socialPreference = value!),
              ),
              RadioListTile<String>(
                title: const Text('Privado (prefiero mi espacio personal)'),
                value: 'private',
                groupValue: _socialPreference,
                onChanged: (value) => setState(() => _socialPreference = value!),
              ),
            ],
          ),
        ),
        _QuestionCard(
          question: '¿Permites invitados en casa?',
          child: SwitchListTile(
            title: const Text('Sí, permito invitados'),
            value: _guestsAllowed,
            onChanged: (value) => setState(() => _guestsAllowed = value),
          ),
        ),
        if (_guestsAllowed)
          _QuestionCard(
            question: '¿Con qué frecuencia invitas gente?',
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Frecuentemente'),
                  value: 'frequently',
                  groupValue: _guestFrequency,
                  onChanged: (value) => setState(() => _guestFrequency = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Ocasionalmente'),
                  value: 'occasionally',
                  groupValue: _guestFrequency,
                  onChanged: (value) => setState(() => _guestFrequency = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Raramente'),
                  value: 'rarely',
                  groupValue: _guestFrequency,
                  onChanged: (value) => setState(() => _guestFrequency = value!),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLifestylePage() {
    return _QuestionSection(
      title: '🌟 Estilo de Vida',
      children: [
        _QuestionCard(
          question: 'Hábitos',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('🚬 Fumo'),
                value: _smoker,
                onChanged: (value) => setState(() => _smoker = value),
              ),
              SwitchListTile(
                title: const Text('🍺 Bebo alcohol'),
                value: _drinker,
                onChanged: (value) => setState(() => _drinker = value),
              ),
            ],
          ),
        ),
        _QuestionCard(
          question: 'Mascotas',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Tengo mascotas'),
                value: _hasPets,
                onChanged: (value) => setState(() {
                  _hasPets = value;
                  if (!value) _petType = null;
                }),
              ),
              if (_hasPets)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: _petType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de mascota',
                      hintText: 'Ej: Perro, Gato, etc.',
                    ),
                    onChanged: (value) => _petType = value,
                  ),
                ),
            ],
          ),
        ),
        _QuestionCard(
          question: 'Preferencia de temperatura',
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('❄️ Frío'),
                value: 'cold',
                groupValue: _temperaturePreference,
                onChanged: (value) => setState(() => _temperaturePreference = value!),
              ),
              RadioListTile<String>(
                title: const Text('🌡️ Moderado'),
                value: 'moderate',
                groupValue: _temperaturePreference,
                onChanged: (value) => setState(() => _temperaturePreference = value!),
              ),
              RadioListTile<String>(
                title: const Text('🔥 Calor'),
                value: 'warm',
                groupValue: _temperaturePreference,
                onChanged: (value) => setState(() => _temperaturePreference = value!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkPage() {
    return _QuestionSection(
      title: '💼 Trabajo y Estudio',
      children: [
        _QuestionCard(
          question: '¿Cuál es tu horario de trabajo/estudio?',
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Mañana'),
                value: 'morning',
                groupValue: _workSchedule,
                onChanged: (value) => setState(() => _workSchedule = value!),
              ),
              RadioListTile<String>(
                title: const Text('Tarde'),
                value: 'afternoon',
                groupValue: _workSchedule,
                onChanged: (value) => setState(() => _workSchedule = value!),
              ),
              RadioListTile<String>(
                title: const Text('Noche'),
                value: 'evening',
                groupValue: _workSchedule,
                onChanged: (value) => setState(() => _workSchedule = value!),
              ),
              RadioListTile<String>(
                title: const Text('Madrugada'),
                value: 'night',
                groupValue: _workSchedule,
                onChanged: (value) => setState(() => _workSchedule = value!),
              ),
              RadioListTile<String>(
                title: const Text('Flexible'),
                value: 'flexible',
                groupValue: _workSchedule,
                onChanged: (value) => setState(() => _workSchedule = value!),
              ),
            ],
          ),
        ),
        _QuestionCard(
          question: '¿Trabajas desde casa?',
          child: SwitchListTile(
            title: const Text('Sí, trabajo/estudio desde casa'),
            value: _worksFromHome,
            onChanged: (value) => setState(() => _worksFromHome = value),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesPage() {
    return _QuestionSection(
      title: '🏠 Preferencias de Vivienda',
      children: [
        _QuestionCard(
          question: 'Compartir espacios',
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Comparto áreas comunes'),
                value: _sharedCommonAreas,
                onChanged: (value) => setState(() => _sharedCommonAreas = value),
              ),
              SwitchListTile(
                title: const Text('Comparto utensilios de cocina'),
                value: _sharedKitchenware,
                onChanged: (value) => setState(() => _sharedKitchenware = value),
              ),
            ],
          ),
        ),
        _QuestionCard(
          question: '¿Qué tan alto escuchas música/TV?',
          child: _SliderQuestion(
            value: _musicVolume,
            min: 1,
            max: 5,
            labels: const ['Muy bajo', 'Bajo', 'Medio', 'Alto', 'Muy alto'],
            onChanged: (value) => setState(() => _musicVolume = value.round()),
          ),
        ),
      ],
    );
  }
}

class _QuestionSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _QuestionSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final Widget child;

  const _QuestionCard({
    required this.question,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _SliderQuestion extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final List<String> labels;
  final ValueChanged<double> onChanged;

  const _SliderQuestion({
    required this.value,
    required this.min,
    required this.max,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          label: labels[value - min],
          onChanged: onChanged,
        ),
        Text(
          labels[value - min],
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}