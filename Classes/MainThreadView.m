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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    [super configureCell:cell atIndexPath:indexPath];
}

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the view title
    self.title = @"Newsgroup";
    
    // Create the history button
    UIBarButtonItem *historyButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"history"] style:UIBarButtonItemStyleBordered target:self action:@selector(showHistory:)];
    self.navigationItem.leftBarButtonItem = historyButton;
    [historyButton release];
    
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
    
    static NSString *CellIdentifier = @"Thread";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

@end

