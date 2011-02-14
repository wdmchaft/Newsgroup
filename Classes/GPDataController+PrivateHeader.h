/*
 * This private header allows test cases to access private 
 * GPDataController methods without generating a compiler error.
 */

@interface GPDataController()

+ (NSURL *)defaultManagedObjectModelURL;

- (id)initWithModelURL:(NSURL *)modelURL andStoreURL:(NSURL *)storeURL;

@end
