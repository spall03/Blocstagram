//
//  BLCLoginViewController.m
//  Blocstagram
//
//  Created by Stephen Palley on 12/26/14.
//  Copyright (c) 2014 Steve Palley. All rights reserved.
//

#import "BLCLoginViewController.h"
#import "BLCDataSource.h"

@interface BLCLoginViewController () <UIWebViewDelegate>

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, strong) UIButton *homeButton;

@end

@implementation BLCLoginViewController

NSString *const BLCLoginViewControllerDidGetAccessTokenNotification = @"BLCLoginViewControllerDidGetAccessTokenNotification";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    NSMutableURLRequest *request = [self buildInstagramURL];
    self.title = @"Login";
    [self.webView loadRequest:request];

}

- (void)loadView {
    UIWebView *webView = [[UIWebView alloc] init];
    webView.delegate = self;
    
    
    self.webView = webView;
    self.view = webView;
    
    UIButton* newHomeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    newHomeButton.contentEdgeInsets = UIEdgeInsetsMake( 2, 2, 2, 2 ); // Let's add some padding to our button title
    [newHomeButton setTitle:NSLocalizedString(@"Home", @"Home button") forState:UIControlStateNormal];
    [newHomeButton addTarget:self action:@selector(homeButtonPressed:) forControlEvents:UIControlEventTouchUpInside]; // The target should be 'self', not 'self.webView', as UIWebView doesn't respond to this selector, homeButtonPressed:
    newHomeButton.backgroundColor = [UIColor redColor]; // Add a dash of color so we can see our button
    [newHomeButton sizeToFit]; // This will ask UIKit to resize the button appropriately, given the title we've given it.
    [newHomeButton setFrame:CGRectMake( 10, self.navigationController.navigationBar.frame.size.height + newHomeButton.frame.size.height, newHomeButton.frame.size.width, newHomeButton.frame.size.height)]; // Let's pin it to the top left corner, beneath our navigationBar title.
    self.homeButton = newHomeButton;
    
    [self.webView addSubview:self.homeButton];
    

}

- (void) homeButtonPressed:(UIButton *) sender
{
    NSMutableURLRequest *request = [self buildInstagramURL];
    
    [self.webView loadRequest:request];
    
}

- (NSMutableURLRequest *) buildInstagramURL
{
    NSString *urlString = [NSString stringWithFormat:@"https://instagram.com/oauth/authorize/?client_id=%@&scope=likes+comments+relationships&redirect_uri=%@&response_type=token", [BLCDataSource instagramClientID], [self redirectURI]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    return request;
}
     
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)redirectURI {
    return @"http://www.applymap.com";
}

- (void) dealloc {
    // Removing this line causes a weird flickering effect when you relaunch the app after logging in, as the web view is briefly displayed, automatically authenticates with cookies, returns the access token, and dismisses the login view, sometimes in less than a second.
    [self clearInstagramCookies];
    
    self.webView.delegate = nil;
}

/**
 Clears Instagram cookies. This prevents caching the credentials in the cookie jar.
 */
- (void) clearInstagramCookies {
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        NSRange domainRange = [cookie.domain rangeOfString:@"instagram.com"];
        if(domainRange.location != NSNotFound) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:[self redirectURI]]) {
        // This contains our auth token
        NSRange rangeOfAccessTokenParameter = [urlString rangeOfString:@"access_token="];
        NSUInteger indexOfTokenStarting = rangeOfAccessTokenParameter.location + rangeOfAccessTokenParameter.length;
        NSString *accessToken = [urlString substringFromIndex:indexOfTokenStarting]; //extract Instagram access token
        [[NSNotificationCenter defaultCenter] postNotificationName:BLCLoginViewControllerDidGetAccessTokenNotification object:accessToken];
        return NO;
    }
    
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
