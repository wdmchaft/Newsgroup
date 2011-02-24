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

- (BOOL)addPostsFromArray:(NSArray *)posts toContext:(NSManagedObjectContext *)context {
    
    for (NSDictionary *postDict in posts) {
        GPPost *post = [NSEntityDescription insertNewObjectForEntityForName:[GPPost entityName] inManagedObjectContext:context];
        post.body = [postDict objectForKey:@"body"];
        post.isRead = [postDict objectForKey:@"isRead"];
        post.memberID = [postDict objectForKey:@"memberID"];
        post.postdate = [[self dateFormatter] dateFromString:[postDict objectForKey:@"postdate"]];
        post.posterName = [postDict objectForKey:@"posterName"];
        post.postID = [postDict objectForKey:@"postID"];
        post.postLevel = [postDict objectForKey:@"postLevel"];
        post.subject = [postDict objectForKey:@"subject"];
        post.threadID = [postDict objectForKey:@"threadID"];
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
