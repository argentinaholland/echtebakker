//
//  facebookViewController.m
//  EchteBakker
//
//  Created by Matias Altalef on 8/21/12.
//
//

#import "FacebookViewController.h"

@interface FacebookViewController ()

@end

@implementation FacebookViewController
@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bakkerFacebookFeed" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:filePath encoding:NSStringEncodingConversionAllowLossy error:nil];
    NSLog(@" AAA  A  %@", html);
    [webView loadHTMLString:html baseURL:baseURL];
    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [webView release];
    [super dealloc];
}
@end
