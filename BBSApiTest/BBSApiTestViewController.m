//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "BBSApiTestViewController.h"
#import "BBSApiHelper.h"

#import "BBSLocalApi.h"


@interface BBSApiTestViewController () {
    NSArray *blockStarts;
    NSArray *blocks;
}

@end

@implementation BBSApiTestViewController

- (NSString *)currentForumHost {
    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    NSString *urlStr = [localForumApi currentForumURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    return url.host;
}

- (void)viewDidLoad {
    [super viewDidLoad];


    BBSLocalApi *localForumApi = [[BBSLocalApi alloc] init];
    id <BBSApiDelegate> forumApi = [BBSApiHelper forumApi:localForumApi.currentForumHost];

    [forumApi listAllForums:^(BOOL isSuccess, id message) {

    }];


}


@end
