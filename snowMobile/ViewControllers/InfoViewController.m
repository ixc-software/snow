//
//  InfoViewController.m
//  snow
//
//  Created by Alex Vinogradov on 01.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"
#import <MessageUI/MessageUI.h>
#import "CompanyAndUserConfiguration.h"
#import "CompanyStuff.h"
#import "CurrentCompany.h"
#import "Carrier.h"
#import "mobileAppDelegate.h"

#import "ClientController.h"
#import "SocialNetworksAuthViewController.h"
#import "HelpForInfoView.h"


@implementation InfoViewController
@synthesize wellcomeTitle;
@synthesize wellcomeSubTitle;
@synthesize companyName;
@synthesize income;
@synthesize profit;
@synthesize profitability;
@synthesize routesQuantityWeBuy;
@synthesize routesQuantityForSale;
@synthesize routesQuantityPushList;
@synthesize carriersQuantity;
@synthesize routesTitle;
@synthesize errorToolBar;

@synthesize readme,operation,managedObjectContext,companyInfoAndConfig,operationProgress,socialNetworksViewController,imgButton;



- (void)dealloc
{
    [errorToolBar release];
    [wellcomeTitle release];
    [wellcomeSubTitle release];
    [companyName release];
    [income release];
    [profit release];
    [profitability release];
    [routesQuantityWeBuy release];
    [routesQuantityForSale release];
    [routesQuantityPushList release];
    [carriersQuantity release];
    [routesTitle release];
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

    imgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *twitter = [UIImage imageNamed:@"socialNetworks.png"];
    [imgButton setImage:twitter forState:UIControlStateNormal];
    imgButton.opaque = NO;
    
    imgButton.frame = CGRectMake(0.0, 0.0, 36 , 36);
    [imgButton addTarget:self action:@selector(authTwitterAccount) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *twitterAuth = [[UIBarButtonItem alloc] initWithCustomView:imgButton];

    self.navigationItem.rightBarButtonItem = twitterAuth;
    [twitterAuth release];
    UISegmentedControl *segmented =  [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Info",@"Configuration", nil]] autorelease];
    [segmented addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    segmented.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
    segmented.segmentedControlStyle = UISegmentedControlStyleBar;
    segmented.selectedSegmentIndex = 0;
    
    UIView *titleView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, segmented.frame.size.width, segmented.frame.size.height)] autorelease];

    [titleView addSubview:segmented];
    self.navigationItem.titleView = titleView;
    NSError *error;
    
    NSString *string = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"README" ofType:@"txt"] encoding:NSUTF8StringEncoding error:&error];
    //if (!string) NSLog(@"%@",[error localizedDescription]);
    readme.text = string;
    BOOL isPad;
    NSRange range = [[[UIDevice currentDevice] model] rangeOfString:@"iPad"];
    if(range.location==NSNotFound) isPad=NO;
    else isPad=YES;
    
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
        companyConfig.managedObjectContext = self.managedObjectContext;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:companyConfig];
        [companyConfig release];
        self.companyInfoAndConfig = nav;
        [nav release];
    }
    readme.userInteractionEnabled = YES;
    

}

-(void)helpShowingDidFinish;
{
    self.navigationController.view.alpha = 1.0;
}

- (void)viewDidUnload
{
    [self setErrorToolBar:nil];
    [self setWellcomeTitle:nil];
    [self setWellcomeSubTitle:nil];
    [self setCompanyName:nil];
    [self setIncome:nil];
    [self setProfit:nil];
    [self setProfitability:nil];
    [self setRoutesQuantityWeBuy:nil];
    [self setRoutesQuantityForSale:nil];
    [self setRoutesQuantityPushList:nil];
    [self setCarriersQuantity:nil];
    [self setRoutesTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}
-(void) updateMainBoard;
{
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
    CompanyStuff *admin = [clientController authorization];
    [clientController release];
    routesQuantityWeBuy.hidden = YES;
    routesQuantityForSale.hidden = YES;
    routesQuantityPushList.hidden = YES;
    routesTitle.text = @"Routes";
    
    if (admin) {
        
        wellcomeTitle.text = [NSString stringWithFormat:@"Wellcome, %@ %@",admin.firstName,admin.lastName];
        NSString *subTitle = nil;
        if ([admin.currentCompany.companyAdminGUID isEqualToString:admin.GUID]) subTitle = @"you are company admin of:";
        else subTitle = @"you are community part of the company:";
        companyName.text = admin.currentCompany.name;
        NSString *totalProfit = [[NSUserDefaults standardUserDefaults] valueForKey:@"totalProfit"];
        NSString *totalIncome = [[NSUserDefaults standardUserDefaults] valueForKey:@"totalIncome"];
        NSString *savedProfitability = [[NSUserDefaults standardUserDefaults] valueForKey:@"profitability"];
        if (totalProfit) profit.text = totalProfit;
        else profit.text = @"";
        if (totalIncome) income.text = totalIncome;
        else income.text = @"";
        if (savedProfitability) profitability.text = savedProfitability;
        else profitability.text = @"";
        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListPushList" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(carrier.companyStuff.GUID == %@)",admin.GUID];
        [fetchRequest setPredicate:predicate];
        NSInteger count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (count > 0) { 
            routesQuantityPushList.hidden = NO;
            routesQuantityPushList.text = [NSString stringWithFormat:@"pushlist:%@",[NSNumber numberWithInteger:count]];
        }
        else routesQuantityPushList.hidden = YES;
        
        entity = [NSEntityDescription entityForName:@"DestinationsListWeBuy" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        predicate = [NSPredicate predicateWithFormat:@"(carrier.companyStuff.GUID == %@) and (lastUsedMinutesLenght > 0)",admin.GUID];
        [fetchRequest setPredicate:predicate];
        count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (count > 0) { 
            routesQuantityWeBuy.hidden = NO;
            routesQuantityWeBuy.text = [NSString stringWithFormat:@"we buy:%@",[NSNumber numberWithInteger:count]];
            routesTitle.text = @"Routes with traffic";
        }
        else { 
            //            routesQuantityWeBuy.hidden = YES;
            //            routesTitle.text = @"Routes";
            
        }
        entity = [NSEntityDescription entityForName:@"DestinationsListForSale" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        predicate = [NSPredicate predicateWithFormat:@"(carrier.companyStuff.GUID == %@) and (lastUsedMinutesLenght > 0)",admin.GUID];
        [fetchRequest setPredicate:predicate];
        count = [self.managedObjectContext countForFetchRequest:fetchRequest error:&error];
        if (count > 0) { 
            routesQuantityForSale.hidden = NO;
            routesQuantityForSale.text = [NSString stringWithFormat:@"we sell:%@",[NSNumber numberWithInteger:count]];
            routesTitle.text = @"Routes with traffic";
            
        }
        else {
            //            routesQuantityForSale.hidden = YES;
            //            routesTitle.text = @"Routes";
            
        }
        carriersQuantity.text = [NSNumber numberWithInteger:admin.carrier.count].description;
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];

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
    [self updateMainBoard];
    //[readme removeFromSuperview];
    //[self.navigationController.view addSubview:readme];
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
        
        [clientController release];
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
