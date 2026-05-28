import 'dart:async';

/// Exponential backoff reconnect manager for WebSocket connections.
///
/// Implements the strategy from AIM dev manual §13.2:
/// 0s → 1s → 2s → 4s → 8s → cap at 10s; reset on success.
class WsReconnectManager {
  WsReconnectManager({
    this.heartbeatTimeout = const Duration(seconds: 60),
    this.maxBackoff = const Duration(seconds: 10),
  });

  final Duration heartbeatTimeout;
  final Duration maxBackoff;

  final List<Duration> _backoffSequence = const [
    Duration.zero,
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
  ];

  int _attempt = 0;
  Timer? _heartbeatWatchdog;
  Completer<void>? _reconnectCompleter;
  Timer? _reconnectTimer;

  /// Callback invoked when a reconnect should be attempted.
  Future<void> Function()? onReconnect;

  /// Callback invoked when the heartbeat watchdog fires (no message received).
  void Function()? onHeartbeatTimeout;

  /// Mark remote activity received. Resets the heartbeat watchdog.
  void markActivity() {
    _heartbeatWatchdog?.cancel();
    _heartbeatWatchdog = Timer(heartbeatTimeout, () {
      onHeartbeatTimeout?.call();
    });
  }

  /// Calculate the next backoff delay and advance the attempt counter.
  Duration nextBackoff() {
    final delay = _attempt < _backoffSequence.length
        ? _backoffSequence[_attempt]
        : maxBackoff;
    _attempt++;
    return delay;
  }

  /// Reset attempt counter (call after successful connection).
  void resetAttempts() {
    _attempt = 0;
  }

  /// Start heartbeat watchdog. Call after WebSocket is connected.
  void startHeartbeat() {
    _heartbeatWatchdog?.cancel();
    _heartbeatWatchdog = Timer(heartbeatTimeout, () {
      onHeartbeatTimeout?.call();
    });
  }

  /// Cancel all timers.
  void dispose() {
    _heartbeatWatchdog?.cancel();
    _heartbeatWatchdog = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectCompleter?.complete();
    _reconnectCompleter = null;
  }
}
