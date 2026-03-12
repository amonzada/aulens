import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/notes_provider.dart';
import '../../../shared/providers/schedule_provider.dart';
import '../../../shared/providers/settings_provider.dart';
import '../../../shared/widgets/app_snackbar.dart';
import '../../../shared/widgets/permission_alerts.dart';
import '../../schedule/models/subject.dart';
import '../services/camera_service.dart';
import '../services/ocr_service.dart';
import '../services/permission_service.dart';

// ── State machine ─────────────────────────────────────────────────────────────
enum _CaptureState { idle, processing, preview }

/// Camera tab – guides the student through capturing a whiteboard photo,
/// auto-detecting the current class, running OCR and saving the note.
class CameraPage extends StatefulWidget {
  final bool autoCapture;
  final Subject? fixedSubject;

  const CameraPage({
    super.key,
    this.autoCapture = false,
    this.fixedSubject,
  });

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  _CaptureState _state = _CaptureState.idle;
  String? _imagePath;
  Subject? _detectedSubject; // auto-detected, shown as a hint
  Subject? _selectedSubject; // what will actually be saved
  bool _saving = false;
  bool _autoCaptureDone = false;

  @override
  void initState() {
    super.initState();
    if (widget.fixedSubject != null) {
      _detectedSubject = widget.fixedSubject;
      _selectedSubject = widget.fixedSubject;
    }

    if (widget.autoCapture) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _autoCaptureDone) return;
        _autoCaptureDone = true;
        _capture();
      });
    }
  }

  // ── Capture flow ───────────────────────────────────────────────────────────

  Future<void> _capture() async {
    // Capture the provider reference before any async gap.
    final scheduleProvider = context.read<ScheduleProvider>();
    final settings = context.read<SettingsProvider>();

    final permissionResult =
        await PermissionService.instance.ensureCameraFlowPermissions();
    if (!mounted) return;

    if (permissionResult == PermissionFlowResult.denied) {
      await PermissionAlerts.showDenied(context);
      return;
    }

    if (permissionResult == PermissionFlowResult.permanentlyDenied) {
      await PermissionAlerts.showPermanentlyDenied(context);
      return;
    }

    setState(() => _state = _CaptureState.processing);

    String? path;
    try {
      // 1. Take photo and persist to documents directory.
      path = await CameraService.instance.capturePhoto();
    } catch (_) {
      if (!mounted) return;
      setState(() => _state = _CaptureState.idle);
      AppSnackBar.showError(context, 'Unable to open camera right now.');
      return;
    }

    if (path == null) {
      // User cancelled – go back to idle.
      if (!mounted) return;
      setState(() => _state = _CaptureState.idle);
      return;
    }

    // 2. Auto-detect current class from schedule.
    final now = DateTime.now();
    final entry = scheduleProvider.getCurrentClass(
      preGraceMinutes: settings.preGraceMinutes,
      postGraceMinutes: settings.postGraceMinutes,
    );
    final detected = entry != null
        ? scheduleProvider.resolveSubjectForEntryOnDate(
            entry,
            now,
          )
        : null;
    final subject = widget.fixedSubject ?? detected;

    if (!mounted) return;
    setState(() {
      _imagePath = path;
      _detectedSubject = detected;
      _selectedSubject = subject; // pre-select the detected or fixed subject
      _state = _CaptureState.preview;
    });
  }

  // ── Save / discard ─────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_saving) return;
    if (_selectedSubject == null) {
      AppSnackBar.showInfo(context, 'Please select a subject first.');
      return;
    }

    final subjectId = _selectedSubject!.id;
    if (subjectId == null) {
      AppSnackBar.showError(context, 'Subject is not ready yet.');
      return;
    }

    if (_imagePath == null) {
      AppSnackBar.showInfo(context, 'No captured image to save.');
      return;
    }

    final imagePath = _imagePath!;
    final notesProvider = context.read<NotesProvider>();
    final scheduleProvider = context.read<ScheduleProvider>();
    final settings = context.read<SettingsProvider>();
    final now = DateTime.now();
    final entry = scheduleProvider.getCurrentClass(
      preGraceMinutes: settings.preGraceMinutes,
      postGraceMinutes: settings.postGraceMinutes,
    );
    final detected = entry != null
        ? scheduleProvider.resolveSubjectForEntryOnDate(
            entry,
            now,
          )
        : null;

    setState(() => _saving = true);
    try {
      final savedNote = await notesProvider.addPhotoNote(
        subjectId: subjectId,
        imagePath: imagePath,
        ocrText: null,
      );

      if (entry != null && detected != null && detected.id != subjectId) {
        final entryId = entry.id;
        if (entryId != null) {
          await scheduleProvider.setSessionOverride(
            scheduleEntryId: entryId,
            date: now,
            subjectId: subjectId,
          );
        }
      }

      CameraService.instance.enqueueBackgroundOcr(
        subjectId: subjectId,
        imagePath: imagePath,
        createdAt: DateTime.now(),
        runOcr: OcrService.instance.extractText,
        saveNote: (ocrText) async {
          if (savedNote.id != null) {
            await notesProvider.updateOcrText(savedNote.id!, ocrText);
          }
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      AppSnackBar.showError(context, 'Failed to save note. Please try again.');
      return;
    }

    if (!mounted) return;
    AppSnackBar.showInfo(context, 'Processing OCR in background...');
    _reset();
  }

  Future<void> _discard() async {
    // Remove the already-persisted image file (user chose not to save).
    final path = _imagePath;
    if (path != null) {
      await CameraService.instance.deleteCapturedPhotoIfOwned(path);
    }
    _reset();
  }

  void _reset() => setState(() {
        _state = _CaptureState.idle;
        _imagePath = null;
        _detectedSubject = null;
        _selectedSubject = null;
        _saving = false;
      });

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: switch (_state) {
        _CaptureState.idle => _IdleView(onCapture: _capture),
        _CaptureState.processing => const _ProcessingView(),
        _CaptureState.preview => _PreviewView(
            imagePath: _imagePath!,
            detectedSubject: _detectedSubject,
            selectedSubject: _selectedSubject,
            subjects: context.watch<ScheduleProvider>().subjects.toList(),
            onSubjectChanged: (s) => setState(() => _selectedSubject = s),
            onSave: _save,
            onDiscard: () {
              _discard();
            },
            isSaving: _saving,
          ),
      },
    );
  }
}

