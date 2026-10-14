import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../Core/network/api_handler.dart';
import '../../../Core/network/api_endpoints.dart';
import '../../../Core/services/storage_service.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../models/message_page_model.dart';

import 'package:villas_qatar/Core/utils/app_toast.dart';
class ChatController extends GetxController {
  ChatController({required this.listingId, this.initialConversationId});

  /// Listing Id
  final String listingId;
  final String? initialConversationId;

  /// Socket
  late IO.Socket socket;
  final ImagePicker _picker = ImagePicker();

  /// Current Conversation
  ConversationModel? conversation;

  /// Conversation Id

  String conversationId = "";

  /// Messages
  List<MessageModel> messages = [];

  /// Controllers
  final TextEditingController messageController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  /// Loading
  bool isLoading = true;

  bool isConnected = false;

  bool isTyping = false;

  bool isLoadingMore = false;

  bool hasMore = true;

  /// Pagination
  int page = 1;

  final int limit = 50;

  /// Logged User

  String myUserId = "";

  /// Typing Timer

  Timer? typingTimer;
  ConversationModel? selectedConversation;

  String get otherUserId {
  final participantIds =
      conversation?.conversation.participantIds ?? [];

  if (participantIds.isEmpty) {
    return "";
  }

  try {
    return participantIds.firstWhere(
      (id) => id.toString() != myUserId,
    ).toString();
  } catch (_) {
    return "";
  }
}

  @override
  void onInit() {
    super.onInit();
    messages.clear();
    myUserId = StorageService.getProfile()?["id"] ?? "";
    if (initialConversationId != null) {
      conversationId = initialConversationId!;
    }

    scrollController.addListener(() {
      debugPrint("📜 Scroll Listener Triggered");
      _scrollListener();
    });
    connectSocket();
  }

