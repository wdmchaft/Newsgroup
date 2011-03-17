//
//  NewPostViewController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 3/16/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NewPostViewController : UIViewController {
    
    UITextView *textView;
    UITextField *titleView;
}

// Properties
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UITextField *titleView;

// Instance Methods
- (void)send:(id)sender;

@end
