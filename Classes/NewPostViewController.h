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
}

@property (nonatomic, retain) IBOutlet UITextView *textView;

@end
