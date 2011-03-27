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


@implementation LoginPasswordViewController
@synthesize usernameTextField = usernameTextField_;
@synthesize passwordTextField = passwordTextField_;
@synthesize statusLabel;
@synthesize progressIndicator;
@synthesize doneButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        operationQueue_ = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [operationQueue_ release];
    
    [usernameTextField_ release];
    [passwordTextField_ release];
    [statusLabel release];
    [progressIndicator release];
    [doneButton release];
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
    
    self.title = NSLocalizedString(@"Login", @"login password title");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.usernameTextField.text = [defaults objectForKey:JKDefaultsUsernameKey];
    self.passwordTextField.text = [defaults objectForKey:JKDefaultsPasswordKey];
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
        [alertView release];  
        
    // Success!
    } else {
        [(UIButton *)sender setEnabled:NO];
        
        self.statusLabel.hidden = NO;
        self.statusLabel.text = NSLocalizedString(@"Validating Password", nil);
        self.progressIndicator.hidden = NO;
        [self.progressIndicator startAnimating];
        
        __block ASIHTTPRequest *request = [RequestGenerator userWithUsername:username andPassword:password];
        
        // Success
        [request setCompletionBlock:^(void) {
            NSDictionary *response = [[request responseString] JSONValue];
            
            if (response == nil) {
                NSLog(@"Cannot parse response string: %@", [request responseString]);
            }
            
            BOOL isAuthenticated = [[response objectForKey:@"Authenticated"] boolValue];
            if (isAuthenticated == NO) {
                self.statusLabel.text = [NSString stringWithFormat:@"Cannot authenticate username \"%@\"", username];
            } else {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setObject:[response objectForKey:@"FullName"] forKey:NewsgroupDefaultsFullNameKey];
                [defaults setObject:[response objectForKey:@"NickName"] forKey:NewsgroupDefaultsNickNameKey];
                self.statusLabel.text = [NSString stringWithFormat:@"Welcome %@!", [response objectForKey:@"FullName"]];
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
