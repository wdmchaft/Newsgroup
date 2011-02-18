//
//  NewsgroupAppDelegate.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "NewsgroupAppDelegate.h"
#import "MainThreadView.h"
#import "GPDataController.h"


@implementation NewsgroupAppDelegate

@synthesize dataController;
@synthesize navigationController;
@synthesize toolbarItems;
@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    

    // Setup the default toolbar
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshData:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *newPost = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newPost:)];
    
    NSArray *buttonArray = [NSArray arrayWithObjects:refreshButton, flexibleSpace, newPost, nil];
    
    [refreshButton release];
    [flexibleSpace release];
    [newPost release];
    
    self.toolbarItems = buttonArray;
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];

    GPDataController *dc = [[GPDataController alloc] init];
    [dc startFetching];
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


@end

