import 'package:hive_ce_flutter/hive_flutter.dart';

class Conexao {
  // Inicializa o Hive e abre as caixas do aplicativo.
  static Future<void> inicializar() async {
    await Hive.initFlutter();

    await Hive.openBox<Map>('usuarios');
    await Hive.openBox<Map>('pessoas');
  }

  // Caixa que armazenará os usuários cadastrados.
  static Box<Map> get usuarios {
    return Hive.box<Map>('usuarios');
  }

  // Caixa que armazenará os contatos.
  static Box<Map> get pessoas {
    return Hive.box<Map>('pessoas');
  }
}
