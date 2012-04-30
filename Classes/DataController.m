//
//  DataController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "DataController.h"
#import "DataControllerPrivate.h"
#import "JSON.h"
#import "NSString+Digest.h"
#import "PostLoadOperation.h"
#import "RequestGenerator.h"
#import "JKConstants.h"
#import "PostHistory.h"

// Notification Strings
NSString *const DataControllerFetchDidBegin = @"GPHTTPRequestDidBegin";
NSString *const DataControllerFetchDidEnd = @"GPHTTPRequestDidEnd";
NSString *const DataControllerNoUnreadPosts = @"DataControllerNoUnreadPosts";
NSString *const DataControllerNewUnreadPosts = @"DataControllerNewUnreadPosts";

// Data Controller Error Domain
NSString *const DataControllerErrorDomain = @"DataControllerErrorDomain";

// Exception Strings
NSString *const DataControllerNoUsernameException = @"DataControllerNoUsernameException";
NSString *const DataControllerNoPasswordException = @"DataControllerNoPasswordException";
NSString *const DataControllerNoPostIDException = @"DataControllerNoPostIDException";

// Helper macros
#define ASSERT_NOT_NIL(object,error) NSAssert1(object != nil, @"%@", error)

@interface DataController()

// Private methods
- (NSUInteger)error:(NSError **)error withErrorCode:(DataControllerErrorCode)code;

// Private properties
@property (readwrite, strong) NSDate *lastFetchTime;
@property (strong, nonatomic) NSManagedObjectModel *model;

@end


@implementation DataController

#pragma mark -
#pragma mark Properties

@synthesize context = context_;
@synthesize delegate = delegate_;
@synthesize model = model_;
- (void)setLogin:(NSString *)login {
    [[NSUserDefaults standardUserDefaults] setObject:login forKey:JKDefaultsUsernameKey];
}

- (NSString *)login {
    return [[NSUserDefaults standardUserDefaults] objectForKey:JKDefaultsUsernameKey];
}

- (void)setPassword:(NSString *)password {
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:JKDefaultsPasswordKey];
}

- (NSString *)password {
    return [[NSUserDefaults standardUserDefaults] objectForKey:JKDefaultsPasswordKey];
}

- (void)setLastFetchTime:(NSDate *)lastFetchTime {
    [[NSUserDefaults standardUserDefaults] setObject:lastFetchTime forKey:DataControllerLastFetchTime];
}

- (NSDate *)lastFetchTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:DataControllerLastFetchTime];
}

- (BOOL)isFetching {
    return NO;
}

#pragma mark -
#pragma mark Class Methods

+ (NSURL *)defaultManagedObjectModelURL {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Newsgroup" ofType:@"momd"]];
}

+ (NSString *)hashString:(NSString *)password {
    NSString *hash = [password hashWithDigestType:JKStringDigestTypeSHA512];
    
    return hash;
}

+ (NSString *)addBodyToHTMLTemplate:(NSString *)body {
    
    NSError *error = nil;
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"post_body" ofType:@"html"];
    NSString *template = [NSString stringWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:&error];
    NSAssert1(template != nil, @"%@", error);
    
    return [template stringByReplacingOccurrencesOfString:@"<%body_text%>" withString:body];
}


#pragma mark -
#pragma mark Init/Dealloc methods

- (id)init {
    
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"Newsgroup.sqlite"];
    
    NSURL *modelURL = [DataController defaultManagedObjectModelURL];
    
    return [self initWithModelURL:modelURL andStoreURL:storeURL];
}

// Designated Initializer
- (id)initWithModelURL:(NSURL *)modelURL andStoreURL:(NSURL *)storeURL {
    if ((self = [super init])) {
        
        NSError *error = nil;
        
        NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]; 
        
        NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
        
        self.context = managedObjectContext;
        self.model = managedObjectModel;
        
        
        // Setup the Operation Queue
        operationQueue_ = [[NSOperationQueue alloc] init];
        [operationQueue_ setName:@"DataController queue"];
        
    }
    return self;
}

