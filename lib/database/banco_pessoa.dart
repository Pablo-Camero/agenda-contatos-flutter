
import 'package:sqflite/sqflite.dart';

import 'conexao.dart';
import '../models/pessoa.dart';

class BancoPessoa {
  static Future<void> inserirPessoa(
    Pessoa pessoa,
    int usuarioId,
  ) async {
    final db = await Conexao.abrirConexao();

    final dados = pessoa.toMap()
      ..remove('id')
      ..['usuario_id'] = usuarioId;

    await db.insert(
      'pessoas',
      dados,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<List<Pessoa>> listarPessoas(
    int usuarioId,
  ) async {
    final db = await Conexao.abrirConexao();

    final List<Map<String, dynamic>> maps = await db.query(
      'pessoas',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'nome ASC',
    );

    return List.generate(maps.length, (i) {
      return Pessoa.fromMap(maps[i]);
    });
  }

  static Future<void> atualizarPessoa(
    Pessoa pessoa,
    int usuarioId,
  ) async {
    final db = await Conexao.abrirConexao();

    await db.update(
      'pessoas',
      pessoa.toMap()..remove('usuario_id'),
      where: 'id = ? AND usuario_id = ?',
      whereArgs: [pessoa.id, usuarioId],
    );
  }

  static Future<void> excluirPessoa(
    Pessoa pessoa,
    int usuarioId,
  ) async {
    final db = await Conexao.abrirConexao();

    await db.delete(
      'pessoas',
      where: 'id = ? AND usuario_id = ?',
      whereArgs: [pessoa.id, usuarioId],
    );
  }
}
