//
//
//  Created by Diyuan Wang on 2019/11/21.
//
//

#import "ForumEntry+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ForumEntry (CoreDataProperties)

+ (NSFetchRequest<ForumEntry *> *)fetchRequest;

@property(nullable, nonatomic, copy) NSNumber *forumId;
@property(nullable, nonatomic, copy) NSString *forumName;
@property(nullable, nonatomic, copy) NSNumber *parentForumId;
@property(nullable, nonatomic, copy) NSString *forumHost;

@end

NS_ASSUME_NONNULL_END
