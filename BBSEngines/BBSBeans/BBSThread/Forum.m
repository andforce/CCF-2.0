//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import "Forum.h"

@implementation Forum
- (NSString *)description {
    if (_childForums != nil) {
        return [NSString stringWithFormat:@"Id=%d\tName=%@\tchildCount=%d\tpatentId=%d", _forumId, _forumName, (int) _childForums.count, _parentForumId];
    } else {
        return [NSString stringWithFormat:@"Id=%d\tName=%@\tchildCount=%d\tpatentId=%d", _forumId, _forumName, 0, _parentForumId];
    }
}
@end
