enum ActionType {
  ssh,
  rdp,
}

abstract class Action {
  ActionType get type;
  String get host;
  String get user;
  String get password;
  String get file;
}
