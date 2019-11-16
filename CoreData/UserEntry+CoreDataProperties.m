//
//  UserEntry+CoreDataProperties.m
//  
//
//  Created by WDY on 2016/12/7.
//
//

#import "UserEntry+CoreDataProperties.h"

@implementation UserEntry (CoreDataProperties)

+ (NSFetchRequest<UserEntry *> *)fetchRequest {
    return [[NSFetchRequest alloc] initWithEntityName:@"UserEntry"];
}

@dynamic userAvatar;
@dynamic userID;
@dynamic forumHost;

@end
