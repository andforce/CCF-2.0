//
// Created by 迪远 王 on 2018/6/2.
// Copyright (c) 2018 andforce. All rights reserved.
//

#import "vBulletinBaseApi.h"


@implementation vBulletinBaseApi {

}
- (void)listAllForums:(HandlerWithBool)handler {

}

- (void)favoriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

}

- (void)unFavouriteForumWithId:(NSString *)forumId handler:(HandlerWithBool)handler {

}

- (void)favoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)unFavoriteThreadWithId:(NSString *)threadPostId handler:(HandlerWithBool)handler {

}

- (void)listFavoriteForums:(HandlerWithBool)handler {

}

- (void)listFavoriteThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listMyAllThreadsWithPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listAllUserThreads:(int)userId withPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)showThreadWithId:(int)threadId andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)forumDisplayWithId:(int)forumId andPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)getAvatarWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {

}

- (void)showProfileWithUserId:(NSString *)userId handler:(HandlerWithBool)handler {

}

- (void)replyWithMessage:(NSString *)message withImages:(NSArray *)images toPostId:(NSString *)postId thread:(ViewThreadPage *)threadPage isQoute:(BOOL)quote handler:(HandlerWithBool)handler {

}

- (void)searchWithKeyWord:(NSString *)keyWord forType:(int)type handler:(HandlerWithBool)handler {

}

- (void)listNewThreadWithPage:(int)page handler:(HandlerWithBool)handler {

}

- (void)listSearchResultWithSearchId:(NSString *)searchId keyWord:(NSString *)keyWord andPage:(int)page type:(int)type handler:(HandlerWithBool)handler {

}

- (void)reportThreadPost:(int)postId andMessage:(NSString *)message handler:(HandlerWithBool)handler {

}

- (BOOL)openUrlByClient:(ForumWebViewController *)controller request:(NSURLRequest *)request {
    return NO;
}

@end