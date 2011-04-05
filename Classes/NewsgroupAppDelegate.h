//
//  NewsgroupAppDelegate.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataController.h"


#define APP_DELEGATE ((NewsgroupAppDelegate *)[UIApplication sharedApplication].delegate)

@class ToolbarProgressView;

@interface NewsgroupAppDelegate : NSObject <UIApplicationDelegate, DataControllerDelegate, UINavigationControllerDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    
    DataController *dataController_;
    ToolbarProgressView *progressView_;
    UIBarButtonItem *refreshButton_;
    UIBarButtonItem *newPostButton_;
    UIBarButtonItem *nextUnreadButton_;
}

// Properties
@property (nonatomic, retain) DataController *dataController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) UIBarButtonItem *refreshButton;
@property (nonatomic, retain) NSArray *toolbarItems;
@property (nonatomic, retain) ToolbarProgressView *progressView;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UIBarButtonItem *newPostButton;
@property (nonatomic, retain) UIBarButtonItem *nextUnreadButton;
@property (nonatomic, retain) NSTimer *refreshTimer;

// Utility Methods
- (NSURL *)applicationDocumentsDirectory;
- (void)configureToolbarButtons;
- (void)setupDataController;
- (void)newPost:(id)sender;
- (void)refreshData:(id)sender;
- (void)nextUnread:(id)sender;
- (void)navigateToPost:(Post *)post;
- (void)createNavigationStackWithPostArray:(NSArray *)postArray;

// Notification methods
- (void)noUnreadPosts:(NSNotification *)notification;
- (void)newUnreadPosts:(NSNotification *)notification;

@end

