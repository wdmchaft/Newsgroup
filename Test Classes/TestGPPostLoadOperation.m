//
//  TestGPPostLoadOperation.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "GPPostLoadOperation.h"

@interface TestGPPostLoadOperation : GHTestCase {
    GPPostLoadOperation *postLoadOperation;
}

@end

@implementation TestGPPostLoadOperation



- (void)setUpClass {
}

- (void)tearDownClass {
}

- (void)setUp {
    postLoadOperation = [[GPPostLoadOperation alloc] init];
}

- (void)tearDown {
    [postLoadOperation release];
}

- (void)testDateFormatter {
    NSString *inputDateString = @"2009-06-21T05:45:13Z";
    NSString *inputDate = @"06-21-2009 05:45:13";
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setDateFormat:@"MM'-'dd'-'yyyy HH':'mm':'ss"];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *myDate = [myDateFormatter dateFromString:inputDate];
    
    NSDate *testDate = [[postLoadOperation dateFormatter] dateFromString:inputDateString];
    
    GHAssertTrue([testDate isEqualToDate:myDate], @"%@ and %@ do not match", testDate, myDate);
}

- (void)testAddPostsFromArray {
    GHAssertTrue(NO, nil);
}


@end
