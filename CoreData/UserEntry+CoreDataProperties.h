//
//  UserEntry+CoreDataProperties.h
//  
//
//  Created by WDY on 2016/12/7.
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
