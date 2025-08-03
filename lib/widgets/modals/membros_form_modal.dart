import 'package:flutter/material.dart';
import 'package:flutter_dashboard_3/widgets/custom_dropdown_form_field.dart';
import 'package:flutter_dashboard_3/widgets/custom_text_form_field.dart';
import 'package:flutter_dashboard_3/models/membro.dart';
import 'package:flutter_dashboard_3/services/database_service.dart';

class MembrosFormModal extends StatefulWidget {
  final Membro? membro; // Null para novo, com dados para edição

  const MembrosFormModal({super.key, this.membro});

  @override
  State<MembrosFormModal> createState() => _MembrosFormModalState();
}

class _MembrosFormModalState extends State<MembrosFormModal> {
  final _formKey = GlobalKey<FormState>();

  // Controladores dos campos de texto
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _observacoesController;

  // Variáveis para dropdowns e data
  String _statusSelecionado = 'ativo';

  final List<String> _statusList = ['ativo', 'inativo', 'pausado'];

  bool _isLoading = false;
  bool get _isEditing => widget.membro != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _preencherCampos();
  }

  void _initializeControllers() {
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _observacoesController = TextEditingController();
  }

  void _preencherCampos() {
    if (_isEditing && widget.membro != null) {
      _nomeController.text = widget.membro!.nome;
      _emailController.text = widget.membro!.email ?? '';
      _telefoneController.text = widget.membro!.telefone ?? '';
      _observacoesController.text = widget.membro!.observacoes ?? '';
      _statusSelecionado = widget.membro!.status;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _salvarMembro() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final db = DatabaseService();

        if (_isEditing) {
          // Editar membro existente
          final membroAtualizado = Membro(
            id: widget.membro!.id,
            nome: _nomeController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            telefone: _telefoneController.text.trim().isEmpty
                ? null
                : _telefoneController.text.trim(),
            status: _statusSelecionado,
            observacoes: _observacoesController.text.trim().isEmpty
                ? null
                : _observacoesController.text.trim(),
          );

          await db.updateMembro(membroAtualizado);

          if (mounted) {
            _mostrarMensagem('Membro atualizado com sucesso!', Colors.green);
            Navigator.pop(context, true); // Retorna true indicando sucesso
          }
        } else {
          // Criar novo membro
          final novoMembro = Membro(
            nome: _nomeController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
            telefone: _telefoneController.text.trim().isEmpty
                ? null
                : _telefoneController.text.trim(),
            status: _statusSelecionado,
            observacoes: _observacoesController.text.trim().isEmpty
                ? null
                : _observacoesController.text.trim(),
          );

          await db.insertMembro(novoMembro);

          if (mounted) {
            _mostrarMensagem('Membro cadastrado com sucesso!', Colors.green);
            Navigator.pop(context, true); // Retorna true indicando sucesso
          }
        }
      } catch (e) {
        if (mounted) {
          _mostrarMensagem(
            'Erro ao ${_isEditing ? 'atualizar' : 'cadastrar'} membro: $e',
            Colors.red,
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensagem), backgroundColor: cor));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 650),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header do Modal
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withValues(alpha: 0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit : Icons.person_add,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Editar Irmão' : 'Cadastro de Irmão',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close, color: Colors.white),
                    tooltip: 'Fechar',
                  ),
                ],
              ),
            ),
            // Corpo do Modal
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormField(
                          controller: _nomeController,
                          label: "Nome",
                          prefixIcon: Icons.person,
                          isRequired: true,
                          isUpperCase: true,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextFormField(
                                controller: _emailController,
                                label: "E-mail",
                                prefixIcon: Icons.email_sharp,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value != null &&
                                      value.trim().isNotEmpty) {
                                    if (!RegExp(
                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                    ).hasMatch(value)) {
                                      return 'Email inválido';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: CustomTextFormField(
                                controller: _telefoneController,
                                label: "Telefone",
                                prefixIcon: Icons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        CustomDropdownFormField(
                          value: _statusSelecionado,
                          label: 'Status',
                          items: _statusList,
                          prefixIcon: Icons.info,
                          isRequired: true,
                          onChanged: (value) =>
                              setState(() => _statusSelecionado = value!),
                        ),
                        const SizedBox(height: 24),
                        CustomTextFormField(
                          controller: _observacoesController,
                          label: 'Observações',
                          prefixIcon: Icons.note,
                          maxLines: 3,
                          hintText:
                              'Adicione observações adicionais sobre o membro...',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Footer com botões
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surface
                    : colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _salvarMembro,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_isEditing ? Icons.save : Icons.add),
                              const SizedBox(width: 8),
                              Text(_isEditing ? 'Atualizar' : 'Salvar'),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
