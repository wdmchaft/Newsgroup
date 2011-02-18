//
//  GPHTTPController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/17/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPHTTPController;

@protocol GPHTTPControllerDelegate

- (void)fetchFailed:(GPHTTPController *)controller withError:(NSError *)error;
- (void)fetchSucceded:(GPHTTPController *)controller withResults:(NSData *)data;

@end

@interface GPHTTPController : NSObject {
    id <GPHTTPControllerDelegate> delegate_;
}

// Init methods
- (id)initWithDelegate:(id <GPHTTPControllerDelegate>)delegate;

// Properties
@property (assign) id <GPHTTPControllerDelegate> delegate;

// Instance Methods
- (void)beginFetching;
- (BOOL)isFetching;
- (void)stopFetching;

@end
