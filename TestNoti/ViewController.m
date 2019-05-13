//
//  ViewController.m
//  TestNoti
//
//  Created by 朱志佳 on 2019/5/13.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self test];
}

- (void)test {
    
    
}

- (IBAction)addLocal:(id)sender {
    [self sendLocalNotification];
}


#pragma mark 1. 注册本地推送通知
static NSString *LocalNotiReqIdentifer = @"LocalNotiReqIdentifer";
- (void)sendLocalNotification {
    NSString *title = @"通知-title";
    NSString *subTitle = @"通知-subTitle";
    NSString *body = @"通知-body";
    NSInteger badge = 1;
    NSInteger timeInterval = 60;//通知间隔时长必须在60s及以上
    NSDictionary *userInfo = @{@"id":@"LOCAL_NOTIFY_SCHEDULE_ID"};
    
    if (!@available(iOS 10.0, *)) {
        //1.创建通知内容
        UNMutableNotificationContent *content = [UNMutableNotificationContent new];
        [content setValue:@(YES) forKey:@"shouldAlwaysAlertWhileAppIsForeground"];
        content.sound = [UNNotificationSound defaultSound];
        content.title = title;
        content.subtitle = subTitle;
        content.body = body;
        content.badge = @(badge);
        
        content.userInfo = userInfo;
        
        // 2.设置通知附件内容
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"logo_img_02" ofType:@"png"];
        UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
        if (error) {
            NSLog(@"attachment error %@", error);
        }
        content.attachments = @[att];
        content.launchImageName = @"icon_certification_status1";
        
        // 3.设置声音
        UNNotificationSound *sound = [UNNotificationSound defaultSound];//[UNNotificationSound soundNamed:@"sound01.wav"]
        content.sound = sound;
        
        // 4.触发模式
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInterval repeats:YES];
        
         // 5.设置UNNotificationRequest
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:LocalNotiReqIdentifer content:content trigger:trigger];
        
        // 6.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"error:%@",error);
        }];
        
    }else {
        UILocalNotification *localNotification = [UILocalNotification new];
        // 1.设置触发时间（如果要立即触发，无需设置）
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
        
         // 2.设置通知标题
        localNotification.alertBody = title;
        
         // 3.设置通知动作按钮的标题
        localNotification.alertAction = @"查看";
        
        // 4.设置提醒的声音
        localNotification.soundName = UILocalNotificationDefaultSoundName;//@"sound01.wav"
        
        // 5.设置通知的 传递的userInfo
        localNotification.userInfo = userInfo;
        
        // 6.在规定的日期触发通知
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        // 7.立即触发一个通知
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
    
    
}

#pragma mark 2. 取消本地推送通知
- (void)cancelLocalNofifications {
     // 取消一个特定的通知
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    // 获取当前所有的本地通知
    if (!notifications || notifications.count <= 0) {
        return;
    }
    for (UILocalNotification *notify in notifications) {
        if ([[notify.userInfo objectForKey:@"id"] isEqualToString:@"LOCAL_NOTIFY_SCHEDULE_ID"]) {
            if (@available(iOS 10.0, *)) {
                [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[LocalNotiReqIdentifer]];
            }else {
                [[UIApplication sharedApplication] cancelLocalNotification:notify];
            }
            break;
        }
    }
    
    // 取消所有的本地通知
    //[[UIApplication sharedApplication] cancelAllLocalNotifications];
}

@end
