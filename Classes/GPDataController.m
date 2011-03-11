//
//  GPDataController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "GPDataController.h"
#import "JSON.h"
#import "NSString+Digest.h"
#import "GPPostLoadOperation.h"

NSString *const GPDataControllerFetchDidBegin = @"GPHTTPRequestDidBegin";
NSString *const GPDataControllerFetchDidEnd = @"GPHTTPRequestDidEnd";

NSString *const GPDataControllerErrorDomain = @"GPDataControllerErrorDomain";

NSString *const GPDataControllerLastFetchTime = @"GPDataControllerLastFetchTime";


NSString *const GPDataControllerNoUsernameException = @"GPDataControllerNoUsernameException";
NSString *const GPDataControllerNoPasswordException = @"GPDataControllerNoPasswordException";
NSString *const GPDataControllerNoPostIDException = @"GPDataControllerNoPostIDException";

#define BASE_URL_STRING @"https://api.greenpride.com/Service.svc/"
#define REPLY_FORMAT @"format=json"

@interface GPDataController()

// Private methods
- (NSUInteger)error:(NSError **)error withErrorCode:(GPDataControllerErrorCode)code;

// Private properties
@property (readwrite, retain) NSDate *lastFetchTime;
@property (retain, nonatomic) NSManagedObjectModel *model;

@end


@implementation GPDataController

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
    NSAssert(template != nil, @"%@", error);
    
    return [template stringByReplacingOccurrencesOfString:@"<%body_text%>" withString:body];
}

+ (ASIHTTPRequest *)hashRequestWithValue:(NSString *)value urlEncode:(BOOL)shouldEncode {
    // Build the URL
    NSString *urlPath = [NSString stringWithFormat:@"%@Hash?Value=%@&URLEncode=%@&%@", BASE_URL_STRING, value, shouldEncode ? @"True" : @"False", REPLY_FORMAT];
    urlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlPath]];
}

+ (ASIHTTPRequest *)markPostAsRead:(NSNumber *)postID username:(NSString *)username password:(NSString *)password {
    NSException *e = nil;
    
    if (postID == nil) {
        e = [NSException exceptionWithName:GPDataControllerNoPostIDException reason:@"This method must take a postID as input" userInfo:nil];
    } else if (username == nil) {
        e = [NSException exceptionWithName:GPDataControllerNoUsernameException reason:@"This method must take a username as input" userInfo:nil];
    } else if (password == nil) {
        e = [NSException exceptionWithName:GPDataControllerNoPasswordException reason:@"This method must take a password as input" userInfo:nil];
    }
    
    if (e) {
        @throw e;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.greenpride.com/Service.svc/PostMarkAs?UserName=%@&Password=%@&Read=True&PostID=%@&format=json", username, [GPDataController hashString:password], postID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [ASIHTTPRequest requestWithURL:url];
}

+ (ASIHTTPRequest *)userWithUsername:(NSString *)username andPassword:(NSString *)password {

    NSMutableString *urlPath = [NSMutableString stringWithFormat:@"%@UserGet?UserName=%@", BASE_URL_STRING, username];
    if (password) {
        [urlPath appendFormat:@"&Password=%@", [GPDataController hashString:password]];
    }
    [urlPath appendFormat:@"&%@", REPLY_FORMAT];
    
    NSURL *url = [NSURL URLWithString:[urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [ASIHTTPRequest requestWithURL:url];
    
}

+ (ASIHTTPRequest *)postsWithUsername:(NSString *)username password:(NSString *)password threadID:(NSInteger)threadID postID:(NSInteger)postID threadLimit:(NSInteger)threadLimit {

    NSMutableString *urlPath = [NSMutableString stringWithFormat:@"%@Posts?UserName=%@&Password=%@", BASE_URL_STRING, username, [GPDataController hashString:password]];
    
    // If you pass a '0' for any of these values then that value is ignored.
    //  i.e. '0' for the thread ID pulls in all threads
    [urlPath appendFormat:@"&ThreadID=%i", threadID];
    [urlPath appendFormat:@"&PostID=%i", postID];
    [urlPath appendFormat:@"&ThreadLimit=%i", threadLimit];
    [urlPath appendFormat:@"&%@", REPLY_FORMAT];

    NSURL *url = [NSURL URLWithString:[urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [ASIHTTPRequest requestWithURL:url];
}

#pragma mark -
#pragma mark Object lifecycle

- (id)init {
    
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"Newsgroup.sqlite"];
    
    NSURL *modelURL = [GPDataController defaultManagedObjectModelURL];
    
    return [self initWithModelURL:modelURL andStoreURL:storeURL];
}

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
        
        // Setup the Operation Queue
        operationQueue_ = [[NSOperationQueue alloc] init];
        [operationQueue_ setName:@"GPDataController queue"];
        
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
    
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

@synthesize context = context_;
@synthesize delegate = delegate_;
@synthesize login = login_;
@synthesize model = model_;
@synthesize password = password_;

- (void)setLastFetchTime:(NSDate *)lastFetchTime {
    [[NSUserDefaults standardUserDefaults] setObject:lastFetchTime forKey:GPDataControllerLastFetchTime];
}

- (NSDate *)lastFetchTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:GPDataControllerLastFetchTime];
}

#pragma mark -
#pragma mark Instance Methods

- (BOOL)markPostAsRead:(NSNumber *)postID {
    ASIHTTPRequest *request = [GPDataController markPostAsRead:postID username:self.login password:self.password];
    [request setDelegate:self];
    
    [operationQueue_ addOperation:request];
    return YES;
}

#pragma mark Begin and End Fetching

- (BOOL)isFetching {
    // Since we're loading data from a plist synchronously, we're never actually "fetching"
    return NO;
}

- (BOOL)fetchAllPostsWithError:(NSError **)error {
    
    // Check for a login and password
    if (!self.login) {
        [self error:error withErrorCode:GPDataControllerErrorNoLogin];
        return NO;
    }
    if (!self.password) {
        [self error:error withErrorCode:GPDataControllerErrorNoPassword];
        return NO;
    }
    
    ASIHTTPRequest *request = [GPDataController postsWithUsername:self.login password:self.password threadID:0 postID:0 threadLimit:0];
    [request setDelegate:self];
    [request setDownloadProgressDelegate:self];
    
    return [self startFetchWithHTTPRequest:request andError:error];
}

- (NSUInteger)error:(NSError **)error withErrorCode:(GPDataControllerErrorCode)code {
    if (error != NULL) {
        
        NSDictionary *userInfo;
        NSString *description;
        NSString *failureReason;
        
        switch (code) {
                
            case GPDataControllerErrorNoDelegate:
                description = NSLocalizedString(@"No Delegate", nil);
                failureReason = NSLocalizedString(@"GPDataController must have a delegate set", nil);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, failureReason, NSLocalizedFailureReasonErrorKey, nil];
                break;
                
            case GPDataControllerErrorNoLogin:
                description = NSLocalizedString(@"No Username", nil);
                failureReason = NSLocalizedString(@"GPDataController must have a username set before attempting a fetch", nil);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, failureReason, NSLocalizedFailureReasonErrorKey, nil];
                break;
                
            case GPDataControllerErrorNoPassword:
                description = NSLocalizedString(@"No Password", nil);
                failureReason = NSLocalizedString(@"GPDataController must have a password set before attempting a fetch", nil);
                userInfo = [NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, failureReason, NSLocalizedFailureReasonErrorKey, nil];
                break;
        }
        
        *error = [[[NSError alloc] initWithDomain:GPDataControllerErrorDomain code:code userInfo:userInfo] autorelease];
    }
    return 0;
}

