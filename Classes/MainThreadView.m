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
#import "PostHistoryViewController.h"

#define POST_SEARCH_SCOPE_INDEX @"POST_SEARCH_SCOPE_INDEX"

@interface MainThreadView ()

- (NSArray *)filterInputArray:(NSArray *)input searchString:(NSString *)searchString scopeIndex:(NSInteger)scopeIndex;
- (void)showHistory:(id)sender;

@end

#pragma mark -
@implementation MainThreadView

#pragma mark Properties

@synthesize allPosts = allPosts_;
@synthesize searchResults = searchResults_;

#pragma mark Instance Methods

- (void)newPost:(id)sender {
    [super newPost:sender];
    
    NewPostViewController *newPostController = [[NewPostViewController alloc] initWithNibName:@"NewPostView" bundle:nil];
    [self.navigationController pushViewController:newPostController animated:YES];
}

- (NSArray *)filterInputArray:(NSArray *)input searchString:(NSString *)searchString scopeIndex:(NSInteger)scopeIndex {
    NSMutableArray *outputResults = [NSMutableArray array];
    
    BOOL shouldSearchSubject = NO;
    BOOL shouldSearchPoster = NO;
    BOOL shouldSearchBody = NO;
    
    if (scopeIndex == 0) {
        shouldSearchSubject = YES;
        shouldSearchPoster = YES;
        shouldSearchBody = YES;
    } else if (scopeIndex == 1) {
        shouldSearchSubject = YES;
    } else if (scopeIndex == 2) {
        shouldSearchPoster = YES;
    } else if (scopeIndex == 3) {
        shouldSearchBody = YES;
    } else {
        NSAssert(NO, @"Something has gone horribly wrong... ");
    }
    
    for (Post *post in input) {
        
        // Search Subject
        if (shouldSearchSubject && [post.subject rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [outputResults addObject:post];
        }
        
        // Search Poster Name
        if (shouldSearchPoster && [post.posterName rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [outputResults addObject:post];
        }
        
        // Search Poster Nickname
        if (shouldSearchPoster && [post.posterNickname rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [outputResults addObject:post];
        }
        
        // Search Body
        if (shouldSearchBody && [post.body rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [outputResults addObject:post];
        }
    }
    
    return outputResults;
}

- (void)showHistory:(id)sender {
    PostHistoryViewController *historyView = [[PostHistoryViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:historyView animated:YES];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect searchFrame = self.searchDisplayController.searchBar.frame;
    CGPoint topOfTable = CGPointMake(0.0f, searchFrame.size.height);
    self.tableView.contentOffset = topOfTable;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    // Configure the cell.
    if (tableView == self.tableView) {
        [self configureCell:cell withPost:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    } else {
        [self configureCell:cell withPost:[self.searchResults objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.tableView) {
        return [super numberOfSectionsInTableView:tableView];
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.tableView) {
        return [super tableView:tableView numberOfRowsInSection:section];
    } else {
        return [self.searchResults count];
    }
}

#pragma mark UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    } else {
        [APP_DELEGATE navigateToPost:[self.searchResults objectAtIndex:indexPath.row]];
    }
}

#pragma mark UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
       
    self.searchResults = [self filterInputArray:self.allPosts searchString:searchString scopeIndex:controller.searchBar.selectedScopeButtonIndex];
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {

    self.searchResults = [self filterInputArray:self.allPosts searchString:controller.searchBar.text scopeIndex:searchOption];
    
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {

    // This method is called *after* [MainThreadView dealloc]
    //   don't try and set any properties.
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:controller.searchBar.selectedScopeButtonIndex] forKey:POST_SEARCH_SCOPE_INDEX];
}

#pragma mark UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    
    searchBar.selectedScopeButtonIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:POST_SEARCH_SCOPE_INDEX] integerValue];
    self.allPosts = [APP_DELEGATE.dataController allPosts];
    
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    // Purge all search results here
    self.allPosts = nil;
    self.searchResults = nil;
}

@end

