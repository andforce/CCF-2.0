//
//  THotList.h
//
//  Created by   on 2018/4/29
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface THotList : NSObject <NSCoding, NSCopying>

@property(nonatomic, strong) NSString *author;
@property(nonatomic, strong) NSString *dbdateline;
@property(nonatomic, strong) NSString *replies;
@property(nonatomic, strong) NSString *groupid;
@property(nonatomic, strong) NSString *authorid;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic, strong) NSString *views;
@property(nonatomic, strong) NSString *groupicon;
@property(nonatomic, strong) NSString *tid;
@property(nonatomic, strong) NSString *attachment;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

@end
