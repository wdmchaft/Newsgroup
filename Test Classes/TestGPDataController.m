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
#import "GPPost.h"

#define POSTID 9876 
#define THREADID 9875
#define MEMBERID 123
#define SUBJECT @"subject"
#define BODY @"this is the body of a post"
#define POSTER_NAME @"woah!"

@interface TestGPDataController : GHTestCase {
    NSURL *testStoreURL;
    NSURL *modelURL;
    GPDataController *dataController;
}

@end

@implementation TestGPDataController

- (void)cleanUpTestFiles {
    NSError *error = nil;
    if ([[NSFileManager defaultManager] removeItemAtURL:testStoreURL error:&error]) {
        NSLog(@"%@", error);
    }

}

- (void)setUpClass {
    
    testStoreURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"TestDatabase.sqlite"];
    modelURL = [GPDataController defaultManagedObjectModelURL];
    
    [testStoreURL retain];
    [modelURL retain];
    
    [self cleanUpTestFiles];
    
    // Load some dummy data
    GPDataController *dc = [[GPDataController alloc] initWithModelURL:modelURL andStoreURL:testStoreURL];
    GPPost *dummyPost = [NSEntityDescription insertNewObjectForEntityForName:[GPPost entityName] inManagedObjectContext:dc.context];
    
    dummyPost.body = BODY;
    dummyPost.isRead = [NSNumber numberWithBool:NO];
    dummyPost.memberID = [NSNumber numberWithInt:MEMBERID];
    dummyPost.postID = [NSNumber numberWithInt:POSTID];
    dummyPost.posterName = POSTER_NAME;
    dummyPost.postLevel = [NSNumber numberWithInt:1];
    dummyPost.subject = SUBJECT;
    dummyPost.threadID = [NSNumber numberWithInt:THREADID];
    dummyPost.postdate = [NSDate date];
    
    NSError *error = nil;
    if ([dc.context save:&error]) {
        NSLog(@"%@", error);
    }
    
    [dc release];
}

- (void)tearDownClass {
    [self cleanUpTestFiles];
        
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
    
    GPPost *thread = (GPPost *)[fetchedObjects objectAtIndex:0];
    GHAssertTrue([thread isMemberOfClass:[GPPost class]], nil);
        
    NSString *subject = thread.subject;
    GHAssertEqualStrings(subject, SUBJECT, nil);
}

- (void)testFetchAllPostsForThread {

    NSFetchedResultsController *fr = [dataController postsWithThreadID:[NSNumber numberWithInt:THREADID]];
    
    BOOL fetchDidComplete = [fr performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    NSArray *fetchedObjects = [fr fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    NSInteger fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, 1, nil);
    
    GPPost *post = [fetchedObjects objectAtIndex:0];
    GHAssertTrue([post isMemberOfClass:[GPPost class]], nil);
    
    GHAssertEqualStrings(post.subject, SUBJECT, nil);
    GHAssertEqualStrings(post.body, BODY, nil);
    GHAssertFalse([post.isRead boolValue], nil);

}

- (void)testFetchPostsForThreadAtPostLevel {
    NSFetchedResultsController *fr = [dataController postsWithThreadID:[NSNumber numberWithInt:THREADID] atPostLevel:[NSNumber numberWithInt:1]];
    
    BOOL fetchDidComplete = [fr performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    NSArray *fetchedObjects = [fr fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    NSInteger fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, 1, nil);
    
    for (GPPost *post in fetchedObjects) {

        GHAssertTrue([post isMemberOfClass:[GPPost class]], nil);
        
        NSInteger postLevel = [post.postLevel intValue];
        GHAssertEquals(postLevel, 1, nil);
    }
}

- (void)testFetchSinglePost {
    NSInteger postID = POSTID;
    GPPost *fetchedPost = [dataController postWithId:postID];
    NSNumber *outputPostID = fetchedPost.postID;
    
    GHAssertEquals(postID, [outputPostID intValue], nil);
}

- (void)testNoDelegate {
    NSError *error = nil;
    
    dataController.login = @"fake login";
    dataController.password = @"fake password";
    
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

- (void)testRequestSuccess {
    id mockRequest = [OCMockObject mockForClass:[ASIHTTPRequest class]];
    [[mockRequest expect] responseString];
    
    [dataController requestFinished:mockRequest];
    
    [mockRequest verify];
}
 
@end
