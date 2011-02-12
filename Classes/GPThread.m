//
//  GPThread.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/11/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "GPThread.h"


@implementation GPThread

#pragma mark Class methods

+ (NSString *)entityName {
    return @"Thread";
}

#pragma mark Properties

@dynamic subject;
@dynamic timestamp;
@dynamic author;

@end
