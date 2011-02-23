//
//  GPHTTPController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/17/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "GPHTTPOperation.h"


@implementation GPHTTPOperation

#pragma mark Init methods

- (id)init {
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id <GPHTTPOperationDelegate>)delegate {
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

#pragma -
#pragma NSOperation methods

-(void)main {
    @try {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        NSLog(@"This does nothing at this time");
        
        [pool release];
    }
    @catch(...) {
        // Do not rethrow exceptions.
    }
}

@end
