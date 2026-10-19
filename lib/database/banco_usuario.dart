
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:sqflite/sqflite.dart';

import 'conexao.dart';
import '../models/usuario.dart';

class BancoUsuario {
  static final Pbkdf2 _algoritmo = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 600000,
    bits: 256,
  );

  static final Random _aleatorio = Random.secure();

  static Future<String> _gerarHash(String senha) async {
    final salt = List<int>.generate(
      16,
      (_) => _aleatorio.nextInt(256),
    );

    final chave = await _algoritmo.deriveKey(
      secretKey: SecretKey(utf8.encode(senha)),
      nonce: salt,
    );

    final bytesChave = await chave.extractBytes();

    return '${base64Encode(salt)}:${base64Encode(bytesChave)}';
  }

  static Future<bool> _verificarSenha(
    String senha,
    String hashArmazenado,
  ) async {
    try {
      final partes = hashArmazenado.split(':');

      if (partes.length != 2) {
        return false;
      }

      final salt = base64Decode(partes[0]);
      final hashOriginal = base64Decode(partes[1]);

      final chave = await _algoritmo.deriveKey(
        secretKey: SecretKey(utf8.encode(senha)),
        nonce: salt,
      );

      final hashDigitado = await chave.extractBytes();

      if (hashOriginal.length != hashDigitado.length) {
        return false;
      }

      var diferenca = 0;

      for (var i = 0; i < hashOriginal.length; i++) {
        diferenca |= hashOriginal[i] ^ hashDigitado[i];
      }

      return diferenca == 0;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> cadastrarUsuario(Usuario usuario) async {
    final db = await Conexao.abrirConexao();

    final email = usuario.email.trim().toLowerCase();

    if (usuario.nome.trim().isEmpty ||
        email.isEmpty ||
        usuario.senha.isEmpty) {
      return false;
    }

    final existente = await db.query(
      'usuarios',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (existente.isNotEmpty) {
      return false;
    }

    final hash = await _gerarHash(usuario.senha);

    try {
      await db.insert(
        'usuarios',
        {
          'nome': usuario.nome.trim(),
          'email': email,
          'senha': hash,
        },
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      return true;
    } on DatabaseException {
      return false;
    }
  }

  static Future<Usuario?> validarLogin(
    String email,
    String senha,
  ) async {
    final db = await Conexao.abrirConexao();

    final resultado = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );

    if (resultado.isEmpty) {
      return null;
    }

    final dados = resultado.first;
    final senhaValida = await _verificarSenha(
      senha,
      dados['senha'] as String,
    );

    if (!senhaValida) {
      return null;
    }

    return Usuario(
      id: dados['id'] as int,
      nome: dados['nome'] as String,
      email: dados['email'] as String,
      senha: '',
    );
  }
}
