//
//  PostLoadOperation.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "PostLoadOperation.h"
#import "Post.h"


@implementation PostLoadOperation

+ (NSDate *)convertToDate:(NSString *)dateString {
    
    NSMutableString *inputString = [dateString mutableCopy];
    
    [inputString replaceOccurrencesOfString:@"/Date(" withString:@"" options:0 range:NSMakeRange(0, [inputString length])];
    [inputString replaceOccurrencesOfString:@"-0700)/" withString:@"" options:0 range:NSMakeRange(0, [inputString length])];
    
    NSDate *gmtDate = [NSDate dateWithTimeIntervalSince1970:[inputString doubleValue]/1000.0];
    
    return gmtDate;
}

// We need to allocated our own context if we use the post load operation in it's own thread. The
//  context will only work properly in the thread in which it was allocated.

- (BOOL)addPostsFromArray:(NSArray *)posts toContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *allPostsRequest = [[[context persistentStoreCoordinator] managedObjectModel] fetchRequestTemplateForName:@"allPosts"];
    
    NSError *error = nil;
    NSArray *allPosts = [context executeFetchRequest:allPostsRequest error:&error];
    if (!allPosts) {
        NSLog(@"%@", error);
    }
    
    NSMutableArray *newPosts = [NSMutableArray array];
    NSMutableArray *oldAndNewPosts = [NSMutableArray arrayWithArray:allPosts];
    
    for (NSDictionary *postDict in posts) {
        
        // If the postID exists, update, else insert
        NSNumber *postID = [postDict objectForKey:@"PostID"];
        
        NSUInteger existingPostIndex = [allPosts indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
            return [[obj postID] isEqualToNumber:postID];
        }];
        
        Post *post;
        if (existingPostIndex == NSNotFound) {
            post = [NSEntityDescription insertNewObjectForEntityForName:[Post entityName] inManagedObjectContext:context];
            post.postID = postID;
            [newPosts addObject:post];
        } else {
            post = [allPosts objectAtIndex:existingPostIndex];
        }
        [oldAndNewPosts addObject:post];
        
        post.body = [postDict objectForKey:@"Description"];
        post.isRead = [postDict objectForKey:@"Read"];
        post.memberID = [postDict objectForKey:@"AuthorID"];
        post.posterName = [postDict objectForKey:@"AuthorName"];
        post.posterNickname = [postDict objectForKey:@"AuthorNickname"];
        post.subject = [postDict objectForKey:@"Subject"];
        post.threadID = [postDict objectForKey:@"ThreadID"];
        post.parentID = [postDict objectForKey:@"ParentID"];
        post.postLevel = [postDict objectForKey:@"Level"];
        post.postdate = [PostLoadOperation convertToDate:[postDict objectForKey:@"Date"]];
        
    }
    
    // Set up the parent/child relationship
    for (Post *post in newPosts) {
        if (![post.parentID isEqualToNumber:post.postID]) {
            NSUInteger parentPostIndex = [oldAndNewPosts indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                return [[obj postID] isEqualToNumber:post.parentID];
            }];
            post.parentPost = [oldAndNewPosts objectAtIndex:parentPostIndex];
        }
    }
    
    return YES;
}

@end
