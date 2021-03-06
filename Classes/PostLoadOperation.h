//
//  PostLoadOperation.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PostLoadOperation : NSOperation {

}

+ (NSDate *)convertToDate:(NSString *)dateString;

- (BOOL)addPostsFromArray:(NSArray *)posts toContext:(NSManagedObjectContext *)context;

@end
