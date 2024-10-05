import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

// State provider for the AI response
final aiResponseProvider = StateNotifierProvider<AIResponseNotifier, String>((ref) {
  return AIResponseNotifier();
});

// Notifier for managing AI response state
class AIResponseNotifier extends StateNotifier<String> {
  AIResponseNotifier() : super('');

  Future<void> askAI(String question) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']; // Load API key from .env
    final url = Uri.parse('https://api.openai.com/v1/completions');

    if (apiKey == null || apiKey.isEmpty) {
      state = 'Error: Missing API key.';
      return;
    }

    try {
      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'prompt': question,
          'max_tokens': 150,
        }),
      )
          .timeout(const Duration(seconds: 15), onTimeout: () {
        // Timeout handling
        throw TimeoutException('Request timed out.');
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = data['choices'][0]['text'];
      } else if (response.statusCode == 429) {
        state = 'Error: Rate limit exceeded. Please try again later.';
      } else if (response.statusCode == 400 && response.body.contains("max_tokens")) {
        state = 'Error: Token limit exceeded. Try using a shorter query.';
      } else {
        state = 'Error: Unable to retrieve response. Status code: ${response.statusCode}.';
      }
    } on TimeoutException catch (_) {
      state = 'Error: Request timed out. Please check your connection and try again.';
    } catch (e) {
      state = 'Error: An unexpected error occurred.';
      print(e); // Log the error for debugging
    }
  }
}

class MathTutorScreen extends ConsumerWidget {
  final TextEditingController _questionController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aiResponse = ref.watch(aiResponseProvider);
    final isLoading = aiResponse == '';

    return Scaffold(
      appBar: AppBar(
        title: Text('MatzApp - AI Math Tutor'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Ask a Math Question',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_questionController.text.isNotEmpty) {
                  // Clear response and set loading state
                  ref.read(aiResponseProvider.notifier).askAI(_questionController.text);
                }
              },
              child: Text('Ask AI'),
            ),
            SizedBox(height: 20),

            // Show loading spinner while waiting for the API response
            isLoading
                ? CircularProgressIndicator()
                : aiResponse.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Response:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Text(
                            aiResponse,
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}
