//
//  FetchedResultsViewController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/15/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "DataController.h"
#import "NewsgroupAppDelegate.h"

@class TDBadgedCell;

@interface FetchedResultsViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
@private
    NSFetchedResultsController *fetchedResultsController_;

}

@property (nonatomic, strong) IBOutlet TDBadgedCell *cell;

- (void)newPost:(id)sender;

@end
