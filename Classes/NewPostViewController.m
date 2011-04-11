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
@synthesize bodyLabel;
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
    [bodyLabel release];
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
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    
    // Resize our view
    CGRect bodyRect = self.bodyView.frame;
    bodyRect.size.height -= keyboardRect.size.height;
    self.bodyView.frame = bodyRect;
    
    
    self.keyboardIsVisible = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (self.keyboardIsVisible == NO) return;
    
    NSDictionary* info = [notification userInfo];
    
    // Get the size of the keyboard.
	NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [self.view convertRect:[aValue CGRectValue] fromView:nil];
    
    // Resize our view
    CGRect bodyRect = self.bodyView.frame;
    bodyRect.size.height += keyboardRect.size.height;
    self.bodyView.frame = bodyRect;

    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Get rid of the toolbar
    callingControllerHidesToolbar = self.navigationController.toolbarHidden;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.toolbarHidden = callingControllerHidesToolbar;
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{    
    [self setBodyView:nil];
    [self setSubjectView:nil];
    [self setBodyLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.bodyLabel.hidden = YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    NSString *bodyText = textView.text;
    
    if (bodyText == nil || [bodyText isEqualToString:@""]) {
        self.bodyLabel.hidden = NO;
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.bodyView becomeFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark Instance Methods

- (void)send:(id)sender {
    [APP_DELEGATE.dataController addPostWithSubject:self.subjectView.text body:self.bodyView.text inReplyTo:parentPostID];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
