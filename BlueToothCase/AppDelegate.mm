//
//  AppDelegate.m
//  BlueToothCase
//
//  Created by wuzhengbin on 2017/4/12.
//  Copyright © 2017年 wuzhengbin. All rights reserved.
//

#import "AppDelegate.h"
#import "BTCTableViewController.h"
#import "SVProgressHUD.h"
#import "XMNetworking.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <BaiduMapAPI_Search/BMKSearchComponent.h>


@interface AppDelegate () {
    BMKMapManager *_manager;
}
@property (nonatomic, strong) NSMutableArray *array;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _manager = [[BMKMapManager alloc] init];
    BOOL ret = [_manager start:@"oGYvpInbfYn8uPvQORXXDArqDQ5Bqa2O" generalDelegate:nil];
    if (!ret) {
        NSLog(@"Manager start failed!");
    }

//    [XMCenter setupConfig:^(XMConfig * _Nonnull config) {
//        config.generalServer = @"http://123.56.184.37:30011/";
////        config.consoleLog = YES;
//    }];
    [XMCenter setupConfig:^(XMConfig * _Nonnull config) {
        config.generalServer = @"http://zhouwj.win/";
    }];
    
//    [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
//        request.api = @"users/app_login/";
//        request.httpMethod = kXMHTTPMethodPOST;
//        request.parameters = @{@"code":@"100000",
//                               @"username":@"admin",
//                               @"password":@"zhou123123"};
//
//    } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"登录:%@", responseObject);
//        NSLog(@"错误: %@", error.localizedDescription);
//    }];
    
    [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
        request.api = @"users/app_list_bed/";
        request.httpMethod = kXMHTTPMethodPOST;
        request.headers = @{@"Authorization":@"JWT 1234567890"};
//        request.parameters = @{@"code":@"100000",
//                               @"username":@"admin",
//                               @"password":@"zhou123123"};
        
    } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"登录:%@", responseObject);
        NSLog(@"错误: %@", error.localizedDescription);
    }];
    
//    [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
//        request.api = @"app/state/";
//        request.httpMethod = kXMHTTPMethodPOST;
//        request.parameters = @{@"device":@"047863A00214",
//                               @"longitude":@"121.362767",
//                               @"latitude":@"31.238190",
//                               @"latch_switch":@1,
//                               @"case_lost":@0};
//    } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"%@", responseObject);
//        NSLog(@"%@", error.localizedDescription);
//    }];
//    [XMCenter sendRequest:^(XMRequest * _Nonnull request) {
//        request.api = @"app/sendcommand/";
//        request.httpMethod = kXMHTTPMethodPOST;
//        request.parameters = @{@"device":@"047863A00564",
//                               @"latch_switch":@"1"};
//    } onFinished:^(id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"发送指令:%@", responseObject);
//        NSLog(@"发送指令失败: %@", error.localizedDescription);
//    }];
//
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
//    self.window.rootViewController = [UIViewController new];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BTCTableViewController alloc] init]];
    [self.window makeKeyAndVisible];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    //

    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NSLog(@"%@", change);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
