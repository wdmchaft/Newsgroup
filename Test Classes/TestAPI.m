//
//  TestAPI.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/28/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "DataController.h"
#import "RequestGenerator.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"

@interface TestAPI : GHTestCase {
@private
    DataController *dataController;
    NSString *login;
    NSString *password;
    NSDictionary *testUser;
}

- (NSString *)runASIRequest:(ASIHTTPRequest *)request;

@end


@implementation TestAPI

- (NSString *)runASIRequest:(ASIHTTPRequest *)request {
    [request startSynchronous];
    NSError *error = [request error];

    if (error) {
        GHAssertTrue(NO, @"Request failed with error: %@", error);
        return nil;
    }
    
    return [request responseString];
}

- (BOOL)shouldRunOnMainThread {
    return NO;
}

- (void)setUpClass {
    NSDictionary *loginPassword = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"login" ofType:@"plist"]];
    
    login = [loginPassword objectForKey:@"login"];
    password = [loginPassword objectForKey:@"password"];
    
    [login retain];
    [password retain];

    testUser = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TestUser" ofType:@"plist"]];
    [testUser retain];
}

- (void)tearDownClass {
    [login release];
    [password release];
    
    [testUser release];
    testUser = nil;
}

- (void)setUp {
    dataController = [[DataController alloc] init];
}

- (void)tearDown {
    [dataController release];
    dataController = nil;
}

#if 1

//- (void)testPostNewThread {
//    NSString *subject = @"Testing posting";
//    NSString *body = @"I'll need to delete this";
//    
//    ASIHTTPRequest *request = [RequestGenerator addPostForUser:login password:password subject:subject body:body inReplyTo:nil];
//
//    NSString *response = [self runASIRequest:request];
//    NSInteger newPostID = [response integerValue];
//    
//    GHAssertNotEquals(newPostID, 0, nil);
//}

- (void)testHash {
    NSString *inputPassword = @"password";
    
    NSString *testHash = @"sQnzu7wkTrgkQZF+0G1hi5AI3Qmzvv0bXgc5THBqi7mAsdd4Xll27ASbRt9fEyavWi6m0QP9B8lThf+rDKy8hg==";
    NSString *actualHash = [DataController hashString:inputPassword];
    
    GHAssertEqualStrings(testHash, actualHash, nil);
    
    inputPassword = @"woah!";
    testHash = @"b3WWq1HOp7UOvKdB5Dvt7dBTV1ktmJMKi3sZSp52cciSH9VttPCNmExll2j+0oAWrqDVBnvnbBYs+/f37w0WUA==";
    actualHash = [DataController hashString:inputPassword];
    
    GHAssertEqualStrings(testHash, actualHash, nil);
    
    inputPassword = @"This is A S8P$R S#4U&RE P455+WO)(RD";
    testHash = @"5CZ3nBaCHt+YJhzvbjfnt8vm1tQOhu8KevqfpV5FWKZidZREEae5DvJmJs8AwKbqxmliBu4v/9hEYZg5650iMw==";
    actualHash = [DataController hashString:inputPassword];
    
    GHAssertEqualStrings(testHash, actualHash, nil);

}

- (void)testGetHash {
    NSString *inputValue = @"test string";
    
    ASIHTTPRequest *request = [RequestGenerator hashRequestWithValue:inputValue urlEncode:NO];
    
    NSString *response = [self runASIRequest:request];

    // The response is not valid JSON, don't try to parse it.
    response = [request responseString];
    response = [response stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    response = [response stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    
    NSString *myHash = [DataController hashString:inputValue];
    
    GHAssertEqualStrings(response, myHash, nil);
}

- (void)testUserGet {
    
    ASIHTTPRequest *request = [RequestGenerator userWithUsername:login andPassword:password];

    NSString *response = [self runASIRequest:request];
    
    NSDictionary *jsonResponse = [response JSONValue];
    
    GHAssertEqualStrings([testUser objectForKey:@"FirstName"], [jsonResponse objectForKey:@"FirstName"], nil);
    GHAssertEqualStrings([testUser objectForKey:@"FullName"], [jsonResponse objectForKey:@"FullName"], nil);
    GHAssertEqualStrings([testUser objectForKey:@"LastName"], [jsonResponse objectForKey:@"LastName"], nil);
    GHAssertEqualStrings([testUser objectForKey:@"NickName"], [jsonResponse objectForKey:@"NickName"], nil);
    GHAssertEqualStrings([testUser objectForKey:@"UserName"], [jsonResponse objectForKey:@"UserName"], nil);
    
    GHAssertTrue([[jsonResponse objectForKey:@"Authenticated"] boolValue], nil);
    GHAssertTrue([[jsonResponse objectForKey:@"UserID"] isEqualToNumber:[testUser objectForKey:@"UserID"]], nil);
}

//- (void)testPosts {
//    
//    ASIHTTPRequest *request = [DataController postsWithUsername:login password:password threadID:0 postID:0 threadLimit:0];
//    
//    // Test pulling in all threads
//    NSString *response = [self runASIRequest:request];
//    NSArray *allThreads = (NSArray *)[response JSONValue];
//    NSInteger allThreadCount = [allThreads count];
//    GHAssertNotNULL((void *)allThreadCount, nil);
//    
//    // Test pulling in a single thread
//    NSNumber *threadId = [[allThreads objectAtIndex:0] objectForKey:@"ThreadID"];
//    GHAssertNotNULL(threadId, nil);
//    
//    request = [DataController postsWithUsername:login password:password threadID:[threadId intValue] postID:0 threadLimit:0];
//    response = [self runASIRequest:request];
//    
//    NSArray *postsInThread = [response JSONValue];
//    GHAssertNotNULL(postsInThread, nil);
//    
//    NSInteger postsInThreadCount = [postsInThread count];
//    GHAssertLessThan(postsInThreadCount, allThreadCount, nil);
//    
//    // Test pulling in a single post
//    NSNumber *postId = [[postsInThread objectAtIndex:0] objectForKey:@"PostID"];
//    GHAssertNotNULL(postId, nil);
//    
//    request = [DataController postsWithUsername:login password:password threadID:0 postID:[postId intValue] threadLimit:0];
//    response = [self runASIRequest:request];
//    
//    NSArray *singlePost = [response JSONValue];
//    GHAssertNotNULL(singlePost, nil);
//    GHAssertTrue(1 == [singlePost count], nil);
//}

#endif

@end
