//
//  ApiTestViewController.m
//
//  Created by WDY on 16/3/1.
//  Copyright © 2016年 andforce. All rights reserved.
//

#import "ApiTestViewController.h"
#import "ForumApiHelper.h"

#import "LocalForumApi.h"


@interface ApiTestViewController () {
    NSArray *blockStarts;
    NSArray *blocks;
}

@end

@implementation ApiTestViewController

- (NSString *)currentForumHost {
    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    NSString *urlStr = [localForumApi currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (void)viewDidLoad {
    [super viewDidLoad];


    LocalForumApi *localForumApi = [[LocalForumApi alloc] init];
    id <ForumApiDelegate> forumApi = [ForumApiHelper forumApi:localForumApi.currentForumHost];

    [forumApi listAllForums:^(BOOL isSuccess, id message) {

    }];


}


@end
