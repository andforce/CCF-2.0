//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "Forums.h"


NSString *const kForumsName = @"name";
NSString *const kForumsUrl = @"url";


@interface Forums ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Forums

@synthesize name = _name;
@synthesize url = _url;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];

    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        self.name = [self objectOrNilForKey:kForumsName fromDictionary:dict];
        self.url = [self objectOrNilForKey:kForumsUrl fromDictionary:dict];

    }

    return self;

}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.name forKey:kForumsName];
    [mutableDict setValue:self.url forKey:kForumsUrl];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

- (NSString *)host {
    NSURL *url = [NSURL URLWithString:self.url];
    return url.host;
}

#pragma mark - Helper Method

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict {
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];

    self.name = [aDecoder decodeObjectForKey:kForumsName];
    self.url = [aDecoder decodeObjectForKey:kForumsUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:_name forKey:kForumsName];
    [aCoder encodeObject:_url forKey:kForumsUrl];
}

- (id)copyWithZone:(NSZone *)zone {
    Forums *copy = [[Forums alloc] init];

    if (copy) {

        copy.name = [self.name copyWithZone:zone];
        copy.url = [self.url copyWithZone:zone];
    }

    return copy;
}


@end
