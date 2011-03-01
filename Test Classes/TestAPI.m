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

@interface TestAPI : GHTestCase {
@private
    GPDataController *dataController;
}
@end


@implementation TestAPI


- (void)setUpClass {

}

- (void)tearDownClass {

}

- (void)setUp {
    dataController = [[GPDataController alloc] init];
}

- (void)tearDown {
    [dataController release];
    dataController = nil;
}

- (void)testHash {
    NSString *inputPassword = @"password";
    
    NSString *testHash = @"sQnzu7wkTrgkQZF%2b0G1hi5AI3Qmzvv0bXgc5THBqi7mAsdd4Xll27ASbRt9fEyavWi6m0QP9B8lThf%2brDKy8hg%3d%3d";
    NSString *actualHash = [GPDataController escapedHashForPassword:inputPassword];
    
    GHAssertEqualStrings(testHash, actualHash, nil);
}




@end
