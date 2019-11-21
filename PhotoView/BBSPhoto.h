//
//  NYTExamplePhoto.h
//  ios-photo-viewer
//
//  Created by Diyuan Wang on 2019/11/21.
//  Copyright (c) 2015 NYTimes. All rights reserved.
//

@import Foundation;

#import <NYTPhotoViewer/NYTPhoto.h>

@interface BBSPhoto : NSObject <NYTPhoto>

// Redeclare all the properties as readwrite for sample/testing purposes.
@property(nonatomic) UIImage *image;
@property(nonatomic) NSData *imageData;
@property(nonatomic) UIImage *placeholderImage;
@property(nonatomic) NSAttributedString *attributedCaptionTitle;
@property(nonatomic) NSAttributedString *attributedCaptionSummary;
@property(nonatomic) NSAttributedString *attributedCaptionCredit;

@end
