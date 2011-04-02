/*
 *  FetchedResultsViewController+PrivateHeader.h
 *  Newsgroup
 *
 *  Created by Jim Kubicek on 2/15/11.
 *  Copyright 2011 jimkubicek.com. All rights reserved.
 *
 */

@interface FetchedResultsViewController()

// Private Properties
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

// Private Methods
- (void)configureCell:(UITableViewCell *)cell withPost:(Post *)post;


@end
