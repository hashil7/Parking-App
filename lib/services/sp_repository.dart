import 'package:parking_app/services/sp_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceRepository extends SharedPreferenceAdapter {
  final SharedPreferences prefs;

  static SharedPreferenceRepository? _instance;
  static SharedPreferenceRepository get instance => _instance!;
  static void setSharedPreferences(SharedPreferences prefs) {
    _instance ??= SharedPreferenceRepository._(prefs);
  }

  SharedPreferenceRepository._(this.prefs);

  @override
  void empty() {
    prefs.clear();
  }

  @override
  T? getValue<T>(String key) {
    switch (T) {
      case String:
        return prefs.getString(key) as T?;
      case int:
        return prefs.getInt(key) as T?;
      case double:
        return prefs.getDouble(key) as T?;
      case bool:
        return prefs.getBool(key) as T?;
      case List:
        return prefs.getStringList(key) as T?;
      default:
        throw UnimplementedError("No implementation GET for ${T.runtimeType}");
    }
  }

  @override
  Future<bool> removeKey(String key) async {
    return await prefs.remove(key);
  }

  @override
  void setKeyValue<T>(String key, T value) {
    switch (T) {
      case String:
        prefs.setString(key, value as String);
      case int:
        prefs.setInt(key, value as int);
      case double:
        prefs.setDouble(key, value as double);
      case bool:
        prefs.setBool(key, value as bool);
      case List:
        prefs.setStringList(key, value as List<String>);
      default:
        throw UnimplementedError("No implementation SET for ${T.runtimeType}");
    }
  }
}
