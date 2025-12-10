import 'package:carwash_app/core/constants/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../domain/models/booking_model.dart';
import '../../../../core/services/socket_service.dart';
import '../../data/repositories/chat_repository.dart';
import '../providers/staff_provider.dart';

class IssueChatScreen extends StatefulWidget {
  final CleanerBooking booking;
  final String issueType;
  final String description;
  final Map<String, dynamic>? chatData;
  final String? roomId;

  const IssueChatScreen({
    super.key,
    required this.booking,
    required this.issueType,
    required this.description,
    this.chatData,
    this.roomId,
  });

  @override
  State<IssueChatScreen> createState() => _IssueChatScreenState();
}

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final bool isAdmin;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.isAdmin,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    // Handle backend API format: content, senderType, createdAt, _id
    // Also handle legacy format: text, senderName, isAdmin, timestamp, id
    final content =
        map['content']?.toString() ??
        map['text']?.toString() ??
        map['message']?.toString() ??
        '';

    final senderType = map['senderType']?.toString() ?? '';
    final isAdmin =
        senderType.toLowerCase() == 'admin' ||
        map['isAdmin'] == true ||
        map['senderName']?.toString().toUpperCase() == 'ADMIN';

    final senderName = isAdmin
        ? 'Admin'
        : (map['senderName']?.toString() ?? map['sender']?.toString() ?? 'You');

    final messageId =
        map['_id']?.toString() ??
        map['id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final senderId = map['senderId']?.toString() ?? '';

    // Handle timestamp from createdAt or timestamp field
    DateTime timestamp;
    if (map['createdAt'] != null) {
      try {
        timestamp = DateTime.parse(map['createdAt'].toString());
      } catch (e) {
        timestamp = DateTime.now();
      }
    } else if (map['timestamp'] != null) {
      try {
        timestamp = map['timestamp'] is DateTime
            ? map['timestamp'] as DateTime
            : DateTime.parse(map['timestamp'].toString());
      } catch (e) {
        timestamp = DateTime.now();
      }
    } else {
      timestamp = DateTime.now();
    }

    return ChatMessage(
      id: messageId,
      text: content,
      senderId: senderId,
      senderName: senderName,
      isAdmin: isAdmin,
      timestamp: timestamp,
    );
  }
}

