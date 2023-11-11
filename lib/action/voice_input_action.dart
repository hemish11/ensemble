import 'package:ensemble/framework/action.dart';
import 'package:ensemble/framework/scope.dart';
import 'package:flutter/cupertino.dart';

class VoiceInputAction extends EnsembleAction {
  VoiceInputAction();

  // TDDO: Add parameters

  factory VoiceInputAction.from(dynamic inputs) {
    // TODO: Add parsing

    return VoiceInputAction();
  }

  @override
  Future<dynamic> execute(BuildContext context, ScopeManager scopeManager) {
    // TODO: Add actions

    return Future.value(null);
  }
}
