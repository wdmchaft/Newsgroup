//
//  GPHTTPController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/17/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPHTTPOperation;

@protocol GPHTTPOperationDelegate

- (void)fetchFailed:(GPHTTPOperation *)controller withError:(NSError *)error;
- (void)fetchSucceded:(GPHTTPOperation *)controller withResults:(NSData *)data;

@end

@interface GPHTTPOperation : NSOperation {
    id <GPHTTPOperationDelegate> delegate_;
}

// Init methods
- (id)initWithDelegate:(id <GPHTTPOperationDelegate>)delegate;

// Properties
@property (assign) id <GPHTTPOperationDelegate> delegate;

// Instance Methods

@end
