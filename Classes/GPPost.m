//
//  GPPost.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/11/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "GPPost.h"


@implementation GPPost

#pragma mark Class methods
+ (NSString *)entityName {
    return @"Post";
}

#pragma mark Properties

@dynamic body;
@dynamic isRead;
@dynamic subject;
@dynamic timestamp;
@dynamic author;
@dynamic thread;

@end
