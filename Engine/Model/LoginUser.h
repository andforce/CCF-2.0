//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUser : NSObject

@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *userID;

@property(nonatomic, strong) NSDate *expireTime;

@end