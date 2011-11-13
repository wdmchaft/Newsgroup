//
//  PostHistory.h
//  Newsgroup
//
//  Created by Jim Kubicek on 4/1/11.
//  Copyright (c) 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Post;

@interface PostHistory : NSManagedObject {
@private
}

// Class methods
+ (NSString *)entityName;

// Properties
@property (nonatomic, strong) NSDate * postViewTime;
@property (nonatomic, strong) Post * post;

@end
