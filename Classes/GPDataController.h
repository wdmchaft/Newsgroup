//
//  GPDataController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPPost.h"
#import "ASIHTTPRequest.h"

/**
 * Notification sent when the a new data fetch begins.
 */
extern NSString *const GPDataControllerFetchDidBegin;

/**
 * Notifcation sent when a data fetch ends
 */
extern NSString *const GPDataControllerFetchDidEnd;

/**
 * Error Domain for any GPDataController errors
 */
extern NSString *const GPDataControllerErrorDomain;

/**
 * GPDataController error codes
 */
typedef enum {
    GPDataControllerErrorNoDelegate,
    GPDataControllerErrorNoLogin,
    GPDataControllerErrorNoPassword
} GPDataControllerErrorCode;

@class GPDataController;

@protocol GPDataControllerDelegate

/**
 * Fetch did fail with error.
 * This error may not necissarily be generated by the GPDataController, so it's 
 * important to check the error domain before utilizing the error code for any logic.
 */
- (void)fetchFailed:(GPDataController *)dataController withError:(NSError *)error;

/**
 * Fetch did succeed
 */
- (void)fetchSucceded:(GPDataController *)dataController;

@end



@interface GPDataController : NSObject <ASIHTTPRequestDelegate> {

    @private
    NSManagedObjectContext *context_;
    id <GPDataControllerDelegate> delegate_;
    BOOL isFetching_;
    NSString *login_;
    NSManagedObjectModel *model_;
    NSString *password_;
    NSOperationQueue *operationQueue_;
    
}

// Properties
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (assign) id <GPDataControllerDelegate> delegate;
@property (readonly, retain) NSDate *lastFetchTime;
@property (copy) NSString *login;
@property (readonly) BOOL isFetching;
@property (copy) NSString *password;

// Class methods
+ (NSURL *)defaultManagedObjectModelURL;
+ (NSString *)hashString:(NSString *)password;
+ (ASIHTTPRequest *)hashRequestWithValue:(NSString *)value urlEncode:(BOOL)shouldEncode;
+ (ASIHTTPRequest *)userWithUsername:(NSString *)username andPassword:(NSString *)password;
+ (ASIHTTPRequest *)postsWithUsername:(NSString *)username password:(NSString *)password threadID:(NSInteger)threadID postID:(NSInteger)postID threadLimit:(NSInteger)threadLimit;

// Init methods
- (id)initWithModelURL:(NSURL *)modelURL andStoreURL:(NSURL *)storeURL;


/**
 * The default method to begin all fetches.
 * @param error The error object, may be nil.
 */
- (BOOL)fetchAllPostsWithError:(NSError **)error;

/**
 * Loads an array of post dictionaries into the given managed object context.
 * This method is for internal use only.
 * @param postDict An array of NSDictionary representations of GPPosts
 * @param context The context into which the posts will be loaded. 
 */
- (void)loadNewPosts:(NSArray *)postDict intoContext:(NSManagedObjectContext *)context;
- (BOOL)startFetchWithHTTPRequest:(ASIHTTPRequest *)request andError:(NSError **)error;
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

/**
 * Post with ID
 * Returns the post with the given ID or null if it does not exist
 */
- (GPPost *)postWithId:(NSUInteger)postID;


@end
