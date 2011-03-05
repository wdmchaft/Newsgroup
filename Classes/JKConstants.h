//
//  JKConstants.h
//  Newsgroup
//
//  Created by Jim Kubicek on 3/2/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

NSString *const JKDefaultsUsernameKey = @"JKDefaultsUsernameKey";
NSString *const JKDefaultsPasswordKey = @"JKDefaultsPasswordKey";

#define MAKE_ERROR NSError *error = nil
#define LOG_ERROR_FROM_METHOD(x) if(!x){ NSLog(@"%@", error) }

#define LOG(x) NSLog(@"%@", x)
