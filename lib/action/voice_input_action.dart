// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:ensemble/framework/action.dart';
import 'package:ensemble/framework/error_handling.dart';
import 'package:ensemble/framework/event.dart';
import 'package:ensemble/framework/scope.dart';
import 'package:ensemble/screen_controller.dart';
import 'package:ensemble/util/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';

final SpeechToText speech = SpeechToText();

class StartListeningAction extends EnsembleAction {
  StartListeningAction({
    this.onStatus,
    this.onError,
    this.onResult,
    this.listenForSeconds,
    this.listenMode,
  });

  final EnsembleAction? onStatus;
  final EnsembleAction? onError;
  final EnsembleAction? onResult;
  final String? listenForSeconds;
  final String? listenMode;

  factory StartListeningAction.from(dynamic inputs) {
    Map? payload;

    if (inputs is! Map) payload = Utils.getYamlMap(inputs);
    if (inputs is Map) payload = inputs;

    if (payload == null || payload['onResult'] == null) {
      throw LanguageError(
          "${ActionType.startListening.name} requires 'onResult'");
    }

    return StartListeningAction(
      onStatus: EnsembleAction.fromYaml(payload['onStatus']),
      onError: EnsembleAction.fromYaml(payload['onError']),
      onResult: EnsembleAction.fromYaml(payload['onResult']),
      listenForSeconds: payload['listenForSeconds'],
      listenMode: payload['listenMode'],
    );
  }

  @override
  Future<dynamic> execute(
    BuildContext context,
    ScopeManager scopeManager,
  ) async {
    bool available = await speech.initialize(
      onStatus: (status) {
        if (onStatus != null) {
          ScreenController().executeActionWithScope(
            context,
            scopeManager,
            onStatus!,
            event: EnsembleEvent(null, data: status),
          );
        }
      },
      onError: (errorNotification) {
        if (onStatus != null) {
          ScreenController().executeActionWithScope(
            context,
            scopeManager,
            onStatus!,
            event: EnsembleEvent(null, data: errorNotification.errorMsg),
          );
        }
      },
    );

    final evalSeconds = Utils.optionalInt(
      scopeManager.dataContext.eval(listenForSeconds),
    );
    final evalListenMode = scopeManager.dataContext.eval(listenMode);

    if (available) {
      await speech.listen(
        listenFor: evalSeconds == null ? null : Duration(seconds: evalSeconds),
        listenMode: ListenMode //
            .values
            .firstWhere(
          (e) => e.name == evalListenMode,
          orElse: () => ListenMode.dictation,
        ),
        onResult: (result) {
          if (onResult != null) {
            ScreenController().executeActionWithScope(
              context,
              scopeManager,
              onResult!,
              event: EnsembleEvent(
                null,
                data: result.recognizedWords,
              ),
            );
          }
        },
      );
    }

    return Future.value(null);
  }
}

class StopListeningAction extends EnsembleAction {
  StopListeningAction({this.onResult});

  final EnsembleAction? onResult;

  factory StopListeningAction.from(dynamic inputs) {
    Map? payload;

    if (inputs is! Map) payload = Utils.getYamlMap(inputs);
    if (inputs is Map) payload = inputs;

    if (payload == null || payload['onResult'] == null) {
      throw LanguageError(
          "${ActionType.startListening.name} requires 'onResult'");
    }

    return StopListeningAction(
      onResult: EnsembleAction.fromYaml(payload['onResult']),
    );
  }

  @override
  Future<dynamic> execute(
    BuildContext context,
    ScopeManager scopeManager,
  ) async {
    await speech.stop();

    ScreenController().executeActionWithScope(
      context,
      scopeManager,
      onResult!,
      event: EnsembleEvent(
        null,
        data: speech.lastRecognizedWords,
      ),
    );

    return Future.value(null);
  }
}
