import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;
  static Function()? _onConnectCallback;
  static Function()? _onDisconnectCallback;
  static Function(dynamic)? _onErrorCallback;

  // Get socket instance
  static IO.Socket? get socket => _socket;

  // Check if connected
  static bool get isConnected => _isConnected;

  // Set connection callbacks
  static void setConnectionCallbacks({
    Function()? onConnect,
    Function()? onDisconnect,
    Function(dynamic)? onError,
  }) {
    _onConnectCallback = onConnect;
    _onDisconnectCallback = onDisconnect;
    _onErrorCallback = onError;
  }

  // Clear connection callbacks
  static void clearConnectionCallbacks() {
    _onConnectCallback = null;
    _onDisconnectCallback = null;
    _onErrorCallback = null;
    // Note: Don't clear _messageCallback here, as we want to keep it for reconnection
  }

  // Initialize socket connection
  static void initialize(String serverUrl, {Map<String, dynamic>? auth}) {
    // If socket exists and is connected, don't reinitialize
    if (_socket != null && _isConnected) {
      if (kDebugMode) {
        print('Socket already connected, skipping reinitialization');
      }
      return;
    }

    // Always clean up existing socket before creating a new one
    // This ensures we can reconnect after leaving and coming back
    if (_socket != null) {
      if (kDebugMode) {
        print(
          '⚠️ Socket exists but not connected, cleaning up before reinitializing...',
        );
      }
      try {
        // Clear all listeners first to prevent callbacks
        _socket!.clearListeners();
        // Clear callbacks
        clearConnectionCallbacks();
        // Disconnect
        _socket!.disconnect();
        // Dispose immediately
        _socket!.dispose();
      } catch (e) {
        if (kDebugMode) {
          print('Error cleaning up old socket: $e');
        }
      } finally {
        // Always reset socket state
        _socket = null;
        _isConnected = false;
        if (kDebugMode) {
          print('✅ Old socket cleaned up, ready for new connection');
        }
      }
    }

    try {
      if (kDebugMode) {
        print('Creating new socket connection to: $serverUrl');
      }

      final optionBuilder = IO.OptionBuilder()
          .setTransports(['websocket', 'polling']) // Add polling as fallback
          .enableAutoConnect()
          .setTimeout(10000); // 10 second timeout

      if (auth != null) {
        optionBuilder.setAuth(Map<dynamic, dynamic>.from(auth));
        if (kDebugMode) {
          print('Socket auth: $auth');
        }
      }

      _socket = IO.io(serverUrl, optionBuilder.build());

      if (kDebugMode) {
        print('Socket instance created, waiting for connection...');
        print('Socket connected state: ${_socket!.connected}');
        print('Socket ID: ${_socket!.id}');
      }

      // Explicitly connect if not already connected (should auto-connect, but just in case)
      if (!_socket!.connected) {
        if (kDebugMode) {
          print('Socket not connected, attempting to connect...');
        }
        _socket!.connect();
      }

      _socket!.onConnect((_) {
        _isConnected = true;
        if (kDebugMode) {
          print('✅ Socket connected: ${_socket!.id}');
          print(
            'Socket connected state after onConnect: ${_socket!.connected}',
          );
        }
        // Re-register message listener when connected
        _registerMessageListener();
        _onConnectCallback?.call();
      });

      _socket!.onDisconnect((reason) {
        _isConnected = false;
        if (kDebugMode) {
          print('❌ Socket disconnected. Reason: $reason');
        }
        _onDisconnectCallback?.call();
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        if (kDebugMode) {
          print('⚠️ Socket connection error: $error');
          print('⚠️ Error type: ${error.runtimeType}');
          print('⚠️ Error details: ${error.toString()}');
        }
        _onErrorCallback?.call(error);
      });

      _socket!.onError((error) {
        _isConnected = false;
        if (kDebugMode) {
          print('⚠️ Socket error: $error');
          print('⚠️ Error type: ${error.runtimeType}');
        }
        _onErrorCallback?.call(error);
      });

      // Additional event listeners for debugging
      _socket!.on('connect_error', (error) {
        _isConnected = false;
        if (kDebugMode) {
          print('⚠️ Socket connect_error event: $error');
        }
        _onErrorCallback?.call(error);
      });

      _socket!.on('reconnect', (data) {
        _isConnected = true;
        if (kDebugMode) {
          print('🔄 Socket reconnected: $data');
        }
        // Re-register message listener on reconnect
        _registerMessageListener();
        _onConnectCallback?.call();
      });

      _socket!.on('reconnect_attempt', (attemptNumber) {
        if (kDebugMode) {
          print('🔄 Socket reconnect attempt #$attemptNumber');
        }
      });

      _socket!.on('reconnect_error', (error) {
        if (kDebugMode) {
          print('⚠️ Socket reconnect error: $error');
        }
      });

      _socket!.on('reconnect_failed', (data) {
        _isConnected = false;
        if (kDebugMode) {
          print('❌ Socket reconnect failed: $data');
        }
        _onErrorCallback?.call('Reconnection failed');
      });

      // Listen for connection timeout
      _socket!.on('connect_timeout', (data) {
        _isConnected = false;
        if (kDebugMode) {
          print('⏱️ Socket connection timeout: $data');
        }
        _onErrorCallback?.call('Connection timeout');
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing socket: $e');
      }
    }
  }

  // Join a room (e.g., issue chat room)
  static void joinRoom(String chatId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('join_room', chatId);
      if (kDebugMode) {
        print('Joined room with chatId: $chatId');
      }
    } else {
      if (kDebugMode) {
        print('Cannot join room: Socket not connected');
      }
    }
  }

  // Leave a room
  static void leaveRoom(String chatId) {
    if (_socket != null && _isConnected) {
      _socket!.emit('leave_room', chatId);
      if (kDebugMode) {
        print('Left room with chatId: $chatId');
      }
    } else {
      if (kDebugMode) {
        print('Cannot leave room: Socket not connected');
      }
    }
  }

  // Send a message
  // Format: {roomId: chatId, message: {senderType, content, createdAt, updatedAt, chatId, senderId}}
  static void sendMessage(String roomId, Map<String, dynamic> messageData) {
    if (_socket != null && _isConnected) {
      _socket!.emit('send_message', {'roomId': roomId, 'message': messageData});
      if (kDebugMode) {
        print('📤 Message sent to room $roomId');
        print('📤 Message data: $messageData');
      }
    } else {
      if (kDebugMode) {
        print('❌ Cannot send message: Socket not connected');
      }
    }
  }

  // Store message callback to re-register on reconnect
  static Function(Map<String, dynamic>)? _messageCallback;

  // Listen for messages
  static void onMessage(Function(Map<String, dynamic>) callback) {
    _messageCallback = callback;

    // Set up listener if socket exists
    if (_socket != null) {
      _registerMessageListener();
    } else {
      if (kDebugMode) {
        print(
          '⚠️ Socket not available yet, message listener will be registered when socket connects',
        );
      }
    }
  }

  // Internal method to register message listener
  static void _registerMessageListener() {
    if (_socket != null && _messageCallback != null) {
      // Remove existing listener to prevent duplicates
      _socket!.off('receive_message');

      _socket!.on('receive_message', (data) {
        if (kDebugMode) {
          print('📨 Message received via Socket.IO: $data');
        }
        if (_messageCallback != null) {
          _messageCallback!(
            data is Map ? Map<String, dynamic>.from(data) : {'data': data},
          );
        }
      });

      if (kDebugMode) {
        print('✅ Message listener registered');
      }
    }
  }

  // Listen for issue updates
  static void onIssueUpdate(Function(Map<String, dynamic>) callback) {
    if (_socket != null) {
      _socket!.on('issue_update', (data) {
        if (kDebugMode) {
          print('Issue update received: $data');
        }
        callback(
          data is Map ? Map<String, dynamic>.from(data) : {'data': data},
        );
      });
    }
  }

  // Disconnect socket
  static void disconnect() {
    if (_socket != null) {
      if (kDebugMode) {
        print('Disconnecting socket...');
      }
      try {
        // Clear all listeners first to prevent any callbacks
        _socket!.clearListeners();
        // Clear callbacks before disconnecting
        clearConnectionCallbacks();
        // Disconnect
        _socket!.disconnect();
        // Dispose
        _socket!.dispose();
      } catch (e) {
        if (kDebugMode) {
          print('Error during socket disconnect: $e');
        }
      } finally {
        // Always reset socket state
        _socket = null;
        _isConnected = false;
        if (kDebugMode) {
          print('Socket disconnected and disposed - ready for new connection');
        }
      }
    } else {
      if (kDebugMode) {
        print('No socket to disconnect');
      }
    }
  }

  // Remove all listeners
  static void removeAllListeners() {
    if (_socket != null) {
      _socket!.clearListeners();
      if (kDebugMode) {
        print('All socket listeners removed');
      }
    }
  }
}
