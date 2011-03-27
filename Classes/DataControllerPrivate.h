//
//  DataControllerPrivate.h
//  Newsgroup
//
//  Created by Jim Kubicek on 3/27/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataController (DataControllerPrivate)

@property (readwrite, copy) NSString *login;
@property (readwrite, copy) NSString *password;

@end
