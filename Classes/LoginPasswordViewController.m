//
//  LoginPasswordViewController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 3/24/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "LoginPasswordViewController.h"
#import "JKConstants.h"
#import "RequestGenerator.h"
#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "NewsgroupAppDelegate.h"


@implementation LoginPasswordViewController

@synthesize displayString = displayString_;
@synthesize usernameTextField = usernameTextField_;
@synthesize passwordTextField = passwordTextField_;
@synthesize statusLabel;
@synthesize progressIndicator;
@synthesize doneButton;

- (void)setDisplayString:(NSString *)displayString {
    // Since this is a copy property, we don't need to worry about being passed the same string as the iVar
    displayString_ = [displayString copy];
    
    if ([displayString_ length] != 0) {
        self.statusLabel.text = displayString_;
        self.statusLabel.hidden = NO;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        operationQueue_ = [[NSOperationQueue alloc] init];
    }
    return self;
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
    
    self.title = NSLocalizedString(@"Login", @"login password title");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.usernameTextField.text = [defaults objectForKey:JKDefaultsUsernameKey];
    self.passwordTextField.text = [defaults objectForKey:JKDefaultsPasswordKey];
    
    if ([self.displayString length] != 0) {
        self.statusLabel.text = self.displayString;
        self.statusLabel.hidden = NO;
    }
    
}

- (void)viewDidUnload
{
    [self setUsernameTextField:nil];
    [self setPasswordTextField:nil];
    [self setStatusLabel:nil];
    [self setProgressIndicator:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)saveUsername:(NSString *)username password:(NSString *)password {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:JKDefaultsUsernameKey];
    [defaults setObject:password forKey:JKDefaultsPasswordKey];
}

- (IBAction)submitLoginPassword:(id)sender {
    
    NSString *username = self.usernameTextField.text;
    NSString *password = self.passwordTextField.text;
    
    [self saveUsername:username password:password];
    
    // No username or password
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] 
                                  initWithTitle:NSLocalizedString(@"You need to enter a login and password", @"No login or password alert title") 
                                  message:NSLocalizedString(@"This app doesn't work without them, buddy", @"no login or password message") 
                                  delegate:nil 
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"Cancel button title") 
                                  otherButtonTitles:nil];
        [alertView show];
        
    // Success!
    } else {
        [(UIButton *)sender setEnabled:NO];
        
        self.statusLabel.hidden = NO;
        self.statusLabel.text = NSLocalizedString(@"Validating Password", nil);
        self.progressIndicator.hidden = NO;
        [self.progressIndicator startAnimating];
        
        __unsafe_unretained ASIHTTPRequest *request = [RequestGenerator userWithUsername:username andPassword:password];
        
        // Success
        [request setCompletionBlock:^(void) {
            BOOL isAuthenticated = [APP_DELEGATE.dataController saveResponseStringFromAuthenticationRequest:[request responseString]];
            
            if (isAuthenticated == NO) {
                self.statusLabel.text = [NSString stringWithFormat:@"Cannot authenticate username \"%@\"", username];
            } else {
                self.statusLabel.text = [NSString stringWithFormat:@"Welcome %@!", [[NSUserDefaults standardUserDefaults] objectForKey:NewsgroupDefaultsFullNameKey]];
                self.doneButton.enabled = YES;
            }
            
            self.progressIndicator.hidden = YES;
            [(UIButton *)sender setEnabled:YES];
        }];
        
        [operationQueue_ addOperation:request];
    }
}

- (IBAction)done:(id)sender {
    [self saveUsername:self.usernameTextField.text password:self.passwordTextField.text];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}
@end
