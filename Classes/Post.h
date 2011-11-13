//
//  GPPost.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/11/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Post : NSManagedObject {
    NSString *displayDate_;
}

// Class methods
+ (NSString *)entityName;

// Custom Properties
@property (unsafe_unretained, nonatomic, readonly) NSString *displayDate;

// Managed Object Properties
@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSNumber * isRead;
@property (nonatomic, strong) NSNumber * memberID;
@property (nonatomic, strong) NSDate * postdate;
@property (nonatomic, strong) NSString * posterName;
@property (nonatomic, strong) NSString * posterNickname;
@property (nonatomic, strong) NSNumber * postID;
@property (nonatomic, strong) NSString * subject;
@property (nonatomic, strong) NSNumber * threadID;
@property (nonatomic, strong) NSNumber * parentID;
@property (nonatomic, strong) NSNumber * postLevel;

@property (nonatomic, strong) Post *parentPost;
@property (nonatomic, strong) NSSet *childPosts;

@end
