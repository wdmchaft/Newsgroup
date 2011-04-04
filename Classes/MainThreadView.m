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
    [newPostController release];
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
    
    for (Post *post in self.allPosts) {
        
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
    
    return [[outputResults copy] autorelease];
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
    [allPosts_ release];
    [searchResults_ release];
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
        NSLog(@"Search table view selected a row");
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

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"Purging search results");
    self.allPosts = nil;
    self.searchResults = nil;
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"go get all posts");
    
    self.allPosts = [APP_DELEGATE.dataController allPosts];
}

@end

