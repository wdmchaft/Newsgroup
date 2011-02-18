//
//  GPHTTPController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/17/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "GPHTTPController.h"


@implementation GPHTTPController

#pragma mark Init methods

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id <GPHTTPControllerDelegate>)delegate {
    if ((self = [super init])) {
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    
    [super dealloc];
}

#pragma mark Properties
@synthesize delegate = delegate_;

#pragma mark Instance Methods
- (void)beginFetching {
    
}

- (BOOL)isFetching {
    return NO;
}

- (void)stopFetching {
    
}

@end
