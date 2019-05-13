//
//  NotificationService.m
//  NotificationService
//
//  Created by 朱志佳 on 2019/5/13.
//  Copyright © 2019年 朱志佳. All rights reserved.
//

#import "NotificationService.h"

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

// 系统接到通知后，有最多30秒在这里重写通知内容（如下载附件并更新通知）
#pragma mark 系统接到通知后，有最多30秒在这里重写通知内容（如下载附件并更新通知）
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    
    // 设置UNNotificationAction
    UNNotificationAction *actionA = [UNNotificationAction actionWithIdentifier:@"ActionA" title:@"A_Required" options:(UNNotificationActionOptionAuthenticationRequired)];
    UNNotificationAction *actionB = [UNNotificationAction actionWithIdentifier:@"ActionB" title:@"B_Destructive" options:(UNNotificationActionOptionDestructive)];
    UNNotificationAction *actionC = [UNNotificationAction actionWithIdentifier:@"ActionC" title:@"C_Foreground" options:(UNNotificationActionOptionForeground)];
    UNNotificationAction *actionD = [UNTextInputNotificationAction actionWithIdentifier:@"ActionD" title:@"D_InputDestructive" options:(UNNotificationActionOptionDestructive) textInputButtonTitle:@"Send" textInputPlaceholder:@"input some words here ..."];
    NSArray *actionArr = [[NSArray alloc] initWithObjects:actionA,actionB,actionC,actionD, nil];
    NSArray *identifierArr = [[NSArray alloc] initWithObjects:@"ActionA",@"ActionB",@"ActionC",@"ActionD", nil];
    UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:@"QiShareCategoryIdentifier" actions:actionArr intentIdentifiers:identifierArr options:(UNNotificationCategoryOptionCustomDismissAction)];
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:notificationCategory]];
    
    // 设置categoryIdentifier
    self.bestAttemptContent.categoryIdentifier = @"QiShareCategoryIdentifier";
    
     // 加载网络请求
    NSDictionary *userInfo = self.bestAttemptContent.userInfo;
    NSString *mediaUrl = userInfo[@"media"][@"url"];
    NSString *mediaType = userInfo[@"media"][@"type"];
    if (!mediaUrl.length) {
        self.contentHandler(self.bestAttemptContent);
    }else {
        [self loadAttachmentForUrlString:mediaUrl withType:mediaType completionHandle:^(UNNotificationAttachment *attach) {
            if (attach) {
                self.bestAttemptContent.attachments = [NSArray arrayWithObject:attach];
            }
            self.contentHandler(self.bestAttemptContent);
        }];
    }
    
   
}

- (void)loadAttachmentForUrlString:(NSString *)urlStr withType:(NSString *)type completionHandle:(void(^)(UNNotificationAttachment *attach))completionHandler
{
    __block UNNotificationAttachment *attachment = nil;
    NSURL *attachmentURL = [NSURL URLWithString:urlStr];
    NSString *fileExt = [self getfileExtWithMediaType:type];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session downloadTaskWithURL:attachmentURL completionHandler:^(NSURL *temporaryFileLocation, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"加载多媒体失败 %@", error.localizedDescription);
        } else {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSURL *localURL = [NSURL fileURLWithPath:[temporaryFileLocation.path stringByAppendingString:fileExt]];
            [fileManager moveItemAtURL:temporaryFileLocation toURL:localURL error:&error];
            
            // 自定义推送UI需要
            NSMutableDictionary * dict = [self.bestAttemptContent.userInfo mutableCopy];
            [dict setObject:[NSData dataWithContentsOfURL:localURL] forKey:@"image"];
            self.bestAttemptContent.userInfo = dict;
            
            NSError *attachmentError = nil;
            attachment = [UNNotificationAttachment attachmentWithIdentifier:@"QiShareCategoryIdentifier" URL:localURL options:nil error:&attachmentError];
            if (attachmentError) {
                NSLog(@"%@", attachmentError.localizedDescription);
            }
        }
        completionHandler(attachment);
    }] resume];
}

- (NSString *)getfileExtWithMediaType:(NSString *)mediaType {
    NSString *fileExt = mediaType;
    if ([mediaType isEqualToString:@"image"]) {
        fileExt = @"jpg";
    }
    if ([mediaType isEqualToString:@"video"]) {
        fileExt = @"mp4";
    }
    if ([mediaType isEqualToString:@"audio"]) {
        fileExt = @"mp3";
    }
    return [@"." stringByAppendingString:fileExt];
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
