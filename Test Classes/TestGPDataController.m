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
    NSError *error = nil;
    
    GHAssertFalse([dataController fetchAllPostsWithError:&error],nil);
    GHAssertEqualStrings([error domain], GPDataControllerErrorDomain, nil);
    GHAssertEquals([error code], GPDataControllerErrorNoDelegate, nil);
    
    
    GHAssertFalse([dataController startFetchWithHTTPRequest:nil andError:&error], nil);
    GHAssertEqualStrings([error domain], GPDataControllerErrorDomain, nil);
    GHAssertEquals([error code], GPDataControllerErrorNoDelegate, nil);
}

- (void)testNoLogin {
    
    NSError *error = nil;
    
    id dataControllerDelegate = [OCMockObject mockForProtocol:@protocol(GPDataControllerDelegate)];    
    dataController.delegate = dataControllerDelegate;

    GHAssertFalse([dataController fetchAllPostsWithError:&error], nil);
    GHAssertEqualStrings([error domain], GPDataControllerErrorDomain, nil);
    GHAssertEquals([error code], GPDataControllerErrorNoLogin, nil);
    
    [dataControllerDelegate verify];
}

- (void)testNoPassword {
    
    NSError *error = nil;
    
    id dataControllerDelegate = [OCMockObject mockForProtocol:@protocol(GPDataControllerDelegate)];
    dataController.delegate = dataControllerDelegate;
    dataController.login = @"login";
    
    GHAssertFalse([dataController fetchAllPostsWithError:&error], nil);
    GHAssertEqualStrings([error domain], GPDataControllerErrorDomain, nil);
    GHAssertEquals([error code], GPDataControllerErrorNoPassword, nil);
    
    [dataControllerDelegate verify];
    
}

- (void)testStartNotifications {
    id mock = [OCMockObject observerMock];
    [[NSNotificationCenter defaultCenter] addMockObserver:mock name:GPDataControllerFetchDidBegin object:nil];
    [[mock expect] notificationWithName:GPDataControllerFetchDidBegin object:[OCMArg any]];
    
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(GPDataControllerDelegate)];
    
    dataController.delegate = mockDelegate;
    dataController.login = @"login";
    dataController.password = @"password";
    [dataController fetchAllPostsWithError:nil];
    
    [mock verify];
    [mockDelegate verify];
}

- (void)testStartHTTPUpdates {
    /*
    id mockRequest = [OCMockObject mockForClass:[ASIHTTPRequest class]];
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(GPDataControllerDelegate)];

    
    dataController.delegate = mockDelegate;
    dataController.login = @"login";
    dataController.password = @"password";
    [dataController fetchAllPostsWithError:nil];
    
    [mockRequest verify];
    [mockDelegate verify];
     */
    GHAssertTrue(NO, @"will alway fail");
}

- (void)testRequestSuccess {
    id mockRequest = [OCMockObject mockForClass:[ASIHTTPRequest class]];
    [[mockRequest expect] responseString];
    
    [dataController requestFinished:mockRequest];
    
    [mockRequest verify];
}

- (void)testRequestFail {
    GHAssertTrue(NO, @"will alway fail");
}
 
@end
