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

@synthesize parentPostID;
@synthesize bodyView = bodyView_;
@synthesize subjectView = subjectView_;
@synthesize subject = subject_;

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
    [parentPostID release];
    [bodyView_ release];
    [subjectView_ release];
    [subject_ release];
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
    
    // If we don't have a subject, make the subject field the first responder, else make the text area the first responder.
    if (self.subject == nil) {
        // Make text area the first responder
        [self.subjectView becomeFirstResponder];
    } else {
        self.subjectView.text = self.subject;
        [self.bodyView becomeFirstResponder];
    }
    
    
    
}

- (void)viewDidUnload
{
    [self setBodyView:nil];
    [self setSubjectView:nil];
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
    [APP_DELEGATE.dataController addPostWithSubject:self.subjectView.text body:self.bodyView.text inReplyTo:parentPostID];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
