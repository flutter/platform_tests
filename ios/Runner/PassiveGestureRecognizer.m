// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "PassiveGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface PassiveGestureRecognizer ()<UIGestureRecognizerDelegate>

@property(nonatomic, weak) UIResponder* eventForwardingTarget;

@end

@implementation PassiveGestureRecognizer

- (instancetype)initWithEventForwardingTarget:(UIResponder*)target {
  self = [super init];

  if (self) {
    self.delegate = self;
    self.eventForwardingTarget = target;
  }

  return self;
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
  [_eventForwardingTarget touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
  [_eventForwardingTarget touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
  [_eventForwardingTarget touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event {
  [_eventForwardingTarget touchesCancelled:touches withEvent:event];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:
        (UIGestureRecognizer*)otherGestureRecognizer {
  return YES;
}

@end
