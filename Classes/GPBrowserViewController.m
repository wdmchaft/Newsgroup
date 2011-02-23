    //
//  GPBrowserViewController.m
//  Newsgroup
//
//  Created by Jim Kubicek on 2/18/11.
//  Copyright 2011 jimkubicek.com. All rights reserved.
//

#import "GPBrowserViewController.h"

@interface GPBrowserViewController()

- (void)setupURLLabel;

@end

@implementation GPBrowserViewController

#pragma mark -
#pragma mark Object Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup the URL Label
    [self setupURLLabel];
    
    // Setup activity indicator

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [self setRefreshButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [refreshButton_ release];
    [url_ release];
    [urlLabel_ release];
    [webView_ release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

@synthesize refreshButton = refreshButton_;
@synthesize url = url_;
@synthesize urlLabel = urlLabel_;
@synthesize webView = webView_;

- (void)setUrl:(NSURL *)url {
    [url retain];
    [url_ release];
    url_ = url;
    
    [self setupURLLabel];
    
}

#pragma mark Instance Methods

- (IBAction)actionButton:(id)sender {
    NSLog(@"ACTION!");
}

- (void)setupURLLabel {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    self.urlLabel.text = [url_ absoluteString];
}

#pragma -
#pragma UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"start loading");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"finished loading");
}
@end
