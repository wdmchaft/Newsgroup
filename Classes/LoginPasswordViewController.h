//
//  LoginPasswordViewController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 3/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginPasswordViewController : UIViewController {
    
    UITextField *usernameTextField;
    UITextField *passwordTextField;
}
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

- (IBAction)submitLoginPassword:(id)sender;

@end
