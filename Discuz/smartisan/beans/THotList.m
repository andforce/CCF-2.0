//
//  THotList.m
//
//  Created by   on 2018/4/29
//  Copyright (c) 2018 __MyCompanyName__. All rights reserved.
//

#import "THotList.h"


NSString *const kTHotListAuthor = @"author";
NSString *const kTHotListDbdateline = @"dbdateline";
NSString *const kTHotListReplies = @"replies";
NSString *const kTHotListGroupid = @"groupid";
NSString *const kTHotListAuthorid = @"authorid";
NSString *const kTHotListSubject = @"subject";
NSString *const kTHotListViews = @"views";
NSString *const kTHotListGroupicon = @"groupicon";
NSString *const kTHotListTid = @"tid";
NSString *const kTHotListAttachment = @"attachment";


@interface THotList ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation THotList

@synthesize author = _author;
@synthesize dbdateline = _dbdateline;
@synthesize replies = _replies;
@synthesize groupid = _groupid;
@synthesize authorid = _authorid;
@synthesize subject = _subject;
@synthesize views = _views;
@synthesize groupicon = _groupicon;
@synthesize tid = _tid;
@synthesize attachment = _attachment;


+ (instancetype)modelObjectWithDictionary:(NSDictionary *)dict
{
    return [[self alloc] initWithDictionary:dict];
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.author = [self objectOrNilForKey:kTHotListAuthor fromDictionary:dict];
            self.dbdateline = [self objectOrNilForKey:kTHotListDbdateline fromDictionary:dict];
            self.replies = [self objectOrNilForKey:kTHotListReplies fromDictionary:dict];
            self.groupid = [self objectOrNilForKey:kTHotListGroupid fromDictionary:dict];
            self.authorid = [self objectOrNilForKey:kTHotListAuthorid fromDictionary:dict];
            self.subject = [self objectOrNilForKey:kTHotListSubject fromDictionary:dict];
            self.views = [self objectOrNilForKey:kTHotListViews fromDictionary:dict];
            self.groupicon = [self objectOrNilForKey:kTHotListGroupicon fromDictionary:dict];
            self.tid = [self objectOrNilForKey:kTHotListTid fromDictionary:dict];
            self.attachment = [self objectOrNilForKey:kTHotListAttachment fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.author forKey:kTHotListAuthor];
    [mutableDict setValue:self.dbdateline forKey:kTHotListDbdateline];
    [mutableDict setValue:self.replies forKey:kTHotListReplies];
    [mutableDict setValue:self.groupid forKey:kTHotListGroupid];
    [mutableDict setValue:self.authorid forKey:kTHotListAuthorid];
    [mutableDict setValue:self.subject forKey:kTHotListSubject];
    [mutableDict setValue:self.views forKey:kTHotListViews];
    [mutableDict setValue:self.groupicon forKey:kTHotListGroupicon];
    [mutableDict setValue:self.tid forKey:kTHotListTid];
    [mutableDict setValue:self.attachment forKey:kTHotListAttachment];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.author = [aDecoder decodeObjectForKey:kTHotListAuthor];
    self.dbdateline = [aDecoder decodeObjectForKey:kTHotListDbdateline];
    self.replies = [aDecoder decodeObjectForKey:kTHotListReplies];
    self.groupid = [aDecoder decodeObjectForKey:kTHotListGroupid];
    self.authorid = [aDecoder decodeObjectForKey:kTHotListAuthorid];
    self.subject = [aDecoder decodeObjectForKey:kTHotListSubject];
    self.views = [aDecoder decodeObjectForKey:kTHotListViews];
    self.groupicon = [aDecoder decodeObjectForKey:kTHotListGroupicon];
    self.tid = [aDecoder decodeObjectForKey:kTHotListTid];
    self.attachment = [aDecoder decodeObjectForKey:kTHotListAttachment];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_author forKey:kTHotListAuthor];
    [aCoder encodeObject:_dbdateline forKey:kTHotListDbdateline];
    [aCoder encodeObject:_replies forKey:kTHotListReplies];
    [aCoder encodeObject:_groupid forKey:kTHotListGroupid];
    [aCoder encodeObject:_authorid forKey:kTHotListAuthorid];
    [aCoder encodeObject:_subject forKey:kTHotListSubject];
    [aCoder encodeObject:_views forKey:kTHotListViews];
    [aCoder encodeObject:_groupicon forKey:kTHotListGroupicon];
    [aCoder encodeObject:_tid forKey:kTHotListTid];
    [aCoder encodeObject:_attachment forKey:kTHotListAttachment];
}

- (id)copyWithZone:(NSZone *)zone
{
    THotList *copy = [[THotList alloc] init];
    
    if (copy) {

        copy.author = [self.author copyWithZone:zone];
        copy.dbdateline = [self.dbdateline copyWithZone:zone];
        copy.replies = [self.replies copyWithZone:zone];
        copy.groupid = [self.groupid copyWithZone:zone];
        copy.authorid = [self.authorid copyWithZone:zone];
        copy.subject = [self.subject copyWithZone:zone];
        copy.views = [self.views copyWithZone:zone];
        copy.groupicon = [self.groupicon copyWithZone:zone];
        copy.tid = [self.tid copyWithZone:zone];
        copy.attachment = [self.attachment copyWithZone:zone];
    }
    
    return copy;
}


@end
