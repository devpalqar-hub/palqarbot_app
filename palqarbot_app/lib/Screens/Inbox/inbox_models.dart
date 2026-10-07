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
  final String text;
  final String time;
  final Sender sender;

  const ChatMessage(this.text, this.time, this.sender);
}

class Conversation {
  final String name;
  final String lastMessage;
  final String time;
  final Channel channel;
  final int unread;
  final bool botActive;
  final List<ChatTag> tags;
  final List<ChatMessage> messages;

  const Conversation({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.channel,
    this.unread = 0,
    this.botActive = false,
    this.tags = const [],
    this.messages = const [],
  });
}

const _general = ChatTag('General', AppColors.textSecondary, AppColors.surfaceSecondary);

const _newLead = ChatTag('New Lead', AppColors.primary, AppColors.primaryLight);

const List<ChatMessage> _anjaliMessages = [
  ChatMessage('Hi, I would like to know more about your services.', '10:24 AM', Sender.customer),
  ChatMessage('Hi! 👋 Thanks for reaching out. We\'d be happy to help you. Could you please share what service you are interested in?', '10:24 AM', Sender.bot),
  ChatMessage('Do you have a pricing plan for small businesses?', '10:26 AM', Sender.customer),
  ChatMessage('Yes, we do have a special plan for small businesses. Our starting plan is ₹2,499 per month. Would you like me to share the full details?', '10:28 AM', Sender.agent),
  ChatMessage('Yes please. Also, do you offer a free trial?', '10:29 AM', Sender.customer),
  ChatMessage('Yes, we offer a 7-day free trial. You can try all the features before choosing a plan. Would you like me to send the signup link?', '10:29 AM', Sender.bot),
  ChatMessage('Sure, please send the link.', '10:30 AM', Sender.customer),
];

const List<Conversation> dummyConversations = [
  Conversation(
    name: 'Rahul Kumar',
    lastMessage: 'Is this product available in different colors?',
    time: '2m',
    channel: Channel.whatsapp,
    unread: 2,
    tags: [_newLead, ChatTag('Product', AppColors.textSecondary, AppColors.surfaceSecondary)],
    messages: [
      ChatMessage('Is this product available in different colors?', '10:40 AM', Sender.customer),
    ],
  ),
  Conversation(
    name: 'Anjali Thomas',
    lastMessage: 'Can you share the price details and delivery time?',
    time: '12m',
    channel: Channel.instagram,
    unread: 1,
    tags: [
      ChatTag('Interested', AppColors.success, AppColors.successLight),
      ChatTag('Pricing', AppColors.textSecondary, AppColors.surfaceSecondary),
    ],
    messages: _anjaliMessages,
  ),
  Conversation(
    name: 'Mohammed Ali',
    lastMessage: 'Thank you for the information!',
    time: '25m',
    channel: Channel.whatsapp,
    botActive: true,
    tags: [ChatTag('Bot Active', AppColors.info, AppColors.infoLight), _general],
    messages: [
      ChatMessage('Thank you for the information!', '10:05 AM', Sender.customer),
    ],
  ),
  Conversation(
    name: 'Sarah Wilson',
    lastMessage: 'Do you have home delivery in Kochi?',
    time: '1h',
    channel: Channel.instagram,
    unread: 3,
    tags: [_newLead, ChatTag('Delivery', AppColors.textSecondary, AppColors.surfaceSecondary)],
    messages: [
      ChatMessage('Do you have home delivery in Kochi?', '9:30 AM', Sender.customer),
    ],
  ),
  Conversation(
    name: 'Arjun Nair',
    lastMessage: 'I would like to book an appointment.',
    time: '2h',
    channel: Channel.whatsapp,
    tags: [
      ChatTag('Contacted', AppColors.warning, AppColors.warningLight),
      ChatTag('Booking', AppColors.textSecondary, AppColors.surfaceSecondary),
    ],
    messages: [
      ChatMessage('I would like to book an appointment.', '8:45 AM', Sender.customer),
    ],
  ),
  Conversation(
    name: 'Priya Menon',
    lastMessage: 'Is this still available?',
    time: '4h',
    channel: Channel.instagram,
    tags: [
      ChatTag('Follow Up', AppColors.error, AppColors.errorLight),
      ChatTag('Product', AppColors.textSecondary, AppColors.surfaceSecondary),
    ],
    messages: [
      ChatMessage('Is this still available?', '6:50 AM', Sender.customer),
    ],
  ),
  Conversation(
    name: 'Vishnu Raj',
    lastMessage: 'Great! I will confirm and place the order.',
    time: '5h',
    channel: Channel.whatsapp,
    tags: [
      ChatTag('Converted', AppColors.success, AppColors.successLight),
      ChatTag('Order', AppColors.textSecondary, AppColors.surfaceSecondary),
    ],
    messages: [
      ChatMessage('Great! I will confirm and place the order.', '5:30 AM', Sender.customer),
    ],
  ),
];