// ── Idle view ─────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final VoidCallback onCapture;
  const _IdleView({required this.onCapture});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.camera_alt_outlined, size: 80, color: cs.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Capture a whiteboard',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'The app will detect your current class\n'
            'and extract the text automatically.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 40),
          FloatingActionButton.large(
            heroTag: 'capture_fab',
            onPressed: onCapture,
            child: const Icon(Icons.camera_alt, size: 36),
          ),
        ],
      ),
    );
  }
}

// ── Processing view ───────────────────────────────────────────────────────────

class _ProcessingView extends StatelessWidget {
  const _ProcessingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Analysing image…'),
        ],
      ),
    );
  }
}

// ── Preview view ──────────────────────────────────────────────────────────────

class _PreviewView extends StatelessWidget {
  final String imagePath;
  final Subject? detectedSubject;
  final Subject? selectedSubject;
  final List<Subject> subjects;
  final ValueChanged<Subject?> onSubjectChanged;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final bool isSaving;

  const _PreviewView({
    required this.imagePath,
    required this.detectedSubject,
    required this.selectedSubject,
    required this.subjects,
    required this.onSubjectChanged,
    required this.onSave,
    required this.onDiscard,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        // ── Photo preview ─────────────────────────────────────────────────
        Expanded(
          flex: 5,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),

        // ── Info panel ────────────────────────────────────────────────────
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Detection chip
                _StatusChip(
                  icon: detectedSubject != null
                      ? Icons.auto_awesome
                      : Icons.info_outline,
                  label: detectedSubject != null
                      ? 'Auto-detected: ${detectedSubject!.name}'
                      : 'No class currently scheduled',
                  color: detectedSubject != null
                      ? cs.primaryContainer
                      : cs.secondaryContainer,
                  textColor: detectedSubject != null
                      ? cs.onPrimaryContainer
                      : cs.onSecondaryContainer,
                ),
                const SizedBox(height: 12),

                // Subject selector
                if (subjects.isEmpty)
                  Text(
                    'No subjects found. Add subjects in the Schedule tab first.',
                    style: TextStyle(color: cs.error),
                  )
                else
                  DropdownButtonFormField<Subject>(
                    initialValue: selectedSubject,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      prefixIcon: Icon(Icons.school_outlined),
                    ),
                    items: subjects
                        .map((s) =>
                            DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: onSubjectChanged,
                  ),
                const SizedBox(height: 12),

                // OCR processing hint
                Text('OCR', style: theme.textTheme.labelMedium),
                const SizedBox(height: 4),
                Text(
                  'Text extraction runs in the background after you tap Save.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isSaving ? null : onDiscard,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Discard'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.error,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isSaving ? null : onSave,
                        icon: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(isSaving ? 'Saving...' : 'Save Note'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: textColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
