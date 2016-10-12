//
//  AppDelegate.m
//  TestUserNotification
//
//  Created by admin on 16/9/27.
//  Copyright © 2016年 LiuPeng. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

#define kLocalNotificationKey @"kLocalNotificationKey"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0){
        
        UNUserNotificationCenter * notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound ) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if(granted){
                //允许
                NSLog(@"register For Remote Notifications succeeded!");
            }
            
            if (!error) {
                //
                NSLog(@"request authorization succeeded!");
            }
            
        }];
        [notificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"application settings = %@",settings);
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];

    
    }else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 10.0 ){
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
        
    }else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge)];
    }

    
    //注册本地通知
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 10.0 ) {
        [self registerLocalNotification];
    }else{
        [self registerLocalUNNotification];
    }
    
    return YES;
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings NS_AVAILABLE_IOS(8_0) {
//    NSLog(@"notificationSettings = %@",notificationSettings);
//    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken NS_AVAILABLE_IOS(3_0) {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"null" withString:@""];
    
    NSLog(@"deviceToken = %@ \n token = %@",deviceToken,token);

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"error = %@",error);
}



#ifdef __IPHONE_10_0 //本地和远程都走这两个
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"willPresentNotification notification = %@  center = %@",notification,center);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);

    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"didReceiveNotificationResponse = %@",response);
}


#endif

#pragma mark ---- iOS10 之前的推送

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"userinfo = %@",userInfo);
    
    id alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    NSString * title = @"提示";
    NSString *message = @"userInfouserInfo";
    
    if([alert isKindOfClass:[NSString class]]){
        //ios10 之前通知
        message = alert;
    }else if ([alert isKindOfClass:[NSDictionary class]]){
        //ios10 之后通知
        title = [alert objectForKey:@"title"];
        message = [alert objectForKey:@"body"];
    }
    
    UIAlertView * aler = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"other", nil];
    [aler show];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"__IPHONE_10_0 userinfo = %@  \n ",userInfo);
    
    id alert = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    NSString * title = @"提示";
    NSString *message = @"userInfouserInfo";
    
    if([alert isKindOfClass:[NSString class]]){
        //ios10 之前通知
        message = alert;
    }else if ([alert isKindOfClass:[NSDictionary class]]){
        //ios10 之后通知
        title = [alert objectForKey:@"title"];
        message = [alert objectForKey:@"body"];
    }
    
    UIAlertView * aler = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"cancle10" otherButtonTitles:@"other10", nil];
    [aler show];
    
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"notification = %@",notification);
    
    NSString *notMess = [notification.userInfo objectForKey:kLocalNotificationKey];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"本地通知"
                                                    message:notMess
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    // 更新显示的徽章个数
    NSInteger badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badge--;
    badge = badge >= 0 ? badge : 0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badge;
    
    // 在不需要再推送时，可以取消推送
    
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")  {
    NSLog(@"identifier = %@   notification = %@  ",identifier,notification);
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler NS_DEPRECATED_IOS(9_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")  {
    NSLog(@"identifier = %@  userinfo = %@   responseinfo = %@",identifier,userInfo,responseInfo);
}


- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler NS_DEPRECATED_IOS(8_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")  {
    NSLog(@"identifier = %@  userinfo = %@ ",identifier,userInfo);
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler NS_DEPRECATED_IOS(9_0, 10_0, "Use UserNotifications Framework's -[UNUserNotificationCenterDelegate didReceiveNotificationResponse:withCompletionHandler:]")  {
    NSLog(@"identifier = %@  notification = %@  responseinfo = %@",identifier,notification,responseInfo);
}
#pragma mark ----end



- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
  
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
}




//本地通知 iOS 10 本地通知
-(void)registerLocalUNNotification {

    UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
    
    NSURL * url = [[NSBundle mainBundle] URLForResource:@"Icon" withExtension:@"png"];
    UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:@"localNotificationImageAttachment" URL:url options:nil error:nil];
    
    content.attachments = @[attachment];
    content.badge = @1;
    content.body = @"iOS 10 本地通知";
    content.sound = [UNNotificationSound defaultSound];
    content.subtitle = @"本地通知";
    content.title = @"iOS 10";
    

    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"本地通知 通知参数" forKey:kLocalNotificationKey];
    content.userInfo = userDict;
    
    //7s 后推送通知
    UNTimeIntervalNotificationTrigger * timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:7 repeats:NO];
    
    //周日早上七点推送通知
