//
//  RequestGenerator.m
//  Newsgroup
//
//  Created by Jim Kubicek on 3/15/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "RequestGenerator.h"
#import "DataController.h"

#define BASE_URL_STRING @"https://api.greenpride.com/Service.svc/"
#define REPLY_FORMAT @"format=json"

@implementation RequestGenerator

+ (ASIHTTPRequest *)hashRequestWithValue:(NSString *)value urlEncode:(BOOL)shouldEncode {
    // Build the URL
    NSString *urlPath = [NSString stringWithFormat:@"%@Hash?Value=%@&URLEncode=%@&%@", BASE_URL_STRING, value, shouldEncode ? @"True" : @"False", REPLY_FORMAT];
    return [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlPath]];
}

+ (ASIHTTPRequest *)markPostAsRead:(NSNumber *)postID username:(NSString *)username password:(NSString *)password {
    NSException *e = nil;
    
    if (postID == nil) {
        e = [NSException exceptionWithName:DataControllerNoPostIDException reason:@"This method must take a postID as input" userInfo:nil];
    } else if (username == nil) {
        e = [NSException exceptionWithName:DataControllerNoUsernameException reason:@"This method must take a username as input" userInfo:nil];
    } else if (password == nil) {
        e = [NSException exceptionWithName:DataControllerNoPasswordException reason:@"This method must take a password as input" userInfo:nil];
    }
    
    if (e) {
        @throw e;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.greenpride.com/Service.svc/PostMarkAs?UserName=%@&Password=%@&Read=True&PostID=%@&format=json", username, [DataController hashString:password], postID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    return [ASIHTTPRequest requestWithURL:url];
}

+ (ASIHTTPRequest *)userWithUsername:(NSString *)username andPassword:(NSString *)password {
    
    NSMutableString *urlPath = [NSMutableString stringWithFormat:@"%@UserGet?UserName=%@", BASE_URL_STRING, username];
    if (password) {
        [urlPath appendFormat:@"&Password=%@", [DataController hashString:password]];
    }
    [urlPath appendFormat:@"&%@", REPLY_FORMAT];
    
    NSURL *url = [NSURL URLWithString:urlPath];
    return [ASIHTTPRequest requestWithURL:url];
    
}

+ (ASIHTTPRequest *)postsWithUsername:(NSString *)username password:(NSString *)password threadID:(NSInteger)threadID postID:(NSInteger)postID threadLimit:(NSInteger)threadLimit {
    
    NSMutableString *urlPath = [NSMutableString stringWithFormat:@"%@Posts?UserName=%@&Password=%@", BASE_URL_STRING, username, [DataController hashString:password]];
    
    // If you pass a '0' for any of these values then that value is ignored.
    //  i.e. '0' for the thread ID pulls in all threads
    [urlPath appendFormat:@"&ThreadID=%i", threadID];
    [urlPath appendFormat:@"&PostID=%i", postID];
    [urlPath appendFormat:@"&ThreadLimit=%i", threadLimit];
    [urlPath appendFormat:@"&%@", REPLY_FORMAT];
    
    NSURL *url = [NSURL URLWithString:urlPath];
    return [ASIHTTPRequest requestWithURL:url];
}

+ (ASIHTTPRequest *)addPostForUser:(NSString *)username password:(NSString *)password subject:(NSString *)subject body:(NSString *)body inReplyTo:(NSNumber *)postID {
    
    NSException *e = nil;
    
    if (username == nil) {
        e = [NSException exceptionWithName:DataControllerNoUsernameException reason:@"This method must take a username as input" userInfo:nil];
    } else if (password == nil) {
        e = [NSException exceptionWithName:DataControllerNoPasswordException reason:@"This method must take a password as input" userInfo:nil];
    }
    
    if (e) {
        @throw e;
    }
    
    if (subject == nil) subject = @"";
    if (body == nil) body = @"";
    
    subject = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)subject, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    body = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)body, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    
    NSString *urlString = [NSString stringWithFormat:@"%@PostAdd?UserName=%@&Password=%@&Subject=%@&Description=%@&ReplyToID=%i&%@",
                           BASE_URL_STRING,
                           username,
                           [DataController hashString:password],
                           subject,
                           body,
                           [postID intValue],
                           REPLY_FORMAT];
    
    [subject release];
    [body release];
    
    NSURL *url = [NSURL URLWithString:urlString];
    return [ASIHTTPRequest requestWithURL:url];
}

@end
