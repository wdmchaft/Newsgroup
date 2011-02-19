    //
//  GPBrowserViewController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/18/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "GPBrowserViewController.h"


@implementation GPBrowserViewController

#pragma mark -
#pragma mark Object Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [refreshButton_ release];
    [urlLabel_ release];
    [webView_ release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

@synthesize refreshButton = refreshButton_;
@synthesize urlLabel = urlLabel_;
@synthesize webView = webView_;

#pragma mark Instance Methods

- (IBAction)actionButton:(id)sender {
    NSLog(@"ACTION!");
}


@end
