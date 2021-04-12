class BinarySearchTree<T extends Comparable> {
  final T data;
  BinarySearchTree<T>? left;
  BinarySearchTree<T>? right;

  BinarySearchTree(this.data);

  void insert(T newData) {
    final comparison = newData.compareTo(data);
    if (comparison < 0) {
      if (left == null) {
        left = BinarySearchTree(newData);
      } else {
        left?.insert(newData);
      }
    } else if (comparison > 0) {
      if (right == null) {
        right = BinarySearchTree(newData);
      } else {
        right?.insert(newData);
      }
    }
  }

  BinarySearchTree get min => left?.min ?? this;

  BinarySearchTree get max => right?.min ?? this;

  List<T> get asList => [...left?.asList ?? [], data, ...right?.asList ?? []];
}