  ///---------------------------------------------------
  /// SOCKET CONNECTION
  ///---------------------------------------------------
  ///
  ///
  ///
  void scrollToBottom() {
    if (!scrollController.hasClients) return;

    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> connectSocket() async {
    try {
      final token = StorageService.getToken();

      socket = IO.io(
        "${ApiHandler.baseUrl}/chat",
        IO.OptionBuilder()
            .setTransports(["websocket"])
            .disableAutoConnect()
            .setAuth({"token": token})
            .build(),
      );

      _registerSocketListeners();

      socket.connect();
    } catch (e) {
      debugPrint("Socket Connection Error : $e");
    }
  }

  ///---------------------------------------------------
  /// REGISTER EVENTS
  ///---------------------------------------------------
  ///---------------------------------------------------
  /// REGISTER EVENTS
  ///---------------------------------------------------
  void _registerSocketListeners() {
    socket.onConnect((_) {
      debugPrint("════════ SOCKET CONNECTED ════════");
      debugPrint("Socket Connected");
      debugPrint("══════════════════════════════════");
    });

    socket.onDisconnect((_) {
      debugPrint("════════ SOCKET DISCONNECTED ═════");
      debugPrint("Socket Disconnected");
      debugPrint("══════════════════════════════════");

      isConnected = false;
      update();
    });

    socket.onConnectError((data) {
      debugPrint("════════ CONNECT ERROR ═══════════");
      debugPrint(data.toString());
      debugPrint("══════════════════════════════════");
    });

    socket.onError((data) {
      debugPrint("════════ SOCKET ERROR ════════════");
      debugPrint(data.toString());
      debugPrint("══════════════════════════════════");
    });

    socket.onAny((event, data) {
      debugPrint("");
      debugPrint("════════ SOCKET EVENT RECEIVED ════════");
      debugPrint("EVENT : $event");
      debugPrint("DATA  : $data");
      debugPrint("═══════════════════════════════════════");
    });

    socket.on("connected", _onConnected);
    socket.on("conversation_joined", _onConversationJoined);
    socket.on("new_message", _onNewMessage);
    socket.on("typing", _onTyping);
    socket.on("error", _onSocketError);
  }

  ///---------------------------------------------------
  /// CONNECTED
  void _onConnected(dynamic data) {
    debugPrint("");
    debugPrint("════════ CONNECTED EVENT ════════");
    debugPrint("DATA : $data");
    debugPrint("User : $myUserId");
    debugPrint("Conversation : $conversationId");
    debugPrint("═════════════════════════════════");

    isConnected = true;
    update();

    if (conversationId.isNotEmpty) {
      loadMessages();
    }

    joinConversation();
  }

  ///---------------------------------------------------
  /// JOIN CONVERSATION
  ///---------------------------------------------------
   void joinConversation() {
  if (listingId.trim().isEmpty) {
    debugPrint("");
    debugPrint("❌ CANNOT JOIN CONVERSATION");
    debugPrint("listingId is empty");
    debugPrint("Conversation ID: $conversationId");
    return;
  }

  final Map<String, dynamic> payload = {
    "listingId": listingId.trim(),

    if (conversationId.trim().isNotEmpty)
      "conversationId": conversationId.trim(),
  };

  debugPrint("");
  debugPrint("════════ SOCKET EMIT ════════════");
  debugPrint("EVENT : join_conversation");
  debugPrint("CONVERSATION ID : $conversationId");
  debugPrint("LISTING ID      : $listingId");
  debugPrint("DATA            : $payload");
  debugPrint("═════════════════════════════════");

  socket.emit(
    "join_conversation",
    payload,
  );
}

  void setConversation(ConversationModel conversation) {
    selectedConversation = conversation;
    update();
  }

  ///---------------------------------------------------
  /// CONVERSATION JOINED
  ///---------------------------------------------------
  void _onConversationJoined(dynamic data) {
    try {
      debugPrint("");
      debugPrint("════════ CONVERSATION JOINED ═══════");
      debugPrint(data.toString());

      conversation = ConversationModel.fromJson(data);

      conversationId = conversation!.conversation.id;
      messages = conversation!.messages;

      page = 1;
      hasMore = true;
      isLoadingMore = false;
      isLoading = false;

      debugPrint("Conversation Id : $conversationId");
      debugPrint("Messages Count  : ${messages.length}");
      debugPrint("═══════════════════════════════════");

      update();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    } catch (e) {
      debugPrint("Conversation Parse Error : $e");
    }
  }

  ///---------------------------------------------------
  /// NEW MESSAGE
  ///---------------------------------------------------
  void _onNewMessage(dynamic data) {
    try {
      debugPrint("");
      debugPrint("════════ NEW MESSAGE ═══════════");
      debugPrint(data.toString());

      final message = MessageModel.fromJson(data);

      debugPrint("Message Id      : ${message.id}");
      debugPrint("Conversation Id : ${message.conversationId}");
      debugPrint("Type            : ${message.type}");
      debugPrint("Content         : ${message.content}");

      if (message.conversationId != conversationId) {
        debugPrint("Ignored (Different Conversation)");
        return;
      }

      messages.add(message);

      debugPrint("Total Messages : ${messages.length}");
      debugPrint("═════════════════════════════════");

      update();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    } catch (e) {
      debugPrint("Message Parse Error : $e");
    }
  }

  ///---------------------------------------------------
  /// TYPING
  ///---------------------------------------------------
  void _onTyping(dynamic data) {
    try {
      debugPrint("");
      debugPrint("════════ TYPING EVENT ═══════════");
      debugPrint(data.toString());

      if (data["conversationId"] != conversationId) return;
      if (data["userId"] == myUserId) return;

      isTyping = true;
      update();

      typingTimer?.cancel();

      typingTimer = Timer(const Duration(seconds: 2), () {
        isTyping = false;
        update();
      });

      debugPrint("Typing User : ${data["userId"]}");
      debugPrint("═════════════════════════════════");
    } catch (e) {
      debugPrint("Typing Error : $e");
    }
  }

  ///---------------------------------------------------
  /// SOCKET ERROR
  ///---------------------------------------------------
  void _onSocketError(dynamic data) {
    debugPrint("");
    debugPrint("════════ SOCKET ERROR EVENT ═══════");
    debugPrint(data.toString());
    debugPrint("═══════════════════════════════════");

    AppToast.show(
      msg: data["message"] ?? "Something went wrong".tr,
    );
  }

  ///---------------------------------------------------
  /// SCROLL
  void _scrollListener() {
    debugPrint("════════════ SCROLL ════════════");

    if (!scrollController.hasClients) {
      debugPrint("❌ No Clients");
      return;
    }

    debugPrint("Pixels      : ${scrollController.position.pixels}");
    debugPrint("Max Scroll  : ${scrollController.position.maxScrollExtent}");
    debugPrint("Min Scroll  : ${scrollController.position.minScrollExtent}");
    debugPrint("Page        : $page");
    debugPrint("Has More    : $hasMore");
    debugPrint("LoadingMore : $isLoadingMore");

    if (scrollController.position.pixels <= 120) {
      debugPrint("🔥 TOP REACHED -> LOAD MORE");
      loadOlderMessages();
    }

    debugPrint("═══════════════════════════════");
  }

  ///---------------------------------------------------
  /// PLACEHOLDERS
  ///---------------------------------------------------
  
  Future<void> loadMessages() async {
    if (conversationId.isEmpty) return;

    page = 1;
    hasMore = true;

    isLoading = true;
    update();

    final response = await ApiHandler.get(
      "${ApiEndpoints.chatConversations}/$conversationId/messages?page=1&limit=$limit",
    );

    final messagePage = MessagePageModel.fromJson(response);

    messages = messagePage.data;
    hasMore = messagePage.meta.page < messagePage.meta.totalPages;

    isLoading = false;
    update();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  Future<void> loadOlderMessages() async {
    if (conversationId.isEmpty) return;

    if (isLoadingMore) return;

    if (!hasMore) return;

    try {
      isLoadingMore = true;

      update();

      page++;

      final previousHeight = scrollController.position.maxScrollExtent;

      final response = await ApiHandler.get(
        "${ApiEndpoints.chatConversations}/$conversationId/messages?page=$page&limit=$limit",
      );

      final messagePage = MessagePageModel.fromJson(response);

      if (messagePage.data.isEmpty) {
        hasMore = false;

        page--;

        isLoadingMore = false;

        update();

        return;
      }

      messages.insertAll(0, messagePage.data);

      hasMore = messagePage.meta.page < messagePage.meta.totalPages;

      isLoadingMore = false;

      update();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;

        final newHeight = scrollController.position.maxScrollExtent;

        scrollController.jumpTo(newHeight - previousHeight);
      });
    } catch (e) {
      page--;

      isLoadingMore = false;

      update();

      debugPrint("Load Older Messages Error : $e");
    }
  }