//    NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
//    dateComponents.weekday = 1;//周日是1开始递增
//    dateComponents.hour = 7;
//    UNCalendarNotificationTrigger * calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:NO];
    
    //#import <CoreLocation/CoreLocation.h>
    //到达某地推送通知
//    CLRegion *region = [[CLRegion alloc] init];
//    UNLocationNotificationTrigger *locationTrigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:NO];
    
    //添加action
    content.categoryIdentifier = @"localNotificationIdentifier";

    UNNotificationAction * action = [UNNotificationAction actionWithIdentifier:@"localNotificationActionIdentifier" title:@"我看到了" options:UNNotificationActionOptionNone];
    UNNotificationAction * action1 = [UNNotificationAction actionWithIdentifier:@"localNotificationActionIdentifier1" title:@"我不想看" options:UNNotificationActionOptionDestructive];
    UNTextInputNotificationAction * textAction = [UNTextInputNotificationAction actionWithIdentifier:@"localNotificationTextActionIdentifier" title:@"说点啥" options:(UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground) textInputButtonTitle:@"说完了" textInputPlaceholder:@"随便说点啥"];

    UNNotificationCategory * category = [UNNotificationCategory categoryWithIdentifier:@"localNotificationIdentifier" actions:@[action,textAction,action1] intentIdentifiers:@[@"localNotificationActionIdentifier",@"localNotificationTextActionIdentifier",@"localNotificationActionIdentifier1"] options:UNNotificationCategoryOptionNone];
    
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithArray:@[category]]];
    
    
    NSString * identifier = @"com.mallcoo.liupeng.usernatification";
    UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:timeTrigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"addNotificationRequest error = %@",error);
    }];
    
//    [[UNUserNotificationCenter currentNotificationCenter] removePendingNotificationRequestsWithIdentifiers:@[identifier]];//删除identifier 通知
}

-(void)updateLocalUNNotification {
    
    static int x = 0;
    UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
    content.badge = @1;
    content.body = @"iOS 10.0.2 本地通知";
    content.sound = [UNNotificationSound defaultSound];
    content.subtitle = @"本地通知";
    content.title = [NSString stringWithFormat:@"iOS 10.0.%d",x];
    x++;
    
    UNTimeIntervalNotificationTrigger * timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:3 repeats:NO];
    
    NSString * identifier = @"com.mallcoo.liupeng.usernatification";
    UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:timeTrigger];
    
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"addNotificationRequest error = %@",error);
    }];
    
}


//本地通知
-(void)registerLocalNotification {
    
    //取消所有本地通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification * localNotification = [[UILocalNotification alloc] init];
    
    //10s以后触发本地通知
    //    NSDate * notificationDate = [NSDate dateWithTimeIntervalSinceNow:10];
    //    localNotification.fireDate = notificationDate;
    
    localNotification.timeZone = [NSTimeZone systemTimeZone];//时区
    
    NSDateFormatter * dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.timeZone = [NSTimeZone systemTimeZone];
    dateformatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate * customDate = [dateformatter dateFromString:@"2016-09-28 17:35"];
    localNotification.fireDate = customDate;//直接设定通知时间
    //    NSLog(@"customDate = %@",customDate);//设置时间，在默认时区的值
    
    //    NSCalendar *calender = [NSCalendar autoupdatingCurrentCalendar];
    //    NSDateComponents *dateComponents = [calender components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour fromDate:customDate];
    //    dateComponents.timeZone = [NSTimeZone systemTimeZone];
    ////    [dateComponents setHour:1];
    //    [dateComponents setMinute:57];//设置时间 推送通知 HH:40
    //    NSDate * fireDate = [calender dateFromComponents:dateComponents];
    //    NSLog(@"fireDate = %@",fireDate);
    //
    //    localNotification.fireDate = fireDate;//
    
    localNotification.repeatInterval = NSDayCalendarUnit;//间隔 通知重复提示 天、周、月
    localNotification.alertBody = @"本地通知";
    localNotification.applicationIconBadgeNumber = 1;//图标小圆点数字
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    // 通知参数
    NSDictionary *userDict = [NSDictionary dictionaryWithObject:@"本地通知 通知参数" forKey:kLocalNotificationKey];
    localNotification.userInfo = userDict;
    
    // ios8后，需要添加这个注册，才能得到授权
    //    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    //        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    //        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
    //                                                                                 categories:nil];
    //        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    //    }
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}



// 取消某个本地推送通知
- (void)cancelLocalNotificationWithKey:(NSString *)key {
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
        for (UILocalNotification *notification in localNotifications) {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo) {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            // 如果找到需要取消的通知，则取消
            if (info != nil) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}

@end
