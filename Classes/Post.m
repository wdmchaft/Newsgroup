//
//  GPPost.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/11/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "Post.h"


@implementation Post

#pragma mark Class methods
+ (NSString *)entityName {
    return @"Post";
}

#pragma mark Properties

@dynamic body;
@dynamic isRead;
@dynamic memberID;
@dynamic postdate;
@dynamic posterName;
@dynamic postID;
@dynamic subject;
@dynamic threadID;
@dynamic parentID;
@dynamic postLevel;


@end
