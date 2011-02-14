//
//  TestGPDataController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/13/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <CoreData/CoreData.h>
#import "GPDataController.h"
#import "GPDataController+PrivateHeader.h"
#import "GPThread.h"

@interface TestGPDataController : GHTestCase {
    
}

@end

@implementation TestGPDataController

- (void)setUpClass {
  // Run at start of all tests in the class
}

- (void)tearDownClass {
  // Run at end of all tests in the class
}

- (void)setUp {
}

- (void)tearDown {
}

- (void)testFetchAllThreads {
    NSURL *storeURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Test Database" ofType:@"sqlite"]];
    
    NSURL *modelURL = [GPDataController defaultManagedObjectModelURL];
    
    GPDataController *dataController = [[GPDataController alloc] initWithModelURL:modelURL andStoreURL:storeURL];
    NSFetchedResultsController *fetchedResults = [dataController allThreads];
    
    BOOL fetchDidComplete = [fetchedResults performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    NSArray *fetchedObjects = [fetchedResults fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    NSInteger fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, 1, nil);
    
    GPThread *thread = (GPThread *)[fetchedObjects objectAtIndex:0];
    GHAssertTrue([thread isMemberOfClass:[GPThread class]], nil);
    
    NSString *subject = thread.subject;
    GHAssertEqualStrings(subject, @"This is a thread subject", nil);
}

@end
