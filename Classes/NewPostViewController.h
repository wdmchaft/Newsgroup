//
//  NewPostViewController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 3/16/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewPostViewController : UIViewController {
    BOOL callingControllerHidesToolbar;
}

// Properties
@property (nonatomic, retain) NSNumber *parentPostID;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, retain) IBOutlet UITextView *bodyView;
@property (nonatomic, retain) IBOutlet UITextField *subjectView;
@property (assign) BOOL keyboardIsVisible;

// Instance Methods
- (void)send:(id)sender;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;

@end
