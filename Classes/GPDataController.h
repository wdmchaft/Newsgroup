//
//  GPDataController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPPost.h"

extern NSString *const GPHTTPRequestDidBegin;
extern NSString *const GPHTTPRequestDidEnd;

@class GPDataController;

@protocol GPDataControllerDelegate

- (void)fetchFailed:(GPDataController *)dataController withError:(NSError *)error;
- (void)fetchSucceded:(GPDataController *)dataController;

@end



@interface GPDataController : NSObject {

    @private
    NSManagedObjectContext *context_;
    id <GPDataControllerDelegate> delegate_;
    BOOL isFetching_;
    NSDate *lastFetchTime_;
    NSManagedObjectModel *model_;
    NSOperationQueue *operationQueue_;
    
}

// Properties
@property (assign) id <GPDataControllerDelegate> delegate;
@property (readonly, retain) NSDate *lastFetchTime;
@property (readonly) BOOL isFetching;

// Instance Methods
- (void)startFetching;
- (void)stopFetching;

/**
 * All Threads
 * This method returns all threads, regardless of date or timestamp.
 * The object using this fetched results controller should always call `performFetch:` before attempting to access data.
 */
- (NSFetchedResultsController *)allThreads;

/**
 * Posts in thread
 * This method returns all posts in a given input thread.
 */
- (NSFetchedResultsController *)postsWithThreadID:(NSNumber *)threadID;

/**
 * Posts in thread, at level
 * Returns all posts in a given thread at a given level. The level counts start at 1, so top level "thread" posts will have a level of 1.
 */
- (NSFetchedResultsController *)postsWithThreadID:(NSNumber *)threadID atPostLevel:(NSNumber *)postLevel;


@end
