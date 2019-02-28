#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

@implementation AppDelegate {
    UINavigationController *nc1;
    UIViewController *ct2;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
    
    CGRect screenRect = UIScreen.mainScreen.bounds;
    self.window.frame = CGRectMake(0, screenRect.size.height /2, screenRect.size.width, screenRect.size.height /2 );
    
    UIViewController *ct1 = [UIViewController new];
    ct1.title = @"ios";
    ct1.view.backgroundColor = [UIColor yellowColor];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn1 setTitle:@"Press for next page" forState:UIControlStateNormal];
    btn1.tintColor = [UIColor blackColor];
    btn1.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    [btn1 addTarget:self action:@selector(buttonHandler) forControlEvents:UIControlEventTouchDown];
    
    UIImage *img = [UIImage imageNamed:@"image_test.jpg"];
    UIImageView *imgv = [[UIImageView alloc]initWithImage:img];
    imgv.frame = CGRectMake(0, 0, ct1.view.bounds.size.width, ct1.view.bounds.size.height/2);
    [ct1.view addSubview:imgv];
    
    [btn1 sizeToFit];
    
    btn1.frame = CGRectMake( ct1.view.bounds.size.width/2 - btn1.frame.size.width/2, ct1.view.bounds.size.height/4 - btn1.frame.size.height/2, btn1.frame.size.width, btn1.frame.size.height);
    [ct1.view addSubview:btn1];
    
    ct2 = [UIViewController new];
    ct2.view.backgroundColor = [UIColor greenColor];
    
    nc1 = [[UINavigationController alloc] initWithRootViewController:ct1];
    nc1.navigationBarHidden = true;
    [nc1.interactivePopGestureRecognizer setDelegate:nil];
    
    self.windowTwo = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height / 2)];
    self.windowTwo.rootViewController = nc1;
    
    [self.windowTwo makeKeyAndVisible];
    
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

-(void)buttonHandler {
    [nc1 pushViewController:ct2 animated:true];
}

@end
