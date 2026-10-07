import 'package:flutter/material.dart';
import 'package:palqarbot_app/Core/Theme/app_colors.dart';

enum Channel { whatsapp, instagram }

enum Sender { customer, bot, agent }

class ChatTag {
  final String label;
  final Color color;
  final Color background;

  const ChatTag(this.label, this.color, this.background);
}

class ChatMessage {
  final String id;
  final String text;
  final DateTime? createdAt;
  final Sender sender;
  final bool failed;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.sender,
    this.failed = false,
  });

  String get time => formatClock(createdAt);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: _str(json['id']) ?? '',
      text: _str(_pick(json, ['content', 'text', 'body', 'message'])) ?? '',
      createdAt: _date(_pick(json, ['createdAt', 'timestamp', 'sentAt'])),
      sender: _sender(json),
      failed: (_str(json['status']) ?? '').toUpperCase() == 'FAILED',
    );
  }

  static Sender _sender(Map<String, dynamic> json) {
    final who = (_str(_pick(json, ['sender', 'senderType', 'role', 'from', 'author'])) ?? '').toLowerCase();
    final direction = (_str(json['direction']) ?? '').toLowerCase();

    if (['user', 'customer', 'contact', 'inbound', 'incoming'].any(who.contains)) {
      return Sender.customer;
    }
    if (['ai', 'bot', 'assistant', 'system'].any(who.contains)) return Sender.bot;
    if (['human', 'agent', 'admin', 'staff', 'manual'].any(who.contains)) return Sender.agent;

    if (direction.contains('in')) return Sender.customer;
    if (json['isAi'] == true || json['aiGenerated'] == true || json['isBot'] == true) {
      return Sender.bot;
    }
    return Sender.agent;
  }
}

class Conversation {
  final String id;
  final String name;
  final String lastMessage;
  final DateTime? lastAt;
  final Channel channel;
  final int unread;
  final bool aiEnabled;
  final String? leadStatus;

  const Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastAt,
    required this.channel,
    required this.unread,
    required this.aiEnabled,
    required this.leadStatus,
  });

  String get time => formatAgo(lastAt);

  List<ChatTag> get tags {
    final list = <ChatTag>[];
    if (leadStatus != null && leadStatus!.isNotEmpty) list.add(_leadTag(leadStatus!));
    if (!aiEnabled) {
      list.add(const ChatTag('Manual', AppColors.warning, AppColors.warningLight));
    }
    return list;
  }

  Conversation copyWith({bool? aiEnabled, int? unread, String? lastMessage, DateTime? lastAt}) {
    return Conversation(
      id: id,
      name: name,
      lastMessage: lastMessage ?? this.lastMessage,
      lastAt: lastAt ?? this.lastAt,
      channel: channel,
      unread: unread ?? this.unread,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      leadStatus: leadStatus,
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final contact = _map(json['contact']) ?? _map(json['customer']) ?? const <String, dynamic>{};
    final lead = _map(json['lead']) ?? const <String, dynamic>{};

    final name = _str(_pick(contact, ['name', 'displayName', 'fullName', 'username', 'waId', 'phone'])) ??
        _str(_pick(json, ['name', 'contactName', 'customerName', 'username', 'phone'])) ??
        'Unknown';

    final shownName = RegExp(r'^\d{8,}$').hasMatch(name) ? '+$name' : name;

    String last = '';
    DateTime? lastAt;
    final lastRaw = _pick(json, ['lastMessage', 'latestMessage', 'lastMessagePreview', 'preview', 'lastMessageContent']);
    if (lastRaw is Map) {
      final m = Map<String, dynamic>.from(lastRaw);
      last = _str(_pick(m, ['content', 'text', 'body', 'message'])) ?? '';
      lastAt = _date(_pick(m, ['createdAt', 'timestamp']));
    } else if (lastRaw != null) {
      last = _str(lastRaw) ?? '';
    } else if (json['messages'] is List && (json['messages'] as List).isNotEmpty) {
      final first = (json['messages'] as List).first;
      if (first is Map) {
        final m = Map<String, dynamic>.from(first);
        last = _str(_pick(m, ['content', 'text', 'body', 'message'])) ?? '';
        lastAt = _date(_pick(m, ['createdAt', 'timestamp']));
      }
    }
    lastAt ??= _date(_pick(json, ['lastMessageAt', 'updatedAt', 'createdAt']));

    final status = (_str(json['status']) ?? '').toUpperCase();
    final aiRaw = _pick(json, ['aiEnabled', 'aiActive', 'autoReply']);
    final aiEnabled = aiRaw is bool ? aiRaw : !status.contains('HUMAN');

    return Conversation(
      id: _str(json['id']) ?? '',
      name: shownName,
      lastMessage: last,
      lastAt: lastAt,
      channel: (_str(json['channel']) ?? '').toLowerCase().contains('insta')
          ? Channel.instagram
          : Channel.whatsapp,
      unread: _int(_pick(json, ['unreadCount', 'unread'])),
      aiEnabled: aiEnabled,
      leadStatus: _str(_pick(lead, ['status', 'stage'])) ?? _str(_pick(json, ['leadStatus', 'stage'])),
    );
  }
}

List<dynamic> extractList(dynamic data) {
  if (data is List) return data;
  if (data is Map) {
    for (final key in ['data', 'items', 'conversations', 'messages', 'results']) {
      final v = data[key];
      if (v is List) return v;
      if (v is Map) {
        final inner = extractList(v);
        if (inner.isNotEmpty) return inner;
      }
    }
  }
  return const [];
}

String formatClock(DateTime? d) {
  if (d == null) return '';
  final t = d.toLocal();
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour >= 12 ? 'PM' : 'AM'}';
}

String formatAgo(DateTime? d) {
  if (d == null) return '';
  final diff = DateTime.now().difference(d.toLocal());
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}

ChatTag _leadTag(String status) {
  final label = status
      .toLowerCase()
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
  final s = status.toLowerCase();

  if (s.contains('new')) return ChatTag(label, AppColors.primary, AppColors.primaryLight);
  if (s.contains('follow') || s.contains('lost')) {
    return ChatTag(label, AppColors.error, AppColors.errorLight);
  }
  if (s.contains('contact')) return ChatTag(label, AppColors.warning, AppColors.warningLight);
  if (s.contains('interest') || s.contains('qualif') || s.contains('convert') || s.contains('won')) {
    return ChatTag(label, AppColors.success, AppColors.successLight);
  }
  return ChatTag(label, AppColors.textSecondary, AppColors.surfaceSecondary);
}

dynamic _pick(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    if (json[k] != null) return json[k];
  }
  return null;
}

Map<String, dynamic>? _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : null;

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

int _int(dynamic v) {
  if (v is int) return v;
  return int.tryParse(v?.toString() ?? '') ?? 0;
}

DateTime? _date(dynamic v) => v == null ? null : DateTime.tryParse(v.toString());
