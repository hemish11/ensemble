// manage Camera
import 'package:ensemble/framework/action.dart';
import 'package:ensemble/framework/bindings.dart';
import 'package:ensemble/framework/scope.dart';
import 'package:ensemble/widget/camera.dart';
import 'package:flutter/material.dart';

const optionMappings = {
  'mode': 'mode',
  'initialCamera': 'initialCamera',
  'allowGalleryPicker': 'allowGalleryPicker',
  'allowCameraRotate': 'allowCameraRotate',
  'allowFlashControl': 'allowFlashControl',
  'preview': 'preview',
  'maxCount': 'maxCount',
  'permissionDeniedMessage': 'permissionDeniedMessage',
  'accessButtonLabel': 'accessButtonLabel',
  'galleryButtonLabel': 'galleryButtonLabel',
  'nextButtonLabel': 'nextButtonLabel',
  'cameraRotateIcon': 'cameraRotateIcon',
  'galleryPickerIcon': 'galleryPickerIcon',
  'maxCountMessage': 'maxCountMessage',
};

const angleAssistOptions = {
  'assistAngleMessage': 'assistAngleMessage',
  'maxAngle': 'maxAngle',
  'minAngle': 'minAngle',
};

const speedAssistOptions = {
  'assistSpeedMessage': 'assistSpeedMessage',
  'maxSpeed': 'maxSpeed',
};

class CameraManager {
  Future<void> openCamera(BuildContext context, ShowCameraAction cameraAction,
      ScopeManager? scopeManager) async {
    Camera camera = Camera();
    if (cameraAction.id != null) {
      final previousAction =
          scopeManager?.dataContext.getContextById(cameraAction.id!) as Camera?;
      if (previousAction != null) camera = previousAction;
      scopeManager?.dataContext.addInvokableContext(cameraAction.id!, camera);
    }

    if (cameraAction.options != null) {      
      cameraAction.onComplete == null
          ? () {}
          : camera.setProperty('onComplete', cameraAction.onComplete);

      if (cameraAction.options!['assistAngle'] != null) {
        camera.setProperty('assistAngle', true);
        for (var option in cameraAction.options!['assistAngle'].keys) {
          final property = angleAssistOptions[option];
          if (property != null) {
            camera.setProperty(property, cameraAction.options!['assistAngle']![option]);
          }
        }
      }
      
      if (cameraAction.options!['assistSpeed'] != null) {
        camera.setProperty('assistSpeed', true);
        for (var option in cameraAction.options!['assistSpeed'].keys) {
          final property = angleAssistOptions[option];
          if (property != null) {
            camera.setProperty(property, cameraAction.options!['assistSpeed']![option]);
          }
        }
      }

       for (var option in cameraAction.options!.keys) {
          final property = optionMappings[option];
          if (property != null) {
            camera.setProperty(property, cameraAction.options![option]);
          }
        }
    }


    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => camera,
      ),
    );

    if (cameraAction.id != null) {
      scopeManager?.dispatch(
          ModelChangeEvent(WidgetBindingSource(cameraAction.id!), camera));
    }
  }

}