- (void)dealloc {
    
    [operationQueue_ cancelAllOperations];
    [operationQueue_ waitUntilAllOperationsAreFinished];
    
}

#pragma mark -


#pragma mark Authentication Methods

- (void)authenticateUser {
    __unsafe_unretained ASIHTTPRequest *request = [RequestGenerator userWithUsername:self.login andPassword:self.password];
    
    // Success
    [request setCompletionBlock:^(void) {
        BOOL isAuthenticated = [self saveResponseStringFromAuthenticationRequest:[request responseString]];
        
        if (isAuthenticated == NO) {
            NSLog(@"Cannot authenticate username/password");
        }
    }];
    
    [operationQueue_ addOperation:request];
}

- (BOOL)saveResponseStringFromAuthenticationRequest:(NSString *)responseString {
    NSDictionary *response = [responseString JSONValue];
    
    if (response == nil) {
        NSLog(@"Cannot parse response string: %@", responseString);
    }
    
    if ([[response objectForKey:@"Authenticated"] boolValue] == YES) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[response objectForKey:@"FullName"] forKey:NewsgroupDefaultsFullNameKey];
        [defaults setObject:[response objectForKey:@"NickName"] forKey:NewsgroupDefaultsNickNameKey];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark Web Methods

- (BOOL)markPostAsRead:(NSNumber *)postID {
    // Check to see if this is the last unread post, if so, disable the next unread button
    NSInteger unreadCount = [self countOfUnreadPosts];
    if (unreadCount == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DataControllerNoUnreadPosts object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:DataControllerNewUnreadPosts object:self];
    }
    
    ASIHTTPRequest *request = [RequestGenerator markPostAsRead:postID username:self.login password:self.password];
    [request setDelegate:self];
    
    [operationQueue_ addOperation:request];
    return YES;
}

- (BOOL)fetchAllPostsWithError:(NSError **)error {
    
    // Check for a login and password
    if (!self.login) {
        [self error:error withErrorCode:DataControllerErrorNoLogin];
        return NO;
    }
    if (!self.password) {
        [self error:error withErrorCode:DataControllerErrorNoPassword];
        return NO;
    }
    
    UIBackgroundTaskIdentifier taskIdent = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    __unsafe_unretained ASIHTTPRequest *request = [RequestGenerator postsWithUsername:self.login password:self.password threadID:0 postID:0 threadLimit:0];
    [request setDownloadProgressDelegate:self];
    
    [request setCompletionBlock:^(void) {
        // Get the response string out of the request
        NSArray *posts = [[request responseString] JSONValue];
        
        [self loadNewPosts:posts intoContext:self.context];
        
        [[UIApplication sharedApplication] endBackgroundTask:taskIdent];
    }];
    
    [request setFailedBlock:^(void) {
        if (self.delegate) {
            NSError *inputError = [request error];
            NSInteger code;
            NSDictionary *userInfo;
            
            NSString *localizedDescription = [[inputError userInfo] objectForKey:NSLocalizedDescriptionKey];
            NSURL *url = [[inputError userInfo] objectForKey:NSURLErrorKey];
            
            switch ([inputError code]) {
                case ASIConnectionFailureErrorType:
                    code = DataControllerErrorConnectionFailure;
                    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                localizedDescription, NSLocalizedDescriptionKey,
                                inputError, NSUnderlyingErrorKey,
                                url, NSURLErrorKey, nil];
                    break;
                    
                case ASIRequestTimedOutErrorType:
                    code = DataControllerErrorRequestTimedOut;
                    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                localizedDescription, NSLocalizedDescriptionKey,
                                inputError, NSUnderlyingErrorKey,
                                url, NSURLErrorKey, nil];
                    break;
                    
                case ASIAuthenticationErrorType:
                    code = DataControllerErrorAuthenticationFailed;
                    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                localizedDescription, NSLocalizedDescriptionKey,
                                inputError, NSUnderlyingErrorKey,
                                url, NSURLErrorKey, nil];
                    break;
                    
                default:
                    code = DataControllerErrorUnknownNetworkFailure;
                    userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                NSLocalizedString(@"Unknown network error occured", nil), NSLocalizedDescriptionKey,
                                inputError, NSUnderlyingErrorKey,
                                url, NSURLErrorKey, nil];
                    break;
            }
            
            NSError *outputError = [NSError errorWithDomain:DataControllerErrorDomain code:code userInfo:userInfo];
            
            [self.delegate fetchFailed:self withError:outputError];
            
            [[UIApplication sharedApplication] endBackgroundTask:taskIdent];
        }
    }];
    
    return [self startFetchWithHTTPRequest:request andError:error];
}

