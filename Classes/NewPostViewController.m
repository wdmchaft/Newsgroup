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
@synthesize keyboardIsVisible = keyboardIsVisible_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNotificationCenter *notCenter = [NSNotificationCenter defaultCenter];
        [notCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [notCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
        self.keyboardIsVisible = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
         
#pragma mark Keyboard notifications
         
- (void)keyboardDidShow:(NSNotification *)notification {
    if (self.keyboardIsVisible) return;
    
    NSDictionary* info = [notification userInfo];
    
    // Get the size of the keyboard.
	NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];    
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // Resize our view
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height -= keyboardSize.height;
    self.view.frame = viewFrame;
    
    self.keyboardIsVisible = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (self.keyboardIsVisible == NO) return;
    
    NSDictionary* info = [notification userInfo];
    
    // Get the size of the keyboard.
	NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];    
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // Resize our view
    CGRect viewFrame = self.view.frame;
    viewFrame.size.height += keyboardSize.height;
    self.view.frame = viewFrame;
    
    self.keyboardIsVisible = NO;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create send button
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send button") style:UIBarButtonItemStyleDone target:self action:@selector(send:)];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Instance Methods

- (void)send:(id)sender {
    [APP_DELEGATE.dataController addPostWithSubject:self.subjectView.text body:self.bodyView.text inReplyTo:parentPostID];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
