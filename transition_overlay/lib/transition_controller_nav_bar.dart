import 'package:flutter/cupertino.dart';
import 'package:transition_overlay/main.dart';
import 'package:transition_overlay/second_page.dart';
import 'package:transition_overlay/time_dilation_provider.dart';
import 'package:transition_overlay/transition_data_provider.dart';

class TransitionControllerNavBar extends StatefulWidget
    with ObstructingPreferredSizeWidget {
  const TransitionControllerNavBar(
      {super.key, this.secondPageKey, this.isForSecondPage = false});

  final GlobalKey? secondPageKey;
  final bool isForSecondPage;

  @override
  State<TransitionControllerNavBar> createState() =>
      _TransitionControllerNavBarState();

  // These are the same as in CupertinoNavigationBar
  @override
  Size get preferredSize =>
      const Size.fromHeight(kMinInteractiveDimensionCupertino);

  @override
  bool shouldFullyObstruct(BuildContext context) {
    final Color backgroundColor = CupertinoTheme.of(context).barBackgroundColor;

    return backgroundColor.alpha == 0xFF;
  }
}

class _TransitionControllerNavBarState
    extends State<TransitionControllerNavBar> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemGrey6,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child:
              widget.isForSecondPage ? const Text("Pop") : const Text("Push"),
          onPressed: () {
            TransitionDataProvider.of(context)!
                .transitionData
                .startTransitionReportingFor(
                  pageKey: widget.secondPageKey!,
                  context: context,
                );

            if (widget.isForSecondPage) {
              platformMethodChannel.invokeMethod('pop');

              Navigator.pop(context);

              return;
            } else {
              final route = CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  platformMethodChannel.invokeMethod('push');

                  return SecondPage(key: widget.secondPageKey);
                },
              );

              Navigator.of(context).push(route);

              // This also tracks pop animation
              route.animation?.addStatusListener((status) {
                if (status == AnimationStatus.completed ||
                    status == AnimationStatus.dismissed) {
                  TransitionDataProvider.of(context)!
                      .transitionData
                      .stopTransitionReporting();
                }
              });
            }
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder(
              valueListenable:
                  TimeDilationProvider.of(context)!.timeDilationNotifier,
              builder: (context, value, child) {
                return value == 1.0
                    ? CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text("Speed: 1.0x"),
                        onPressed: () {
                          platformMethodChannel.invokeMethod('slow-mo enabled');

                          TimeDilationProvider.of(context)!
                              .setNewTimeDilation(5.0);
                        },
                      )
                    : CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Text("Speed: 0.2x"),
                        onPressed: () {
                          platformMethodChannel
                              .invokeMethod('slow-mo disabled');

                          TimeDilationProvider.of(context)!
                              .setNewTimeDilation(1.0);
                        },
                      );
              },
            ),
            const SizedBox(width: 8),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: AnimatedBuilder(
                  animation: TransitionDataProvider.of(context)!
                      .transitionConfiguration,
                  builder: (context, child) {
                    return Text(
                        "Resolution: ${TransitionDataProvider.of(context)!.transitionConfiguration.resolution}x");
                  }),
              onPressed: () {
                final config =
                    TransitionDataProvider.of(context)!.transitionConfiguration;

                if (config.resolution == 4) {
                  config.setResolution(6);
                } else if (config.resolution == 6) {
                  config.setResolution(8);
                } else if (config.resolution == 8) {
                  config.setResolution(10);
                } else if (config.resolution == 10) {
                  config.setResolution(4);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