- (void)stopFetching {
    
}

#pragma mark Fetch posts from the data store

- (NSFetchedResultsController *)allThreads {
    
    // Copying the request allows it to be modified and prevents "Can't modify a named fetch request in an immutable model." exception.
    NSFetchRequest *fetchRequest = [[self.model fetchRequestTemplateForName:@"allThreads"] copy];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
        
    return aFetchedResultsController;
}

- (NSFetchedResultsController *)postsWithThreadID:(NSNumber *)threadID {
    
    // Get the fetch request
    NSDictionary *dict = [NSDictionary dictionaryWithObject:threadID forKey:@"threadID"];
    NSFetchRequest *fetchRequest = [self.model fetchRequestFromTemplateWithName:@"postsForThread" substitutionVariables:dict];
       
    // Set the sort key
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:NO];
    NSArray *sortArray = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSFetchedResultsController *fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    return fetchedResults;
}

- (NSFetchedResultsController *)postsWithParentID:(NSNumber *)parentID {
    
    // Get the fetch request
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:parentID, @"parentID", nil];
    NSFetchRequest *fetchRequest = [self.model fetchRequestFromTemplateWithName:@"postsWithParentID" substitutionVariables:dict];
    
    // Set the sort key
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:YES];
    NSArray *sortArray = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSFetchedResultsController *fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    return fetchedResults;
}

- (Post *)postWithId:(NSNumber *)postID {
    
    // get the fetch request
    NSDictionary *dict = [NSDictionary dictionaryWithObject:postID forKey:@"postID"];
    NSFetchRequest *fetchRequest = [self.model fetchRequestFromTemplateWithName:@"postWithID" substitutionVariables:dict];
    
    NSError *error = nil;
    NSArray *resultArray = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if( !resultArray ) {
        NSLog(@"%@", error);
        return nil;
    } else if ([resultArray count] != 1) {
        NSLog(@"There was an error, either no posts exist with that ID, or more than one post exists with that ID");
        return nil;
    } else {
        return [resultArray objectAtIndex:0];
    }
}

- (BOOL)postHasChildren:(NSNumber *)postID {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:postID forKey:@"parentID"];
    NSFetchRequest *fetchRequest = [self.model fetchRequestFromTemplateWithName:@"postsWithParentID" substitutionVariables:dict];
    
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:fetchRequest error:&error];
    
    if (!results) {
        NSLog(@"%@", error);
        return NO;
    } else if ([results count] == 0) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark Post history

- (NSFetchedResultsController *)postHistory {
    NSFetchRequest *fetchRequest = [self.model fetchRequestFromTemplateWithName:@"postHistory" substitutionVariables:nil];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postViewTime" ascending:NO];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSFetchedResultsController *fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    return fetchedResults;
}

- (void)addPostToHistory:(Post *)post {
    [self addPostToHistory:post withDate:[NSDate date]];
}

- (void)addPostToHistory:(Post *)post withDate:(NSDate *)date {
    PostHistory *postHistory = [NSEntityDescription insertNewObjectForEntityForName:[PostHistory entityName] inManagedObjectContext:self.context];
    
    postHistory.post = post;
    postHistory.postViewTime = date;
}

