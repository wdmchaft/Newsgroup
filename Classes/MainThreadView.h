//
//  MainThreadView.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "FetchedResultsViewController.h"

@interface MainThreadView : FetchedResultsViewController {

}

@property (retain) NSArray *searchResults;

@end
