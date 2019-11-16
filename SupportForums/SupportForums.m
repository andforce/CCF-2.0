//
//  SupportForums.m
//
//  Created by   on 2016/12/10
//  Copyright (c) 2016 __MyCompanyName__. All rights reserved.
//

#import "SupportForums.h"
#import "Forums.h"


NSString *const kSupportForumsForums = @"forums";


@interface SupportForums ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation SupportForums

@synthesize forums = _forums;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict {
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];

    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if (self && [dict isKindOfClass:[NSDictionary class]]) {
        NSObject *receivedForums = [dict objectForKey:kSupportForumsForums];
        NSMutableArray *parsedForums = [NSMutableArray array];
        if ([receivedForums isKindOfClass:[NSArray class]]) {
            for (NSDictionary *item in (NSArray *) receivedForums) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    [parsedForums addObject:[Forums modelObjectWithDictionary:item]];
                }
            }
        } else if ([receivedForums isKindOfClass:[NSDictionary class]]) {
            [parsedForums addObject:[Forums modelObjectWithDictionary:(NSDictionary *) receivedForums]];
        }

        self.forums = [NSArray arrayWithArray:parsedForums];

    }

    return self;

}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    NSMutableArray *tempArrayForForums = [NSMutableArray array];
    for (NSObject *subArrayObject in self.forums) {
        if ([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForForums addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForForums addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForForums] forKey:kSupportForumsForums];

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

    self.forums = [aDecoder decodeObjectForKey:kSupportForumsForums];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

    [aCoder encodeObject:_forums forKey:kSupportForumsForums];
}

- (id)copyWithZone:(NSZone *)zone {
    SupportForums *copy = [[SupportForums alloc] init];

    if (copy) {

        copy.forums = [self.forums copyWithZone:zone];
    }

    return copy;
}


@end