#pragma mark Make a new post
- (void)addPostWithSubject:(NSString *)subject body:(NSString *)body inReplyTo:(NSNumber *)postID {
    ASIHTTPRequest *request = [RequestGenerator addPostForUser:self.login password:self.password subject:subject body:body inReplyTo:postID];
    
    Post *post = [NSEntityDescription insertNewObjectForEntityForName:[Post entityName] inManagedObjectContext:self.context];
    
    post.parentID = postID;
    post.postdate = [NSDate date];
    post.isRead = [NSNumber numberWithBool:YES];
    post.subject = subject;
    post.body = body;
    post.posterName = [[NSUserDefaults standardUserDefaults] stringForKey:NewsgroupDefaultsFullNameKey];
    
    if (postID == nil) {
        post.postLevel = [NSNumber numberWithInteger:1];
    }
    
    [self addPost:post withRequest:request];
}

- (void)addPost:(Post *)post withRequest:(ASIHTTPRequest *)request {
    UIBackgroundTaskIdentifier taskIdent = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    
    __unsafe_unretained ASIHTTPRequest *bRequest = request;
    
    [bRequest setCompletionBlock:^(void) {
        NSInteger postID = [[bRequest responseString] integerValue];
        post.postID = [NSNumber numberWithInteger:postID];
        [[UIApplication sharedApplication] endBackgroundTask:taskIdent];
    }];
    
    [bRequest setFailedBlock:^(void) {
        [[UIApplication sharedApplication] endBackgroundTask:taskIdent];
    }];
    
    [self startFetchWithHTTPRequest:request andError:nil];
}


#pragma mark Unread Post Methods

- (NSInteger)countOfUnreadPosts {
    NSFetchRequest *fetchRequest = [self.model fetchRequestTemplateForName:@"allUnread"];
    
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:fetchRequest error:&error];
    ASSERT_NOT_NIL(results, error);
    
    return [results count];
}

- (NSArray *)pathToNextUnreadPost {
    Post *post = [self nextUnreadPost];
    if (post) {
        return [self pathToPost:post];
    } else {
        return nil;
    }
}

- (NSArray *)pathToNextUnreadPostUnderPost:(Post *)post {
    Post *nextUnreadPost = [self nextUnreadPostUnderPost:post];
    if (nextUnreadPost) {
        return [self pathToPost:nextUnreadPost];
    } else {
        return nil;
    }
    
}

- (Post *)nextUnreadPost {
    NSFetchRequest *fetchRequest = [[self.model fetchRequestTemplateForName:@"allUnread"] copy];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sd]];
    [fetchRequest setFetchLimit:1];
    
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:fetchRequest error:&error];
    ASSERT_NOT_NIL(results, error);
    
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    } else {
        return nil;
    }
}

- (Post *)nextUnreadPostUnderPost:(Post *)post {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:post.postID forKey:@"parentID"];
    NSFetchRequest *fetchRequest = [self.model fetchRequestFromTemplateWithName:@"postsWithParentID" substitutionVariables:dict];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sd]];
    
    NSError *error = nil;
    NSArray *results = [self.context executeFetchRequest:fetchRequest error:&error];
    ASSERT_NOT_NIL(results, error);
    
    // If this post has no children, return nil
    if ([results count] == 0) {
        return nil;
    }
    
    // Iterate over the posts
    for (Post *childPost in results) {
        // if the child is unread, return it
        if ([childPost.isRead boolValue] == NO) {
            return childPost;
        } else {
            // Get the unread post for the children
            Post *grandchildPost = [self nextUnreadPostUnderPost:childPost];
            if (grandchildPost) {
                return grandchildPost;
            }
        }
    }
    
    return nil;
}

- (NSArray *)pathToPost:(Post *)post {
    // If we are a top level post, return an array with only us in it
    if ([post.parentID isEqualToNumber:post.postID]) {
        return [NSArray arrayWithObject:post];
    } else {
        Post *parentPost = [self postWithId:post.parentID];
        return [[self pathToPost:parentPost] arrayByAddingObject:post];
    }
}

