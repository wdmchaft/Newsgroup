//
//  IndividualThreadView.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/15/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "IndividualThreadView.h"
#import "NewPostViewController.h"
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
    
    [super configureCell:cell atIndexPath:indexPath];
}

- (void)newPost:(id)sender {
    [super newPost:sender];
    
    NewPostViewController *newPostController = [[NewPostViewController alloc] initWithNibName:@"NewPostView" bundle:nil];
    newPostController.parentPostID = self.post.postID;
    newPostController.subject = self.post.subject;
    [self.navigationController pushViewController:newPostController animated:YES];
    [newPostController release];
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
    [self.webView loadHTMLString:[DataController addBodyToHTMLTemplate:self.post.body] baseURL:nil];
    
    // Set the current post as read
    if ([self.post.isRead boolValue] == NO) {
        self.post.isRead = [NSNumber numberWithBool:YES];
        [APP_DELEGATE.dataController markPostAsRead:self.post.postID];
    }
    
    // Add the current post to the history table
    
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] description] isEqualToString:@"about:blank"]) {
        return YES;
    } else {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
}

@end

