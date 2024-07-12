abstract class SharedPreferenceAdapter {
  void setKeyValue<T>(String key, T value);
  T? getValue<T>(String key);
  Future<bool> removeKey(String key);
  void empty();
}
