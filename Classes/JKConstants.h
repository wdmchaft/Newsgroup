//
//  JKConstants.h
//  Newsgroup
//
//  Created by Jim Kubicek on 3/2/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#define JKDefaultsUsernameKey @"JKDefaultsUsernameKey"
#define JKDefaultsPasswordKey @"JKDefaultsPasswordKey"

#define NewsgroupDefaultsFullNameKey @"NewsgroupDefaultsFullNameKey"
#define NewsgroupDefaultsNickNameKey @"NewsgroupDefaultsNickNameKey"
#define NewsgroupDefaultsUserIDKey @"NewsgroupDefaultsUserIDKey"

NSString *const DataControllerFullName = @"DataControllerFullName";
NSString *const DataControllerNickName = @"DataControllerNickName";
NSString *const DataControllerUserID = @"DataControllerUserID";

#define MAKE_ERROR NSError *error = nil
#define LOG_ERROR_FROM_METHOD(x) if(!x){ NSLog(@"%@", error) }

#define LOG(x) NSLog(@"%@", x)
