//
//  THotData.h
//
//  Created by   on 2018/4/29
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class THotPage;

@interface THotData : NSObject <NSCoding, NSCopying>

@property(nonatomic, strong) THotPage *page;
@property(nonatomic, strong) NSArray *list;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

@end
