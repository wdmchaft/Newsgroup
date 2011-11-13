//
//  LoginPasswordViewController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 3/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginPasswordViewController : UIViewController {
    
    NSOperationQueue *operationQueue_;
    
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    UILabel *statusLabel;
    UIActivityIndicatorView *progressIndicator;
    UIBarButtonItem *doneButton;
}

// Instance Methods
- (void)saveUsername:(NSString *)username password:(NSString *)password;

// Properties
@property (nonatomic, copy) NSString *displayString;

// Nib properies
@property (nonatomic, strong) IBOutlet UITextField *usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *progressIndicator;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;

// IBActions
- (IBAction)submitLoginPassword:(id)sender;
- (IBAction)done:(id)sender;

@end
