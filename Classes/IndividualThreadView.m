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

#define POST_LINK_PREFIX @"http://newsgroup.greenpride.com/ViewPost.aspx?PostID="

@interface IndividualThreadView()

@end

#pragma mark -
@implementation IndividualThreadView

@synthesize post = post_;

- (void)setPost:(Post *)post {
    [post retain];
    [post_ release];
    post_ = post;
}

// IBOutlets
@synthesize headerView;
@synthesize subjectLabel;
@synthesize authorLabel;
@synthesize postTimeLabel;
@synthesize webView;

#pragma mark Instance Methods

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
    
    // Setup the headerview
    UINib *headerNib = [UINib nibWithNibName:@"HeaderView" bundle:nil];
    [headerNib instantiateWithOwner:self options:nil];
    self.tableView.tableHeaderView = self.headerView;
    self.authorLabel.text = self.post.posterName;
    self.subjectLabel.text = self.post.subject;
    self.postTimeLabel.text = self.post.displayDate;
    [self.webView loadHTMLString:[DataController addBodyToHTMLTemplate:self.post.body] baseURL:nil];
    
    // Set the current post as read
    if ([self.post.isRead boolValue] == NO) {
        self.post.isRead = [NSNumber numberWithBool:YES];
        [APP_DELEGATE.dataController markPostAsRead:self.post.postID];
    }
    
    // Add the current post to the history table
    [APP_DELEGATE.dataController addPostToHistory:self.post];
    
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
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell.
    [self configureCell:cell withPost:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    
    return cell;
}

#pragma mark UIWebViewDelegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlDescription = [[request URL] description];
    if ([urlDescription isEqualToString:@"about:blank"]) {
        return YES;
    } else if ([urlDescription rangeOfString:POST_LINK_PREFIX].location != NSNotFound) {
        NSString *postIDString = [urlDescription stringByReplacingOccurrencesOfString:POST_LINK_PREFIX withString:@""];
        NSInteger postID = [postIDString integerValue];
        if (postID != 0) {
            [APP_DELEGATE navigateToPostID:[NSNumber numberWithInteger:postID]];
             return NO;
        }
    }
        
    [[UIApplication sharedApplication] openURL:[request URL]];
    return NO;
}

@end

