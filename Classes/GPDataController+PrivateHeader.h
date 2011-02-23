/*
 * This private header allows test cases to access private 
 * GPDataController methods without generating a compiler error.
 */

@class GPHTTPOperation;

@interface GPDataController()

// Class methods
+ (NSURL *)defaultManagedObjectModelURL;


// Init methods
- (id)initWithModelURL:(NSURL *)modelURL andStoreURL:(NSURL *)storeURL;


// Instance Methods
- (void)startFetchWithHTTPController:(GPHTTPOperation *)controller;

@end
