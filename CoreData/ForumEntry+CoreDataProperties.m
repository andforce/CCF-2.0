//
//
//  
//
//  Created by Diyuan Wang on 2019/11/21.
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
