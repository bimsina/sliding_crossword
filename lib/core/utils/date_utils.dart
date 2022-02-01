extension DateUtil on Duration {
  String toMS() {
    return "${inMinutes.remainder(60).toString().padLeft(2, '0')}m ${(inSeconds.remainder(60)).toString().padLeft(2, '0')}s";
  }

  String toHMS() {
    return "${inHours.remainder(24).toString().padLeft(2, '0')}h ${toMS()}";
  }
}