class _IssueChatScreenState extends State<IssueChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isConnected = false;
  bool _hasJoinedRoom = false; // Flag to prevent duplicate joins
  bool _showRefreshButton =
      false; // Flag to show refresh button after connection failure
  bool _isInitializing = false; // Flag to prevent duplicate initialization
  String _roomId = '';
  bool _isLoadingMessages = false; // Flag to track message loading state

  // Check if issue is resolved
  bool get _isIssueResolved {
    if (widget.chatData != null) {
      final status = widget.chatData!['status']?.toString().toLowerCase() ?? '';
      final isResolved =
          widget.chatData!['isResolved'] == true ||
          widget.chatData!['resolved'] == true ||
          widget.chatData!['closed'] == true;
      return status == 'resolved' ||
          status == 'closed' ||
          status == 'completed' ||
          isResolved;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _loadChatMessages();
    _initializeChat();
  }

  void _initializeChat() {
    // Prevent duplicate initialization
    if (_isInitializing) {
      debugPrint('⚠️ Already initializing chat, skipping duplicate call');
      return;
    }

    _isInitializing = true;

    // Reset connection state
    _hasJoinedRoom = false;
    _showRefreshButton = false;

    // Use room ID from API response if available, otherwise generate one
    if (widget.roomId != null && widget.roomId!.isNotEmpty) {
      _roomId = widget.roomId!;
      debugPrint('📦 Using room ID from API: $_roomId');
    } else {
      // Generate room ID based on booking ID and issue type (fallback)
      _roomId =
          'issue_${widget.booking.id}_${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('📦 Generated room ID: $_roomId');
    }

    // Extract socket URL from baseurl (remove /api/v1 for Socket.IO)
    final socketUrl = baseurl.replaceAll('/api/v1', '');

    debugPrint('🔌 Initializing Socket.IO connection to: $socketUrl');
    debugPrint('📋 Booking ID: ${widget.booking.id}');
    debugPrint('📦 Room ID: $_roomId');

    // Set connection callbacks to update UI when connection status changes
    SocketService.setConnectionCallbacks(
      onConnect: () {
        debugPrint('✅ Socket connected!');
        if (mounted) {
          setState(() {
            _isConnected = true;
            _showRefreshButton =
                false; // Hide refresh button on successful connection
          });
          // Set up message listener when connected
          _setupMessageListener();
          // Join room when connected (only if not already joined)
          if (_roomId.isNotEmpty && !_hasJoinedRoom) {
            _joinRoom();
          }
        }
      },
      onDisconnect: () {
        debugPrint('❌ Socket disconnected');
        // Don't update state if widget is being disposed
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
        }
      },
      onError: (error) {
        debugPrint('⚠️ Socket connection error: $error');
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
          // Show refresh button after 5 seconds delay
          _scheduleRefreshButton();
        }
      },
    );

    // Initialize socket connection (just connect, don't join room yet)
    // Always ensure any existing socket is cleaned up first
    // Force disconnect to ensure clean state
    SocketService.disconnect();

    // Wait a bit for cleanup to complete before creating new socket
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        debugPrint('🔄 Initializing fresh socket connection...');
        SocketService.initialize(
          socketUrl,
          auth: {
            'bookingId': widget.booking.id,
            'userId': widget.booking.user?.id ?? 'cleaner',
            'userType': 'cleaner',
          },
        );

        // Set up message listener after socket is initialized
        // The listener will also be set up in onConnect callback, but set it here too as fallback
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _setupMessageListener();
          }
        });
      }
    });

    // Check if already connected (in case connection was established quickly)
    if (SocketService.isConnected) {
      debugPrint('✅ Socket already connected');
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
        // Set up message listener if already connected
        _setupMessageListener();
        // Join room immediately if connected (only if not already joined)
        if (_roomId.isNotEmpty && !_hasJoinedRoom) {
          _joinRoom();
        }
      }
    } else {
      debugPrint('⏳ Socket not connected yet, waiting...');
      // Schedule refresh button immediately (will show after 5 seconds if not connected)
      _scheduleRefreshButton();

      // Wait a bit and check again
      Future.delayed(const Duration(milliseconds: 500), () {
        if (SocketService.isConnected && mounted) {
          debugPrint('✅ Socket connected after delay');
          setState(() {
            _isConnected = true;
            _showRefreshButton = false; // Hide refresh button if connected
          });
          // Set up message listener if connected
          _setupMessageListener();
          // Join room after connection (only if not already joined)
          if (_roomId.isNotEmpty && !_hasJoinedRoom) {
            _joinRoom();
          }
        } else {
          debugPrint(
            '❌ Socket still not connected after delay. Current status: ${SocketService.isConnected}',
          );
        }
      });
    }

    // Only add initial message if no messages were loaded from API
    if (_messages.isEmpty) {
      _addInitialMessages();
    }
  }

  /// Set up message listener for Socket.IO
  void _setupMessageListener() {
    debugPrint('📥 Setting up message listener...');
    SocketService.onMessage((data) {
      debugPrint('📨 Received message via Socket.IO: $data');
      if (mounted) {
        // Check if message already exists (prevent duplicates)
        final messageId =
            data['_id']?.toString() ??
            data['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();

        final messageExists = _messages.any((msg) => msg.id == messageId);
        if (!messageExists) {
          setState(() {
            _messages.add(ChatMessage.fromMap(data));
          });
          _scrollToBottom();
          debugPrint(
            '✅ Message added to chat: ${data['content'] ?? data['text']}',
          );
        } else {
          debugPrint(
            '⚠️ Message already exists, skipping duplicate: $messageId',
          );
        }
      }
    });
  }

  /// Load chat messages from API
  Future<void> _loadChatMessages() async {
    // Only load if we have a roomId (chatId)
    final chatId = widget.roomId;
    if (chatId == null || chatId.isEmpty) {
      debugPrint('⚠️ No chatId available, skipping message load');
      return;
    }

    setState(() {
      _isLoadingMessages = true;
    });

    try {
      debugPrint('📥 Loading chat messages for chatId: $chatId');
      final result = await ChatRepository.getChatMessages(chatId: chatId);

      if (!mounted) return;

      if (result['success'] == true) {
        final messagesList = result['messages'] as List<dynamic>? ?? [];
        debugPrint('✅ Loaded ${messagesList.length} messages from API');

        // Convert API messages to ChatMessage objects
        final loadedMessages = messagesList.map((msg) {
          final messageMap = msg as Map<String, dynamic>;
          final senderType = messageMap['senderType']?.toString() ?? '';
          final isAdmin = senderType.toLowerCase() == 'admin';

          return ChatMessage(
            id: messageMap['_id']?.toString() ?? '',
            text: messageMap['content']?.toString() ?? '',
            senderId: messageMap['senderId']?.toString() ?? '',
            senderName: isAdmin ? 'Admin' : 'You',
            isAdmin: isAdmin,
            timestamp: messageMap['createdAt'] != null
                ? DateTime.parse(messageMap['createdAt'].toString())
                : DateTime.now(),
          );
        }).toList();

        setState(() {
          _messages.clear();
          _messages.addAll(loadedMessages);
          _isLoadingMessages = false;
        });

        // Scroll to bottom after loading messages
        _scrollToBottom();
      } else {
        debugPrint('❌ Failed to load messages: ${result['message']}');
        setState(() {
          _isLoadingMessages = false;
        });
        // Still add initial message if loading failed
        _addInitialMessages();
      }
    } catch (e) {
      debugPrint('❌ Error loading messages: $e');
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
        });
        // Still add initial message if loading failed
        _addInitialMessages();
      }
    }
  }

  void _addInitialMessages() {
    // Add the initial issue report as a message
    final issueMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          'ISSUE REPORTED: ${widget.description.isNotEmpty ? widget.description : widget.issueType}',
      senderId: widget.booking.user?.id ?? 'cleaner',
      senderName: 'You',
      isAdmin: false,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(issueMessage);
    });
  }

  // Method to join room later when needed
  void _joinRoom() {
    // Prevent duplicate joins
    if (_hasJoinedRoom) {
      debugPrint('⚠️ Already joined room, skipping duplicate join');
      return;
    }

    // Use room ID from widget if available, otherwise use the one from state
    final chatIdToUse = widget.roomId ?? _roomId;

    if (chatIdToUse.isEmpty) {
      // Generate room ID when joining (fallback)
      _roomId =
          'issue_${widget.booking.id}_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      _roomId = chatIdToUse;
    }

    if (SocketService.isConnected && _roomId.isNotEmpty) {
      debugPrint('📦 Joining room with chatId: $_roomId');
      // Emit join_room with chatId
      SocketService.joinRoom(_roomId);
      // Mark as joined to prevent duplicates
      _hasJoinedRoom = true;
    } else {
      debugPrint(
        '⚠️ Cannot join room: Socket not connected or chatId is empty',
      );
    }
  }

  // Schedule refresh button to show after 5 seconds
  void _scheduleRefreshButton() {
    // Don't schedule if already scheduled or already showing
    if (_showRefreshButton) {
      return;
    }

    debugPrint('⏰ Scheduling refresh button to show in 5 seconds...');
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isConnected && !_showRefreshButton) {
        debugPrint('🔴 Showing refresh button - connection failed');
        setState(() {
          _showRefreshButton = true;
        });
      } else {
        if (_isConnected) {
          debugPrint('✅ Connection established, not showing refresh button');
        }
      }
    });
  }

  // Retry connection
  void _retryConnection() {
    setState(() {
      _showRefreshButton = false;
      _hasJoinedRoom = false; // Reset join flag to allow re-joining
      _isInitializing = false; // Reset initialization flag to allow retry
    });

    // Disconnect existing socket first
    SocketService.disconnect();

    // Wait a bit before reinitializing
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        // Reinitialize chat connection
        _initializeChat();
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || !_isConnected) return;

    // Ensure room ID exists before sending
    if (_roomId.isEmpty) {
      _joinRoom();
    }

    // Get cleaner ID from StaffProvider
    final staffProvider = Provider.of<StaffProvider>(context, listen: false);
    final cleanerId =
        staffProvider.staff?.id ?? staffProvider.staff?.cleanerId ?? '';

    if (cleanerId.isEmpty) {
      debugPrint('⚠️ Cleaner ID not available, cannot send message');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to send message: Cleaner ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final chatId = _roomId;

    // Format message according to backend API structure
    final messageData = {
      'senderType': 'Cleaner',
      'content': text,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'chatId': chatId,
      'senderId': cleanerId,
    };

    // Add to local messages immediately (for UI display)
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          senderId: cleanerId,
          senderName: 'You',
          isAdmin: false,
          timestamp: now,
        ),
      );
    });

    // Send via socket using the correct format
    if (_roomId.isNotEmpty) {
      SocketService.sendMessage(_roomId, messageData);
      debugPrint(
        '📤 Sending message with format: roomId=$_roomId, message=$messageData',
      );
    }

    // Clear input
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    debugPrint('🔌 Leaving chat and disconnecting Socket.IO...');

    // Clear callbacks first to prevent setState calls after dispose
    SocketService.clearConnectionCallbacks();

    // Leave room if joined (use chatId from widget or state)
    final chatIdToLeave = widget.roomId ?? _roomId;
    if (chatIdToLeave.isNotEmpty && _hasJoinedRoom) {
      debugPrint('🚪 Leaving room with chatId: $chatIdToLeave');
      SocketService.leaveRoom(chatIdToLeave);
    }

    // Disconnect socket when leaving the screen
    // This will clean up the socket completely so it can be recreated on next visit
    SocketService.disconnect();

    // Reset all state flags so next visit can initialize properly
    _isInitializing = false;
    _hasJoinedRoom = false;
    _isConnected = false;
    _showRefreshButton = false;

    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return isIOS ? _buildIOSScreen() : _buildAndroidScreen();
  }

  Widget _buildIOSScreen() {
    return CupertinoPageScaffold(
      backgroundColor: Colors.black,
      child: _buildContent(isIOS: true),
    );
  }

  Widget _buildAndroidScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildContent(isIOS: false),
    );
  }

  Widget _buildContent({required bool isIOS}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final horizontalPadding = isSmallScreen ? 16.0 : 20.0;

    return SafeArea(
      child: Column(
        children: [
          // Header
          _buildHeader(context, isIOS, isSmallScreen, horizontalPadding),
          // Status indicator
          _buildStatusIndicator(isIOS, isSmallScreen, horizontalPadding),
          // Refresh button (shown when connection fails)
          if (_showRefreshButton)
            _buildRefreshButton(
              context,
              isIOS,
              isSmallScreen,
              horizontalPadding,
            ),
          // Messages
          Expanded(child: _buildMessagesList(isIOS, isSmallScreen)),
          // Message input (only show if issue is not resolved)
          if (!_isIssueResolved)
            _buildMessageInput(
              context,
              isIOS,
              isSmallScreen,
              horizontalPadding,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 20, horizontalPadding, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Back button
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFF04CDFE),
              shape: BoxShape.circle,
            ),
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(
                      CupertinoIcons.arrow_left,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
          ),
          const Spacer(),
          // Centered heading
          Text(
            widget.issueType,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
              fontFamily: isIOS ? '.SF Pro Display' : 'Roboto',
            ),
          ),
          const Spacer(),
          // Invisible placeholder
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(
    bool isIOS,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    final isResolved = _isIssueResolved;
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isResolved ? Colors.grey : const Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isResolved ? 'RESOLVED' : 'OPEN TICKET',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
            ),
          ),
          const Spacer(),
          if (!isResolved && !_isConnected && !_showRefreshButton)
            Text(
              'Connecting...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: isSmallScreen ? 10 : 12,
                fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 8, horizontalPadding, 8),
      child: GestureDetector(
        onTap: _retryConnection,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(isIOS ? 12 : 10),
            border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isIOS ? CupertinoIcons.refresh : Icons.refresh,
                color: Colors.white,
                size: isSmallScreen ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Connection Failed. Tap to Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(bool isIOS, bool isSmallScreen) {
    if (_isLoadingMessages) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isIOS)
              const CupertinoActivityIndicator()
            else
              const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading messages...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: isSmallScreen ? 14 : 16,
                fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
              ),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: isSmallScreen ? 14 : 16,
            fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: 16,
      ),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index], isIOS, isSmallScreen);
      },
    );
  }

  Widget _buildMessageBubble(
    ChatMessage message,
    bool isIOS,
    bool isSmallScreen,
  ) {
    final isUser = !message.isAdmin;
    final timeString =
        '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 14 : 16,
            vertical: isSmallScreen ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: isUser
                ? const Color(0xFF04CDFE)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isIOS ? 18 : 16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.isAdmin)
                Text(
                  'ADMIN: ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                  ),
                ),
              Text(
                message.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 13 : 15,
                  fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timeString,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmallScreen ? 10 : 11,
                  fontFamily: isIOS ? '.SF Pro Text' : 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    bool isIOS,
    bool isSmallScreen,
    double horizontalPadding,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isIOS ? 20 : 18),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: isIOS
                  ? CupertinoTextField(
                      controller: _messageController,
                      placeholder: 'TYPE A MESSAGE..',
                      placeholderStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: isSmallScreen ? 13 : 15,
                        fontFamily: '.SF Pro Text',
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: '.SF Pro Text',
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: const BoxDecoration(),
                      onSubmitted: (_) => _sendMessage(),
                    )
                  : TextField(
                      controller: _messageController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Roboto',
                      ),
                      decoration: InputDecoration(
                        hintText: 'TYPE A MESSAGE..',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: isSmallScreen ? 13 : 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: isSmallScreen ? 44 : 48,
            height: isSmallScreen ? 44 : 48,
            decoration: const BoxDecoration(
              color: Color(0xFF04CDFE),
              shape: BoxShape.circle,
            ),
            child: isIOS
                ? CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _isConnected ? _sendMessage : null,
                    child: const Icon(
                      CupertinoIcons.paperplane_fill,
                      color: Colors.white,
                      size: 20,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _isConnected ? _sendMessage : null,
                    padding: EdgeInsets.zero,
                  ),
          ),
        ],
      ),
    );
  }
}
