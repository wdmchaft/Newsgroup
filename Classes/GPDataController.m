//
//  GPDataController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "GPDataController.h"
#import "GPDataController+PrivateHeader.h"

@interface GPDataController()

// Private methods
- (void)setupWithURL:(NSURL *)url;

// Private properties
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) NSManagedObjectModel *model;

@end


@implementation GPDataController

#pragma mark -
#pragma mark Object lifecycle

- (id)init {
    
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"Newsgroup.sqlite"];
    
    return [self initWithStoreURL:storeURL];
}

- (id)initWithStoreURL:(NSURL *)url {
    if ((self = [super init])) {
        [self setupWithURL:url];
    }
    return self;
}

- (void)dealloc {
    [context_ release];
    [model_ release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

@synthesize context = context_;
@synthesize model = model_;

#pragma mark -
#pragma mark Instance Methods

- (void)setupWithURL:(NSURL *)url {
        
    NSError *error = nil;
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Newsgroup" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL]; 
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
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

#pragma mark Begin and End Fetching

- (BOOL)isFetching {
    // Since we're loading data from a plist synchronously, we're never actually "fetching"
    return NO;
}

- (void)startFetching {
    
    NSString *testDataPath = [[NSBundle mainBundle] pathForResource:@"TestData" ofType:@"plist"];
    NSDictionary *testDict = [NSDictionary dictionaryWithContentsOfFile:testDataPath];
    
    // Setup the author
    NSDictionary *author = [testDict objectForKey:@"Author"];
    
    NSEntityDescription *userEntity = [[self.model entitiesByName] objectForKey:[GPUser entityName]];
    GPUser *user = [[GPUser alloc] initWithEntity:userEntity insertIntoManagedObjectContext:self.context];
    
    user.email = [author objectForKey:@"email"];
    user.name = [author objectForKey:@"name"];
    user.handle = [author objectForKey:@"handle"];
    
    
    // Setup the threads
    NSDictionary *threadDict = [[testDict objectForKey:@"Threads"] objectAtIndex:0];
    NSEntityDescription *threadEntity = [[self.model entitiesByName] objectForKey:[GPThread entityName]];
    GPThread *thread = [[GPThread alloc] initWithEntity:threadEntity insertIntoManagedObjectContext:self.context];
    
    thread.subject = [threadDict objectForKey:@"subject"];
    thread.timestamp = [threadDict objectForKey:@"timestamp"];
    thread.author = user;
    
    // Setup the posts
    NSArray *posts = [testDict objectForKey:@"Posts"];
    
    NSEntityDescription *postEntity = [[self.model entitiesByName] objectForKey:[GPPost entityName]];
    for (NSDictionary *post in posts) {
        GPPost *postObject = [[GPPost alloc] initWithEntity:postEntity insertIntoManagedObjectContext:self.context];
        
        postObject.body = [post objectForKey:@"body"];
        postObject.isRead = [post objectForKey:@"isRead"];
        postObject.subject = [post objectForKey:@"subject"];
        postObject.timestamp = [post objectForKey:@"timestamp"];
        postObject.author = user;
        postObject.thread = thread;
    }
 
    NSLog(@"%@", [self.context insertedObjects]);

    //[self.context save:nil];
}

- (void)stopFetching {
    
}

#pragma mark FetchedResultsControllers

- (NSFetchedResultsController *)allThreads {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Thread" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:nil cacheName:@"allThreads"];


    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
        
    return [aFetchedResultsController autorelease];
}

@end
