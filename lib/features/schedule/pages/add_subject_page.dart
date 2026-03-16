import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/providers/schedule_provider.dart';
import '../models/subject.dart';

/// Simple form for creating a new [Subject].
class AddSubjectPage extends StatefulWidget {
  final Subject? subject;
  const AddSubjectPage({super.key, this.subject});

  @override
  State<AddSubjectPage> createState() => _AddSubjectPageState();
}

class _AddSubjectPageState extends State<AddSubjectPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _professorCtrl;
  late final TextEditingController _classroomCtrl;
  int? _weekday;
  TimeOfDay? _start;
  TimeOfDay? _end;
  bool _saving = false;

  bool get _isEdit => widget.subject != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.subject?.name ?? '');
    _professorCtrl =
        TextEditingController(text: widget.subject?.professor ?? '');
    _classroomCtrl =
        TextEditingController(text: widget.subject?.classroom ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _professorCtrl.dispose();
    _classroomCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  int _mins(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_start ?? const TimeOfDay(hour: 8, minute: 0))
        : (_end ?? const TimeOfDay(hour: 10, minute: 0));
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final hasAnyScheduleField =
        _weekday != null || _start != null || _end != null;
    if (hasAnyScheduleField) {
      if (_weekday == null || _start == null || _end == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Complete weekday, start time, and end time.'),
          ),
        );
        return;
      }

      if (_mins(_start!) >= _mins(_end!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End time must be after start time.'),
          ),
        );
        return;
      }
    }

    setState(() => _saving = true);
    final provider = context.read<ScheduleProvider>();
    if (_isEdit) {
      await provider.updateSubject(
        id: widget.subject!.id!,
        name: _nameCtrl.text,
        professor: _professorCtrl.text,
        classroom: _classroomCtrl.text,
      );
    } else {
      await provider.addSubjectWithOptionalSchedule(
        name: _nameCtrl.text,
        professor: _professorCtrl.text,
        classroom: _classroomCtrl.text,
        weekday: _weekday,
        startTime: _start == null ? null : _fmt(_start!),
        endTime: _end == null ? null : _fmt(_end!),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Subject' : 'New Subject')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Subject name',
                  hintText: 'e.g., Mathematics',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty)
                        ? 'Name cannot be empty'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _professorCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Professor (optional)',
                  hintText: 'e.g., Dr. Almeida',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _classroomCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Classroom (optional)',
                  hintText: 'e.g., IC-402',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Schedule (Optional)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _weekday,
                  decoration: const InputDecoration(
                    labelText: 'Weekday',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  items: List.generate(
                    AppConstants.weekdayNames.length,
                    (i) => DropdownMenuItem<int>(
                      value: i + 1,
                      child: Text(AppConstants.weekdayNames[i]),
                    ),
                  ),
                  onChanged: _saving
                      ? null
                      : (value) => setState(() => _weekday = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TimeField(
                        label: 'Start time',
                        value: _start,
                        onTap: _saving
                            ? null
                            : () => _pickTime(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeField(
                        label: 'End time',
                        value: _end,
                        onTap: _saving
                            ? null
                            : () => _pickTime(isStart: false),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEdit ? 'Save Changes' : 'Save Subject'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay? value;
  final VoidCallback? onTap;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? 'Select'
        : '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.schedule_outlined),
        ),
        child: Text(text),
      ),
    );
  }
}
