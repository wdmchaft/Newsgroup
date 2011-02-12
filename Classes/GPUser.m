//
//  GPUser.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/11/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "GPUser.h"


@implementation GPUser

#pragma mark Class Methods

+ (NSString *)entityName {
    return @"User";
}

#pragma mark Properties

@dynamic email;
@dynamic handle;
@dynamic name;

@end
