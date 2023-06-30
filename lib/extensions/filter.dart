extension Filter<T> on Stream<List<T>> {
  // testing 'where' condition to filter out things from the stream of list of
  // things that match and satisfy
  Stream<List<T>> filter(bool Function(T) where) => map((items) => items.where(where).toList());
}
