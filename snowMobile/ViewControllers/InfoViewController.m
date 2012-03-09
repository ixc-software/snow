//
//  InfoViewController.m
//  snow
//
//  Created by Alex Vinogradov on 01.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
#import <MessageUI/MessageUI.h>
//#import "iphoneAppDelegate.h"
#import "CompanyAndUserConfiguration.h"
#import "CompanyStuff.h"
#import "mobileAppDelegate.h"

#import "ClientController.h"
//#import "SA_OAuthTwitterEngine.h"
#import "SocialNetworksAuthViewController.h"
#import "HelpForInfoView.h"
//#import "DarkView.h"
/* Define the constants below with the Twitter 
 Key and Secret for your application. Create
 Twitter OAuth credentials by registering your
 application as an OAuth Client here: http://twitter.com/apps/new
 */

//#define kOAuthConsumerKey				@"VUY8coMFF42XqEP2gQU5A"		//REPLACE With Twitter App OAuth Key  
//#define kOAuthConsumerSecret			@"tPeDllo8tHWy2ccTCpbcuruXbSkw32VZz4Bs2vGA"		//REPLACE With Twitter App OAuth Secret


@implementation InfoViewController
@synthesize errorToolBar;

@synthesize readme,operation,managedObjectContext,companyInfoAndConfig,operationProgress,socialNetworksViewController,imgButton;



- (void)dealloc
{
    [errorToolBar release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
    UIBarButtonItem *itemFor = [[[UIBarButtonItem alloc] initWithCustomView:self.errorToolBar] autorelease];
    [self setToolbarItems:[NSArray arrayWithObject:itemFor]];
    
    //self.title = @"Info";
    imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *twitter = [UIImage imageNamed:@"socialNetworks.png"];

//    UIImageView *imageView = [[UIImageView alloc] initWithImage:twitter];
    
    [imgButton setImage:twitter forState:UIControlStateNormal];
//    [imageView release];
    imgButton.opaque = NO;
    //imgButton.alpha = 0.5;
    
    imgButton.frame = CGRectMake(0.0, 0.0, 36 , 36);
    [imgButton addTarget:self action:@selector(authTwitterAccount) forControlEvents:UIControlEventTouchUpInside];
    //twitter = 0.5;
    UIBarButtonItem *twitterAuth = [[UIBarButtonItem alloc] initWithCustomView:imgButton];;
//
    self.navigationItem.rightBarButtonItem = twitterAuth;
    
    UISegmentedControl *segmented =  [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Info",@"Configuration", nil]] autorelease];
    [segmented addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    segmented.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
    segmented.segmentedControlStyle = UISegmentedControlStyleBar;
    segmented.selectedSegmentIndex = 0;
    
    UIView *titleView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, segmented.frame.size.width, segmented.frame.size.height)] autorelease];
    imgButton.frame = CGRectMake(imgButton.frame.origin.x + segmented.frame.size.width + 40, imgButton.frame.origin.y - 3, imgButton.frame.size.width, imgButton.frame.size.height);
    segmented.frame = CGRectMake(segmented.frame.origin.x + 20, segmented.frame.origin.y, segmented.frame.size.width, segmented.frame.size.height);

    [titleView addSubview:segmented];
    //[titleView addSubview:imgButton];
    self.navigationItem.titleView = titleView;
    
//    [twitterAuth release];
    //self.readme.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:0.8];
    //self.view.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:0.8];
    //self.readme.textColor = [UIColor whiteColor];

    NSError *error;
    //NSLog(@"className of readme is \"%@\".", [self.readme class]);
    
    NSString *string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"README" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    //if (!string) NSLog(@"%@",[error localizedDescription]);
    readme.text = string;
    //readme.text = @"";
    BOOL isPad;
    NSRange range = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if(range.location==NSNotFound) isPad=NO;
    else isPad=YES;
    //NSLog(@"Current device is :%@",isPad ? @"iPad" : @"iPhone");
    
    if (isPad) { 
        CGRect frame = self.readme.frame;
        frame.size = CGSizeMake(728, 964);
        self.readme.frame = frame; 
        self.operationProgress.frame = CGRectMake(operationProgress.frame.origin.x, operationProgress.frame.origin.y, operationProgress.frame.size.width + 450, operationProgress.frame.size.height);
        self.operation.frame = CGRectMake(operation.frame.origin.x, operation.frame.origin.y, operation.frame.size.width + 450, operation.frame.size.height);


    }
    
    if (!self.companyInfoAndConfig) {
        CompanyAndUserConfiguration *companyConfig = [[CompanyAndUserConfiguration alloc] initWithStyle:UITableViewStyleGrouped];
        companyConfig.infoController = self;
//        companyConfig.userController = self.userController;
        companyConfig.managedObjectContext = self.managedObjectContext;
        //companyConfig.tabBarItem = self.tabBarItem;
        //NSLog(@"%@",companyConfig.tabBarItem);
        /*NSString *email = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
        NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
        
        NSManagedObjectContext *context = self.managedObjectContext;
        
        NSError *error = nil;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(email == %@) AND (password == %@)",email,password];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:context];
        NSFetchRequest *companyStuffRequest = [[NSFetchRequest alloc] init];
        [companyStuffRequest setEntity:entity];
        [companyStuffRequest setResultType:NSManagedObjectIDResultType];
        [companyStuffRequest setPredicate:predicate];
        NSArray *companyStuff = [context executeFetchRequest:companyStuffRequest error:&error];
        predicate = nil;
        entity = nil;
        [companyStuffRequest release], companyStuffRequest = nil;
        
        if ([companyStuff count] > 1) NSLog(@"WARNING, duplicate company stuff with list:%@",companyStuff);
        CompanyStuff *findedStuff = [companyStuff lastObject];
        companyConfig.stuff = findedStuff;*/
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:companyConfig];
        [companyConfig release];
        //[self.tabBarItem]
        //UITabBarController *tabBar = self.tabBarController;
        //tabBar.selectedViewController = nav;
        self.companyInfoAndConfig = nav;
        [nav release];
        
        //[nav release];
        //[self.companyInfoAndConfig.view addSubview:self.tabBarController.view];
    }
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //self.readme.alpha = 0.8;
    
    //DarkView *darkView = [[DarkView alloc] init];
    //[self.navigationController.view addSubview:darkView.view];
    //NSLog(@"COLOR:%@",self.view.backgroundColor);
    readme.userInteractionEnabled = YES;
    

}

