
import 'package:shared_preferences/shared_preferences.dart';

import '../models/usuario.dart';

class SessaoService{
  static const String _chaveId = 'usuario_id';
  static const String _chaveNome = 'usuario_nome';
  static const String _chaveEmail = 'usuario_email';

  // Salva os dados do usuário que fez login.
  static Future<void> salvarSessao(Usuario usuario) async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.setInt(_chaveId, usuario.id);
    await preferencias.setString(_chaveNome, usuario.nome);
    await preferencias.setString(_chaveEmail, usuario.email);
  }

  // Recupera o ID do usuário conectado.
  static Future<int?> obterUsuarioId() async {
    final preferencias = await SharedPreferences.getInstance();

    return preferencias.getInt(_chaveId);
  }

  // Recupera o nome do usuário conectado.
  static Future<String?> obterNomeUsuario() async {
    final preferencias = await SharedPreferences.getInstance();

    return preferencias.getString(_chaveNome);
  }

  // Verifica se existe uma sessão salva.
  static Future<bool> estaLogado() async {
    final id = await obterUsuarioId();

    return id != null && id > 0;
  }

  // Encerra a sessão do usuário.
  static Future<void> encerrarSessao() async {
    final preferencias = await SharedPreferences.getInstance();

    await preferencias.remove(_chaveId);
    await preferencias.remove(_chaveNome);
    await preferencias.remove(_chaveEmail);
  }
}
