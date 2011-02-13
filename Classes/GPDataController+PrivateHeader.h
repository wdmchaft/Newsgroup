/*
 * This private header allows test cases to access private 
 * GPDataController methods without generating a compiler error.
 */

@interface GPDataController()

- (id)initWithStoreURL:(NSURL *)url;

@end