-(void)helpShowingDidFinish;
{
    self.navigationController.view.alpha = 1.0;
}

- (void)viewDidUnload
{
    [self setErrorToolBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
//    readme.userInteractionEnabled = YES;

//    float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if(iOSVersion <= 4.3){
//        //[[tabBarController tabBar] insertSubview:viewa aboveSubview:self.tabBarController.view];
//        
//    }else{
//        //iOS5
//        CGRect frame = CGRectMake(0, 0, 400, 148);
//        UIView *viewa = [[UIView alloc] initWithFrame:frame];
//        UIImage *tabBarBackgroundImage = [UIImage imageNamed:@"background.png"];
//        UIColor *color = [[UIColor alloc] initWithPatternImage:tabBarBackgroundImage];
//        [viewa setBackgroundColor:color];
//        [viewa setAlpha:0.5];
//        [[self.tabBarController tabBar] insertSubview:viewa aboveSubview:self.tabBarController.view];
//        
//        [color release];
//        [viewa release];
//        
//    }
//    
//    
//    
//    for(UIView *view in self.tabBarController.tabBar.subviews) {  
//        if([view isKindOfClass:[UIImageView class]]) {  
//            [view removeFromSuperview];  
//        }  
//    }  
//    
//    
//    
//    UIImageView *newViewInfo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_30x30.png"]] autorelease];
//    
//    UIImageView *newViewEvents = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"events.png"]] autorelease];
//    
//    UIImageView *newViewRoutes = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"apple-update_0_30x30-1.png"]] autorelease];
//    
//    
//    if ([delegate isPad]) {
//        newViewInfo.frame = CGRectMake(258, 5, 30, 30);
//        newViewEvents.frame = CGRectMake(372, 5, 30, 30);
//        newViewRoutes.frame = CGRectMake(480, 5, 30, 30);
//        
//    } else {
//        newViewInfo.frame = CGRectMake(38, 5, 30, 30);
//        newViewEvents.frame = CGRectMake(147, 5, 30, 30);
//        newViewRoutes.frame = CGRectMake(252, 5, 30, 30);
//    }
//    
//    [self.tabBarController.tabBar insertSubview:newViewInfo belowSubview:self.tabBarController.view];
//    [self.tabBarController.tabBar insertSubview:newViewEvents belowSubview:self.tabBarController.view];
//    [self.tabBarController.tabBar insertSubview:newViewRoutes belowSubview:self.tabBarController.view];
//    
//    UIBarItem *info = [self.tabBarController.tabBar.items objectAtIndex:0];
//    
//    info.title = @"Info and config";
//    info = [self.tabBarController.tabBar.items objectAtIndex:1];
//    info.title = @"Events";
//    
//    info = [self.tabBarController.tabBar.items objectAtIndex:2];
//    info.title = @"Routes";
    
//    for(UIView *view in self.tabBarController.tabBar.subviews) {  
//        if([view isKindOfClass:[UIImageView class]]) {  
//            [view removeFromSuperview];  
//        }  
//    }  
//    UIImageView *newViewInfo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_30x30.png"]] autorelease];
//    
//    UIImageView *newViewEvents = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"events.png"]] autorelease];
//
//    UIImageView *newViewRoutes = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"apple-update_0_30x30-1.png"]] autorelease];
//
//    
//    if ([delegate isPad]) {
//        newViewInfo.frame = CGRectMake(258, 5, 30, 30);
//        newViewEvents.frame = CGRectMake(372, 5, 30, 30);
//        newViewRoutes.frame = CGRectMake(480, 5, 30, 30);
//
//    } else {
//        newViewInfo.frame = CGRectMake(38, 5, 30, 30);
//        newViewEvents.frame = CGRectMake(147, 5, 30, 30);
//        newViewRoutes.frame = CGRectMake(252, 5, 30, 30);
//    }
//    
//    [self.tabBarController.tabBar insertSubview:newViewInfo atIndex:0];
//    [self.tabBarController.tabBar insertSubview:newViewEvents atIndex:1];
//    [self.tabBarController.tabBar insertSubview:newViewRoutes atIndex:2];
//
//    UIBarItem *info = [self.tabBarController.tabBar.items objectAtIndex:0];
//    
//    info.title = @"Info and config";
//    info = [self.tabBarController.tabBar.items objectAtIndex:1];
//    info.title = @"Events";
//    
//    info = [self.tabBarController.tabBar.items objectAtIndex:2];
//    info.title = @"Routes";


    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    UIImageView *reachabilityView = delegate.reachabilityImageView;
    [barButton setCustomView:reachabilityView];
    self.navigationItem.leftBarButtonItem = barButton;
    [barButton release];
    
    HelpForInfoView *helpView = [[HelpForInfoView alloc] init];
    
    helpView.isInfoSheet = YES;
    if ([helpView isHelpNecessary]) {
        self.navigationController.view.alpha = 0.8;
        helpView.delegate = self;
        [self.tabBarController.view addSubview:helpView.view];
    } else [helpView release];
    [readme removeFromSuperview];
    [self.navigationController.view addSubview:readme];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Mail compose view controller delegate method

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void) sendMailCompose
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    NSArray *toRecipients = [NSArray arrayWithObjects:@"iphone@ixcglobal.com",
                             nil];
    NSString *subject = [NSString stringWithFormat:@"snow ixc opinion"];
    [picker setSubject:subject];
    [picker setToRecipients:toRecipients];
    //NSLog(@"%@",subject);
    
    [self presentModalViewController:picker animated:YES];
    
    
}

