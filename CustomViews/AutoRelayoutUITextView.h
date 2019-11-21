//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright © 2019年 Diyuan Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMiniHeight 30
#define kMaxHeight  180

@protocol AutoRelayoutUITextViewDelegate <NSObject>

@required
- (void)heightChanged:(CGFloat)height;

@end


@interface AutoRelayoutUITextView : UITextView

@property(nonatomic, strong) id <AutoRelayoutUITextViewDelegate> heightDelegate;


- (void)showPlaceHolder:(BOOL)show;

@end
