//
//  PostHistory.m
//  Newsgroup
//
//  Created by Jim Kubicek on 4/1/11.
//  Copyright (c) 2011 jimkubicek.com. All rights reserved.
//

#import "PostHistory.h"
#import "Post.h"


@implementation PostHistory

#pragma mark Class methods
+ (NSString *)entityName {
    return @"PostHistory";
}

#pragma mark Properties

@dynamic postViewTime;
@dynamic post;


@end
