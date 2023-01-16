import 'dart:async';

class GlobalTimer {
  static const maxSeconds = 60;
  int seconds = maxSeconds;
  Timer globalTimer;
}
