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
        [views_ retain];
    }
    return self;
}

- (void)dealloc {
    [views_ release];
    [super dealloc];
}

#pragma mark Properties

@synthesize progress;
@synthesize timestamp;
@synthesize viewType;

- (void)setProgress:(float)prog {
    progress_ = prog;
    
    [self configureViews];
}

- (void)setTimestamp:(NSDate *)date {
    [date retain];
    [timestamp_ release];
    timestamp_ = date;
    
    [self configureViews];
}

- (void)setViewType:(ViewType)vt {

    UIView *view = [views_ objectAtIndex:vt];
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
    
    dateLabel.text = [NSDate stringForDisplayFromDate:timestamp_ prefixed:YES];
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
