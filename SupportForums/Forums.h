//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Forums : NSObject <NSCoding, NSCopying>

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *url;

+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryRepresentation;

- (NSString *)host;

@end
