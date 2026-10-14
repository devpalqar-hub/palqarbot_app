import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:villas_qatar/Core/network/api_endpoints.dart';
import 'package:villas_qatar/modules/chats/models/chat_lsit_model.dart';

import '../../../Core/network/api_handler.dart';

class ChatListController extends GetxController {
  bool isLoading = false;

  List<ChatListModel> conversations = [];

  List<ChatListModel> filteredConversations = [];

  String searchText = "";

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    try {
      isLoading = true;
      update();

      debugPrint("Fetching conversations...");

      final response = await ApiHandler.get(ApiEndpoints.chatConversations);

      debugPrint("Response Type: ${response.runtimeType}");
      debugPrint("Response: $response");
      conversations = (response as List)
          .map((e) => ChatListModel.fromJson(e))
          .toList();

      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      filteredConversations = List.from(conversations);
    } catch (e) {
      debugPrint("Chat List Error : $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> refreshList() async {
    await fetchConversations();
  }

  void searchConversation(String value) {
    searchText = value.trim();

    if (searchText.isEmpty) {
      filteredConversations = List.from(conversations);
    } else {
      filteredConversations = conversations.where((conversation) {
        final property = conversation.listing.propertyName.toLowerCase();

        final seller = conversation.participants
            .map((e) => e.user.name ?? "")
            .join(" ")
            .toLowerCase();

        final message = conversation.lastMessage?.content?.toLowerCase() ?? "";

        return property.contains(searchText.toLowerCase()) ||
            seller.contains(searchText.toLowerCase()) ||
            message.contains(searchText.toLowerCase());
      }).toList();
    }

    update();
  }

  void filterAll() {
    filteredConversations = List.from(conversations);

    update();
  }

  void filterUnread() {
    filteredConversations = List.from(conversations);

    update();
  }

  void filterOffers() {
    filteredConversations = conversations.where((e) {
      final msg = e.lastMessage?.content ?? "";

      return msg.toLowerCase().contains("offer") ||
          msg.toLowerCase().contains("buy") ||
          msg.toLowerCase().contains("qar");
    }).toList();

    update();
  }

  void filterArchived() {
    filteredConversations = [];

    update();
  }

  void updateConversation(ChatListModel conversation) {
    final index = conversations.indexWhere((e) => e.id == conversation.id);

    if (index != -1) {
      conversations[index] = conversation;

      conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      searchConversation(searchText);
    }
  }

  void removeConversation(String conversationId) {
    conversations.removeWhere((e) => e.id == conversationId);

    searchConversation(searchText);
  }

  ChatListModel? getConversation(String id) {
    try {
      return conversations.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
