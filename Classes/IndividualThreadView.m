//
//  IndividualThreadView.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/15/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "IndividualThreadView.h"
#import "FetchedResultsViewController+PrivateHeader.h"
#import "NSDate+Helper.h"

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
    
    GPPost *thread = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = thread.subject;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", thread.posterName, [NSDate stringForDisplayFromDate:thread.postdate]];
}

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the view title
    self.title = self.post.subject;
    
    // Setup the headerview
    UINib *headerNib = [UINib nibWithNibName:@"HeaderView" bundle:nil];
    [headerNib instantiateWithOwner:self options:nil];
    self.tableView.tableHeaderView = self.headerView;
    self.authorLabel.text = self.post.posterName;
    self.subjectLabel.text = self.post.subject;
    self.postTimeLabel.text = [NSDate stringForDisplayFromDate:self.post.postdate];
    [self.webView loadHTMLString:self.post.body baseURL:nil];
    
    // Fetch all our threads
    NSFetchedResultsController *fetchedResults = [APP_DELEGATE.dataController postsWithParentID:self.post.postID];
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

#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] description] isEqualToString:@"about:blank"]) {
        return YES;
    } else {
        return NO;
    }
}

@end

