//
//  NewsgroupAppDelegate.h
//  Newsgroup
//
//  Created by Jim Kubicek on 2/10/11.
//  Copyright 2011 Jim Kubicek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPDataController.h"


#define APP_DELEGATE ((NewsgroupAppDelegate *)[UIApplication sharedApplication].delegate)

@interface NewsgroupAppDelegate : NSObject <UIApplicationDelegate, GPDataControllerDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;

}

// Properties
@property (nonatomic, retain) GPDataController *dataController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSArray *toolbarItems;
@property (nonatomic, retain) IBOutlet UIWindow *window;

// Utility Methods
- (NSURL *)applicationDocumentsDirectory;
- (void)newPost:(id)sender;
- (void)refreshData:(id)sender;

@end

