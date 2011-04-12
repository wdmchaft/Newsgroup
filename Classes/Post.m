//
//  GPPost.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/11/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "Post.h"
#import "NSDate+Helper.h"

@implementation Post

#pragma mark Class methods
+ (NSString *)entityName {
    return @"Post";
}

#pragma mark Instance Methods

- (void)didTurnIntoFault {
    [displayDate_ release];
    displayDate_ = nil;
}

#pragma mark Custom Properties

- (NSString *)displayDate {
    if (displayDate_ == nil) {
        displayDate_ = [NSDate stringForDisplayFromDate:self.postdate];
        [displayDate_ retain];
    }
    return displayDate_;
}

#pragma mark Managed Object Properties

@dynamic body;
@dynamic isRead;
@dynamic memberID;
@dynamic postdate;
@dynamic posterName;
@dynamic posterNickname;
@dynamic postID;
@dynamic subject;
@dynamic threadID;
@dynamic parentID;
@dynamic postLevel;

@dynamic parentPost;
@dynamic childPosts;

@end
