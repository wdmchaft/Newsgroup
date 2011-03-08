//
//  GPPost.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/11/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GPUser;
@class GPThread;


@interface GPPost : NSManagedObject {

}

// Class methods
+ (NSString *)entityName;

// Properties
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * memberID;
@property (nonatomic, retain) NSDate * postdate;
@property (nonatomic, retain) NSString * posterName;
@property (nonatomic, retain) NSNumber * postID;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * threadID;



@end
