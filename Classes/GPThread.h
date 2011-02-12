//
//  GPThread.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/11/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GPUser;


@interface GPThread : NSManagedObject {

}

// Class methods
+ (NSString *)entityName;

// Properties
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) GPUser * author;

@end