- (ReadUnread)countOfUnreadPostsUnderPost:(Post *)post {
    
    NSSet *childPosts = post.childPosts;
    
    // If this post has no children, return nil
    if ([childPosts count] == 0) {
        return (ReadUnread){0,0};
    }
    
    NSInteger children = 0;
    NSInteger unreadChildren = 0;
    
    // Iterate over the posts
    for (Post *childPost in childPosts) {
        
        children++;
        
        if ([childPost.isRead boolValue] == NO) {
            unreadChildren++;
        }
        
        ReadUnread childCount = [self countOfUnreadPostsUnderPost:childPost];
        children += childCount.children;
        unreadChildren += childCount.unreadChildren;
    }
    
    ReadUnread returnCounts = {children, unreadChildren};
    
    return returnCounts;
}

#pragma mark Search Methods

- (NSArray *)allPosts {
    NSFetchRequest *fetchRequest = [self.model fetchRequestTemplateForName:@"allPosts"];
    
    NSError *error = nil;
    NSArray *allPosts = [self.context executeFetchRequest:fetchRequest error:&error];
    ASSERT_NOT_NIL(allPosts, error);
    
    return allPosts;
}

#pragma mark -
#pragma mark Private internal methods

- (NSUInteger)error:(NSError **)error withErrorCode:(DataControllerErrorCode)code {
    if (error != NULL) {
        
        NSDictionary *userInfo = nil;
        NSString *description = nil;
        NSString *failureReason = nil;
        
        switch (code) {
                
            case DataControllerErrorNoDelegate:
                description = NSLocalizedString(@"No Delegate", nil);
                failureReason = NSLocalizedString(@"DataController must have a delegate set", nil);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, failureReason, NSLocalizedFailureReasonErrorKey, nil];
                break;
                
            case DataControllerErrorNoLogin:
                description = NSLocalizedString(@"No Username", nil);
                failureReason = NSLocalizedString(@"DataController must have a username set before attempting a fetch", nil);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, failureReason, NSLocalizedFailureReasonErrorKey, nil];
                break;
                
            case DataControllerErrorNoPassword:
                description = NSLocalizedString(@"No Password", nil);
                failureReason = NSLocalizedString(@"DataController must have a password set before attempting a fetch", nil);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, failureReason, NSLocalizedFailureReasonErrorKey, nil];
                break;
                
            default:
                NSAssert1(NO, @"Unhandled DataControllerErrorCode %i", code);
        }
        
        *error = [[NSError alloc] initWithDomain:DataControllerErrorDomain code:code userInfo:userInfo];
    }
    return 0;
}

- (void)loadNewPosts:(NSArray *)posts intoContext:(NSManagedObjectContext *)context {
    PostLoadOperation *postLoad = [[PostLoadOperation alloc] init];
    if ( [postLoad addPostsFromArray:posts toContext:context] ) {
        // Update the last fetch time
        self.lastFetchTime = [NSDate date];
        
        // send notification that we're finished
        [[NSNotificationCenter defaultCenter] postNotificationName:DataControllerFetchDidEnd object:self];
        
        // let delegate know
        [self.delegate fetchSucceded:self];
    } else {
        NSAssert(YES, @"Construct some sort of error here");
    }
    
    NSInteger unreadCount = [self countOfUnreadPosts];
    if (unreadCount != 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DataControllerNewUnreadPosts object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:DataControllerNoUnreadPosts object:self];
    }
}

- (BOOL)startFetchWithHTTPRequest:(ASIHTTPRequest *)request andError:(NSError **)error {
    
    // Assure that we have got a delegate
    if (!self.delegate) {
        [self error:error withErrorCode:DataControllerErrorNoDelegate];
        return NO;
    }    
    
    // Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:DataControllerFetchDidBegin object:self];
    
    // Add to queue
    [operationQueue_ addOperation:request];
    
    return YES;
}


#pragma ASIProgressDelegate

- (void)setProgress:(float)newProgress {
    
    [self.delegate setProgress:newProgress dataController:self];
}

@end
