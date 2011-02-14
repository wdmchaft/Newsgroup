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
    NSURL *testStoreURL;
    NSURL *modelURL;
    GPDataController *dataController;
}

@end

@implementation TestGPDataController

- (GPThread *)getTestThread {
    GPDataController *dc = [[GPDataController alloc] initWithModelURL:modelURL andStoreURL:testStoreURL];
    NSFetchedResultsController *fr = [dc allThreads];
    [dc release];
    return (GPThread *)[[fr fetchedObjects] objectAtIndex:0];
}

- (void)setUpClass {
    testStoreURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Test Database" ofType:@"sqlite"]];
    modelURL = [GPDataController defaultManagedObjectModelURL];
    
    [testStoreURL retain];
    [modelURL retain];
}

- (void)tearDownClass {
    [testStoreURL release];
    [modelURL release];
}

- (void)setUp {
    dataController = [[GPDataController alloc] initWithModelURL:modelURL andStoreURL:testStoreURL];
}

- (void)tearDown {
    [dataController release];

}

- (void)testFetchAllThreads {
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

- (void)testFetchAllPostsForThread {
    GPThread *thread = [self getTestThread];
    NSFetchedResultsController *fr = [dataController postsInThread:thread];
    
    BOOL fetchDidComplete = [fr performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    NSArray *fetchedObjects = [fr fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    NSInteger fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, 1, nil);
    
    GPPost *post = (GPPost *)[fetchedObjects objectAtIndex:0];
    GHAssertTrue([post isMemberOfClass:[GPPost class]], nil);
    
    GHAssertEqualStrings(post.subject, @"This is a subject", nil);
    GHAssertEqualStrings(post.body, @"This is a body.", nil);
    GHAssertFalse([post.isRead boolValue], nil);
}

@end
