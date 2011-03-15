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
#import "Post.h"

#define CHILD_POSTID 9876 
#define THREADID 9875
#define PARENTID 9875
#define MEMBERID 123
#define SUBJECT @"subject"
#define BODY @"this is the body of a post"
#define POSTER_NAME @"woah!"

@interface TestGPDataController : GHTestCase {
    NSURL *testStoreURL;
    NSURL *modelURL;
    GPDataController *dataController;
    
    NSInteger countOfTestPosts;
    NSInteger countOfThreads;
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
    
    Post *parentPost = [NSEntityDescription insertNewObjectForEntityForName:[Post entityName] inManagedObjectContext:dc.context];
    
    parentPost.body = BODY;
    parentPost.isRead = [NSNumber numberWithBool:YES];
    parentPost.memberID = [NSNumber numberWithInt:MEMBERID];
    parentPost.postID = [NSNumber numberWithInt:PARENTID];
    parentPost.posterName = POSTER_NAME;
    parentPost.subject = SUBJECT;
    parentPost.threadID = [NSNumber numberWithInt:THREADID];
    parentPost.postdate = [NSDate date];
    parentPost.postLevel = [NSNumber numberWithInt:1];
    parentPost.parentID = [NSNumber numberWithInt:PARENTID];
    
    Post *childPost = [NSEntityDescription insertNewObjectForEntityForName:[Post entityName] inManagedObjectContext:dc.context];
    
    childPost.body = BODY;
    childPost.isRead = [NSNumber numberWithBool:NO];
    childPost.memberID = [NSNumber numberWithInt:MEMBERID];
    childPost.postID = [NSNumber numberWithInt:CHILD_POSTID];
    childPost.posterName = POSTER_NAME;
    childPost.subject = SUBJECT;
    childPost.threadID = [NSNumber numberWithInt:THREADID];
    childPost.postdate = [NSDate date];
    childPost.parentID = parentPost.postID;
    childPost.postLevel = [NSNumber numberWithInt:2];
    
    countOfTestPosts = 2;
    countOfThreads = 1;
    
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
    GHAssertEquals(fetchCount, countOfThreads, nil);
    
    Post *thread = (Post *)[fetchedObjects objectAtIndex:0];
    GHAssertTrue([thread isMemberOfClass:[Post class]], nil);
        
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
    GHAssertEquals(fetchCount, countOfTestPosts, nil);
    
    Post *post = [fetchedObjects objectAtIndex:0];
    GHAssertTrue([post isMemberOfClass:[Post class]], nil);
    
    GHAssertEqualStrings(post.subject, SUBJECT, nil);
    GHAssertEqualStrings(post.body, BODY, nil);
    GHAssertFalse([post.isRead boolValue], nil);

}

