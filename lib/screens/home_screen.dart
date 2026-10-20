
import 'package:flutter/material.dart';

import '../database/banco_pessoa.dart';
import '../models/pessoa.dart';
import '../services/sessao_service.dart';
import 'login_screen.dart';
import 'pessoa_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pessoa> _pessoas = [];
  bool _carregando = true;
  int? _usuarioId;
  String _nomeUsuario = '';

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final id = await SessaoService.obterUsuarioId();
    final nome = await SessaoService.obterNomeUsuario();

    if (!mounted) return;

    if (id == null || id <= 0) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
        (route) => false,
      );
      return;
    }

    _usuarioId = id;
    _nomeUsuario = nome ?? '';

    await _carregarPessoas();
  }

  Future<void> _carregarPessoas() async {
    final id = _usuarioId;

    if (id == null) return;

    setState(() {
      _carregando = true;
    });

    try {
      final pessoas = await BancoPessoa.listarPessoas(id);

      if (!mounted) return;

      setState(() {
        _pessoas = pessoas;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _carregando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível carregar os contatos.'),
        ),
      );
    }
  }

  Future<void> _abrirFormulario({Pessoa? pessoa}) async {
    final id = _usuarioId;

    if (id == null) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PessoaFormScreen(
          pessoa: pessoa,
          usuarioId: id,
        ),
      ),
    );

    if (resultado == true) {
      await _carregarPessoas();
    }
  }

  Future<void> _excluirPessoa(Pessoa pessoa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir contato'),
        content: Text(
          'Deseja realmente excluir ${pessoa.nome}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true || _usuarioId == null) return;

    try {
      await BancoPessoa.excluirPessoa(pessoa, _usuarioId!);
      await _carregarPessoas();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contato excluído com sucesso.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível excluir o contato.'),
        ),
      );
    }
  }

  Future<void> _sair() async {
    await SessaoService.encerrarSessao();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _abrirMeusContatos() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const corPrincipal = Color(0xFF356859);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),

      // Menu lateral de navegação.
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: corPrincipal,
              ),
              accountName: Text(
                _nomeUsuario.isEmpty ? 'Usuário' : _nomeUsuario,
              ),
              accountEmail: const Text('Agenda de Contatos'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 38,
                  color: corPrincipal,
                ),
              ),
            ),

            ListTile(
              leading: const Icon(
                Icons.contacts_outlined,
                color: corPrincipal,
              ),
              title: const Text('Meus contatos'),
              selected: true,
              onTap: _abrirMeusContatos,
            ),

            const Divider(),

            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text('Sair da conta'),
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _sair();
              },
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Agenda de Contatos',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),

      appBar: AppBar(
        title: const Text('Agenda de Contatos'),
        backgroundColor: corPrincipal,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $_nomeUsuario!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Gerencie seus contatos em um só lugar.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _carregando
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _pessoas.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.contacts_outlined,
                                  size: 76,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Nenhum contato cadastrado',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Toque no botão abaixo para adicionar '
                                  'seu primeiro contato.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => _abrirFormulario(),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Adicionar contato'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _carregarPessoas,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              16, 8, 16, 100,
                            ),
                            itemCount: _pessoas.length,
                            itemBuilder: (context, index) {
                              final pessoa = _pessoas[index];

                              return Dismissible(
                                key: ValueKey(pessoa.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.only(right: 20),
                                  alignment: Alignment.centerRight,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (_) async {
                                  await _excluirPessoa(pessoa);
                                  return false;
                                },
                                child: Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: CircleAvatar(
                                      backgroundColor: corPrincipal,
                                      foregroundColor: Colors.white,
                                      child: Text(
                                        pessoa.nome.isNotEmpty
                                            ? pessoa.nome[0].toUpperCase()
                                            : '?',
                                      ),
                                    ),
                                    title: Text(
                                      pessoa.nome,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        'E-mail: ${pessoa.email}\n'
                                        'Telefone: ${pessoa.telefone}\n'
                                        'Idade: ${pessoa.idade} anos',
                                      ),
                                    ),
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      tooltip: 'Editar contato',
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () =>
                                          _abrirFormulario(pessoa: pessoa),
                                    ),
                                    onTap: () =>
                                        _abrirFormulario(pessoa: pessoa),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        backgroundColor: corPrincipal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Novo contato'),
      ),
    );
  }
}
