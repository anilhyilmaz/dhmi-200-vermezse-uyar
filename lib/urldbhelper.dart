import 'package:dhmigov/url.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{
  static final _databaseName = 'urldb.db';
  static final _databaseVersion = 1;
  static final table = 'urls_table';
  static final columnId = 'id';
  static final columnUrl = 'url';


  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;


  Future get database async{
    if(_database!=null) return _database;
    return _database ??= await _initDatabase();
  }

  _initDatabase() async{
    String path = join(await getDatabasesPath(),_databaseName);
    return await openDatabase(path,version: _databaseVersion,onCreate: _onCreate);
  }

  Future _onCreate(Database db,int version) async{
    return await db.execute('''
    CREATE TABLE $table (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnUrl TEXT NOT NULL
    )
    ''');
  }

  Future<int> insert(Url url) async{
    Database db = await instance.database;
    return await db.insert(table, {'url':url.url});
  }

  Future<int> update(Url url) async{
    Database db = await instance.database;
    int id = url.toMap()['id'];
    return await db.update(table, url.toMap(),where: '$columnId = ?',whereArgs: [id]);
  }
  Future<int> delete(int id) async{
    Database db = await instance.database;
    return await db.delete(table,where: '$columnId = ?',whereArgs: [id]);
  }
  Future<List<Map<String,dynamic>>> queryRows(url) async{
    Database db = await instance.database;
    return await db.query(table,where:"$columnUrl LIKE '%$url%'");
  }
  Future<List<Map<String,dynamic>>> queryAllRows() async{
    Database db = await instance.database;
    return await db.query(table);
  }
  Future<int?> queryRowCount() async{
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }




}






