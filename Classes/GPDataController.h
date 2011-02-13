//
//  GPDataController.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUser.h"
#import "GPThread.h"
#import "GPPost.h"


@interface GPDataController : NSObject {

    @private
    NSManagedObjectContext *context_;
    NSManagedObjectModel *model_;
    
}

// Begin and end fetching
- (BOOL)isFetching;
- (void)startFetching;
- (void)stopFetching;

// FetchedResultsControllers
- (NSFetchedResultsController *)allThreads;


@end
