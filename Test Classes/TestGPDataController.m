//
//  TestGPDataController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/13/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import <CoreData/CoreData.h>
#import "OCMock.h"
#import "GPDataController.h"
#import "GPDataController+PrivateHeader.h"

@interface TestGPDataController : GHTestCase {
    NSURL *testStoreURL;
    NSURL *modelURL;
    GPDataController *dataController;
}

@end

@implementation TestGPDataController



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
    GHAssertEquals(fetchCount, 5, nil);
    
    GPPost *thread = (GPPost *)[fetchedObjects objectAtIndex:0];
    GHAssertTrue([thread isMemberOfClass:[GPPost class]], nil);
        
    NSString *subject = thread.subject;
    GHAssertEqualStrings(subject, @"hrm, this sure smells like change", nil);
}

- (void)testFetchAllPostsForThread {

    NSFetchedResultsController *fr = [dataController postsWithThreadID:[NSNumber numberWithInt:1109]];
    
    BOOL fetchDidComplete = [fr performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    NSArray *fetchedObjects = [fr fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    NSInteger fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, 5, nil);
    
    GPPost *post = [fetchedObjects objectAtIndex:0];
    GHAssertTrue([post isMemberOfClass:[GPPost class]], nil);
    
    GHAssertEqualStrings(post.subject, @"that's their fault", nil);
    GHAssertEqualStrings(post.body, @"No descriptions <em>loaded</em> <a href=\"http://google.com\">yet</a>", nil);
    GHAssertFalse([post.isRead boolValue], nil);

}

- (void)testFetchPostsForThreadAtPostLevel {
    NSFetchedResultsController *fr = [dataController postsWithThreadID:[NSNumber numberWithInt:1109] atPostLevel:[NSNumber numberWithInt:2]];
    
    BOOL fetchDidComplete = [fr performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    NSArray *fetchedObjects = [fr fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    NSInteger fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, 1, nil);
    
    for (GPPost *post in fetchedObjects) {

        GHAssertTrue([post isMemberOfClass:[GPPost class]], nil);
        
        NSInteger postLevel = [post.postLevel intValue];
        GHAssertEquals(postLevel, 2, nil);
    }
}

- (void)testNoDelegate {
    GHAssertThrows([dataController fetchAllPosts],nil);
    GHAssertThrows([dataController startFetchWithHTTPRequest:nil], nil);
}

- (void)testNoLogin {
    id dataControllerDelegate = [OCMockObject mockForProtocol:@protocol(GPDataControllerDelegate)];
    [[dataControllerDelegate expect] fetchFailed:dataController withError:[OCMArg any]];
    
    dataController.delegate = dataControllerDelegate;

    [dataController fetchAllPosts];
    
    [dataControllerDelegate verify];
}

- (void)testNoPassword {
    GHAssertFalse(YES, nil);
}

- (void)testHTTPUpdates {
    GHAssertFalse(YES, nil);
}

 
@end
