import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:rebellion/utils/logger.dart';

abstract class Translator {
  const Translator();

  Future<String> translate(
    String sourceLanguage,
    String targetLanguage,
    String value,
    String? valueDescription,
  );
}

class OpenAiTranslator extends Translator {
  final String model;
  static const _accessTokenEnvVariable = 'REBELLION_OPEN_AI';

  const OpenAiTranslator({required this.model});

  @override
  Future<String> translate(
    String sourceLanguage,
    String targetLanguage,
    String value,
    String? valueDescription,
  ) async {
    final accessKey = Platform.environment[_accessTokenEnvVariable];
    if (accessKey == null || accessKey.isEmpty) {
      logError(
        'Access key must be provided using the environment variable $_accessTokenEnvVariable',
      );
      exit(1);
    }

    OpenAI.apiKey = accessKey;

    // The system message that will be sent to the request
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.assistant,
      content: [
        ...[
          'I want you to act as a translator for mobile application strings.',
          'Try to keep length of the translated text.',
          '''You need to answer only with the translation and nothing else until I say to stop it.''',
          'No commentaries.',
          'This app is a Flutter app, string format is ARB.',
        ].map(OpenAIChatCompletionChoiceMessageContentItemModel.text),
        if (valueDescription != null)
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            'The context for this string is "$valueDescription"',
          ),
      ],
    );

    // User message that will be sent to the request
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          'Translate next text from $sourceLanguage to $targetLanguage: $value',
        ),
      ],
    );

    final chatCompletion = await OpenAI.instance.chat.create(
      model: model,
      messages: [systemMessage, userMessage],
    );

    final response = chatCompletion.choices.first.message;
    logMessage('API response: $response'); // TODO delete this
    return response.content!.first.text!;
  }
}
