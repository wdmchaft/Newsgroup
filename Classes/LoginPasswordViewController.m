//
//  LoginPasswordViewController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 3/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "LoginPasswordViewController.h"
#import "JKConstants.h"


@implementation LoginPasswordViewController
@synthesize usernameTextField = usernameTextField_;
@synthesize passwordTextField = passwordTextField_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [usernameTextField_ release];
    [passwordTextField_ release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Username/Password", @"login password title");
}

- (void)viewDidUnload
{
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)submitLoginPassword:(id)sender {
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString(@"You need to enter a login and password", @"No login or password alert title") 
                                  message:NSLocalizedString(@"This app doesn't work without them, buddy", @"no login or password message") 
                                  delegate:nil 
                                  cancelButtonTitle:nil 
                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];                                                                                                                                                     
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:username forKey:JKDefaultsUsernameKey];
        [defaults setObject:password forKey:JKDefaultsPasswordKey];
    }
}
@end
