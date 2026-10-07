import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:palqarbot_app/Core/Constants/storage_keys.dart';

class InboxSocket {
  static const String _url = 'https://mybotapi.palqar.com/messaging';

  final String profileId;
  final void Function(String event, dynamic data) onEvent;

  io.Socket? _socket;
  Timer? _retry;
  bool _closed = false;

  InboxSocket({required this.profileId, required this.onEvent});

  Future<void> connect() async {
    if (_closed) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(StorageKeys.accessToken) ?? '';
    if (token.isEmpty || profileId.isEmpty) return;

    _socket?.dispose();

    final socket = io.io(
      _url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'profileId': profileId, 'token': token})
          .disableAutoConnect()
          .disableReconnection()
          .build(),
    );

    socket.on('connected', (_) => debugPrint('SOCKET: connected'));
    socket.on('message.new', (d) => onEvent('message.new', d));
    socket.on('conversation.updated', (d) => onEvent('conversation.updated', d));

    socket.on('error', (e) {
      debugPrint('SOCKET: error $e');
      _retryLater();
    });
    socket.onConnectError((e) {
      debugPrint('SOCKET: connect error $e');
      _retryLater();
    });
    socket.onDisconnect((reason) {
      debugPrint('SOCKET: disconnected $reason');
      _retryLater();
    });

    socket.connect();
    _socket = socket;
  }

  // reconnect with a fresh token from storage, the old one may have expired
  void _retryLater() {
    if (_closed || (_retry?.isActive ?? false)) return;
    _retry = Timer(const Duration(seconds: 10), connect);
  }

  void dispose() {
    _closed = true;
    _retry?.cancel();
    _socket?.dispose();
  }
}
