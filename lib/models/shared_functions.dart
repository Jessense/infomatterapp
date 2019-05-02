class SharedFuctions {
  static bool inputIllegal(String str) {
    if (str.contains('|') || str.contains(' ') || str.contains('(') || str.contains(')') || str.contains('\'') || str.contains('\"')) {
      return true;
    }
    return false;
  }
}