- (void)loadNewPosts:(NSArray *)posts intoContext:(NSManagedObjectContext *)context {
    GPPostLoadOperation *postLoad = [[GPPostLoadOperation alloc] init];
    if ( [postLoad addPostsFromArray:posts toContext:context] ) {
        // Update the last fetch time
        self.lastFetchTime = [NSDate date];
        
        // send notification that we're finished
        [[NSNotificationCenter defaultCenter] postNotificationName:GPDataControllerFetchDidEnd object:self];
        
        // let delegate know
        [self.delegate fetchSucceded:self];
    } else {
        NSAssert(YES, @"Construct some sort of error here");
    }
    [postLoad release];
}

- (BOOL)startFetchWithHTTPRequest:(ASIHTTPRequest *)request andError:(NSError **)error {
    
    // Assure that we have got a delegate
    if (!self.delegate) {
        [self error:error withErrorCode:GPDataControllerErrorNoDelegate];
        return NO;
    }    
    
    // Post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:GPDataControllerFetchDidBegin object:self];
    
    // Add to queue
    [operationQueue_ addOperation:request];
    
    return YES;
}

- (void)stopFetching {
    
}

#pragma mark FetchedResultsControllers

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
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:NO];
    NSArray *sortArray = [NSArray arrayWithObject:sortDescriptor];
    [sortDescriptor release];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSFetchedResultsController *fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    return [fetchedResults autorelease];
}

- (GPPost *)postWithId:(NSUInteger)postID {
    
    // get the fetch request
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:postID] forKey:@"postID"];
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

#pragma mark Unread Posts

- (NSInteger)countOfUnreadPosts {
    return 0;
}

- (NSArray *)pathToNextUnreadPost {
    return nil;
}

- (NSArray *)pathToNextUnreadPostUnderPost:(GPPost *)post {
    return nil;
}

- (GPPost *)nextUnreadPost {
    return nil;
}

- (GPPost *)nextUnreadPostUnderPost:(GPPost *)post {
    return nil;
}

- (NSArray *)pathToPost:(GPPost *)post {
    return nil;
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    // Get the response string out of the request
    NSString *response = [request responseString];
    NSArray *posts = [response JSONValue];
    
    [self loadNewPosts:posts intoContext:self.context];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSLog(@"%@", [request error]);
}

#pragma ASIProgressDelegate

- (void)setProgress:(float)newProgress {
    [self.delegate setProgress:newProgress dataController:self];
}

@end
