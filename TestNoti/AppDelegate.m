//
//  AppDelegate.m
//  TestNoti
//
//  Created by 朱志佳 on 2019/5/13.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "AppDelegate.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


//- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    // Override point for customization after application launch.
//    return YES;
//}


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

#pragma mark 3. 通知 AppDelegate中的回调方法
#pragma mark 通知回调 系统版本 < iOS 10
// 如果App已经完全退出：
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
     NSDictionary *userInfoLocal = (NSDictionary *)[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    NSLog(@"userInfoLocal:%@",userInfoLocal);
     NSDictionary *userInfoRemote = (NSDictionary *)[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"userInfoRemote:%@",userInfoRemote);
    
    return YES;
}
// 当App已经完全退出时，获取userInfo参数过程如下：
// NSDictionary *userInfoLocal = (NSDictionary *)[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
// NSDictionary *userInfoRemote = (NSDictionary *)[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
// 如果App还在运行（前台or后台）
// 注：iOS10以上如果不使用UNUserNotificationCenter时，也将走此回调方法
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // iOS6及以下系统
    if (userInfo) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {// app位于前台通知
            NSLog(@"app位于前台通知(didReceiveRemoteNotification:):%@", userInfo);
        } else {// 切到后台唤起
            NSLog(@"app位于后台通知(didReceiveRemoteNotification:):%@", userInfo);
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler NS_AVAILABLE_IOS(7_0) {
    // iOS7及以上系统
    if (userInfo) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            NSLog(@"app位于前台通知(didReceiveRemoteNotification:fetchCompletionHandler:):%@", userInfo);
        } else {
            NSLog(@"app位于后台通知(didReceiveRemoteNotification:fetchCompletionHandler:):%@", userInfo);
        }
    }
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    NSLog(@"notification:%@",notification);
}

#pragma mark 系统版本 >= iOS 10
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#pragma mark UNUserNotificationCenterDelegate
//  iOS>=10: app在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    NSLog(@"notification:%@",notification);
}
//  iOS>=10: 点击通知进入app时触发（杀死/切到后台唤起）
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    NSLog(@"response:%@",response);
}
#endif

// iOS 8及以上版本的远程推送通知注册
#pragma mark iOS 8及以上版本的远程推送通知注册
- (void)registerRemoteNotifications
{
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            } else {
                NSLog(@"request authorization failed!");
            }
        }];
    } else {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}
#pragma mark 2. App获取device token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    NSLog(@"deviceToken:%@",deviceToken);
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"%@##%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    NSLog(@"error:%@",error);
}


@end
