//
//  TestPostLoadOperation.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "PostLoadOperation.h"
#import "DataController.h"
#import "JKConstants.h"

@interface TestPostLoadOperation : GHTestCase {
    PostLoadOperation *postLoadOperation;
}

@end

@implementation TestPostLoadOperation



- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    postLoadOperation = [[PostLoadOperation alloc] init];
}

- (void)tearDown {
    [postLoadOperation release];
}

- (void)testDateConversion {
    NSString *paveyDateString = @"/Date(1299282285000-0700)/";
    NSString *myDateString = @"03-04-2011 16:44:45";
    
    NSDate *paveyDate = [PostLoadOperation convertToDate:paveyDateString];
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"MM'-'dd'-'yyyy HH':'mm':'ss"];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-0700"]];
    NSDate *myDate = [myDateFormatter dateFromString:myDateString];
    [myDateFormatter release]; 
    
    GHAssertTrue([paveyDate isEqualToDate:myDate], nil);
}

- (void)testAddPostsFromArray {
    NSArray *testArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"newsgroup_posts_cleaned" ofType:@"plist"]];
    
    PostLoadOperation *postLoad = [[PostLoadOperation alloc] init];
    
    // Create the context
    NSURL *testStoreURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"TestPostLoadOperation.sqlite"];
    NSURL *modelURL = [DataController defaultManagedObjectModelURL];

    // We're loading 15 threads
    NSInteger loadCount = 15;

    
    // Remove the old persistant store
    MAKE_ERROR;
    if (![[NSFileManager defaultManager] removeItemAtURL:testStoreURL error:&error]) {
        NSLog(@"%@", error);
    }
    
    // Do a full fetch, the number of posts in the context should be the same as what was passed in.
    DataController *dataController = [[DataController alloc] initWithModelURL:modelURL andStoreURL:testStoreURL];
    NSFetchedResultsController *fetchedResults = [dataController allThreads];
    BOOL fetchDidComplete = [fetchedResults performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    NSArray *fetchedObjects = [fetchedResults fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    NSInteger fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, 0, nil);
    
    [postLoad addPostsFromArray:testArray toContext:dataController.context];
    BOOL didSave = [dataController.context save:&error];
    GHAssertTrue(didSave, nil);
    fetchedResults = [dataController allThreads];
    
    fetchDidComplete = [fetchedResults performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    fetchedObjects = [fetchedResults fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, loadCount, nil); //todo: I'm counting the number of posts loaded and comparing it against the number of *threads* returned. They should usually not match!
    
    // Add the posts to the context again, then do a full fetch. The results shouldn't change.
    [postLoad addPostsFromArray:testArray toContext:dataController.context];
    GHAssertTrue([dataController.context save:nil], nil);
    fetchedResults = [dataController allThreads];
    
    fetchDidComplete = [fetchedResults performFetch:nil];
    GHAssertTrue(fetchDidComplete, nil);
    
    fetchedObjects = [fetchedResults fetchedObjects];
    GHAssertNotNil(fetchedObjects, nil);
    
    fetchCount = [fetchedObjects count];
    GHAssertEquals(fetchCount, loadCount, nil);
    
    [postLoad release];

    
    // Test the parent/child relationship
    Post *parentPost = [dataController postWithId:[NSNumber numberWithInt:29333]];
    
    GHAssertNil(parentPost.parentPost, nil);
    NSUInteger childCount = [parentPost.childPosts count];
    GHAssertTrue(childCount == 2, nil);
}


@end
