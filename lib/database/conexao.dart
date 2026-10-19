
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Conexao {
  static Future<Database> abrirConexao() async {
    final caminhoBanco = await getDatabasesPath();
    final caminhoCompleto = join(caminhoBanco, 'pessoas.db');

    return await openDatabase(
      caminhoCompleto,
      version: 2,

      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            senha TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE pessoas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            idade INTEGER NOT NULL,
            email TEXT NOT NULL,
            telefone TEXT NOT NULL,
            usuario_id INTEGER NOT NULL,
            FOREIGN KEY (usuario_id)
              REFERENCES usuarios (id)
              ON DELETE CASCADE
          )
        ''');
      },

      onUpgrade: (db, versaoAntiga, versaoNova) async {
        if (versaoAntiga < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS usuarios (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nome TEXT NOT NULL,
              email TEXT NOT NULL UNIQUE,
              senha TEXT NOT NULL
            )
          ''');

          final colunas = await db.rawQuery(
            'PRAGMA table_info(pessoas)',
          );

          final possuiUsuarioId = colunas.any(
            (coluna) => coluna['name'] == 'usuario_id',
          );

          if (!possuiUsuarioId) {
            await db.execute('''
              ALTER TABLE pessoas
              ADD COLUMN usuario_id INTEGER NOT NULL DEFAULT 0
            ''');
          }
        }
      },
    );
  }
}
