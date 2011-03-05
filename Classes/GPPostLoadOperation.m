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
    // @"/Date(1299282285000-0700)/"
    
    NSMutableString *inputString = [dateString mutableCopy];
    [inputString replaceOccurrencesOfString:@"/Date(" withString:@"" options:0 range:NSMakeRange(0, [inputString length])];
    [inputString replaceOccurrencesOfString:@")/" withString:@"" options:0 range:NSMakeRange(0, [inputString length])];
    
    NSArray *dateComponents = [inputString componentsSeparatedByString:@"-"];
    
    NSDate *gmtDate = [NSDate dateWithTimeIntervalSince1970:[[dateComponents objectAtIndex:0] doubleValue]/1000.0];
    
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

- (NSDateFormatter *)dateFormatter {
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    assert(dateFormatter != nil);
    
    NSLocale *enUSPOSIXLocale = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease];
    assert(enUSPOSIXLocale != nil);
    
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return dateFormatter;
}

@end
