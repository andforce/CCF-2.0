//
//  THotPage.m
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "SmartisanHotPage.h"


NSString *const kTHotPagePageSize = @"pageSize";
NSString *const kTHotPagePageCount = @"pageCount";
NSString *const kTHotPagePageTotal = @"pageTotal";


@interface SmartisanHotPage ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SmartisanHotPage

@synthesize pageSize = _pageSize;
@synthesize pageCount = _pageCount;
@synthesize pageTotal = _pageTotal;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];

    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.pageSize = [[self objectOrNilForKey:kTHotPagePageSize fromDictionary:dict] doubleValue];
        self.pageCount = [[self objectOrNilForKey:kTHotPagePageCount fromDictionary:dict] doubleValue];
        self.pageTotal = [[self objectOrNilForKey:kTHotPagePageTotal fromDictionary:dict] doubleValue];

    }

    return self;

}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.pageSize] forKey:kTHotPagePageSize];
    [mutableDict setValue:[NSNumber numberWithDouble:self.pageCount] forKey:kTHotPagePageCount];
    [mutableDict setValue:[NSNumber numberWithDouble:self.pageTotal] forKey:kTHotPagePageTotal];

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

    self.pageSize = [aDecoder decodeDoubleForKey:kTHotPagePageSize];
    self.pageCount = [aDecoder decodeDoubleForKey:kTHotPagePageCount];
    self.pageTotal = [aDecoder decodeDoubleForKey:kTHotPagePageTotal];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeDouble:_pageSize forKey:kTHotPagePageSize];
    [aCoder encodeDouble:_pageCount forKey:kTHotPagePageCount];
    [aCoder encodeDouble:_pageTotal forKey:kTHotPagePageTotal];
}

- (id)copyWithZone:(NSZone *)zone {
    SmartisanHotPage *copy = [[SmartisanHotPage alloc] init];

    if (copy) {

        copy.pageSize = self.pageSize;
        copy.pageCount = self.pageCount;
        copy.pageTotal = self.pageTotal;
    }

    return copy;
}


@end
