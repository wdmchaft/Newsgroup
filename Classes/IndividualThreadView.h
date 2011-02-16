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

@class GPPost;

@interface IndividualThreadView : FetchedResultsViewController {

    @private
    GPPost *post_;
}

@property (nonatomic, retain) GPPost *post;

// IBOutlets
@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UILabel *subjectLabel;
@property (nonatomic, retain) IBOutlet UILabel *authorLabel;
@property (nonatomic, retain) IBOutlet UILabel *postTimeLable;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
