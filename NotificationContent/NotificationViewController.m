//
//  NotificationViewController.m
//  NotificationContent
//
//  Created by 朱志佳 on 2019/5/13.
//  Copyright © 2019年 朱志佳. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

#define Margin      15

@interface NotificationViewController () <UNNotificationContentExtension>

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *hintLabel;


@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    
    CGPoint origin = self.view.frame.origin;
    CGSize size = [UIScreen mainScreen].bounds.size;
 
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(Margin, Margin, size.width-Margin*2, 30)];
    self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.label];
    
    self.subLabel = [[UILabel alloc] initWithFrame:CGRectMake(Margin, CGRectGetMaxY(self.label.frame)+10, size.width-Margin*2, 30)];
    self.subLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.subLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(Margin, CGRectGetMaxY(self.subLabel.frame)+10, 100, 100)];
    [self.view addSubview:self.imageView];
    
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(Margin, CGRectGetMaxY(self.imageView.frame)+10, size.width-Margin*2, 20)];
    [self.hintLabel setText:@"我是hintLabel"];
    [self.hintLabel setFont:[UIFont systemFontOfSize:14]];
    [self.hintLabel setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:self.hintLabel];
    
    self.view.frame = CGRectMake(origin.x, origin.y, size.width, CGRectGetMaxY(self.imageView.frame)+Margin);
    
    // 设置控件边框颜色
    [self.label.layer setBorderColor:[UIColor redColor].CGColor];
    [self.label.layer setBorderWidth:1.0];
    [self.subLabel.layer setBorderColor:[UIColor greenColor].CGColor];
    [self.subLabel.layer setBorderWidth:1.0];
    [self.imageView.layer setBorderWidth:2.0];
    [self.imageView.layer setBorderColor:[UIColor blueColor].CGColor];
    [self.view.layer setBorderWidth:2.0];
    [self.view.layer setBorderColor:[UIColor cyanColor].CGColor];
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.title;
    self.subLabel.text = [NSString stringWithFormat:@"%@ [ContentExtension modified]", notification.request.content.subtitle];
    self.subLabel.text = NSLocalizedString(@"title", nil);
    
    NSData *data = notification.request.content.userInfo[@"image"];
    UIImage *image = [UIImage imageWithData:data];
    image = [UIImage imageNamed:@"logo_img_02"];
    [self.imageView setImage:image];
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    
    [self.hintLabel setText:[NSString stringWithFormat:@"触发了%@", response.actionIdentifier]];
    if ([response.actionIdentifier isEqualToString:@"ActionA"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(UNNotificationContentExtensionResponseOptionDismiss);
        });
    } else if ([response.actionIdentifier isEqualToString:@"ActionB"]) {
        
    } else if ([response.actionIdentifier isEqualToString:@"ActionC"]) {
        
    }  else if ([response.actionIdentifier isEqualToString:@"ActionD"]) {
        
    } else {
        completion(UNNotificationContentExtensionResponseOptionDismiss);
    }
    completion(UNNotificationContentExtensionResponseOptionDoNotDismiss);
}

@end
