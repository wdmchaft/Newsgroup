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
    UILabel *statusLabel;
    UIActivityIndicatorView *progressIndicator;
}
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *progressIndicator;

- (IBAction)submitLoginPassword:(id)sender;

@end
