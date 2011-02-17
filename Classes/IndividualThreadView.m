//
//  IndividualThreadView.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/15/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "IndividualThreadView.h"
#import "FetchedResultsViewController+PrivateHeader.h"

@interface IndividualThreadView()


@end

#pragma mark -
@implementation IndividualThreadView

@synthesize post = post_;

// IBOutlets
@synthesize headerView;
@synthesize subjectLabel;
@synthesize authorLabel;
@synthesize postTimeLabel;
@synthesize webView;

#pragma mark Instance Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    GPPost *thread = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = thread.subject;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", thread.posterName, [dateFormatter stringFromDate:thread.postdate]];
}


#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the view title
    self.title = self.post.subject;
    
    // Setup the headerview
    self.tableView.tableHeaderView = self.headerView;
    
    // Fetch all our threads
    NSNumber *postLevel = [NSNumber numberWithInt:(1 + [self.post.postLevel intValue])];
    NSFetchedResultsController *fetchedResults = [APP_DELEGATE.dataController postsWithThreadID:self.post.threadID atPostLevel:postLevel];
    fetchedResults.delegate = self;
    
    NSError *error = nil;
    if (![fetchedResults performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    self.fetchedResultsController = fetchedResults;
}

- (void)dealloc {
    [post_ release];
    [super dealloc];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Post";
    
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

