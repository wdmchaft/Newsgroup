#import <GHUnitIOS/GHUnit.h>
#import "RequestGenerator.h"
#import "DataController.h"
#import "ASIHTTPRequest.h"

@interface TestRequestGenerator : GHTestCase {
@private
    NSString *username;
    NSString *password;
    NSNumber *postID;
    NSString *subject;
    NSString *body;
}
@end

@implementation TestRequestGenerator

- (void)setUp {
    username = [@"username" retain];
    password = [@"password" retain];
    postID = [[NSNumber numberWithInt:1235] retain];
    subject = [@"subject has some spaces and <> crap" retain];
    body = [@"body \n ?&2@**23 woah!\n\t\r" retain];
}

- (void)tearDown {
    [username release];
    username = nil;
    
    [password release];
    password = nil;
    
    [postID release];
    postID = nil;
    
    [subject release];
    subject = nil;
    
    [body release];
    body = nil;
}


- (void)testGenerateMarkPostAsReadRequest {
    ASIHTTPRequest *request;
    
    GHAssertThrows([RequestGenerator markPostAsRead:nil username:nil password:nil], nil);
    GHAssertThrows([RequestGenerator markPostAsRead:postID username:nil password:nil], nil);
    GHAssertThrows([RequestGenerator markPostAsRead:postID username:username password:nil], nil);
    GHAssertNoThrow(request = [RequestGenerator markPostAsRead:postID username:username password:password], nil);
    GHAssertNotNil(request, nil);
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.greenpride.com/Service.svc/PostMarkAs?UserName=%@&Password=%@&Read=True&PostID=%@&format=json", username, [DataController hashString:password], postID];
    NSURL *targetURL = [NSURL URLWithString:urlString];
    NSURL *testURL = [request url];
    
    GHAssertEqualObjects(targetURL, testURL, nil);
}

- (void)testGenerateMakePost {
    
    ASIHTTPRequest *request;
    NSString *urlString;
    NSURL *targetURL;
    NSString *hashedPassword = [DataController hashString:password];
    
    GHAssertThrows([RequestGenerator addPostForUser:nil password:nil subject:nil body:nil inReplyTo:nil], nil);
    GHAssertThrows([RequestGenerator addPostForUser:username password:nil subject:nil body:nil inReplyTo:nil], nil);
    
    // Just the username and password
    request = [RequestGenerator addPostForUser:username password:password subject:nil body:nil inReplyTo:nil];
    GHAssertNotNil(request, nil);
    urlString = [NSString stringWithFormat:@"https://api.greenpride.com/Service.svc/PostAdd?UserName=%@&Password=%@&Subject=%@&Description=%@&ReplyToID=%i&format=json", username, hashedPassword, @"", @"", 0];
    targetURL = [NSURL URLWithString:urlString];
    GHAssertEqualObjects(targetURL, [request url], nil);
    
    // Username, password and subject
    request = [RequestGenerator addPostForUser:username password:password subject:subject body:nil inReplyTo:nil];
    GHAssertNotNil(request, nil);
    urlString = [NSString stringWithFormat:@"https://api.greenpride.com/Service.svc/PostAdd?UserName=%@&Password=%@&Subject=%@&Description=%@&ReplyToID=%i&format=json", username, hashedPassword, [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], @"", 0];
    targetURL = [NSURL URLWithString:urlString];
    GHAssertEqualObjects(targetURL, [request url], nil);
    
    // Username, password, subject, body
    request = [RequestGenerator addPostForUser:username password:password subject:subject body:body inReplyTo:nil];
    GHAssertNotNil(request, nil);
    urlString = [NSString stringWithFormat:@"https://api.greenpride.com/Service.svc/PostAdd?UserName=%@&Password=%@&Subject=%@&Description=%@&ReplyToID=%i&format=json", username, hashedPassword, [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 0];
    targetURL = [NSURL URLWithString:urlString];
    GHAssertEqualObjects(targetURL, [request url], nil);
    
    // Username, password, subject, body and replyToID
    request = [RequestGenerator addPostForUser:username password:password subject:subject body:body inReplyTo:postID];
    GHAssertNotNil(request, nil);
    urlString = [NSString stringWithFormat:@"https://api.greenpride.com/Service.svc/PostAdd?UserName=%@&Password=%@&Subject=%@&Description=%@&ReplyToID=%i&format=json", username, hashedPassword, [subject stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [postID intValue]];
    targetURL = [NSURL URLWithString:urlString];
    GHAssertEqualObjects(targetURL, [request url], nil);
}


@end
