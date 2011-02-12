//
//  GPUser.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/11/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GPUser : NSManagedObject {

}

// Class Methods
+ (NSString *)entityName;

// Properties
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * handle;
@property (nonatomic, retain) NSString * name;

@end
