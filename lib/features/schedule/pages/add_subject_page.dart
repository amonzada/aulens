import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
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
      await provider.addSubject(
        name: _nameCtrl.text,
        professor: _professorCtrl.text,
        classroom: _classroomCtrl.text,
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
          child: Column(
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
