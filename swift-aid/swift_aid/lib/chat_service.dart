import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:swift_aid/api.dart';

class ChatService {
  static const String apiKey = geminiApiKey;

  // 🧠 Keeps conversation history
  final List<Content> _history = [];

  // ✅ Restrict to health and first aid topics
  bool _isHealthRelated(String input) {
    final lower = input.toLowerCase();
    final allowedKeywords = [
      'injury',
      'burn',
      'bleeding',
      'choking',
      'faint',
      'emergency',
      'cpr',
      'cut',
      'snake bite',
      'fracture',
      'asthma',
      'pain',
      'unconscious',
      'wound',
      'first aid',
      'bandage',
      'heart attack',
      'pressure',
      'blood',
      'wound care',
      'medical',
    ];
    return allowedKeywords.any((word) => lower.contains(word));
  }

  Future<String> sendMessage(String userMessage) async {
    // Combine previous chat for smarter filtering (helps follow-ups)
    final previousContext = _history.isNotEmpty
        ? _history
            .map(
              (e) => e.parts
                  .map((p) =>
                      p is TextPart ? p.text : '') // ✅ correct text extraction
                  .join(' '),
            )
            .join(' ')
        : '';
    final combined = "$previousContext $userMessage";

    // 🩺 Apply filter only for first message, or if conversation clearly unrelated
    if (_history.isEmpty && !_isHealthRelated(userMessage)) {
      return "⚠️ Please ask only health or first-aid related questions.";
    } else if (_history.isNotEmpty && !_isHealthRelated(combined)) {
      final related = _isHealthRelated(previousContext);
      if (!related) {
        return "⚠️ This topic doesn't seem related to first aid or health. Please ask relevant questions.";
      }
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: apiKey,
      );

      final chat = model.startChat(history: _history);

      final userContent = Content.text(userMessage);
      _history.add(userContent); // store user's message

      final response = await chat.sendMessage(userContent);

      // ✅ Safely extract the bot’s text
      final reply = response.text ??
          response.candidates
              ?.map((c) => c.content.parts
                  .whereType<TextPart>()
                  .map((p) => p.text)
                  .join(' '))
              .join(' ')
              .trim();

      if (reply == null || reply.isEmpty) {
        return "I couldn't understand that. Please rephrase your question.";
      }

      // Save model reply for context
      _history.add(Content.model([TextPart(reply)]));

      return reply;
    } catch (e) {
      print("🔥 Gemini API error: $e");
      return "Something went wrong while connecting to Gemini. Please check your API key or internet.";
    }
  }

  // Optional: Reset chat manually (for “New Chat” button)
  void resetChat() {
    _history.clear();
  }
}
