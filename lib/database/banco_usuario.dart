
import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

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
    final caixa = Conexao.usuarios;

    final nome = usuario.nome.trim();
    final email = usuario.email.trim().toLowerCase();

    if (nome.isEmpty || email.isEmpty || usuario.senha.isEmpty) {
      return false;
    }

    // Verifica se já existe um usuário com esse e-mail.
    final existente = caixa.values.any((dados) {
      return dados['email'] == email;
    });

    if (existente) {
      return false;
    }

    final hash = await _gerarHash(usuario.senha);

    // Gera um ID numérico para o novo usuário.
    var novoId = 1;

    for (final chave in caixa.keys) {
      if (chave is int && chave >= novoId) {
        novoId = chave + 1;
      }
    }

    await caixa.put(novoId, {
      'id': novoId,
      'nome': nome,
      'email': email,
      'senha': hash,
    });

    return true;
  }

  static Future<Usuario?> validarLogin(
    String email,
    String senha,
  ) async {
    final caixa = Conexao.usuarios;
    final emailNormalizado = email.trim().toLowerCase();

    for (final dados in caixa.values) {
      if (dados['email'] == emailNormalizado) {
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

    return null;
  }
}
