//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile : NSObject

@property(nonatomic, strong) NSString *profileUserId;
@property(nonatomic, strong) NSString *profileRank;
@property(nonatomic, strong) NSString *profileName;
@property(nonatomic, strong) NSString *profileRegisterDate;
@property(nonatomic, strong) NSString *profileRecentLoginDate;
@property(nonatomic, strong) NSString *profileTotalPostCount;


@end
