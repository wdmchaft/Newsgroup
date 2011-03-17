//
//  NewPostViewController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 3/16/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "NewPostViewController.h"
#import "NewsgroupAppDelegate.h"


@implementation NewPostViewController
@synthesize textView;
@synthesize titleView;

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
    [textView release];
    [titleView release];
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
    
    // Set Title
    self.title = NSLocalizedString(@"New Post", @"New Post screen title");
    
    // Create send button
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(send:)];
    self.navigationItem.rightBarButtonItem = sendButton;
    [sendButton release];
    
    // Make text area the first responder
    [self.titleView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setTitleView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Instance Methods

- (void)send:(id)sender {
    [APP_DELEGATE.dataController addPostWithSubject:self.titleView.text body:self.textView.text inReplyTo:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
