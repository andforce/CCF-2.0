//
//  User.h
//
//  Created by WDY on 15/12/29.
//  Copyright © 2015年 andforce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic, strong) NSString *userID;          //1. userId

@property(nonatomic, strong) NSString *userName;        //2. userName
@property(nonatomic, strong) NSString *userAvatar;      //3. avatar
@property(nonatomic, strong) NSString *userRank;        //4. rank
@property(nonatomic, strong) NSString *userSignDate;    //5. signDate
@property(nonatomic, strong) NSString *userPostCount;   //6. postCount
@property(nonatomic, strong) NSString *forumHost;       //7. forumHost

@end
