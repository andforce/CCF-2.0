//
//  ForumApiBaseViewController.h
//
//  Created by 迪远 王 on 16/4/2.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ForumApiHelper.h"
#import "TransBundleUIViewController.h"

@interface ForumApiBaseViewController : TransBundleUIViewController

@property(nonatomic, strong) id<ForumApiDelegate> forumApi;

- (NSString *)currentForumHost;

@end
