//
//  FetchedResultsViewController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/15/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "GPDataController.h"
#import "NewsgroupAppDelegate.h"

@interface FetchedResultsViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    
@private
    NSFetchedResultsController *fetchedResultsController_;

}

- (void)newPost:(id)sender;

@end
