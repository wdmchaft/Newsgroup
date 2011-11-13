//
//  IndividualThreadView.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/15/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FetchedResultsViewController.h"


@class Post;

@interface IndividualThreadView : FetchedResultsViewController <UIWebViewDelegate> {

    @private
    Post *post_;
}

@property (nonatomic, strong) Post *post;

// IBOutlets
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UILabel *subjectLabel;
@property (nonatomic, strong) IBOutlet UILabel *authorLabel;
@property (nonatomic, strong) IBOutlet UILabel *postTimeLabel;
@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end
