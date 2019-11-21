//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SmartisanHotData;

@interface SmartisanHotTHotThreadPage : NSObject <NSCoding, NSCopying>

@property(nonatomic, strong) NSString *message;
@property(nonatomic, strong) SmartisanHotData *data;
@property(nonatomic, strong) NSString *code;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

@end
