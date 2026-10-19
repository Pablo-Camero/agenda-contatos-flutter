
import 'package:flutter/material.dart';

import '../database/banco_pessoa.dart';
import '../models/pessoa.dart';

class PessoaFormScreen extends StatefulWidget {
  final Pessoa? pessoa;
  final int usuarioId;

  const PessoaFormScreen({
    super.key,
    this.pessoa,
    required this.usuarioId,
  });

  @override
  State<PessoaFormScreen> createState() => _PessoaFormScreenState();
}

class _PessoaFormScreenState extends State<PessoaFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _idadeController = TextEditingController();
  final _telefoneController = TextEditingController();

  bool _carregando = false;

  bool get _editando => widget.pessoa != null;

  @override
  void initState() {
    super.initState();

    if (_editando) {
      _nomeController.text = widget.pessoa!.nome;
      _emailController.text = widget.pessoa!.email;
      _idadeController.text = widget.pessoa!.idade.toString();
      _telefoneController.text = widget.pessoa!.telefone;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _idadeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  Future<void> _salvarPessoa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      final pessoa = Pessoa(
        id: widget.pessoa?.id ?? 0,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        idade: int.parse(_idadeController.text.trim()),
        telefone: _telefoneController.text.trim(),
      );

      if (_editando) {
        await BancoPessoa.atualizarPessoa(
          pessoa,
          widget.usuarioId,
        );
      } else {
        await BancoPessoa.inserirPessoa(
          pessoa,
          widget.usuarioId,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Contato atualizado com sucesso!'
                : 'Contato cadastrado com sucesso!',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar o contato.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          _editando ? 'Editar contato' : 'Novo contato',
        ),
        backgroundColor: const Color(0xFF356859),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          _editando
                              ? Icons.edit_note
                              : Icons.person_add_alt_1,
                          size: 64,
                          color: const Color(0xFF356859),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _editando
                              ? 'Atualizar informações'
                              : 'Cadastrar contato',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          _editando
                              ? 'Altere os dados necessários abaixo.'
                              : 'Preencha os dados da pessoa.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 28),

                        TextFormField(
                          controller: _nomeController,
                          enabled: !_carregando,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nome completo',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Informe o nome.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          enabled: !_carregando,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Informe o e-mail.';
                            }

                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(valor.trim())) {
                              return 'Informe um e-mail válido.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _idadeController,
                          enabled: !_carregando,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Idade',
                            prefixIcon: Icon(Icons.cake_outlined),
                            suffixText: 'anos',
                            border: OutlineInputBorder(),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Informe a idade.';
                            }

                            final idade = int.tryParse(valor.trim());

                            if (idade == null) {
                              return 'Digite uma idade válida.';
                            }

                            if (idade < 0 || idade > 120) {
                              return 'A idade deve estar entre 0 e 120.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _telefoneController,
                          enabled: !_carregando,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Telefone',
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: '(67) 99999-9999',
                            border: OutlineInputBorder(),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Informe o telefone.';
                            }

                            if (valor.trim().length < 8) {
                              return 'Informe um telefone válido.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed:
                                _carregando ? null : _salvarPessoa,
                            icon: _carregando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(
                              _carregando
                                  ? 'Salvando...'
                                  : 'Salvar contato',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF356859),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        TextButton(
                          onPressed: _carregando
                              ? null
                              : () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
