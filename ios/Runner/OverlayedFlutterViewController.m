// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "OverlayScrollView.h"
#import "OverlayedFlutterViewController.h"

@interface OverlayedFlutterViewController ()

@property(nonatomic, strong) OverlayScrollView* overlay;

@end

@implementation OverlayedFlutterViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.overlay = [[OverlayScrollView alloc] initWithFlutterViewController:self];

  [self.view addSubview:self.overlay];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  self.overlay.frame = self.view.bounds;
}

@end
