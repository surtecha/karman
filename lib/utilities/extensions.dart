extension NullSafeOperations<T> on T? {
  R? let<R>(R Function(T) operation) {
    final value = this;
    return value != null ? operation(value) : null;
  }
}