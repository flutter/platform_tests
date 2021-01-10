#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"

#define controllers_relative_position(a, b) [a.view.layer.presentationLayer convertRect:a.view.layer.presentationLayer.frame toLayer:    b.view.layer].origin.x

NSString *point_print_format = @"(%f, %f)\n";
NSString *file_output_name = @"points.txt";


@implementation AppDelegate {
    
    UINavigationController *navigation_controller;
    
    UIViewController *test_controller1;
    UIViewController *test_controller2;
    UIViewController *push_controller;
    UIViewController *back_controller;
    
    NSOutputStream *stream;
    
    NSTimer *timer;
    bool is_first_cycle;
    
    NSTimeInterval time_start;
    NSTimeInterval duration;
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    is_first_cycle = true;
    
    test_controller1 = [UIViewController new];
    test_controller1.view.backgroundColor = [UIColor orangeColor];
    
    test_controller2 = [UIViewController new];
    test_controller2.view.backgroundColor = [UIColor orangeColor];
    
    push_controller = [UIViewController new];
    push_controller.view.backgroundColor = [UIColor yellowColor];
    
    back_controller = [UIViewController new];
    back_controller.view.backgroundColor = [UIColor greenColor];
    
    navigation_controller = [[UINavigationController alloc] initWithRootViewController:back_controller];
    navigation_controller.delegate = self;
    
    CGRect screen = UIScreen.mainScreen.bounds;
    self.window = [[UIWindow alloc] initWithFrame:screen];
    self.window.rootViewController = navigation_controller;
    [self.window makeKeyAndVisible];
    
    
    NSString *documents_path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)[0];
    NSString *file_path = [NSString stringWithFormat:@"%@/%@", documents_path, file_output_name];
    
    
    NSLog(@"The output file is located at '%@'. The points array is formatted to be copy/pasted to https://www.desmos.com/calculator", documents_path);
    
    float __block current_position;
    float screen_width = UIScreen.mainScreen.bounds.size.width;
    
    
    [@"" writeToFile:file_path atomically:false encoding:NSUTF8StringEncoding error:nil];
    stream = [[NSOutputStream alloc] initToFileAtPath:file_path append:YES];
    [stream open];
    
    timer = [NSTimer timerWithTimeInterval:0.001 repeats:true block:^(NSTimer * _Nonnull timer) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self->is_first_cycle) {
                self->time_start = [NSDate timeIntervalSinceReferenceDate];
                self->is_first_cycle = false;
            }
            
            current_position = controllers_relative_position(self->push_controller, self->navigation_controller);
            float position_delta = (screen_width - current_position) / screen_width;
            
            NSTimeInterval current_time = [NSDate timeIntervalSinceReferenceDate];
            NSTimeInterval time_delta = (current_time - self->time_start) / self->duration;
            
            NSString *string = [NSString stringWithFormat:point_print_format, time_delta, position_delta];
            
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            [self->stream write:(uint8_t *)[data bytes] maxLength:[data length]];
            
            if (position_delta == 1) {
                [timer invalidate];
                [self->stream close];
            }
        });
    }];
    
    [navigation_controller pushViewController:test_controller1 animated:true];
    NSLog(@"Test 1: Preparing..."); // First transition animation revealed to be different from normal
    return true;
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    
    
    if ([viewController isEqual:test_controller2]) {
        
        NSLog(@"Test 2: Getting transition duration...");
        time_start = [NSDate timeIntervalSinceReferenceDate];
        
    } else if ([viewController isEqual:push_controller]) {
        
        NSLog(@"Test 3: Getting animation curve...");
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        time_start = [NSDate timeIntervalSinceReferenceDate];
        
    }
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if ([viewController isEqual:test_controller2]) {
        
        duration = [NSDate timeIntervalSinceReferenceDate] - time_start;
        NSLog(@"Duration got: %fs", duration);
        [navigation_controller popViewControllerAnimated:false];
        [navigation_controller pushViewController:push_controller animated:true];
        
    } else if ([viewController isEqual:push_controller]) {
        
        NSLog(@"Timer stopped, animation duration: %fs", [NSDate timeIntervalSinceReferenceDate] - time_start);
        
    } else if ([viewController isEqual:test_controller1]){
        
        [navigation_controller popViewControllerAnimated:false];
        [navigation_controller pushViewController:test_controller2 animated:true];
    }
}

@end
