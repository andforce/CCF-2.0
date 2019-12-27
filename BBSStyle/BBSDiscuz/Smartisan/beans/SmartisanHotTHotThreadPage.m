//
//  THotTHotThreadPage.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "SmartisanHotTHotThreadPage.h"
#import "SmartisanHotData.h"


NSString *const kTHotTHotThreadPageMessage = @"message";
NSString *const kTHotTHotThreadPageData = @"data";
NSString *const kTHotTHotThreadPageCode = @"code";


@interface SmartisanHotTHotThreadPage ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SmartisanHotTHotThreadPage

@synthesize message = _message;
@synthesize data = _data;
@synthesize code = _code;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];

    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.message = [self objectOrNilForKey:kTHotTHotThreadPageMessage fromDictionary:dict];
        self.data = [SmartisanHotData modelObjectWithDictionary:[dict objectForKey:kTHotTHotThreadPageData]];
        self.code = [self objectOrNilForKey:kTHotTHotThreadPageCode fromDictionary:dict];

    }

    return self;

}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.message forKey:kTHotTHotThreadPageMessage];
    [mutableDict setValue:[self.data dictionaryRepresentation] forKey:kTHotTHotThreadPageData];
    [mutableDict setValue:self.code forKey:kTHotTHotThreadPageCode];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict {
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];

    self.message = [aDecoder decodeObjectForKey:kTHotTHotThreadPageMessage];
    self.data = [aDecoder decodeObjectForKey:kTHotTHotThreadPageData];
    self.code = [aDecoder decodeObjectForKey:kTHotTHotThreadPageCode];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:_message forKey:kTHotTHotThreadPageMessage];
    [aCoder encodeObject:_data forKey:kTHotTHotThreadPageData];
    [aCoder encodeObject:_code forKey:kTHotTHotThreadPageCode];
}

- (id)copyWithZone:(NSZone *)zone {
    SmartisanHotTHotThreadPage *copy = [[SmartisanHotTHotThreadPage alloc] init];

    if (copy) {

        copy.message = [self.message copyWithZone:zone];
        copy.data = [self.data copyWithZone:zone];
        copy.code = [self.code copyWithZone:zone];
    }

    return copy;
}


@end
