//
//  DataController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "DataController.h"
#import "JSON.h"
#import "NSString+Digest.h"
#import "PostLoadOperation.h"
#import "RequestGenerator.h"

// Notification Strings
NSString *const DataControllerFetchDidBegin = @"GPHTTPRequestDidBegin";
NSString *const DataControllerFetchDidEnd = @"GPHTTPRequestDidEnd";
NSString *const DataControllerNoUnreadPosts = @"DataControllerNoUnreadPosts";
NSString *const DataControllerNewUnreadPosts = @"DataControllerNewUnreadPosts";

// Data Controller Error Domain
NSString *const DataControllerErrorDomain = @"DataControllerErrorDomain";

// User Default keys
NSString *const DataControllerLastFetchTime = @"DataControllerLastFetchTime";
NSString *const DataControllerFullName = @"DataControllerFullName";
NSString *const DataControllerNickName = @"DataControllerNickName";
NSString *const DataControllerUserID = @"DataControllerUserID";

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
@property (readwrite, retain) NSDate *lastFetchTime;
@property (retain, nonatomic) NSManagedObjectModel *model;

@end


@implementation DataController

#pragma mark -
#pragma mark Properties

@synthesize context = context_;
@synthesize delegate = delegate_;
@synthesize login = login_;
@synthesize model = model_;
@synthesize password = password_;
@synthesize postAddRequests = postAddRequests_;
@synthesize postAddPosts = postAddPosts_;

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
        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
        
        self.context = managedObjectContext;
        self.model = managedObjectModel;
        
        [managedObjectModel release];
        [managedObjectContext release];
        [persistentStoreCoordinator release];
        
        // Setup postAdd Requests and posts
        self.postAddRequests = [NSMutableArray array];
        self.postAddPosts = [NSMutableArray array];
        
        // Setup the Operation Queue
        operationQueue_ = [[NSOperationQueue alloc] init];
        [operationQueue_ setName:@"DataController queue"];
        
    }
    return self;
}

- (void)dealloc {
    [context_ release];
    [login_ release];
    [model_ release];
    [password_ release];
    
    [operationQueue_ cancelAllOperations];
    [operationQueue_ waitUntilAllOperationsAreFinished];
    [operationQueue_ release];
    
    [postAddRequests_ release];
    [postAddPosts_ release];
    
    [super dealloc];
}

#pragma mark -
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
    
    __block ASIHTTPRequest *request = [RequestGenerator postsWithUsername:self.login password:self.password threadID:0 postID:0 threadLimit:0];
    [request setDownloadProgressDelegate:self];
    
    [request setCompletionBlock:^(void) {
        // Get the response string out of the request
        NSArray *posts = [[request responseString] JSONValue];
        
        [self loadNewPosts:posts intoContext:self.context];
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
        }
    }];
    
    return [self startFetchWithHTTPRequest:request andError:error];
}

- (void)stopFetching {
    
}

#pragma mark Fetch posts from the data store

- (NSFetchedResultsController *)allThreads {
    
    NSFetchRequest *fetchRequest = [self.model fetchRequestTemplateForName:@"allThreads"];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [sortDescriptor release];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
        
    return [aFetchedResultsController autorelease];
}

- (NSFetchedResultsController *)postsWithThreadID:(NSNumber *)threadID {
    
    // Get the fetch request
    NSDictionary *dict = [NSDictionary dictionaryWithObject:threadID forKey:@"threadID"];
    NSFetchRequest *fetchRequest = [self.model fetchRequestFromTemplateWithName:@"postsForThread" substitutionVariables:dict];
       
    // Set the sort key
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:NO];
    NSArray *sortArray = [NSArray arrayWithObject:sortDescriptor];
    [sortDescriptor release];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSFetchedResultsController *fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    return [fetchedResults autorelease];
}

- (NSFetchedResultsController *)postsWithParentID:(NSNumber *)parentID {
    
    // Get the fetch request
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:parentID, @"parentID", nil];
    NSFetchRequest *fetchRequest = [self.model fetchRequestFromTemplateWithName:@"postsWithParentID" substitutionVariables:dict];
    
    // Set the sort key
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:YES];
    NSArray *sortArray = [NSArray arrayWithObject:sortDescriptor];
    [sortDescriptor release];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSFetchedResultsController *fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    return [fetchedResults autorelease];
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

#pragma mark Make a new post
- (void)addPostWithSubject:(NSString *)subject body:(NSString *)body inReplyTo:(NSNumber *)postID {
    ASIHTTPRequest *request = [RequestGenerator addPostForUser:self.login password:self.password subject:subject body:body inReplyTo:postID];
    
    Post *post = [NSEntityDescription insertNewObjectForEntityForName:[Post entityName] inManagedObjectContext:self.context];
    
    post.parentID = postID;
    post.postdate = [NSDate date];
    post.isRead = [NSNumber numberWithBool:YES];
    post.subject = subject;
    post.body = body;
    
    [self addPost:post withRequest:request];
}

- (void)addPost:(Post *)post withRequest:(ASIHTTPRequest *)request {
    [self.postAddRequests addObject:request];
    [self.postAddPosts addObject:post];
    
    __block ASIHTTPRequest *bRequest = request;
    
    [bRequest setCompletionBlock:^(void) {
        NSInteger postID = [[bRequest responseString] integerValue];
        post.postID = [NSNumber numberWithInteger:postID];
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
    NSFetchRequest *fetchRequest = [self.model fetchRequestTemplateForName:@"allUnread"];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sd]];
    [sd release];
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
    [sd release];
    
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

#pragma mark -
#pragma mark Private internal methods

- (NSUInteger)error:(NSError **)error withErrorCode:(DataControllerErrorCode)code {
    if (error != NULL) {
        
        NSDictionary *userInfo;
        NSString *description;
        NSString *failureReason;
        
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
        
        *error = [[[NSError alloc] initWithDomain:DataControllerErrorDomain code:code userInfo:userInfo] autorelease];
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
    [postLoad release];
    
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
