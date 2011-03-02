//
//  TestAPI.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/28/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "GPDataController.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"

@interface TestAPI : GHTestCase {
@private
    GPDataController *dataController;
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
    dataController = [[GPDataController alloc] init];
}

- (void)tearDown {
    [dataController release];
    dataController = nil;
}

#if 1

- (void)testHash {
    NSString *inputPassword = @"password";
    
    NSString *testHash = @"sQnzu7wkTrgkQZF+0G1hi5AI3Qmzvv0bXgc5THBqi7mAsdd4Xll27ASbRt9fEyavWi6m0QP9B8lThf+rDKy8hg==";
    NSString *actualHash = [GPDataController hashString:inputPassword];
    
    GHAssertEqualStrings(testHash, actualHash, nil);
}

- (void)testGetHash {
    NSString *inputValue = @"test string";
    
    ASIHTTPRequest *request = [GPDataController hashRequestWithValue:inputValue urlEncode:NO];
    [request startSynchronous];
    NSError *error = [request error];
    NSString *response = nil;
    if (!error) {
        // The response is not valid JSON, don't try to parse it.
        response = [request responseString];
        response = [response stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        response = [response stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    }
    
    
    NSString *myHash = [GPDataController hashString:inputValue];
    
    GHAssertEqualStrings(response, myHash, nil);
}

- (void)testUserGet {
    
    ASIHTTPRequest *request = [GPDataController userWithUsername:login andPassword:password];
    [request startSynchronous];
    NSError *error = [request error];
    NSString *response = nil;
    if (!error) {
        response = [request responseString];
    } else {
        NSLog(@"%@", error);
    }
    
    NSDictionary *jsonResponse = [response JSONValue];
    
    
    GHAssertEqualStrings([testUser objectForKey:@"FirstName"], [jsonResponse objectForKey:@"FirstName"], nil);
    GHAssertEqualStrings([testUser objectForKey:@"FullName"], [jsonResponse objectForKey:@"FullName"], nil);
    GHAssertEqualStrings([testUser objectForKey:@"LastName"], [jsonResponse objectForKey:@"LastName"], nil);
    GHAssertEqualStrings([testUser objectForKey:@"NickName"], [jsonResponse objectForKey:@"NickName"], nil);
    GHAssertEqualStrings([testUser objectForKey:@"UserName"], [jsonResponse objectForKey:@"UserName"], nil);
    
    GHAssertTrue([[jsonResponse objectForKey:@"Authenticated"] boolValue], nil);
    GHAssertTrue([[jsonResponse objectForKey:@"UserID"] isEqualToNumber:[testUser objectForKey:@"UserID"]], nil);
}

#endif

- (void)testPosts {
    
    ASIHTTPRequest *request = [GPDataController postsWithUsername:login password:password threadID:0 postID:0 threadLimit:0];
    
    // Test pulling in all threads
    [request startSynchronous];
}

@end
