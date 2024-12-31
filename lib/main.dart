import 'package:flutter/material.dart';
import 'package:groq/groq.dart';
import 'dart:convert'; // Import this to handle UTF-8 decoding

void main() {
  runApp(TranslationApp());
}

// Initialize Groq client
final groq = Groq(
  apiKey: const String.fromEnvironment('groqApiKey'),
  model: "llama-3.3-70b-versatile",
);

class TranslationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groq Translator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = '';
  bool _isLoading = false;
  String _selectedLanguage = 'French';

  final List<String> _languages = [
    'French',
    'Spanish',
    'German',
    'Italian',
    'Japanese',
    'Punjabi',
  ];

  Future<void> _translateText() async {
    setState(() {
      _isLoading = true;
    });

    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) {
      setState(() {
        _translatedText = "Please enter text to translate.";
        _isLoading = false;
      });
      return;
    }

    try {
      groq.startChat();

      // Formulate the translation prompt
      final String prompt =
          'Translate the following text into $_selectedLanguage "$inputText" in String';

      // Sending the prompt to the Groq client
      GroqResponse response = await groq.sendMessage(prompt);

      // Get the raw response
      final String rawResponse = response.choices.first.message.content.trim();
      print(rawResponse);

      // Decode the response to handle any encoding issues (like utf-8)
      String decodedResponse =
          utf8.decode(rawResponse.runes.toList(), allowMalformed: true);

      setState(() {
        _translatedText = decodedResponse;
      });
    } catch (error) {
      setState(() {
        _translatedText = 'An error occurred: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groq Translator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _inputController,
              decoration: const InputDecoration(
                labelText: 'Enter Text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                });
              },
              items:
                  _languages.map<DropdownMenuItem<String>>((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _translateText,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Translate'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Translated Output:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16.0),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                _translatedText, // Use SelectableText for better text handling
                style: const TextStyle(color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
