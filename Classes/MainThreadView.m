//
//  MainThreadView.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import "MainThreadView.h"
#import "FetchedResultsViewController+PrivateHeader.h"
#import "IndividualThreadView.h"
#import "NewPostViewController.h"
#import "NSDate+Helper.h"
#import "PostHistoryViewController.h"

@interface MainThreadView ()

- (void)showHistory:(id)sender;

@end

#pragma mark -
@implementation MainThreadView


#pragma mark Instance Methods

- (void)newPost:(id)sender {
    [super newPost:sender];
    
    NewPostViewController *newPostController = [[NewPostViewController alloc] initWithNibName:@"NewPostView" bundle:nil];
    [self.navigationController pushViewController:newPostController animated:YES];
    [newPostController release];
}


- (void)showHistory:(id)sender {
    PostHistoryViewController *historyView = [[PostHistoryViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:historyView animated:YES];
    [historyView release];
}

#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Set the view title
        self.title = @"Newsgroup";
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create the history button
    UIBarButtonItem *historyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStyleBordered target:self action:@selector(showHistory:)];
    self.navigationItem.leftBarButtonItem = historyButton;
    [historyButton release];
    
    // Set the view title
    self.title = @"Newsgroup";
    
    // Fetch all our threads
    NSFetchedResultsController *fetchedResults = [APP_DELEGATE.dataController allThreads];
    fetchedResults.delegate = self;
    
    NSError *error = nil;
    if (![fetchedResults performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.fetchedResultsController = fetchedResults;
}

- (void)dealloc {
    [super dealloc];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;
    
    if (tableView == self.tableView) {
        CellIdentifier = @"Thread";
    } else {
        CellIdentifier = @"SearchCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    if (tableView == self.tableView) {
        [self configureCell:cell withPost:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    } else {
        NSLog(@"about to configure a cell for the search table view");
        [self configureCell:cell withPost:nil];
    }
    
    
    return cell;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return [super numberOfSectionsInTableView:tableView];
    } else {
        NSLog(@"search results table view number of sections");
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [super tableView:tableView numberOfRowsInSection:section];
    } else {
        NSLog(@"search results table view number rows in section");
        return 0;
    }
}

#pragma mark UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else {
        NSLog(@"Search table view selected a row");
    }
}

#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"start search for %@", searchString);
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"purge the posts from our cache");
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"go get all posts");
}

@end

