//
//  ForumEntry+CoreDataProperties.m
//  
//
//  Created by WDY on 2016/12/7.
//
//

#import "ForumEntry+CoreDataProperties.h"

@implementation ForumEntry (CoreDataProperties)

+ (NSFetchRequest<ForumEntry *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"ForumEntry"];
}

@dynamic forumId;
@dynamic forumName;
@dynamic parentForumId;
@dynamic forumHost;

@end
