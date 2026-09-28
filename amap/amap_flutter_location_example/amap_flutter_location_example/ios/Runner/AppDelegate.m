#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
//#import <AMapFoundationKit/AMapFoundationKit.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
//    通过native代码配置key
//    [AMapServices sharedServices].apiKey =@"您的key";
    
    [GeneratedPluginRegistrant registerWithRegistry:self];
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