- (void)testFetchPostsWithParentPostId {
    NSFetchedResultsController *fr = [dataController postsWithParentID:[NSNumber numberWithInt:THREADID]];
    
    BOOL fetchDidComplete = [fr performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    NSArray *fetchedObjects = [fr fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    NSInteger fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, 1, nil);
    
    for (Post *post in fetchedObjects) {

        GHAssertTrue([post isMemberOfClass:[Post class]], nil);
        GHAssertTrue([post.parentID isEqualToNumber:[NSNumber numberWithInt:PARENTID]], nil);
    }
}

- (void)testFetchSinglePost {
    NSInteger postID = CHILD_POSTID;
    Post *fetchedPost = [dataController postWithId:[NSNumber numberWithInt:postID]];
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
    
    id mockDelegate = [OCMockObject niceMockForProtocol:@protocol(GPDataControllerDelegate)];
    
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

- (void)testGenerateMarkPostAsReadRequest {
    NSNumber *postID = [NSNumber numberWithInt:1234];
    NSString *username = @"username";
    NSString *password = @"password";
    
    ASIHTTPRequest *request;
    
    GHAssertThrows([GPDataController markPostAsRead:nil username:nil password:nil], nil);
    GHAssertThrows([GPDataController markPostAsRead:postID username:nil password:nil], nil);
    GHAssertThrows([GPDataController markPostAsRead:postID username:username password:nil], nil);
    GHAssertNoThrow(request = [GPDataController markPostAsRead:postID username:username password:password], nil);
    GHAssertNotNil(request, nil);
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.greenpride.com/Service.svc/PostMarkAs?UserName=%@&Password=%@&Read=True&PostID=%@&format=json", username, [GPDataController hashString:password], postID];
    NSURL *targetURL = [NSURL URLWithString:urlString];
    NSURL *testURL = [request url];
    
    GHAssertEqualObjects(targetURL, testURL, nil);
}

-(void)testCountOfUnreadPosts {
    NSInteger expectedValue = 1;
    NSInteger actualValue = [dataController countOfUnreadPosts];
    
    GHAssertEquals(actualValue, expectedValue, nil);
}

-(void)testPathToNextUnreadPost {
    NSArray *outputArray = [dataController pathToNextUnreadPost];
    
    NSUInteger expectedCount = 2;
    NSUInteger actualCount = [outputArray count];
    GHAssertEquals(actualCount, expectedCount, nil);
    
    NSUInteger expectedFirstPostID = PARENTID;
    NSUInteger actualFirstPostID = [[[outputArray objectAtIndex:0] postID] intValue];
    GHAssertEquals(expectedFirstPostID, actualFirstPostID, nil);
    
    NSUInteger expectedSecondPostID = CHILD_POSTID;
    NSUInteger actualSecondPostID = [[[outputArray objectAtIndex:1] postID] intValue];
    GHAssertEquals(expectedSecondPostID, actualSecondPostID, nil);
}

-(void)testPathToNextUnreadPostUnderPost {
    Post *parentPost = [dataController postWithId:[NSNumber numberWithInt:PARENTID]];
    Post *childPost = [dataController postWithId:[NSNumber numberWithInt:CHILD_POSTID]];
    NSArray *outputArray = [dataController pathToNextUnreadPostUnderPost:parentPost];
    
    NSUInteger expectedCount = 2;
    NSUInteger actualCount = [outputArray count];
    GHAssertEquals(expectedCount, actualCount, nil);
    
    outputArray = [dataController pathToNextUnreadPostUnderPost:childPost];
    GHAssertNil(outputArray, nil);
}

-(void)testNextUnreadPost {
    NSUInteger expectedPostID = CHILD_POSTID;
    NSUInteger actualPostID = [[dataController nextUnreadPost].postID intValue];
    GHAssertEquals(expectedPostID, actualPostID, nil);
}

-(void)testNextUnreadPostUnderPost {
    Post *parentPost = [dataController postWithId:[NSNumber numberWithInt:PARENTID]];
    
    NSUInteger expectedPostID = CHILD_POSTID;
    NSUInteger actualPostID = [[dataController nextUnreadPostUnderPost:parentPost].postID intValue];
    GHAssertEquals(expectedPostID, actualPostID, nil);
}

-(void)testPathToPost {
    Post *childPost = [dataController postWithId:[NSNumber numberWithInt:CHILD_POSTID]];
    
    NSArray *outputArray = [dataController pathToPost:childPost];
    
    NSUInteger expectedCount = 2;
    NSUInteger actualCount = [outputArray count];
    GHAssertEquals(actualCount, expectedCount, nil);
    
    NSUInteger expectedFirstPostID = PARENTID;
    NSUInteger actualFirstPostID = [[[outputArray objectAtIndex:0] postID] intValue];
    GHAssertEquals(expectedFirstPostID, actualFirstPostID, nil);
    
    NSUInteger expectedSecondPostID = CHILD_POSTID;
    NSUInteger actualSecondPostID = [[[outputArray objectAtIndex:1] postID] intValue];
    GHAssertEquals(expectedSecondPostID, actualSecondPostID, nil);
}
 
@end
