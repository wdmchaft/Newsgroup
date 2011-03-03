//
//  NewsgroupAppDelegate.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "NewsgroupAppDelegate.h"
#import "MainThreadView.h"
#import "ToolbarProgressView.h"
#import "JKConstants.h"
#import "DDAlertPrompt.h"

#define PROGRESS_VIEW_FRAME CGRectMake(0.0f, 0.0f, 200.0f, 40.0f)

@implementation NewsgroupAppDelegate

@synthesize dataController;
@synthesize navigationController;
@synthesize toolbarItems;
@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    // Setup the default toolbar
    //TODO: This should be setup propertly
    ToolbarProgressView *progView = [[ToolbarProgressView alloc] initWithFrame:PROGRESS_VIEW_FRAME];
    progView.viewType = GPProgressDeterminiteView;
    progView.progress = 0.69f;
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshData:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *progressView = [[UIBarButtonItem alloc] initWithCustomView:progView];
    UIBarButtonItem *newPost = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newPost:)];
    
    NSArray *buttonArray = [NSArray arrayWithObjects:refreshButton, flexibleSpace, progressView, flexibleSpace, newPost, nil];
    
    [refreshButton release];
    [flexibleSpace release];
    [progressView release];
    [newPost release];
    
    self.toolbarItems = buttonArray;
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    // Get the username and passwords
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:JKDefaultsUsernameKey];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:JKDefaultsPasswordKey];

    // If they don't exist, pop up an alert
    if (!username || !password) {
        // TODO: POP UP AN ALERT, YO
    }
    
    // Setup the data controller
    GPDataController *dc = [[GPDataController alloc] init];
    dc.login = username;
    dc.password = password;
    dc.delegate = self;
    
    NSError *error = nil;
    if (![dc fetchAllPostsWithError:&error]) {
        NSLog(@"%@", error);
        NSAssert(NO, nil);
    }
    self.dataController = dc;
    [dc release];
    
    return YES;
}

- (void)dealloc {
    
    [dataController release];
    [navigationController release];
    [toolbarItems release];
    [window release];
    [super dealloc];
}

#pragma mark -
#pragma mark Instance Methods

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)newPost:(id)sender {
    NSLog(@"newPost");
}

- (void)refreshData:(id)sender {
    NSLog(@"refreshData");
}

#pragma mark -
#pragma mark GPDataControllerDelegate Methods

- (void)fetchFailed:(GPDataController *)dataController withError:(NSError *)error {
    // Kill the progress bar
}

- (void)fetchSucceded:(GPDataController *)dataController {
    // Kill the progress bar, update the timestamp
}


@end

