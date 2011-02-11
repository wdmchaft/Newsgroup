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

@end


@implementation GPDataController

static GPDataController *sharedDataController = nil;

#pragma mark -
#pragma mark Properties

@synthesize context = context_;

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
    [managedObjectModel release];
}

#pragma mark Begin and End Fetching

- (BOOL)isFetching {
    // Since we're loading data from a plist synchronously, we're never actually "fetching"
    return NO;
}

- (void)startFetching {
    
    NSString *testDataPath = [[NSBundle mainBundle] pathForResource:@"TestData" ofType:@"plist"];
    NSDictionary *testDict = [NSDictionary dictionaryWithContentsOfFile:testDataPath];
    
    s
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
