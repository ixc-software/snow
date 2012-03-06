//
//  TwitterAuthController.m
//  snow
//
//  Created by Oleksii Vynogradov on 24.08.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "TwitterAuthorizationController.h"
#import "TwitterUpdateDataController.h"
#import "InfoViewController.h"
#import "LinkedinUpdateDataController.h"

@implementation TwitterAuthorizationController

@synthesize authorize,back,pin,webView,infoController,twitterController,activity,isAuthorizationProcessed,countTremorAnimation,infoViewController,linkedinController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) performPinTremorIsMovingLeft:(BOOL)isMovingLeft isFirstStep:(BOOL)isFirstStep;
{
    if (isFirstStep) { 
        countTremorAnimation = 0;
    }
    [UIView animateWithDuration:0.05 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (isMovingLeft) [pin.layer setFrame:CGRectMake(pin.frame.origin.x + 5, pin.frame.origin.y, pin.frame.size.width, pin.frame.size.height)]; else [pin.layer setFrame:CGRectMake(pin.frame.origin.x - 5, pin.frame.origin.y, pin.frame.size.width, pin.frame.size.height)];
                     } 
                     completion:^(BOOL finished){
                         countTremorAnimation++;
                         if (countTremorAnimation < 4) [self performPinTremorIsMovingLeft:!isMovingLeft isFirstStep:NO]; 
                         else authorize.selectedSegmentIndex = -1;

                     }];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    webView.delegate = self;
    
    [authorize removeAllSegments];
    [authorize insertSegmentWithTitle:@"authorize" atIndex:0 animated:NO];
    [authorize addTarget:self action:@selector(didAuthorization:) forControlEvents:UIControlEventValueChanged];
    authorize.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];

    [back removeAllSegments];
    [back insertSegmentWithTitle:@"Back" atIndex:0 animated:NO];
    [back addTarget:self action:@selector(backToInfoViewController:) forControlEvents:UIControlEventValueChanged];
    back.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
    
    if (!twitterController) twitterController = [[TwitterUpdateDataController alloc] init];
    twitterController.delegate = self;
    
    if (!linkedinController) linkedinController = [[LinkedinUpdateDataController alloc] init];
    linkedinController.delegate = self;
    
    activity.hidden = NO;
    [activity startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

        //[twitterController startAuthorization:self];
        [linkedinController startAuthorization:self];
    });
    
    isAuthorizationProcessed = NO;
    // Do any additional setup after loading the view from its nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        //[twitterController startAuthorization:self];
        //[linkedinController startAuthorization:self];
        //linkedinController
    });

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backToInfoViewController:(id)sender {
    self.infoController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    back.selectedSegmentIndex = -1;
    authorize.selectedSegmentIndex = -1;

    [self dismissModalViewControllerAnimated:YES];
    //[self presentModalViewController:infoController animated:YES];
}

-(void) didAuthorization:(id) sender;
{
    if ([pin.text isEqualToString:@""] || [pin.text length] != 7) { 
        
        [self performPinTremorIsMovingLeft:NO isFirstStep:YES];

    }
    else {
        twitterController.twitterPIN = pin.text;
        
        if (!isAuthorizationProcessed ) {
            isAuthorizationProcessed = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                [twitterController finishAuthorization:self];
                isAuthorizationProcessed = NO;
            });
        }
        activity.hidden = NO;
        [activity startAnimating];
//        self.infoController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//        back.selectedSegmentIndex = -1;
//        authorize.selectedSegmentIndex = -1;
//        
//        
//        [self dismissModalViewControllerAnimated:YES];
    }
    //[self presentModalViewController:infoController animated:YES];
 
}
-(void)twitterAuthSuccess;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [activity stopAnimating];
        activity.hidden = YES;
        self.infoViewController.imgButton.alpha = 1.0;
        
        self.infoController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        back.selectedSegmentIndex = -1;
        authorize.selectedSegmentIndex = -1;
        
        
        [self dismissModalViewControllerAnimated:YES];
    });
}
-(void)twitterAuthFailed;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [self performPinTremorIsMovingLeft:NO isFirstStep:YES];
    });
}

-(BOOL)isAuthorized;
{
    if (twitterController) return twitterController.isAuthorized;
    else return NO;
}

-(void) sendUpdate:(NSString *)text;
{
    if (twitterController) [twitterController postTwitterMessageWithText:text];
}

-(void)startTwitterAuthForURL:(NSURL *)url;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        NSLog(@"START URL:%@",url);

        [webView loadRequest:[NSURLRequest requestWithURL:url]];
    });

}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        activity.hidden = YES;
        [activity stopAnimating];
    });
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        activity.hidden = NO;
        [activity startAnimating];
    });

}
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType 
{
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
    NSLog(@"CALLBACK URL:%@",urlString);

    
    BOOL requestForCallbackURL = ([urlString rangeOfString:@"hdlinked://linkedin/oauth"].location != NSNotFound);
    if ( requestForCallbackURL )
    {
        BOOL userAllowedAccess = ([urlString rangeOfString:@"user_refused"].location == NSNotFound);
        if ( userAllowedAccess )
        {            
            //self.linkedinController.accessToken.verifier =  url;
            [linkedinController finishAuthorization:self withUrl:url];
            //NSLog(@"VERIFIER URL:%@",self.linkedinController.accessToken.verifier);

        }
        else
        {
            // User refused to allow our app access
            // Notify parent and close this view
        }
    }
    else
    {
        // Case (a) or (b), so ignore it
    }
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqualToString:@""]) return NO;
    else {
        [self didAuthorization:self];
        return YES;
    }
    
}


@end
