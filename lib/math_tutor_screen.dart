import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// State provider for the AI response
final aiResponseProvider = StateNotifierProvider<AIResponseNotifier, String>((ref) {
  return AIResponseNotifier();
});

// Notifier for managing AI response state
class AIResponseNotifier extends StateNotifier<String> {
  AIResponseNotifier() : super('');

  Future<void> askAI(String question) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']; // Load API key from .env

    if (apiKey == null || apiKey.isEmpty) {
      print("API key is missing.");
      state = 'Error: API key is missing';
      return;
    }

    final url = Uri.parse('https://api.openai.com/v1/completions');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'text-davinci-003',
          'prompt': question,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = data['choices'][0]['text'];
      } else {
        state = 'Error: Unable to retrieve response. Status: ${response.statusCode}';
      }
    } catch (e) {
      state = 'Error: Failed to call API';
      print(e); // Log the error to see what's happening
    }
  }
}

class MathTutorScreen extends ConsumerWidget {
  final TextEditingController _questionController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('Building MathTutorScreen UI...');
    final aiResponse = ref.watch(aiResponseProvider);

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
                  ref.read(aiResponseProvider.notifier).askAI(_questionController.text);
                }
              },
              child: Text('Ask AI'),
            ),
            SizedBox(height: 20),
            aiResponse.isNotEmpty
                ? Text(
                    'AI Response:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                : Container(),
            SizedBox(height: 10),
            aiResponse.isNotEmpty
                ? Text(
                    aiResponse,
                    style: TextStyle(fontSize: 16),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context, WidgetRef ref) {
  //   final aiResponse = ref.watch(aiResponseProvider);

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('MatzApp - AI Math Tutor'),
  //     ),
  //     body: Padding(
  //       padding: EdgeInsets.all(16.0),
  //       child: Column(
  //         children: <Widget>[
  //           TextField(
  //             controller: _questionController,
  //             decoration: InputDecoration(
  //               labelText: 'Ask a Math Question',
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //           SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: () {
  //               if (_questionController.text.isNotEmpty) {
  //                 ref.read(aiResponseProvider.notifier).askAI(_questionController.text);
  //               }
  //             },
  //             child: Text('Ask AI'),
  //           ),
  //           SizedBox(height: 20),
  //           aiResponse.isNotEmpty
  //               ? Text(
  //                   'AI Response:',
  //                   style: TextStyle(fontWeight: FontWeight.bold),
  //                 )
  //               : Container(),
  //           SizedBox(height: 10),
  //           aiResponse.isNotEmpty
  //               ? Text(
  //                   aiResponse,
  //                   style: TextStyle(fontSize: 16),
  //                 )
  //               : Container(),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
