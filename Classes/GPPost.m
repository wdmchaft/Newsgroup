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
@dynamic memberID;
@dynamic postdate;
@dynamic posterName;
@dynamic postID;
@dynamic subject;
@dynamic threadID;
@dynamic parentPost;
@dynamic childPosts;


- (void)addChildPostsObject:(GPPost *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"childPosts" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"childPosts"] addObject:value];
    [self didChangeValueForKey:@"childPosts" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeChildPostsObject:(GPPost *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"childPosts" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"childPosts"] removeObject:value];
    [self didChangeValueForKey:@"childPosts" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addChildPosts:(NSSet *)value {    
    [self willChangeValueForKey:@"childPosts" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"childPosts"] unionSet:value];
    [self didChangeValueForKey:@"childPosts" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeChildPosts:(NSSet *)value {
    [self willChangeValueForKey:@"childPosts" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"childPosts"] minusSet:value];
    [self didChangeValueForKey:@"childPosts" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
