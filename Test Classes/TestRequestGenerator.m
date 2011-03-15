#import <GHUnitIOS/GHUnit.h>
#import "RequestGenerator.h"
#import "DataController.h"
#import "ASIHTTPRequest.h"

@interface TestRequestGenerator : GHTestCase {
@private
    
}
@end

@implementation TestRequestGenerator

- (void)testGenerateMarkPostAsReadRequest {
    NSNumber *postID = [NSNumber numberWithInt:1234];
    NSString *username = @"username";
    NSString *password = @"password";
    
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


@end
