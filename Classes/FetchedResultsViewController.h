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

@interface FetchedResultsViewController : UIViewController {
    
@private
    NSFetchedResultsController *fetchedResultsController_;

}

@end
