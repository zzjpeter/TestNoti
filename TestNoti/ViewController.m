//
//  ViewController.m
//  TestNoti
//
//  Created by 朱志佳 on 2019/5/13.
//  Copyright © 2019 朱志佳. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "YYkit.h"

//#define LocalizationFilePath ([[NSBundle mainBundle] pathForResource:[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguage"] ofType:@"lproj"]==NULL ? @"en" : [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguage"])
//#define LPLocalizedString(key, comment) \
//({ \
//NSString *string = [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",LocalizationFilePath] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]; \
//string == nil ? key : string; \
//})
//#define MyLocal(x, ...) LPLocalizedString(x, nil)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self test];
}

- (void)test {
    NSString *title = NSLocalizedString(@"title", nil);
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, 100, 100, 100);
    [button setTitle:title forState:UIControlStateNormal];
    [self.view addSubview:button];
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
    
    //构造通知消息
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"apnsJson.json" ofType:nil];
    NSError *error = nil;
    NSString *apns = [NSString stringWithContentsOfFile:filePath encoding:(NSUTF8StringEncoding) error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }
    userInfo = [[self class] dictionaryWithJsonString:apns];
    
    if (@available(iOS 10.0, *)) {
        //1.创建通知内容
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        [content setValue:@(YES) forKey:@"shouldAlwaysAlertWhileAppIsForeground"];
        content.sound = [UNNotificationSound defaultSound];
        content.title = title;
        content.subtitle = subTitle;
        content.body = body;
        content.badge = @(badge);
        
        content.userInfo = userInfo;
        
        content.categoryIdentifier = @"QiShareCategoryIdentifier";//指明了category和某个通知的关联关系
        /*
         通知中心可以注册很多这样的Category，那么如何确定某个通知使用哪一个呢？  这就是靠categoryIdentifier了，在很多地方都用到啦、 就是图片里面画红色线那个。。   想到前面设置UNMutableNotificationContent时候给出提示很重要的那个东西了么？content.categoryIdentifier =  @"catorgry";  就是这句话指明了category和某个通知的关联关系。。。 so，这里一定要对应起来啊。。
         */
        // 设置notificationCategory 与 UNNotificationAction
        UNNotificationAction *actionA = [UNNotificationAction actionWithIdentifier:@"ActionA" title:@"A_Required" options:(UNNotificationActionOptionAuthenticationRequired)];
        UNNotificationAction *actionB = [UNNotificationAction actionWithIdentifier:@"ActionB" title:@"B_Destructive" options:(UNNotificationActionOptionDestructive)];
        UNNotificationAction *actionC = [UNNotificationAction actionWithIdentifier:@"ActionC" title:@"C_Foreground" options:(UNNotificationActionOptionForeground)];
        UNNotificationAction *actionD = [UNTextInputNotificationAction actionWithIdentifier:@"ActionD" title:@"D_InputDestructive" options:(UNNotificationActionOptionDestructive) textInputButtonTitle:@"Send" textInputPlaceholder:@"input some words here ..."];
        NSArray *actionArr = [[NSArray alloc] initWithObjects:actionA,actionB,actionC,actionD, nil];
        NSArray *identifierArr = [[NSArray alloc] initWithObjects:@"ActionA",@"ActionB",@"ActionC",@"ActionD", nil];
        UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:@"QiShareCategoryIdentifier" actions:actionArr intentIdentifiers:identifierArr options:(UNNotificationCategoryOptionCustomDismissAction)];
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:notificationCategory, nil]];
        
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

#pragma mark 字典转字符串 与 字符串转字典
+(NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
