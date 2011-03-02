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

NSString *const GPDataControllerFetchDidBegin = @"GPHTTPRequestDidBegin";
NSString *const GPDataControllerFetchDidEnd = @"GPHTTPRequestDidEnd";

NSString *const GPDataControllerErrorDomain = @"GPDataControllerErrorDomain";

#define BASE_URL_STRING @"https://api.greenpride.com/Service.svc/"
#define REPLY_FORMAT @"format=json"

@interface GPDataController()

// Private methods
- (void)error:(NSError **)error withErrorCode:(GPDataControllerErrorCode)code;

// Private properties
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (readwrite, retain) NSDate *lastFetchTime;
@property (retain, nonatomic) NSManagedObjectModel *model;

@end


@implementation GPDataController

#pragma mark -
#pragma mark Class Methods

+ (NSURL *)defaultManagedObjectModelURL {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Newsgroup" ofType:@"momd"]];
}

+ (NSString *)escapedHashForPassword:(NSString *)password {
    NSString *hash = [password hashWithDigestType:JKStringDigestTypeSHA512];
    
    return hash;
}

+ (ASIHTTPRequest *)hashRequestWithValue:(NSString *)value urlEncode:(BOOL)shouldEncode {
    // Build the URL
    NSString *urlPath = [NSString stringWithFormat:@"%@Hash?Value=%@&URLEncode=%@&%@", BASE_URL_STRING, value, shouldEncode ? @"True" : @"False", REPLY_FORMAT];
    urlPath = [urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlPath]];
}

+ (ASIHTTPRequest *)userWithUsername:(NSString *)username andPassword:(NSString *)password {

    NSMutableString *urlPath = [NSMutableString stringWithFormat:@"%@UserGet?UserName=%@", BASE_URL_STRING, username];
    if (password) {
        [urlPath appendFormat:@"&Password=%@", [GPDataController escapedHashForPassword:password]];
    }
    [urlPath appendFormat:@"&%@", REPLY_FORMAT];
    
    NSURL *url = [NSURL URLWithString:[urlPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return [ASIHTTPRequest requestWithURL:url];
    
}

+ (ASIHTTPRequest *)postsWithUsername:(NSString *)username password:(NSString *)password threadID:(NSInteger)threadID postID:(NSInteger)postID threadLimit:(NSInteger)threadLimit {

    NSMutableString *urlPath = [NSMutableString stringWithFormat:@"%@Posts?UserName=%@&Password=%@", BASE_URL_STRING, username, [GPDataController escapedHashForPassword:password]];
    
    [urlPath appendFormat:@"&ThreadID=%i", threadID];
    [urlPath appendFormat:@"&PostID=%i", postID];
    [urlPath appendFormat:@"&ThreadLimit=%i", threadLimit];

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
    [lastFetchTime_ release];
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
@synthesize lastFetchTime = lastFetchTime_;
@synthesize login = login_;
@synthesize model = model_;
@synthesize password = password_;

#pragma mark -
#pragma mark Instance Methods

#pragma mark Begin and End Fetching

- (BOOL)isFetching {
    // Since we're loading data from a plist synchronously, we're never actually "fetching"
    return NO;
}

- (BOOL)fetchAllPostsWithError:(NSError **)error {

    return [self startFetchWithHTTPRequest:nil andError:error];
}

- (void)error:(NSError **)error withErrorCode:(GPDataControllerErrorCode)code {
    if (error != NULL) {
        
        NSDictionary *userInfo = nil;
        switch (code) {
            case GPDataControllerErrorNoDelegate:
                // setup the userInfo dict
                break;
            case GPDataControllerErrorNoLogin:
                // userInfo
                break;
            case GPDataControllerErrorNoPassword:
                // userInfo
                break;
        }
        
        *error = [[[NSError alloc] initWithDomain:GPDataControllerErrorDomain code:code userInfo:userInfo] autorelease];
    }
}

- (void)loadNewPosts:(NSArray *)posts intoContext:(NSManagedObjectContext *)context {
    assert(@"This method needs to do something");
}

- (BOOL)startFetchWithHTTPRequest:(ASIHTTPRequest *)request andError:(NSError **)error {
    
    // Assure that we have got a delegate
    if (!self.delegate) {
        [self error:error withErrorCode:GPDataControllerErrorNoDelegate];
        return NO;
    }    
    // Check for a login and password
    if (!self.login) {
        [self error:error withErrorCode:GPDataControllerErrorNoLogin];
        return NO;
    }
    if (!self.password) {
        [self error:error withErrorCode:GPDataControllerErrorNoPassword];
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

- (NSFetchedResultsController *)postsWithThreadID:(NSNumber *)threadID atPostLevel:(NSNumber *)postLevel {
    
    // Get the fetch request
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:threadID, @"threadID", postLevel, @"postLevel", nil];
    NSFetchRequest *fetchRequest = [self.model fetchRequestFromTemplateWithName:@"postsForThreadAtLevel" substitutionVariables:dict];
    
    // Set the sort key
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postdate" ascending:NO];
    NSArray *sortArray = [NSArray arrayWithObject:sortDescriptor];
    [sortDescriptor release];
    [fetchRequest setSortDescriptors:sortArray];
    
    NSFetchedResultsController *fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:nil];
    
    return [fetchedResults autorelease];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate

- (void)requestStarted:(ASIHTTPRequest *)request {
    //NSLog(@"%c", (int)_cmd);
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    // Get the response string out of the request
    NSString *response = [request responseString];
    NSArray *posts = [response JSONValue];
    [self loadNewPosts:posts intoContext:self.context];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    //NSLog(@"%c", _cmd);
}

@end
