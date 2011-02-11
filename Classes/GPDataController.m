//
//  GPDataController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "GPDataController.h"

@interface GPDataController()

// Private methods
- (void)setupDataController;

// Private properties
@property (retain, nonatomic) NSManagedObjectContext *context;
@property (retain, nonatomic) NSManagedObjectModel *model;

@end


@implementation GPDataController

static GPDataController *sharedDataController = nil;

#pragma mark -
#pragma mark Properties

@synthesize context = context_;
@synthesize model = model_;

#pragma mark -
#pragma mark Instance Methods

- (void)setupDataController {
    
    NSURL *storeURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"Newsgroup.sqlite"];
    
    NSError *error = nil;
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"Newsgroup" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
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
    
    NSEntityDescription *userEntity = [[self.model entitiesByName] objectForKey:@"User"];
    NSManagedObject *userObject = [[NSManagedObject alloc] initWithEntity:userEntity insertIntoManagedObjectContext:self.context];
    
    [userObject setValue:[author objectForKey:@"email"] forKey:@"email"];
    [userObject setValue:[author objectForKey:@"name"] forKey:@"name"];
    [userObject setValue:[author objectForKey:@"handle"] forKey:@"handle"];
    
    
    // Setup the threads
    NSDictionary *thread = [[testDict objectForKey:@"Threads"] objectAtIndex:0];
    NSEntityDescription *threadEntity = [[self.model entitiesByName] objectForKey:@"Thread"];
    NSManagedObject *threadObject = [[NSManagedObject alloc] initWithEntity:threadEntity insertIntoManagedObjectContext:self.context];
    
    [threadObject setValue:[thread objectForKey:@"subject"] forKey:@"subject"];
    [threadObject setValue:[thread objectForKey:@"timestamp"] forKey:@"timestamp"];
    [threadObject setValue:userObject forKey:@"author"];
    
    // Setup the posts
    NSArray *posts = [testDict objectForKey:@"Posts"];
    
    NSEntityDescription *postEntity = [[self.model entitiesByName] objectForKey:@"Post"];
    for (NSDictionary *post in posts) {
        NSManagedObject *postObject = [[NSManagedObject alloc] initWithEntity:postEntity insertIntoManagedObjectContext:self.context];
        
        [postObject setValue:[post objectForKey:@"body"] forKey:@"body"];
        [postObject setValue:[post objectForKey:@"isRead"] forKey:@"isRead"];
        [postObject setValue:[post objectForKey:@"subject"] forKey:@"subject"];
        [postObject setValue:[post objectForKey:@"timestamp"] forKey:@"timestamp"];
        [postObject setValue:userObject forKey:@"author"];
        [postObject setValue:threadObject forKey:@"thread"];
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

#pragma mark -
#pragma mark Object lifecycle methods

+ (GPDataController *)sharedDataController
{
    if (sharedDataController == nil) {
        sharedDataController = [[super allocWithZone:NULL] init];
        [sharedDataController setupDataController];
    }
    return sharedDataController;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedDataController] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}


@end
