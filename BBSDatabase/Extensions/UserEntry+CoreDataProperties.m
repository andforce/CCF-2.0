//
//
//  Created by Diyuan Wang on 2019/11/21.
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
