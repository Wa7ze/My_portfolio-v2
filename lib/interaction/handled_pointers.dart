/// Shared set of pointer ids that some [Interactive]-wrapped widget (or
/// NetButton) has already claimed on `pointerDown`. [ClickRouter] checks
/// this on `pointerUp` to decide whether a release is a genuine "empty
/// click" on blank canvas or a real interaction it shouldn't double-count.
class HandledPointers {
  final Set<int> _pointers = {};

  void add(int pointer) => _pointers.add(pointer);
  bool contains(int pointer) => _pointers.contains(pointer);
  void remove(int pointer) => _pointers.remove(pointer);
}
