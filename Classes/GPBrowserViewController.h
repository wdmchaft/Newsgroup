//
//  GPBrowserViewController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/18/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GPBrowserViewController : UIViewController <UIWebViewDelegate> {
    
    @private
    UIBarButtonItem *refreshButton_;
    NSURL *url_;
    UILabel *urlLabel_;
    UIWebView *webView_;

    UIBarButtonItem *refreshingButton;
}

// Properties
@property (retain, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (retain, nonatomic) NSURL *url;
@property (retain, nonatomic) IBOutlet UILabel *urlLabel;
@property (retain, nonatomic) IBOutlet UIWebView *webView;

// Instance Methods
- (IBAction)actionButton:(id)sender;

@end
