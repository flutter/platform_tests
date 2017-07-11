// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PassiveGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface PassiveGestureRecognizer ()<UIGestureRecognizerDelegate, FlutterStreamHandler>

@property(nonatomic, weak) UIResponder* eventForwardingTarget;

@end

@implementation PassiveGestureRecognizer {
  FlutterEventChannel* velocityChannel;
  FlutterEventSink velocitySink;
  CGFloat (^scrollVelocityGetter)(void);
}

- (instancetype)initWithFlutterViewController:(FlutterViewController *)controller
                           withVelocityGetter:(CGFloat (^)(void))velocityGetter {
  self = [super init];
  scrollVelocityGetter = velocityGetter;

  if (self) {
    self.delegate = self;
    self.eventForwardingTarget = controller.view;
    velocityChannel =
        [FlutterEventChannel eventChannelWithName:@"scroll_overlay.flutter.io/velocity"
                                  binaryMessenger:controller];
    // This shouldn't be executed inline because this method is invoked during the flutter view's
    // construction and it is referred to by setStreamHandler.
    dispatch_async(dispatch_get_main_queue(), ^{
      [velocityChannel setStreamHandler:self];
    });
  }

  return self;
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
  [_eventForwardingTarget touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
  [_eventForwardingTarget touchesMoved:touches withEvent:event];
  if (velocitySink) {
    velocitySink([NSNumber numberWithFloat:scrollVelocityGetter()]);
  }
}

- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
  [_eventForwardingTarget touchesEnded:touches withEvent:event];
  if (velocitySink) {
    velocitySink([NSNumber numberWithFloat:scrollVelocityGetter()]);
  }
}

- (void)touchesCancelled:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
  [_eventForwardingTarget touchesCancelled:touches withEvent:event];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:
    (UIGestureRecognizer*)otherGestureRecognizer {
  return YES;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
  velocitySink = events;
  return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments {
  velocitySink = nil;
  return nil;
}

@end
