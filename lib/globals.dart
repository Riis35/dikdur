class Globals {
  static final Globals _instance = Globals._internal();

  factory Globals() {
    return _instance;
  }

  Globals._internal();
  int _dateTime = 0;
  int _currentValue = 1;
  int get currentValue => _currentValue;
  set currentValue(int value) {
    _currentValue = value;
  }
  int get dateTime => _dateTime; 
  set dateTime(int value) {
    _dateTime = value;
  }
}