/*
 *  FetchedResultsViewController+PrivateHeader.h
 *  Newsgroup
 *
 *  Created by Jim Kubicek on 2/15/11.
 *  Copyright 2011 jimkubicek.com. All rights reserved.
 *
 */

@class TDBadgedCell;

// UIView tags for our custom cell
typedef enum _CustomCellViewTags {
    CustomCellSubjectLabelTag = 1,
    CustomCellPosterLabelTag = 2,
    CustomCellTimeLabelTag = 3,
    CustomCellUnreadImageViewTag = 4
} CustomCellViewTags;

@interface FetchedResultsViewController()

// Private Properties
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// Private Methods
- (void)configureCell:(UITableViewCell *)cell withPost:(Post *)post;
- (void)configureReadUnreadBadge:(TDBadgedCell *)cell withPost:(Post *)post readColor:(UIColor *)readColor unreadColor:(UIColor *)unreadColor;


@end
