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
    UILabel *bodyLabel;
}

// Properties
@property (nonatomic, strong) NSNumber *parentPostID;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, strong) IBOutlet UITextView *bodyView;
@property (nonatomic, strong) IBOutlet UITextField *subjectView;
@property (nonatomic, strong) IBOutlet UILabel *bodyLabel;
@property (assign) BOOL keyboardIsVisible;

// Instance Methods
- (void)send:(id)sender;
- (void)keyboardDidShow:(NSNotification *)notification;
- (void)keyboardDidHide:(NSNotification *)notification;

@end
