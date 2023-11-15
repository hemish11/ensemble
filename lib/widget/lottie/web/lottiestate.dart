import 'dart:math';

import 'package:ensemble/framework/event.dart';
import 'package:ensemble/framework/widget/widget.dart';
import 'package:ensemble/screen_controller.dart';
import 'package:ensemble/util/utils.dart';
import 'package:ensemble/widget/helpers/widgets.dart';
import 'package:ensemble/widget/lottie/lottie.dart';
import 'package:ensemble/widget/widget_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:js_widget/js_widget.dart';
import 'dart:js' as js;

import 'package:lottie/lottie.dart';

class LottieState extends WidgetState<EnsembleLottie> {
  String id = 'lottie_' + (Random().nextInt(900000) + 100000).toString();
  @override
  Widget buildWidget(BuildContext context) {
    final isCanvasKit = js.context['flutterCanvasKit'] != null;
    print('isCanvasKit=$isCanvasKit');
    BoxFit? fit = Utils.getBoxFit(widget.controller.fit);

    Widget rtn = BoxWrapper(
        widget: isCanvasKit ? buildLottieCanvas(fit) : buildLottieHtml(fit),
        boxController: widget.controller,
        ignoresMargin: true,
        ignoresDimension: true);
    if (widget.controller.onTap != null) {
      rtn = GestureDetector(
          child: rtn,
          onTap: () => ScreenController().executeAction(
              context, widget.controller.onTap!,
              event: EnsembleEvent(widget)));
    }
    if (widget.controller.margin != null) {
      rtn = Padding(padding: widget.controller.margin!, child: rtn);
    }
    return rtn;
  }

  Widget buildLottieHtml(BoxFit? fit) {
    String source = widget.controller.source.trim();
    double width = widget.controller.width?.toDouble() ?? 250;
    double height = widget.controller.height?.toDouble() ?? 250;
    String _id = widget.controller.id ?? id;
    String repeat = (widget.controller.repeat == null)
        ? 'true'
        : widget.controller.repeat!.toString();
    String tag = '<div id="$_id"></div>';
    if (widget.controller.width == null || widget.controller.height == null) {
      print(
          'Lottie widget must have explicit width and height for html renderer in the browser (this includes the preview in the editor). You do not need to specify width or height for native apps or for canvaskit renderer. Defaulting to $width for width and $height for height');
    }

    if (source.isNotEmpty) {
      // image binding is tricky. When the URL has not been resolved
      // the image will throw exception. We have to use a permanent placeholder
      // until the binding engages
      return JsWidget(
          id: _id,
          createHtmlTag: () => tag,
          data: source,
          listener: (String msg) {
            if (widget.controller.onTap != null) {
              ScreenController().executeAction(
                  context, widget.controller.onTap!,
                  event: EnsembleEvent(widget));
            }
          },
          scriptToInstantiate: (String c) {
            String script =
                'bodymovin.loadAnimation({container: document.getElementById("$_id"),renderer: "svg",loop: $repeat,autoplay: true,path: "$c"});';
            if (widget.controller.onTap != null) {
              script +=
                  'document.getElementById("$_id").addEventListener("click",() => handleMessage("$_id",""));';
            }
            return script;
          },
          size: Size(width, height));
    }
    return blankPlaceholder();
  }

  Widget buildLottieCanvas(BoxFit? fit) {
    String source = widget.controller.source.trim();
    if (source.isNotEmpty) {
      // if is URL
      if (source.startsWith('https://') || source.startsWith('http://')) {
        // image binding is tricky. When the URL has not been resolved
        // the image will throw exception. We have to use a permanent placeholder
        // until the binding engages
        return Lottie.network(
          widget.controller.source,
          controller: widget.controller.lottieController,
          onLoaded: (composition) {
            widget.controller.initializeLottieController(composition);
          },
          width: widget.controller.width?.toDouble(),
          height: widget.controller.height?.toDouble(),
          repeat: widget.controller.repeat ?? true,
          fit: fit,
          errorBuilder: (context, error, stacktrace) => placeholderImage(),
        );
      }
      // else attempt local asset

      return Lottie.asset(Utils.getLocalAssetFullPath(widget.controller.source),
          controller: widget.controller.lottieController,
          onLoaded: (LottieComposition composition) {
            widget.controller.initializeLottieController(composition);
          },
          width: widget.controller.width?.toDouble(),
          height: widget.controller.height?.toDouble(),
          repeat: widget.controller.repeat,
          fit: fit,
          errorBuilder: (context, error, stacktrace) => placeholderImage());
    }
    return blankPlaceholder();
  }

  Widget placeholderImage() {
    return SizedBox(
        width: widget.controller.width?.toDouble(),
        height: widget.controller.height?.toDouble(),
        child: Image.asset('assets/images/img_placeholder.png',
            package: 'ensemble'));
  }

  Widget blankPlaceholder() => SizedBox(
      width: widget.controller.width?.toDouble(),
      height: widget.controller.height?.toDouble());
}
