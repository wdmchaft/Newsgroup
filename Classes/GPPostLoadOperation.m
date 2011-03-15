//
//  GPPostLoadOperation.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "GPPostLoadOperation.h"
#import "Post.h"


@implementation GPPostLoadOperation

+ (NSDate *)convertToDate:(NSString *)dateString {
    
    NSMutableString *inputString = [dateString mutableCopy];
    
    [inputString replaceOccurrencesOfString:@"/Date(" withString:@"" options:0 range:NSMakeRange(0, [inputString length])];
    [inputString replaceOccurrencesOfString:@"-0700)/" withString:@"" options:0 range:NSMakeRange(0, [inputString length])];
    
    NSDate *gmtDate = [NSDate dateWithTimeIntervalSince1970:[inputString doubleValue]/1000.0];
    [inputString release];
    
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
        } else {
            post = [allPosts objectAtIndex:existingPostIndex];
        }
        
        post.body = [postDict objectForKey:@"Description"];
        post.isRead = [postDict objectForKey:@"Read"];
        post.memberID = [postDict objectForKey:@"AuthorID"];
        post.posterName = [postDict objectForKey:@"AuthorName"];
        post.subject = [postDict objectForKey:@"Subject"];
        post.threadID = [postDict objectForKey:@"ThreadID"];
        post.parentID = [postDict objectForKey:@"ParentID"];
        post.postLevel = [postDict objectForKey:@"Level"];
        post.postdate = [GPPostLoadOperation convertToDate:[postDict objectForKey:@"Date"]];
        
    }
    
    return YES;
}

@end
