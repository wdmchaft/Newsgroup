//
//  NewsgroupAppDelegate.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "NewsgroupAppDelegate.h"
#import "MainThreadView.h"
#import "IndividualThreadView.h"
#import "ToolbarProgressView.h"
#import "JKConstants.h"

#define PROGRESS_VIEW_FRAME CGRectMake(0.0f, 0.0f, 200.0f, 40.0f)

@implementation NewsgroupAppDelegate

@synthesize dataController = dataController_;
@synthesize navigationController;
@synthesize toolbarItems;
@synthesize progressView = progressView_;
@synthesize window;
@synthesize refreshButton = refreshButton_;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    [self configureToolbarButtons];
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    [self setupDataController];
    
    return YES;
}

- (void)dealloc {
    
    [dataController_ release];
    [navigationController release];
    [toolbarItems release];
    [window release];
    [refreshButton_ release];
    [super dealloc];
}

#pragma mark -
#pragma mark Instance Methods

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)configureToolbarButtons {
    ToolbarProgressView *progView = [[ToolbarProgressView alloc] initWithFrame:PROGRESS_VIEW_FRAME];
    progView.viewType = GPProgressDeterminiteView;
    progView.progress = 0.0f;
    
    // Create the bar buttons
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshData:)];
   
    UIBarButtonItem *nextUnreadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(nextUnread:)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *progressView = [[UIBarButtonItem alloc] initWithCustomView:progView];
    
    UIBarButtonItem *newPost = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newPost:)];
    
    // Add the buttons to an array
    NSArray *buttonArray = [NSArray arrayWithObjects:refreshButton, nextUnreadButton, flexibleSpace, progressView, flexibleSpace, newPost, nil];

    self.toolbarItems = buttonArray;
    self.progressView = progView;
    self.refreshButton = refreshButton;
    
    [progView release];
    [refreshButton release];
    [nextUnreadButton release];
    [flexibleSpace release];
    [progressView release];
    [newPost release];
}

- (void)setupDataController {
    // Get the username and passwords
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:JKDefaultsUsernameKey];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:JKDefaultsPasswordKey];
    
    // If they don't exist, pop up an alert
    if (!username || !password) {
        NSAssert(YES, @"You need to add a pop-up for checking on the status of the username/password");
    }
    
    // Setup the data controller
    GPDataController *dc = [[GPDataController alloc] init];
    dc.login = username;
    dc.password = password;
    dc.delegate = self;
    
    self.dataController = dc;
    [self refreshData:self];
    [dc release];

}

- (void)newPost:(id)sender {
    NSLog(@"newPost");
}

- (void)refreshData:(id)sender {
    
    self.refreshButton.enabled = NO;
    
    NSError *error = nil;
    if (![self.dataController fetchAllPostsWithError:&error]) {
        NSLog(@"%@", error);
        NSAssert(NO, nil);
    }
    
}

- (void)nextUnread:(id)sender {
    // Get a path to the next unread posts.
    NSArray *pathToPost = [self.dataController pathToNextUnreadPost];
    
    if (pathToPost == nil) {
        return;
    }
    
    MainThreadView *mainThreadView = [[MainThreadView alloc] initWithNibName:@"MainThreadView" bundle:nil];
    NSMutableArray *controllerArray = [NSMutableArray arrayWithObject:mainThreadView];
    [mainThreadView release];
    
    for (GPPost *post in pathToPost) {
        IndividualThreadView *threadView = [[IndividualThreadView alloc] initWithNibName:nil bundle:nil];
        threadView.post = post;
        [controllerArray addObject:threadView];
        [threadView release];
    }
    
    self.navigationController.viewControllers = controllerArray;
}

#pragma mark -
#pragma mark GPDataControllerDelegate Methods

- (void)fetchFailed:(GPDataController *)dataController withError:(NSError *)error {
    
    self.refreshButton.enabled = YES;
    
}

- (void)fetchSucceded:(GPDataController *)dataController {
    self.progressView.timestamp = dataController.lastFetchTime;
    self.progressView.viewType = GPProgressTimestampView;
    
    self.refreshButton.enabled = YES;
}

- (void)setProgress:(float)newProgress dataController:(GPDataController *)dataController {
    self.progressView.progress = newProgress;
}

@end

