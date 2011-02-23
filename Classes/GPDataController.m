//
//  GPDataController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "GPDataController.h"
#import "GPDataController+PrivateHeader.h"

NSString *const GPHTTPRequestDidBegin = @"GPHTTPRequestDidBegin";
NSString *const GPHTTPRequestDidEnd = @"GPHTTPRequestDidEnd";

@interface GPDataController()

// Private methods

// Private properties
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) GPHTTPOperation *httpController;
@property (readwrite, retain) NSDate *lastFetchTime;
@property (retain, nonatomic) NSManagedObjectModel *model;

@end


@implementation GPDataController

#pragma mark -
#pragma mark Class Methods

+ (NSURL *)defaultManagedObjectModelURL {
    return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Newsgroup" ofType:@"momd"]];
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
        
    }
    return self;
}

- (void)dealloc {
    [context_ release];
    [httpController_ release];
    [lastFetchTime_ release];
    [model_ release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

@synthesize context = context_;
@synthesize delegate = delegate_;
@synthesize httpController = httpController_;
@synthesize lastFetchTime = lastFetchTime_;
@synthesize model = model_;

#pragma mark -
#pragma mark Instance Methods

#pragma mark Begin and End Fetching

- (BOOL)isFetching {
    // Since we're loading data from a plist synchronously, we're never actually "fetching"
    return NO;
}

- (void)startFetching {
    
    GPHTTPOperation *httpController = [[GPHTTPOperation alloc] initWithDelegate:self];
    [self startFetchWithHTTPController:httpController];
    self.httpController = httpController;
    [httpController release];
    
    // TODO: Remove all this crap
    /*
    NSString *testDataPath = [[NSBundle mainBundle] pathForResource:@"TestData" ofType:@"plist"];
    NSArray *testArray = [NSArray arrayWithContentsOfFile:testDataPath];
    
    NSEntityDescription *postEntity = [[self.model entitiesByName] objectForKey:[GPPost entityName]];
    for (NSDictionary *post in testArray) {
        GPPost *postObject = [[GPPost alloc] initWithEntity:postEntity insertIntoManagedObjectContext:self.context];
        
        postObject.body = @"No descriptions <em>loaded</em> <a href=\"http://google.com\">yet</a>";
        postObject.isRead = [post objectForKey:@"Read"];
        postObject.memberID = [post objectForKey:@"MemberID"];
        postObject.postdate = [post objectForKey:@"PostDate"];
        postObject.posterName = [post objectForKey:@"PosterName"];
        postObject.postID = [post objectForKey:@"PostID"];
        postObject.postLevel = [post objectForKey:@"PostLevel"];
        postObject.subject = [post objectForKey:@"Subject"];
        postObject.threadID = [post objectForKey:@"ThreadID"];
    }
 
    [self.context save:nil];
     */
}

- (void)startFetchWithHTTPController:(GPHTTPOperation *)controller {
    // File notification
    [[NSNotificationCenter defaultCenter] postNotificationName:GPHTTPRequestDidBegin object:self];
    
    // Start the fetch
    [controller beginFetching];
    
    //FIXME:
    // Since our controller doesn't actually do anything yet, just call the didFinish method.
    [self fetchSucceded:nil withResults:nil];
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
#pragma mark GPHTTPControllerDelegate Methods

- (void)fetchFailed:(GPHTTPOperation *)controller withError:(NSError *)error {
    
    // Send the notification
    [[NSNotificationCenter defaultCenter] postNotificationName:GPHTTPRequestDidEnd object:self];
    
    // Tell the delegate
    id <GPDataControllerDelegate> delegate = self.delegate;
    if (delegate) {
        [delegate fetchFailed:self withError:error];
    }
}

- (void)fetchSucceded:(GPHTTPOperation *)controller withResults:(NSData *)data {
    
    // Send the notification
    [[NSNotificationCenter defaultCenter] postNotificationName:GPHTTPRequestDidEnd object:self];
    
    // Notify the delegate
    id delegate = self.delegate;
    if (delegate) {
        [delegate fetchSucceded:self];
    }
    
    // Set the last fetch date
    self.lastFetchTime = [NSDate date];
}

@end
