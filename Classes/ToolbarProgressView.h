//
//  ToolbarProgressView.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/17/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    GPProgressTimestampView,
    GPProgressIndeterminiteView,
    GPProgressDeterminiteView
} ViewType;

@interface ToolbarProgressView : UIView {

    float progress_;
    NSDate *timestamp_;
    NSArray *views_;
    ViewType viewType_;
}

@property (assign, nonatomic) float progress; 
@property (retain, nonatomic) NSDate *timestamp;
@property (assign, nonatomic) ViewType viewType;

@end
