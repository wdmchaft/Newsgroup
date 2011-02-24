/*
 * This private header allows test cases to access private 
 * GPDataController methods without generating a compiler error.
 */

@class GPHTTPOperation;
@class ASIHTTPRequest;


@interface GPDataController()

// Class methods
+ (NSURL *)defaultManagedObjectModelURL;


// Init methods
- (id)initWithModelURL:(NSURL *)modelURL andStoreURL:(NSURL *)storeURL;


// Instance Methods
- (void)loadNewPosts:(NSArray *)postDict intoContext:(NSManagedObjectContext *)context;
- (BOOL)startFetchWithHTTPRequest:(ASIHTTPRequest *)request andError:(NSError **)error;

@end
