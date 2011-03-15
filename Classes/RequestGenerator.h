//
//  RequestGenerator.h
//  Newsgroup
//
//  Created by Jim Kubicek on 3/15/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"


@interface RequestGenerator : NSObject {
    
}

+ (ASIHTTPRequest *)hashRequestWithValue:(NSString *)value urlEncode:(BOOL)shouldEncode;
+ (ASIHTTPRequest *)markPostAsRead:(NSNumber *)postID username:(NSString *)username password:(NSString *)password;
+ (ASIHTTPRequest *)userWithUsername:(NSString *)username andPassword:(NSString *)password;
+ (ASIHTTPRequest *)postsWithUsername:(NSString *)username password:(NSString *)password threadID:(NSInteger)threadID postID:(NSInteger)postID threadLimit:(NSInteger)threadLimit;
+ (ASIHTTPRequest *)addPostForUser:(NSString *)username password:(NSString *)password subject:(NSString *)subject body:(NSString *)body inReplyTo:(NSNumber *)postID;


@end
