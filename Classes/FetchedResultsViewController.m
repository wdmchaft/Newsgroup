    //
//  FetchedResultsViewController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/15/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "FetchedResultsViewController.h"
#import "FetchedResultsViewController+PrivateHeader.h"
#import "NewsgroupAppDelegate.h"
#import "NSDate+Helper.h"
#import "IndividualThreadView.h"
#import "JKConstants.h"

typedef enum _CustomCellViewTags {
    CustomCellSubjectLabelTag = 1,
    CustomCellPosterLabelTag = 2,
    CustomCellTimeLabelTag = 3,
    CustomCellUnreadImageViewTag = 4
} CustomCellViewTags;

#pragma mark -
@implementation FetchedResultsViewController

@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize cell = cell_;


#pragma mark Instance Methods

- (void)configureCell:(UITableViewCell *)cell withPost:(Post *)post {
    // Get the poster name
    bool shouldShowNicknames = [[[NSUserDefaults standardUserDefaults] objectForKey:JKDefaultsShouldShowNicknames] boolValue];
    NSString *name;
    if (shouldShowNicknames) {
        name = post.posterNickname;
    } else {
        name = post.posterName;
    }

    [(UILabel *)[cell viewWithTag:CustomCellSubjectLabelTag] setText:post.subject];
    [(UILabel *)[cell viewWithTag:CustomCellPosterLabelTag] setText:name];
    [(UILabel *)[cell viewWithTag:CustomCellTimeLabelTag] setText:[NSDate stringForDisplayFromDate:post.postdate]];
    
    if ([post.isRead boolValue] == NO) {
        [(UIImageView *)[cell viewWithTag:CustomCellUnreadImageViewTag] setHidden:NO];
    } 

}    

- (void)newPost:(id)sender {
    NSLog(@"newPost in FetchedResultsController");
}

#pragma mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // nothing special
    }
    return self;
}

- (void)viewDidLoad {
    // Setup the toolbar
    self.toolbarItems = APP_DELEGATE.toolbarItems;
    
    self.navigationItem.rightBarButtonItem = APP_DELEGATE.nextUnreadButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    APP_DELEGATE.newPostButton.target = self;
    APP_DELEGATE.newPostButton.action = @selector(newPost:);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    APP_DELEGATE.newPostButton.target = nil;
    APP_DELEGATE.newPostButton.action = nil;
}

- (void)viewDidUnload {
    self.cell = nil;
}

- (void)dealloc {
    [fetchedResultsController_ release];
    [super dealloc];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert(NO, @"tableView:cellForRowAtIndexPath: must be implimented in the FetchedResultsViewController subclasses");
    return nil;
}

#pragma mark Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *selectedPost = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // Mark the current post as read
    if ([selectedPost.isRead boolValue] == NO) {
        selectedPost.isRead = [NSNumber numberWithBool:YES];
        [APP_DELEGATE.dataController markPostAsRead:selectedPost.postID];
    }
    
    // Get rid of the unread indicator
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    IndividualThreadView *viewController = [[IndividualThreadView alloc] initWithNibName:nil bundle:nil];
    viewController.post = selectedPost;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    
    
    [super didReceiveMemoryWarning];
}


@end
