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

@interface MainThreadView ()


@end

#pragma mark -
@implementation MainThreadView


#pragma mark Instance Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    GPPost *thread = (GPPost *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = thread.subject;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", thread.posterName, [dateFormatter stringFromDate:thread.postdate]];
}


#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    static NSString *CellIdentifier = @"Thread";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GPPost *selectedPost = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    IndividualThreadView *viewController = [[IndividualThreadView alloc] initWithNibName:nil bundle:nil];
    viewController.post = selectedPost;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

@end

