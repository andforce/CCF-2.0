//
//  THotData.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SmartisanHotPage;

@interface SmartisanHotData : NSObject <NSCoding, NSCopying>

@property(nonatomic, strong) SmartisanHotPage *page;
@property(nonatomic, strong) NSArray *list;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

@end
