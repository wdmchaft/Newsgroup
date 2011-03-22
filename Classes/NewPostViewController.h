//
//  NewPostViewController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 3/16/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewPostViewController : UIViewController {
    
}

// Properties
@property (nonatomic, retain) NSNumber *parentPostID;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, retain) IBOutlet UITextView *bodyView;
@property (nonatomic, retain) IBOutlet UITextField *subjectView;

// Instance Methods
- (void)send:(id)sender;

@end
