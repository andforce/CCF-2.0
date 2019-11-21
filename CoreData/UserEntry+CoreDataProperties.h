//
//
//  
//
//  Created by Diyuan Wang on 2019/11/21.
//
//

#import "UserEntry+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface UserEntry (CoreDataProperties)

+ (NSFetchRequest<UserEntry *> *)fetchRequest;

@property(nullable, nonatomic, copy) NSString *userAvatar;
@property(nullable, nonatomic, copy) NSString *userID;
@property(nullable, nonatomic, copy) NSString *forumHost;

@end

NS_ASSUME_NONNULL_END
