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
#import "LoginPasswordViewController.h"

#define PROGRESS_VIEW_FRAME CGRectMake(0.0f, 0.0f, 200.0f, 40.0f)
#define REFRESH_INTERVAL 120.0

#define JKDefaultsShouldShowIconBadge @"JKDefaultsShouldShowIconBadge"

@implementation NewsgroupAppDelegate

@synthesize dataController = dataController_;
@synthesize navigationController;
@synthesize toolbarItems;
@synthesize progressView = progressView_;
@synthesize window;
@synthesize refreshButton = refreshButton_;
@synthesize makeNewPostButton = newPostButton_;
@synthesize nextUnreadButton = nextUnreadButton_;
@synthesize refreshTimer = refreshTimer_;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    // Set the default preferences
    NSDictionary *defaults = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithBool:NO], JKDefaultsShouldShowNicknames,
                              [NSNumber numberWithBool:YES], JKDefaultsShouldShowIconBadge,
                              nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
    // Register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noUnreadPosts:) name:DataControllerNoUnreadPosts object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newUnreadPosts:) name:DataControllerNewUnreadPosts object:nil];
    
    // Configure the toolbar buttons
    [self configureToolbarButtons];
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    // Setup the data controller
    [self setupDataController];
    
    // Configure the nav controller
    self.navigationController.delegate = self;
    
    // Set the version string
    NSString *versionFilePath = [[NSBundle mainBundle] pathForResource:@"version" ofType:@"txt"];
    NSString *versionString = [NSString stringWithContentsOfFile:versionFilePath encoding:NSUTF8StringEncoding error:nil];
    [[NSUserDefaults standardUserDefaults] setValue:versionString forKey:@"JKVersion"];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self refreshData:nil];
    
    NSTimer *refreshTimer = [NSTimer timerWithTimeInterval:REFRESH_INTERVAL target:self selector:@selector(refreshData:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:refreshTimer forMode:NSDefaultRunLoopMode];
    self.refreshTimer = refreshTimer;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)dealloc {
    
    // Unregister for notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark -
#pragma mark Instance Methods

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)configureToolbarButtons {
    ToolbarProgressView *progView = [[ToolbarProgressView alloc] initWithFrame:PROGRESS_VIEW_FRAME];
    progView.viewType = GPProgressTimestampView;
    progView.timestamp = [[NSUserDefaults standardUserDefaults] objectForKey:DataControllerLastFetchTime];
    
    // Create the toolbar bar buttons
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshData:)];
       
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *progressView = [[UIBarButtonItem alloc] initWithCustomView:progView];
    
    UIBarButtonItem *newPost = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newPost:)];
    
    // Add the buttons to an array
    NSArray *buttonArray = [NSArray arrayWithObjects:refreshButton, flexibleSpace, progressView, flexibleSpace, newPost, nil];
    
    UIBarButtonItem *nextUnreadButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Next button title") style:UIBarButtonItemStyleBordered target:self action:@selector(nextUnread:)];
    
    // Next Unread is disabled by default
    nextUnreadButton.enabled = NO;

    self.toolbarItems = buttonArray;
    self.progressView = progView;
    self.refreshButton = refreshButton;
    self.makeNewPostButton = newPost;
    self.nextUnreadButton = nextUnreadButton;
    
}

- (void)setupDataController {
    // Get the username and passwords
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:JKDefaultsUsernameKey];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:JKDefaultsPasswordKey];
    
    // Setup the data controller
    DataController *dc = [[DataController alloc] init];
    dc.delegate = self;
    self.dataController = dc;
    
    
    // If they don't exist, pop up an alert
    if ([username length] == 0 || [password length] == 0) {
        LoginPasswordViewController *logPass = [[LoginPasswordViewController alloc] initWithNibName:@"LoginPasswordView" bundle:nil];
        [self.navigationController.topViewController presentModalViewController:logPass animated:YES];
    }

}

- (void)newPost:(id)sender {
    NSLog(@"newPost");
}

- (void)refreshData:(id)sender {
    NSError *error = nil;
    if ([self.dataController fetchAllPostsWithError:&error]) {
        
        self.refreshButton.enabled = NO;
        self.progressView.viewType = GPProgressDeterminiteView;
        self.progressView.progress = 0.0f;
        
    } else {
        NSLog(@"%@", error);
    }
    
}

- (void)nextUnread:(id)sender {
    // Get a path to the next unread posts.
    NSArray *pathToPost = [self.dataController pathToNextUnreadPost];
    
    if (pathToPost == nil) {
        return;
    }
    
    [self createNavigationStackWithPostArray:pathToPost];
}

- (BOOL)navigateToPostID:(NSNumber *)postID {
    Post *post = [self.dataController postWithId:postID];
    if (post) {
        [self navigateToPost:post];
        return YES;
    } else {
        return NO;
    }
    
}

- (void)navigateToPost:(Post *)post {
    NSArray *pathToPost = [self.dataController pathToPost:post];
    [self createNavigationStackWithPostArray:pathToPost];
}

- (void)createNavigationStackWithPostArray:(NSArray *)postArray {
    MainThreadView *mainThreadView = [[MainThreadView alloc] initWithNibName:@"MainThreadView" bundle:nil];
    NSMutableArray *controllerArray = [NSMutableArray arrayWithObject:mainThreadView];
    
    for (Post *post in postArray) {
        IndividualThreadView *threadView = [[IndividualThreadView alloc] initWithNibName:nil bundle:nil];
        threadView.post = post;
        [controllerArray addObject:threadView];
    }
    
    self.navigationController.viewControllers = controllerArray;
}

- (void)longPressOnBackButton:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self.navigationController.navigationBar];
    CGFloat backButtonWidth = 2.0f * self.navigationController.navigationBar.frame.size.height;
    
    if (touchPoint.x <= backButtonWidth) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark Notification methods

- (void)noUnreadPosts:(NSNotification *)notification {
    self.nextUnreadButton.enabled = NO;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)newUnreadPosts:(NSNotification *)notification {
    self.nextUnreadButton.enabled = YES;   
    BOOL showIconBadge = [[NSUserDefaults standardUserDefaults] boolForKey:JKDefaultsShouldShowIconBadge];
    if (showIconBadge) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[self.dataController countOfUnreadPosts]];
    } else {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    
}

#pragma mark -
#pragma mark DataControllerDelegate Methods

- (void)fetchFailed:(DataController *)dataController withError:(NSError *)error {
    
    NSLog(@"Fetch failed: %@", error);
    
    if ([error code] == DataControllerErrorAuthenticationFailed) {
        LoginPasswordViewController *loginController = [[LoginPasswordViewController alloc] initWithNibName:@"LoginPasswordView" bundle:nil];
        loginController.displayString = NSLocalizedString(@"Login failed", @"String to display when the login fails");
        [self.navigationController pushViewController:loginController animated:YES];
    }
    
    self.refreshButton.enabled = YES;
    self.progressView.viewType = GPProgressTimestampView;
    
}

- (void)fetchSucceded:(DataController *)dataController {
    self.progressView.timestamp = dataController.lastFetchTime;
    self.progressView.viewType = GPProgressTimestampView;
    
    self.refreshButton.enabled = YES;
}

- (void)setProgress:(float)newProgress dataController:(DataController *)dataController {
    self.progressView.progress = newProgress;
}

#pragma mark UINavigationControllerDelegate methods

- (void)navigationController:(UINavigationController *)locNavigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnBackButton:)];
    
    [locNavigationController.navigationBar addGestureRecognizer:longPress];
    
}

@end

