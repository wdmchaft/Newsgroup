//
//  GPPostLoadOperation.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "GPPostLoadOperation.h"
#import "GPPost.h"


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
    
    for (NSDictionary *postDict in posts) {
        GPPost *post = [NSEntityDescription insertNewObjectForEntityForName:[GPPost entityName] inManagedObjectContext:context];
        post.body = [postDict objectForKey:@"Description"];
        post.isRead = [postDict objectForKey:@"Read"];
        post.memberID = [postDict objectForKey:@"AuthorID"];
        post.posterName = [postDict objectForKey:@"AuthorName"];
        post.postID = [postDict objectForKey:@"PostID"];
        post.postLevel = [postDict objectForKey:@"Level"];
        post.subject = [postDict objectForKey:@"Subject"];
        post.threadID = [postDict objectForKey:@"ThreadID"];
        
        post.postdate = [GPPostLoadOperation convertToDate:[postDict objectForKey:@"Date"]];
    }
    
    return YES;
}

@end
