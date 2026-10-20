
import 'conexao.dart';
import '../models/pessoa.dart';

class BancoPessoa {
  static Future<void> inserirPessoa(
    Pessoa pessoa,
    int usuarioId,
  ) async {
    final caixa = Conexao.pessoas;

    // Gera um ID numérico para o novo contato.
    var novoId = 1;

    for (final chave in caixa.keys) {
      if (chave is int && chave >= novoId) {
        novoId = chave + 1;
      }
    }

    final dados = pessoa.toMap()
      ..['id'] = novoId
      ..['usuario_id'] = usuarioId;

    await caixa.put(novoId, dados);
  }

  static Future<List<Pessoa>> listarPessoas(
    int usuarioId,
  ) async {
    final caixa = Conexao.pessoas;

    final contatos = caixa.values
        .where((dados) => dados['usuario_id'] == usuarioId)
        .toList();

    contatos.sort((a, b) {
      final nomeA = (a['nome'] as String).toLowerCase();
      final nomeB = (b['nome'] as String).toLowerCase();

      return nomeA.compareTo(nomeB);
    });

    return contatos.map((dados) {
      return Pessoa.fromMap(
        Map<String, dynamic>.from(dados),
      );
    }).toList();
  }

  static Future<void> atualizarPessoa(
    Pessoa pessoa,
    int usuarioId,
  ) async {
    final caixa = Conexao.pessoas;
    final dadosExistentes = caixa.get(pessoa.id);

    if (dadosExistentes == null ||
        dadosExistentes['usuario_id'] != usuarioId) {
      return;
    }

    final dadosAtualizados = pessoa.toMap()
      ..['usuario_id'] = usuarioId;

    await caixa.put(pessoa.id, dadosAtualizados);
  }

  static Future<void> excluirPessoa(
    Pessoa pessoa,
    int usuarioId,
  ) async {
    final caixa = Conexao.pessoas;
    final dadosExistentes = caixa.get(pessoa.id);

    // Impede excluir contatos pertencentes a outro usuário.
    if (dadosExistentes == null ||
        dadosExistentes['usuario_id'] != usuarioId) {
      return;
    }

    await caixa.delete(pessoa.id);
  }
}
