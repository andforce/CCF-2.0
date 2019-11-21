//
//  THotPage.h
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface THotPage : NSObject <NSCoding, NSCopying>

@property(nonatomic, assign) double pageSize;
@property(nonatomic, assign) double pageCount;
@property(nonatomic, assign) double pageTotal;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

@end
