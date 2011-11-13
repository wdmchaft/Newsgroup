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
@property (nonatomic, strong) DataController *dataController;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) NSArray *toolbarItems;
@property (nonatomic, strong) ToolbarProgressView *progressView;
@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) UIBarButtonItem *makeNewPostButton;
@property (nonatomic, strong) UIBarButtonItem *nextUnreadButton;
@property (nonatomic, strong) NSTimer *refreshTimer;

// Utility Methods
- (NSURL *)applicationDocumentsDirectory;
- (void)configureToolbarButtons;
- (void)setupDataController;
- (void)newPost:(id)sender;
- (void)refreshData:(id)sender;
- (void)nextUnread:(id)sender;
- (BOOL)navigateToPostID:(NSNumber *)postID;
- (void)navigateToPost:(Post *)post;
- (void)createNavigationStackWithPostArray:(NSArray *)postArray;

// Notification methods
- (void)noUnreadPosts:(NSNotification *)notification;
- (void)newUnreadPosts:(NSNotification *)notification;

@end