-(void) changeView:(id)sender;
{
    UISegmentedControl *control = sender;
    if ([control selectedSegmentIndex] == 0) {
    //NSLog(@"plu0");
    }
    if ([control selectedSegmentIndex] == 1) {
        //NSLog(@"plu1");
        self.companyInfoAndConfig.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        //self.view.frame = CGRectMake(0, 0, 300, 300);
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
        if ([clientController authorization]) { 
            [self presentModalViewController:companyInfoAndConfig animated:YES];
            control.selectedSegmentIndex = 0;
        } else {
            [self.navigationController setToolbarHidden:NO animated:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                sleep(3);
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [self.navigationController setToolbarHidden:YES animated:YES];

                });
            });
        }
//        [clientController release];
    }
    
}
-(void) authTwitterAccount
{
    //NSLog(@"authTwitter");
    // Twitter Initialization / Login Code Goes Here
//    if(!_engine){  
//        _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
//        _engine.consumerKey    = kOAuthConsumerKey;  
//        _engine.consumerSecret = kOAuthConsumerSecret;  
//    }  	
//    
//    if(![_engine isAuthorized]){  
//        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];  
//        
//        if (controller){  
//            [self presentModalViewController: controller animated: YES];  
//        }  
//    }    
    

    
    if (!socialNetworksViewController) {
        NSRange range = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
        NSString *finalNib = nil;
        if(range.location==NSNotFound) finalNib = @"SocialNetworksAuthViewController";
        else finalNib = @"SocialNetworksAuthViewControlleriPad";
        socialNetworksViewController = [[SocialNetworksAuthViewController alloc] initWithNibName:finalNib bundle:[NSBundle mainBundle]];
        socialNetworksViewController.infoViewController = self;
        //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tw];
        //tw.infoController = nav;
        //[nav release];

    }
//    if (![tw isTwitterAuthorized]) {
        //[self dismissModalViewControllerAnimated:YES];
        socialNetworksViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentModalViewController:socialNetworksViewController animated:YES];
//    }
}

-(IBAction)updateTwitter:(id)sender
{

    
	
	//Twitter Integration Code Goes Here
    //[_engine sendUpdate:@"test"];
}



@end
