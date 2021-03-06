//
//  ToolbarProgressView.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/17/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "ToolbarProgressView.h"
#import "NSDate+Helper.h"

#define GPProgressTimestampString(x) [NSString stringWithFormat:@"Updated %@", x]

typedef enum {
    GPProgressTagsDeterminiteViewProgressBar = 1
} GPProgressTagsDeterminiteView;

typedef enum {
    GPProgressTagsTimestampViewDate = 1
} GPProgressTagsTimestampView;

@interface ToolbarProgressView()

- (void)configureDeterminateView;
- (void)configureIndeterminateView;
- (void)configureTimestamp;
- (void)configureViews;

@end


@implementation ToolbarProgressView


#pragma mark Object Lifecycle Methods

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        views_ = [[UINib nibWithNibName:@"ProgressView" bundle:nil] instantiateWithOwner:nil options:nil];
    }
    return self;
}


#pragma mark Properties

@synthesize progress = progress_;
@synthesize timestamp = timestamp_;
@synthesize viewType = viewType_;

- (void)setProgress:(float)prog {
    progress_ = prog;
    
    [self configureViews];
}

- (void)setTimestamp:(NSDate *)date {
    timestamp_ = date;
    
    [self configureViews];
}

- (void)setViewType:(ViewType)vt {

    UIView *view = [views_ objectAtIndex:vt];

    // Remove all subviews
    NSArray *subviews = self.subviews;
    [subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    
    [self addSubview:view];
    viewType_ = vt;
    
    [self configureViews];
}

#pragma mark Instance Methods

- (void)configureDeterminateView {
    UIProgressView *pv = (UIProgressView *)[[views_ objectAtIndex:GPProgressDeterminiteView] viewWithTag:GPProgressTagsDeterminiteViewProgressBar];
    [pv setProgress:progress_];
}

- (void)configureIndeterminateView {
    // Nothing to configure
}

- (void)configureTimestamp {
   
    UILabel *dateLabel = (UILabel *)[[views_ objectAtIndex:GPProgressTimestampView] viewWithTag:GPProgressTagsTimestampViewDate];
    
    if (self.timestamp) {
        NSString *dateString = GPProgressTimestampString([NSDate stringForDisplayFromDate:timestamp_ prefixed:YES]);
        dateLabel.text = dateString;
    } else {
        dateLabel.text = @"";
    }
    
}

- (void)configureViews {
    switch (viewType_) {
        case GPProgressTimestampView:
            [self configureTimestamp];
            break;
        
        case GPProgressDeterminiteView:
            [self configureDeterminateView];
            break;
        
        case GPProgressIndeterminiteView:
            [self configureIndeterminateView];
            break;
    }
}

@end
