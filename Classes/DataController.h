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
extern NSString *const DataControllerNoUnreadPosts;
extern NSString *const DataControllerNewUnreadPosts;

// Data Controller Error Domain
extern NSString *const DataControllerErrorDomain;

// Error codes
typedef enum {
    DataControllerErrorNoDelegate,
    DataControllerErrorNoLogin,
    DataControllerErrorNoPassword,
    DataControllerErrorConnectionFailure,
    DataControllerErrorRequestTimedOut,
    DataControllerErrorAuthenticationFailed,
    DataControllerErrorUnknownNetworkFailure
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

@interface DataController : NSObject {

    @private
    NSManagedObjectContext *context_;
    id <DataControllerDelegate> delegate_;
    NSString *login_;
    NSManagedObjectModel *model_;
    NSString *password_;
    NSOperationQueue *operationQueue_;
}

// Properties
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (assign) id <DataControllerDelegate> delegate;
@property (readonly, retain) NSDate *lastFetchTime;
@property (readonly, copy) NSString *login;
@property (readonly) BOOL isFetching;
@property (readonly, copy) NSString *password;

// Class methods
+ (NSURL *)defaultManagedObjectModelURL;
+ (NSString *)hashString:(NSString *)password;
+ (NSString *)addBodyToHTMLTemplate:(NSString *)body;

// Designated Initializer
- (id)initWithModelURL:(NSURL *)modelURL andStoreURL:(NSURL *)storeURL;

// Authentication Methods
- (void)authenticateUser;
- (BOOL)saveResponseStringFromAuthenticationRequest:(NSString *)responseString;

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

// Post history
- (NSFetchedResultsController *)postHistory;
- (void)addPostToHistory:(Post *)post;
- (void)addPostToHistory:(Post *)post withDate:(NSDate *)date;

// Make a new post
- (void)addPostWithSubject:(NSString *)subject body:(NSString *)body inReplyTo:(NSNumber *)postID;
- (void)addPost:(Post *)post withRequest:(ASIHTTPRequest *)request;

// Unread Post Methods
- (NSInteger)countOfUnreadPosts;
- (NSArray *)pathToNextUnreadPost;
- (NSArray *)pathToNextUnreadPostUnderPost:(Post *)post;
- (Post *)nextUnreadPost;
- (Post *)nextUnreadPostUnderPost:(Post *)post;
- (NSArray *)pathToPost:(Post *)post;
- (NSInteger)countOfUnreadPostsUnderPost:(Post *)post;

// Search Methods
- (NSArray *)allPosts;

@end
