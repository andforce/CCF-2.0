//
//  AppDelegate.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "AppDelegate.h"
#import "BBSLoginViewController.h"

#import "BBSCoreDataManager.h"
#import "BBSApiTestViewController.h"
#import "NSUserDefaults+Setting.h"
#import "UIStoryboard+Forum.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "BBSTabBarController.h"
#import "BBSTableViewController.h"
#import "Forums.h"
#import "BBSLocalApi.h"
#import <UserNotifications/UserNotifications.h>

#import "BBSPayManager.h"

#import "HybridNSURLProtocol.h"
#import "BBSPayUITableViewController.h"

static BOOL API_DEBUG = NO;
static int DB_VERSION = 11;

static BOOL PAY_DEBUG = NO;

@interface AppDelegate ()<UNUserNotificationCenterDelegate> {

}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [NSURLProtocol registerClass:[HybridNSURLProtocol class]];
    
    [self changeUserAgentForWebView];

    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];

    BBSPayManager * payManager = [BBSPayManager shareInstance];
    [payManager verifyPay:localForumApi.currentProductID with:^(long timeHave) {

        if (timeHave == 0){
            [payManager setPayed:FALSE for:localForumApi.currentProductID];
            NSLog(@"AppDelegate --> not payed");
        } else {
            [payManager setPayed:TRUE for:localForumApi.currentProductID];
            NSLog(@"AppDelegate --> payed success");
        }
    }];


    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:200 * 1024 * 1024 diskCapacity:1024 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:cache];

    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    application.applicationIconBadgeNumber = 0;

    if (API_DEBUG) {
        NSDictionary *dic = [[NSBundle mainBundle] infoDictionary];
        NSLog(@"AppDelegate --> infoDictionary %@",dic);

        NSString *versionCode = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSLog(@"AppDelegate --> versionCode %@",versionCode);
        
        BBSApiTestViewController *testController = [[BBSApiTestViewController alloc] init];
        self.window.rootViewController = testController;
        return YES;
    }

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];//Documents目录

    NSLog(@"AppDelegate --> 文件路径: %@", documentsDirectory);

    // 设置默认数值
    NSUserDefaults *setting = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dictonary = [NSMutableDictionary dictionary];
    [dictonary setValue:@1 forKey:kSIGNATURE];
    [dictonary setValue:@1 forKey:kTOP_THREAD];
    [setting registerDefaults:dictonary];

    // 检查数据库
    BOOL isClearDB = NO;
    if ([localForumApi dbVersion] != DB_VERSION) {
        
        BBSCoreDataManager *formManager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeForm];
        
        // 清空数据库
        [formManager deleteData];
        
        BBSCoreDataManager *userManager = [[BBSCoreDataManager alloc] initWithEntryType:EntryTypeUser];
        [userManager deleteData];
        
        [localForumApi setDBVersion:DB_VERSION];

        NSArray<Forums *> * forums = localForumApi.supportForums;
        for (Forums * f in forums) {
            [localForumApi logout:f.url];
        }
        
        isClearDB = YES;
    }
    
    // 检查登录情况
    NSString *currentSelectForumHost = localForumApi.currentForumHost;
    if (currentSelectForumHost){
        if (![localForumApi isHaveLogin:localForumApi.currentForumHost]){
            NSArray<Forums *> * loginForums = localForumApi.loginedSupportForums;
            if(loginForums != nil && loginForums.count >0){
                [localForumApi saveCurrentForumURL:loginForums.firstObject.url];
            }
        }

        // 判断是否登录
        if (![localForumApi isHaveLoginForum] || isClearDB) {

            [self showReloginController:localForumApi];

        }
    } else {
        
        [self showReloginController:localForumApi];
    }


    if (launchOptions[@"UIApplicationLaunchOptionsShortcutItemKey"] == nil) {
        NSLog(@"AppDelegate --> UIApplicationLaunchOptionsShortcutItemKey yes");
        return YES;
    } else {
        NSLog(@"AppDelegate --> UIApplicationLaunchOptionsShortcutItemKey no");
        return NO;
    }
    
    return YES;
}

- (void)changeUserAgentForWebView {
//    NSString *newAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.99 Safari/537.36";
//    NSDictionary *dictionary = @{@"UserAgent": newAgent, @"User-Agent":newAgent,@"useragent":newAgent, @"user-agent":newAgent};
//    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

- (void)showReloginController:(BBSLocalApi *)localForumApi {
    NSString *bundleId = [localForumApi bundleIdentifier];

    if ([bundleId isEqualToString:@"com.andforce.forums"]) {
        [localForumApi clearCurrentForumURL];
        self.window.rootViewController = [[UIStoryboard mainStoryboard] finControllerById:@"ShowSupportForums"];
    } else {

        id <BBSConfigDelegate> api = [BBSApiHelper forumConfig:localForumApi.currentForumHost];
        NSString *cId = api.loginControllerId;
        [[UIStoryboard mainStoryboard] changeRootViewControllerTo:cId];

    }
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"AppDelegate --> >>>>>>>>>>>>>>>>>>>>>>   userNotificationCenter   didReceiveNotificationResponse");
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    completionHandler();  // 系统要求执行这个方法
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification {
    NSLog(@"AppDelegate --> >>>>>>>>>>>>>>>>>>>>>>   userNotificationCenter   openSettingsForNotification");
    NSDictionary * userInfo = notification.request.content.userInfo;
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
    }else{
        //从通知设置界面进入应用
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    NSLog(@"AppDelegate --> >>>>>>>>>>>>>>>>>>>>>>   userNotificationCenter   willPresentNotification");
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {

    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {


    if (application.applicationState == UIApplicationStateActive) {
        // 转换成一个本地通知，显示到通知栏，你也可以直接显示出一个 alertView，只是那样稍显 aggressive：）
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [userInfo[@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        NSLog(@"AppDelegate --> >>>>>>>>>>>>>>>>>>>>>>   didReceiveRemoteNotification   createLocale");
    } else {
        NSLog(@"AppDelegate --> >>>>>>>>>>>>>>>>>>>>>>   didReceiveRemoteNotification  remote");
        //[AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}


- (NSArray *)flatForm:(Forum *)form {
    NSMutableArray *resultArray = [NSMutableArray array];
    [resultArray addObject:form];
    for (Forum *childForm in form.childForums) {
        [resultArray addObjectsFromArray:[self flatForm:childForm]];
    }
    return resultArray;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.andforce.Forum" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"forum" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    // Create the coordinator and store

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"forum.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"AppDelegate --> Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"AppDelegate --> Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

/** 处理shortcutItem */
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    if ([localForumApi isHaveLoginForum]){
        NSString *shortCutItemType = shortcutItem.type;

        BBSTabBarController * controller = (BBSTabBarController *) self.window.rootViewController;

        controller.selectedIndex = 2;
        BBSTableViewController * forumTableViewController = controller.selectedViewController.childViewControllers.firstObject;
        [forumTableViewController showControllerByShortCutItemType:shortCutItemType];
    }
}

@end
