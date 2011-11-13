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
#import "TDBadgedCell.h"

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
    
    UIColor *unreadColor = [UIColor blueColor];
    UIColor *readColor = [UIColor grayColor];
    
    if ([post.isRead boolValue] == NO) {
        [(UIImageView *)[cell viewWithTag:CustomCellUnreadImageViewTag] setHidden:NO];
        ((TDBadgedCell *)cell).badgeColor = unreadColor;
    } else {
        [(UIImageView *)[cell viewWithTag:CustomCellUnreadImageViewTag] setHidden:YES];
        ((TDBadgedCell *)cell).badgeColor = readColor;
    }
    
    [self configureReadUnreadBadge:(TDBadgedCell *)cell withPost:post readColor:readColor unreadColor:unreadColor];
}    

- (void)configureReadUnreadBadge:(TDBadgedCell *)cell withPost:(Post *)post readColor:(UIColor *)readColor unreadColor:(UIColor *)unreadColor {
    // Set the cell badge
    ReadUnread ru = [APP_DELEGATE.dataController countOfUnreadPostsUnderPost:post];
    
    NSString *badgeString;
    if (ru.children > 0 && ru.unreadChildren > 0) {
        cell.badgeColor = unreadColor;
        badgeString = [NSString stringWithFormat:@"%i/%i", ru.unreadChildren, ru.children];
    } else if (ru.children > 0 && ru.unreadChildren == 0) {
        badgeString = [NSString stringWithFormat:@"%i", ru.children];
    } else {
        badgeString = nil;
    }
    
    cell.badgeString = badgeString;    
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
    
    APP_DELEGATE.makeNewPostButton.target = self;
    APP_DELEGATE.makeNewPostButton.action = @selector(newPost:);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    APP_DELEGATE.makeNewPostButton.target = nil;
    APP_DELEGATE.makeNewPostButton.action = nil;
}

- (void)viewDidUnload {
    self.cell = nil;
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
    
    static NSString *CellIdentifier = @"PostCell";
    
    TDBadgedCell *cell = (TDBadgedCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:self options:nil];
        cell = self.cell;
        self.cell = nil;
    }
    
    return cell;
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
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    
    
    [super didReceiveMemoryWarning];
}


@end
