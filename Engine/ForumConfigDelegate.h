//
// Created by 迪远 王 on 2017/4/30.
// Copyright (c) 2017 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ForumCommonConfigDelegate.h"
#import "DiscuzConfigDelegate.h"
#import "PhpWindConfigDelegage.h"
#import "vBulletinConfigDelegate.h"
#import "ForumBaseConfigDelegate.h"

#define JS_FAST_CLICK_LIB [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fastclick_lib" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil]
#define JS_HANDLE_CLICK [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"handle_click" ofType:@"js"] encoding:NSUTF8StringEncoding error:nil]


#define THREAD_PAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define THREAD_PAGE_NOTITLE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_view_notitle" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define POST_MESSAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]
#define PRIVATE_MESSAGE [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"private_message" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil]

@protocol ForumConfigDelegate <ForumBaseConfigDelegate, ForumCommonConfigDelegate, DiscuzConfigDelegate, PhpWindConfigDelegage, vBulletinConfigDelegate>


@end