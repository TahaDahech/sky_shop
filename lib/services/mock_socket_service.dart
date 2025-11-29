import 'dart:async';
import 'dart:math';

import '../models/chat_message.dart';
import '../models/order.dart';

/// Enum representing the current connection state of the mock socket.
enum MockSocketConnectionState {
  connecting,
  connected,
  disconnected,
}

/// Service that simulates a WebSocket connection using Dart Streams.
///
/// This is designed to be easily replaceable by a real [SocketService] later.
class MockSocketService {
  final _random = Random();

  MockSocketConnectionState _connectionState =
      MockSocketConnectionState.disconnected;
  String? _currentEventId;

  final _connectionStateController =
      StreamController<MockSocketConnectionState>.broadcast();
  final _chatController = StreamController<ChatMessage>.broadcast();
  final _productFeaturedController = StreamController<String>.broadcast();
  final _viewerCountController = StreamController<int>.broadcast();
  final _newOrderController = StreamController<Order>.broadcast();

  Timer? _viewerCountTimer;
  Timer? _productFeaturedTimer;

  /// Stream of connection state changes.
  Stream<MockSocketConnectionState> get connectionStateStream =>
      _connectionStateController.stream;

  /// Stream emitting chat messages for the current live event.
  Stream<ChatMessage> get chatMessages => _chatController.stream;

  /// Stream emitting product IDs that are featured in real time.
  Stream<String> get productFeatured => _productFeaturedController.stream;

  /// Stream emitting viewer count updates.
  Stream<int> get viewerCount => _viewerCountController.stream;

  /// Stream emitting newly created orders.
  Stream<Order> get newOrder => _newOrderController.stream;

  MockSocketConnectionState get connectionState => _connectionState;

  /// Simulates joining a live event and starting periodic updates.
  void joinLiveEvent(String eventId) {
    if (_connectionState == MockSocketConnectionState.connected &&
        _currentEventId == eventId) {
      return;
    }

    _currentEventId = eventId;
    _setConnectionState(MockSocketConnectionState.connecting);

    // Simulate async handshake.
    Future.delayed(const Duration(milliseconds: 400), () {
      _setConnectionState(MockSocketConnectionState.connected);
      _startViewerCountUpdates();
      _startProductFeaturedUpdates();
    });
  }

  /// Simulates leaving the current live event and stopping updates.
  void leaveLiveEvent(String eventId) {
    if (_currentEventId != eventId) return;

    _currentEventId = null;
    _stopViewerCountUpdates();
    _stopProductFeaturedUpdates();
    _setConnectionState(MockSocketConnectionState.disconnected);
  }

  /// Simulates sending a chat message with a small artificial delay.
  void sendChatMessage(String message) {
    if (_connectionState != MockSocketConnectionState.connected ||
        _currentEventId == null) {
      return;
    }

    Future.delayed(const Duration(milliseconds: 200), () {
      final chatMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: 'current_user',
        senderName: 'Vous',
        message: message,
        timestamp: DateTime.now().toUtc(),
        isVendor: false,
        replyTo: null,
        reactions: const [],
      );
      _chatController.add(chatMessage);
    });
  }

  /// Allows the app to push a newly created order into the real-time stream.
  void emitNewOrder(Order order) {
    if (_connectionState == MockSocketConnectionState.connected) {
      _newOrderController.add(order);
    }
  }

  void _setConnectionState(MockSocketConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  void _startViewerCountUpdates() {
    _stopViewerCountUpdates();
    // Start around 200–250 viewers and vary a bit.
    var currentCount = 200 + _random.nextInt(50);
    _viewerCountController.add(currentCount);

    _viewerCountTimer =
        Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      final delta = _random.nextInt(15) - 7; // -7..+7
      currentCount = (currentCount + delta).clamp(150, 500);
      _viewerCountController.add(currentCount);
    });
  }

  void _stopViewerCountUpdates() {
    _viewerCountTimer?.cancel();
    _viewerCountTimer = null;
  }

  void _startProductFeaturedUpdates() {
    _stopProductFeaturedUpdates();

    // Simulate featuring a new product every 10 seconds.
    final sampleProductIds = <String>[
      'prod_001',
      'prod_002',
      'prod_003',
      'prod_004',
      'prod_005',
      'prod_006',
      'prod_007',
    ];

    _productFeaturedTimer =
        Timer.periodic(const Duration(seconds: 10), (Timer timer) {
          final id = sampleProductIds[_random.nextInt(sampleProductIds.length)];
          _productFeaturedController.add(id);
        });
  }

  void _stopProductFeaturedUpdates() {
    _productFeaturedTimer?.cancel();
    _productFeaturedTimer = null;
  }

  /// Cleanly closes all streams and timers.
  Future<void> dispose() async {
    _stopViewerCountUpdates();
    _stopProductFeaturedUpdates();

    await _connectionStateController.close();
    await _chatController.close();
    await _productFeaturedController.close();
    await _viewerCountController.close();
    await _newOrderController.close();
  }
}


