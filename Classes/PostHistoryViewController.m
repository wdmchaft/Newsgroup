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
#import "PostHistory.h"


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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PostHistory";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    PostHistory *postHistory = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self configureCell:cell withPost:postHistory.post];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PostHistory *postHistory = [self.fetchedResultsController objectAtIndexPath:indexPath];
    Post *post = postHistory.post;
    [APP_DELEGATE navigateToPost:post];
}

@end
