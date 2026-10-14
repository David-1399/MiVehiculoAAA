import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/catalogs/presentation/controllers/catalogs_provider.dart';
import '../../../../core/evidence/evidence_upload_service.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/evidence_camera_field.dart';
import '../controllers/documents_provider.dart';

class DocumentEditPage extends ConsumerStatefulWidget {
  const DocumentEditPage({super.key});

  @override
  ConsumerState<DocumentEditPage> createState() {
    return _DocumentEditPageState();
  }
}

class _DocumentEditPageState extends ConsumerState<DocumentEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _uploadService = EvidenceUploadService();

  String? _documentTypeId;
  DateTime _issueDate = DateTime.now();
  DateTime? _expirationDate;
  bool _hasExpiration = true;

  String? _newEvidenceLocalPath;
  bool _removeEvidence = false;
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _initialize() {
    if (_initialized) {
      return;
    }

    final document = ref.read(documentsProvider).selectedDocument;

    if (document == null) {
      return;
    }

    _numberController.text = document.number;
    _documentTypeId = document.documentTypeId;
    _issueDate = document.issueDate;
    _expirationDate = document.expirationDate;
    _hasExpiration = document.expirationDate != null;
    _initialized = true;
  }

  String _date(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');

    return '$day/$month/${value.year}';
  }

  Future<void> _pickIssueDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (result != null && mounted) {
      setState(() {
        _issueDate = result;

        if (_expirationDate != null && _expirationDate!.isBefore(result)) {
          _expirationDate = null;
        }
      });
    }
  }

  Future<void> _pickExpirationDate() async {
    final initial =
        _expirationDate ?? _issueDate.add(const Duration(days: 365));

    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _issueDate,
      lastDate: DateTime(2100),
    );

    if (result != null && mounted) {
      setState(() {
        _expirationDate = result;
      });
    }
  }

  Future<void> _submit() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }

    final current = ref.read(documentsProvider).selectedDocument;

    if (current == null) {
      return;
    }

    if (_hasExpiration && _expirationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha de vencimiento.')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      String? evidencePath = current.evidencePath;

      if (_removeEvidence) {
        evidencePath = null;
      }

      if (_newEvidenceLocalPath != null) {
        evidencePath = await _uploadService.uploadImage(_newEvidenceLocalPath!);
      }

      await ref
          .read(documentsProvider.notifier)
          .updateDocument(
            current: current,
            documentTypeId: _documentTypeId!,
            number: _numberController.text,
            issueDate: _issueDate,
            hasExpiration: _hasExpiration,
            expirationDate: _expirationDate,
            evidencePath: evidencePath,
            clearEvidencePath: _removeEvidence && _newEvidenceLocalPath == null,
          );

      if (!mounted) {
        return;
      }

      context.go(AppRoutes.documentDetail);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initialize();

    final document = ref.watch(documentsProvider).selectedDocument;
    final catalogsAsync = ref.watch(catalogsProvider);

    if (document == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar documento')),
        body: Center(
          child: FilledButton(
            onPressed: () {
              context.go(AppRoutes.documents);
            },
            child: const Text('Volver a documentos'),
          ),
        ),
      );
    }

    final evidencePath =
        _newEvidenceLocalPath ??
        (_removeEvidence ? null : document.evidencePath);

    return Scaffold(
      appBar: AppBar(title: const Text('Editar documento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              catalogsAsync.when(
                data: (catalogs) {
                  return DropdownButtonFormField<String>(
                    initialValue: _documentTypeId,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de documento',
                    ),
                    items: catalogs.activeDocumentTypes
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            setState(() {
                              _documentTypeId = value;
                            });
                          },
                    validator: (value) {
                      return value == null || value.isEmpty
                          ? 'Selecciona el tipo'
                          : null;
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, _) =>
                    const Text('No fue posible cargar los tipos de documento.'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberController,
                enabled: !_saving,
                decoration: const InputDecoration(labelText: 'Número'),
                validator: (value) {
                  return value == null || value.trim().isEmpty
                      ? 'Ingresa el número'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de expedición'),
                subtitle: Text(_date(_issueDate)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _saving ? null : _pickIssueDate,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tiene fecha de vencimiento'),
                value: _hasExpiration,
                onChanged: _saving
                    ? null
                    : (value) {
                        setState(() {
                          _hasExpiration = value;

                          if (!value) {
                            _expirationDate = null;
                          }
                        });
                      },
              ),
              if (_hasExpiration)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha de vencimiento'),
                  subtitle: Text(
                    _expirationDate == null
                        ? 'Seleccionar'
                        : _date(_expirationDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: _saving ? null : _pickExpirationDate,
                ),
              const SizedBox(height: 20),
              const Text(
                'Evidencia fotográfica',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              EvidenceCameraField(
                filePath: evidencePath,
                enabled: !_saving,
                onChanged: (value) {
                  setState(() {
                    if (value == null) {
                      _newEvidenceLocalPath = null;
                      _removeEvidence = true;
                    } else {
                      _newEvidenceLocalPath = value;
                      _removeEvidence = false;
                    }
                  });
                },
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: !_saving && catalogsAsync.hasValue ? _submit : null,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
