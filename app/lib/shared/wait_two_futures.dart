Future<MapEntry<T, B>> waitForTwo<T, B>(Future<T> a, Future<B> b) async {
  final results = await Future.wait([a, b]);

  return MapEntry(results[0] as T, results[1] as B);
}