  Future<void> sendTextMessage() async {
    if (!isConnected) return;

    final text = messageController.text.trim();

    if (text.isEmpty) return;

    if (conversationId.isEmpty) return;

    socket.emit("send_message", {
      "conversationId": conversationId,
      "type": "TEXT",
      "content": text,
    });

    messageController.clear();
  }

  void sendTyping() {
    if (!isConnected) return;

    if (conversationId.isEmpty) return;

    socket.emit("typing", {"conversationId": conversationId});
  }

  void sendOnEnter(String value) {
    if (value.trim().isEmpty) return;

    sendTextMessage();
  }

  Future<String?> uploadImage(File image) async {
    try {
      final token = StorageService.getToken();

      final request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiHandler.baseUrl}/api/chat/upload"),
      );

      request.headers.addAll({
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      });

      final mimeType = lookupMimeType(image.path) ?? "image/png";

      debugPrint("Mime Type: $mimeType");
      debugPrint("File Exists: ${await image.exists()}");
      debugPrint("File Size: ${await image.length()}");
      debugPrint("File Name: ${image.path.split('/').last}");

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          image.path,
          filename: image.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      );

      debugPrint("=========== CHAT IMAGE UPLOAD ==========");
      debugPrint("URL : ${request.url}");
      debugPrint("FILE : ${image.path}");
      debugPrint("=========== REQUEST ==========");
      debugPrint("URL: ${request.url}");
      debugPrint("Headers: ${request.headers}");

      for (final file in request.files) {
        debugPrint("Field: ${file.field}");
        debugPrint("Filename: ${file.filename}");
        debugPrint("Length: ${file.length}");
        debugPrint("ContentType: ${file.contentType}");
      }
      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint("STATUS : ${response.statusCode}");
      debugPrint("BODY : ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);

        return json["url"];
      }

      final error = jsonDecode(response.body);

      throw Exception(error["message"] ?? "Image upload failed".tr);
    } catch (e) {
      debugPrint("UPLOAD IMAGE ERROR : $e");

      AppToast.show(msg: e.toString());

      return null;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      await sendImage(File(pickedFile.path));
    } catch (e) {
      debugPrint("Gallery Image Error : $e");
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      await sendImage(File(pickedFile.path));
    } catch (e) {
      debugPrint("Camera Image Error : $e");
    }
  }

  Future<void> sendImage(File image) async {
    try {
      if (!isConnected) return;

      if (conversationId.isEmpty) return;

      final imageUrl = await uploadImage(image);

      if (imageUrl == null) {
        return;
      }

      socket.emit("send_message", {
        "conversationId": conversationId,
        "type": "IMAGE",
        "mediaUrl": imageUrl,
      });
    } catch (e) {
      debugPrint("Send Image Error : $e");
    }
  }

  Future<void> sendLocation() async {
    try {
      if (!isConnected) {
        AppToast.show(
          msg: "Please wait for chat to connect.".tr,
        );
        return;
      }

      if (conversationId.isEmpty) return;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        AppToast.show(
          msg: "Please enable location services.".tr,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        AppToast.show(
          msg: "Location permission is required.".tr,
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        AppToast.show(
          msg: "Enable location permission from settings.".tr,
        );
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      socket.emit("send_message", {
        "conversationId": conversationId,
        "type": "LOCATION",
        "latitude": position.latitude,
        "longitude": position.longitude,
        "locationLabel":
            "${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}",
      });
    } catch (e) {
      debugPrint("Send Location Error: $e");

      AppToast.show(msg: e.toString());
    }
  }

  @override
  void onClose() {
    typingTimer?.cancel();

    messageController.dispose();
    scrollController.dispose();

    socket.dispose();

    super.onClose();
  }

  void disposeTyping() {
    typingTimer?.cancel();
    isTyping = false;
    update();
  }
}
