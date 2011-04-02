//
//  PostHistoryViewController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 4/1/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "PostHistoryViewController.h"
#import "DataController.h"
#import "FetchedResultsViewController+PrivateHeader.h"


@implementation PostHistoryViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set title
    self.title = NSLocalizedString(@"History", @"History view title");
    
    // Fetch all our posts
    NSFetchedResultsController *fetchedResults = [APP_DELEGATE.dataController postHistory];
    fetchedResults.delegate = self;
    
    NSError *error = nil;
    if (![fetchedResults performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.fetchedResultsController = fetchedResults;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
