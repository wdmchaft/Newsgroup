//
//  DataController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import "ASIHTTPRequest.h"

// Notification Strings
extern NSString *const DataControllerFetchDidBegin;
extern NSString *const DataControllerFetchDidEnd;

// Data Controller Error Domain
extern NSString *const DataControllerErrorDomain;

// Error codes
typedef enum {
    DataControllerErrorNoDelegate,
    DataControllerErrorNoLogin,
    DataControllerErrorNoPassword
} DataControllerErrorCode;

// Exception strings
extern NSString *const DataControllerNoUsernameException;
extern NSString *const DataControllerNoPasswordException;
extern NSString *const DataControllerNoPostIDException;

@class DataController;

@protocol DataControllerDelegate

- (void)fetchFailed:(DataController *)dataController withError:(NSError *)error;
- (void)fetchSucceded:(DataController *)dataController;
- (void)setProgress:(float)newProgress dataController:(DataController *)dataController;

@end

@interface DataController : NSObject <ASIHTTPRequestDelegate, ASIHTTPRequestDelegate> {

    @private
    NSManagedObjectContext *context_;
    id <DataControllerDelegate> delegate_;
    BOOL isFetching_;
    NSString *login_;
    NSManagedObjectModel *model_;
    NSString *password_;
    NSOperationQueue *operationQueue_;
    
}

// Properties
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (assign) id <DataControllerDelegate> delegate;
@property (readonly, retain) NSDate *lastFetchTime;
@property (copy) NSString *login;
@property (readonly) BOOL isFetching;
@property (copy) NSString *password;

// Class methods
+ (NSURL *)defaultManagedObjectModelURL;
+ (NSString *)hashString:(NSString *)password;
+ (NSString *)addBodyToHTMLTemplate:(NSString *)body;

// Designated Initializer
- (id)initWithModelURL:(NSURL *)modelURL andStoreURL:(NSURL *)storeURL;

// Web Methods
- (BOOL)markPostAsRead:(NSNumber *)postID;
- (BOOL)fetchAllPostsWithError:(NSError **)error;
- (void)stopFetching;

// Fetch posts from the data store
- (NSFetchedResultsController *)allThreads;
- (NSFetchedResultsController *)postsWithThreadID:(NSNumber *)threadID;
- (NSFetchedResultsController *)postsWithParentID:(NSNumber *)parentID;
- (Post *)postWithId:(NSNumber *)postID;
- (BOOL)postHasChildren:(NSNumber *)postID;

// Unread Post Methods
- (NSInteger)countOfUnreadPosts;
- (NSArray *)pathToNextUnreadPost;
- (NSArray *)pathToNextUnreadPostUnderPost:(Post *)post;
- (Post *)nextUnreadPost;
- (Post *)nextUnreadPostUnderPost:(Post *)post;
- (NSArray *)pathToPost:(Post *)post;

// Private Methods (internal use only)
- (void)loadNewPosts:(NSArray *)postDict intoContext:(NSManagedObjectContext *)context;
- (BOOL)startFetchWithHTTPRequest:(ASIHTTPRequest *)request andError:(NSError **)error;

@end
