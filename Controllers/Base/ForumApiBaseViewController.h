//
//
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBSApiHelper.h"
#import "TransBundleUIViewController.h"

@interface ForumApiBaseViewController : TransBundleUIViewController

@property(nonatomic, strong) id <BBSApiDelegate> forumApi;

- (NSString *)currentForumHost;

@end
