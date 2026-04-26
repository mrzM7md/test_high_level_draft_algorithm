import 'dart:async';

class DebouncerHelper {
  /// The duration (in milliseconds) to wait before executing the action.
  final int milliseconds;

  /// The timer that tracks the delay between keystrokes.
  Timer? _timer;

  //   /// Constructs a Debouncer with the specified delay in milliseconds.
  DebouncerHelper({this.milliseconds = 300});

  /// Runs the provided action after the debounced delay.
  /// - Cancels any existing timer if the user is still typing.
  /// - Starts a new timer and executes the action when the delay elapses.
  void run(Function action) {
    // Cancel any existing timer if the user is still typing
    _timer?.cancel();
    // Start a new timer; if it completes (no new input), run the action
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      action();
    });
  }

  /// Cancels the current timer manually if needed.
  void cancel() {
    _timer?.cancel();
  }
}
