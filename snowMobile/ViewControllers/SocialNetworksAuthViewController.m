//
//  TwitterAuthController.m
//  snow
//
//  Created by Oleksii Vynogradov on 24.08.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "SocialNetworksAuthViewController.h"
#import "TwitterUpdateDataController.h"
#import "InfoViewController.h"
#import "LinkedinUpdateDataController.h"
#import "mobileAppDelegate.h"
#import "DestinationsListPushList.h"

@implementation SocialNetworksAuthViewController
@synthesize groupsToMessage;
@synthesize saveChanges;
@synthesize reloadButton;
@synthesize authorizedDoneLogo;
@synthesize authorizedDoneTitle;
@synthesize twitterEnabled;
@synthesize linkedinEnabled;
@synthesize facebookEnabled;
@synthesize groupsActivity;
@synthesize changeAuthorizationType;
@synthesize groupsList;
@synthesize groupsBack;
@synthesize groupsView;

@synthesize authorize,back,pin,webView,infoController,twitterController,activity,isAuthorizationProcessed,countTremorAnimation,infoViewController,linkedinController,cellInfo,groupListObjects,isGroupToPostSelected,groupListObjectsForCollectAllGroups;


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
    [groupListObjectsForCollectAllGroups release];
    [changeAuthorizationType release];
    [groupsList release];
    [groupsBack release];
    [groupsView release];
    [groupListObjects release];
    [twitterEnabled release];
    [linkedinEnabled release];
    [facebookEnabled release];
    [authorizedDoneLogo release];
    [authorizedDoneTitle release];
    [reloadButton release];
    [groupsActivity release];
    [groupsToMessage release];
    [saveChanges release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
-(void) performWebKitTremorIsMovingLeft:(BOOL)isMovingLeft isFirstStep:(BOOL)isFirstStep;
{
    if (isFirstStep) { 
        countTremorAnimation = 0;
    }
    [UIView animateWithDuration:0.05 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (isMovingLeft) [webView.layer setFrame:CGRectMake(webView.frame.origin.x + 5, webView.frame.origin.y, webView.frame.size.width, webView.frame.size.height)]; else [webView.layer setFrame:CGRectMake(webView.frame.origin.x - 5, webView.frame.origin.y, webView.frame.size.width, webView.frame.size.height)];
                     } 
                     completion:^(BOOL finished){
                         countTremorAnimation++;
                         if (countTremorAnimation < 4) [self performWebKitTremorIsMovingLeft:!isMovingLeft isFirstStep:NO]; 
                         else authorize.selectedSegmentIndex = -1;
                         
                     }];
    
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
    [authorize addTarget:self action:@selector(didTwitterAuthorization:) forControlEvents:UIControlEventValueChanged];
    authorize.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];

    [back removeAllSegments];
    [back insertSegmentWithTitle:@"Back" atIndex:0 animated:NO];
    [back addTarget:self action:@selector(backToInfoViewController:) forControlEvents:UIControlEventValueChanged];
    
    [groupsBack removeAllSegments];
    [groupsBack insertSegmentWithTitle:@"Back" atIndex:0 animated:NO];
    [groupsBack addTarget:self action:@selector(backToInfoViewController:) forControlEvents:UIControlEventValueChanged];

    [saveChanges removeAllSegments];
    [saveChanges insertSegmentWithTitle:@"Save" atIndex:0 animated:NO];
    [saveChanges addTarget:self action:@selector(saveMessageChanges:) forControlEvents:UIControlEventValueChanged];


    back.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
    
    if (!twitterController) twitterController = [[TwitterUpdateDataController alloc] init];
    twitterController.delegate = self;
    
    if (!linkedinController) linkedinController = [[LinkedinUpdateDataController alloc] init];
    linkedinController.delegate = self;
    
    activity.hidden = NO;
    [activity startAnimating];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

        [twitterController startAuthorization:self];
        //[linkedinController startAuthorization:self];
    });
    
    isAuthorizationProcessed = NO;
    isGroupToPostSelected = YES;
    
    groupListObjects = [[NSMutableArray alloc] init];
    groupListObjectsForCollectAllGroups = [[NSMutableArray alloc] init];
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
    [self setChangeAuthorizationType:nil];
    [self setGroupsList:nil];
    [self setGroupsBack:nil];
    [self setGroupsView:nil];
    [self setTwitterEnabled:nil];
    [self setLinkedinEnabled:nil];
    [self setFacebookEnabled:nil];
    [self setAuthorizedDoneLogo:nil];
    [self setAuthorizedDoneTitle:nil];
    [self setReloadButton:nil];
    [self setGroupsActivity:nil];
    [self setGroupsToMessage:nil];
    [self setSaveChanges:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - internal methods

-(NSMutableString *)stringFromObjectIDs:(NSArray *)objecIDs includeRates:(BOOL) isIncludeRates;
{
    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = delegate.managedObjectContext;
    NSMutableString *finalString = [NSMutableString string];
    NSNumberFormatter *rateFormatter = [[NSNumberFormatter alloc] init];
    [rateFormatter setMaximumFractionDigits:5];
    [rateFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

    [objecIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
        //DestinationsListPushList *object = (DestinationsListPushList *)[context objectWithID:objectID];
        NSManagedObject *object = [context objectWithID:objectID];
        NSString *country = [object valueForKey:@"country"];
        NSString *specific = [object valueForKey:@"specific"];
        NSNumber *rateNumber = [object valueForKey:@"rate"];
        NSString *rate = [rateFormatter stringFromNumber:rateNumber];
        [rateFormatter setMaximumFractionDigits:0];

        NSString *minutesLenght = nil;
        if ([object.entity.name isEqualToString:@"DestinationsListPushList"]) {
            minutesLenght = [rateFormatter stringFromNumber:[object valueForKey:@"minutesLenght"]];
        } else {
            minutesLenght = [rateFormatter stringFromNumber:[object valueForKey:@"lastUsedMinutesLenght"]];
        }
        if (isIncludeRates) [finalString appendString:[NSString stringWithFormat:@"%@/%@ with price $%@ volume %@",country,specific,rate,minutesLenght]];
        else [finalString appendString:[NSString stringWithFormat:@"%@/%@ volume %@",country,specific,rate,minutesLenght]];
        
        if (objecIDs.count > 1 && idx != objecIDs.count -1) [finalString appendString:@"\n"]; 
    }];
    return finalString;
}

#pragma mark - action methods


- (IBAction)backToInfoViewController:(id)sender {
    self.infoController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    back.selectedSegmentIndex = -1;
    authorize.selectedSegmentIndex = -1;
    groupsBack.selectedSegmentIndex = -1;
    
    [self dismissModalViewControllerAnimated:YES];
    //[self presentModalViewController:infoController animated:YES];
}

-(void) didTwitterAuthorization:(id) sender;
{
    if ([pin.text isEqualToString:@""] || [pin.text length] != 7) { 
        
        [self performPinTremorIsMovingLeft:NO isFirstStep:YES];

    }
    else {
        [pin resignFirstResponder];

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

- (IBAction)changeAuthorizationType:(id)sender {
    if (changeAuthorizationType.selectedSegmentIndex == 0) {
        // twitter authorization
        groupsView.hidden = YES;

        if (twitterController.isAuthorized) {
            webView.hidden = YES;
            authorizedDoneLogo.hidden = NO;
            authorizedDoneTitle.hidden = NO;
            pin.hidden = YES;
            authorize.hidden = YES;
            reloadButton.hidden = YES;
            [authorize addTarget:self action:@selector(didTwitterAuthorization:) forControlEvents:UIControlEventValueChanged];

        } else {
            back.hidden = NO;
            webView.hidden = NO;
            authorizedDoneLogo.hidden = YES;
            authorizedDoneTitle.hidden = YES;
            pin.hidden = NO;
            authorize.hidden = NO;
            reloadButton.hidden = NO;
            [twitterController startAuthorization:self];
            //authorize.hidden = YES;//[authorize addTarget:self action:@selector(didTwitterAuthorization:) forControlEvents:UIControlEventValueChanged];

        }

    }
    
    if (changeAuthorizationType.selectedSegmentIndex == 1) {
        // linkedin authorization
        groupsView.hidden = NO;

        if (linkedinController.isAuthorized) {
            webView.hidden = YES;
            authorizedDoneLogo.hidden = NO;
            authorizedDoneTitle.hidden = NO;
            pin.hidden = YES;
            authorize.hidden = YES;
            reloadButton.hidden = YES;

        } else {
            webView.hidden = NO;
            authorizedDoneLogo.hidden = YES;
            authorizedDoneTitle.hidden = YES;
            pin.hidden = NO;
            authorize.hidden = NO;
            reloadButton.hidden = NO;
            [linkedinController startAuthorization:self];
        }
    }

}

- (IBAction)changeGroupsToPostToGroupsMessage:(id)sender {
    if (groupsToMessage.selectedSegmentIndex == 0) {
       // groups 
        isGroupToPostSelected = YES;
        groupsList.rowHeight = 45;

        [groupsList reloadData];
        
    } else {
       // message
        isGroupToPostSelected = NO;
        groupsList.rowHeight = 200;

        [groupsList reloadData];

    }
}
- (IBAction)saveMessageChanges:(id)sender {
    saveChanges.selectedSegmentIndex = -1;
    LinkedinGroupsTableViewCell *cell = (LinkedinGroupsTableViewCell *)[groupsList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.signature resignFirstResponder];
    [cell.bodyForEdit resignFirstResponder];
    [cell.postingTitle resignFirstResponder];
    
    [[NSUserDefaults standardUserDefaults] setValue:cell.bodyForEdit.text forKey:@"bodyForEdit"];
    [[NSUserDefaults standardUserDefaults] setValue:cell.signature.text forKey:@"signature"];
    [[NSUserDefaults standardUserDefaults] setValue:cell.postingTitle.text forKey:@"postingTitle"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:cell.includeRates.on] forKey:@"includeRates"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [sender setHidden:YES];
}
- (IBAction)routesListIncludePriceChanged:(id)sender {
    NSNumber *includeRates = [[NSUserDefaults standardUserDefaults] valueForKey:@"includeRates"];

    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:!includeRates.boolValue] forKey:@"includeRates"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Twitter controller delegates


-(void)twitterAuthSuccess;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        webView.hidden = YES;
        authorizedDoneLogo.hidden = NO;
        authorizedDoneTitle.hidden = NO;
        pin.hidden = YES;
        authorize.hidden = YES;
        reloadButton.hidden = YES;
        [activity stopAnimating];
        activity.hidden = YES;
        self.infoViewController.imgButton.alpha = 1.0;
        
        self.infoController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        back.selectedSegmentIndex = -1;
        authorize.selectedSegmentIndex = -1;
        //[twitterController postTwitterMessageWithText:@"Hey from new api Snow IXC"];
        [twitterEnabled setImage:[UIImage imageNamed:@"enabledPoint.png"]];
        
        //[self dismissModalViewControllerAnimated:YES];
    });
}
-(void)twitterAuthFailed;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [self performPinTremorIsMovingLeft:NO isFirstStep:YES];
    });
}

-(void)startTwitterAuthForURL:(NSURL *)url;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        NSLog(@"startTwitterAuthForURL:%@",url);
        [authorize setEnabled:YES];
        [pin setEnabled:YES];

        [webView loadRequest:[NSURLRequest requestWithURL:url]];
    });
    
}


#pragma mark - Twitter methods

-(BOOL)isTwitterAuthorized;
{
    if (twitterController) return twitterController.isAuthorized;
    else return NO;
}

-(void) sendTwitterUpdate:(NSArray *)managedObjectIDs;
{
//    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
//    NSManagedObjectContext *moc = delegate.managedObjectContext;

    [managedObjectIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
        NSMutableString *finalDestinationsListString = [self stringFromObjectIDs:[NSArray arrayWithObject:objectID] includeRates:YES];
        NSMutableString *twitterText = [[NSMutableString alloc] initWithCapacity:0];
        [twitterText appendString:@"I'm currently interesting for those destination:"];
        [twitterText appendString:@"\n"];

        [twitterText appendString:finalDestinationsListString];
        [twitterText appendString:@"\n"];

        [twitterText appendString:@"(posted from snow ixc)"];
        if (twitterText.length > 139) [twitterText replaceCharactersInRange:NSMakeRange(139,twitterText.length - 139) withString:@""];
        NSLog(@"SOCIAL NETWORK CONTROLLER: twitter message to post:%@",twitterText);
        
        if (twitterController) [twitterController postTwitterMessageWithText:twitterText];

    }];
    
//    if (twitterController) [twitterController postTwitterMessageWithText:text];
}

#pragma mark - Linkedin controller delegates


-(void)linkedinAuthSuccess;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        [linkedinController getGroupsStart:0 count:10];
        webView.hidden = YES;
        authorizedDoneLogo.hidden = NO;
        authorizedDoneTitle.hidden = NO;
        pin.hidden = YES;
        authorize.hidden = YES;
        reloadButton.hidden = YES;
        back.hidden = YES;
        groupsBack.hidden = YES;
        
        [activity stopAnimating];
        activity.hidden = YES;
        self.infoViewController.imgButton.alpha = 1.0;
        
        self.infoController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        back.selectedSegmentIndex = -1;
        authorize.selectedSegmentIndex = -1;
        //[twitterController postTwitterMessageWithText:@"Hey from new api Snow IXC"];
        [linkedinEnabled setImage:[UIImage imageNamed:@"enabledPoint.png"]];
        
        groupsView.frame = CGRectMake(groupsView.frame.origin.x, groupsView.frame.origin.y + groupsView.frame.size.height + 45, groupsView.frame.size.width, groupsView.frame.size.height);
        [self.view addSubview:groupsView];
        [UIView animateWithDuration:2 
                              delay:0 
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             groupsView.frame = CGRectMake(groupsView.frame.origin.x, groupsView.frame.origin.y - groupsView.frame.size.height, groupsView.frame.size.width, groupsView.frame.size.height);
                         } 
                         completion:^(BOOL finished){
                             groupsBack.hidden = NO;

                         }];
        
        
        //[self dismissModalViewControllerAnimated:YES];
    });
}
-(void)linkedinAuthFailed;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [self performWebKitTremorIsMovingLeft:NO isFirstStep:YES];
    });
}

-(void)linkedinAuthForURL:(NSURL *)url;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        NSLog(@"LINKEDIN START URL:%@",url);

        [webView loadRequest:[NSURLRequest requestWithURL:url]];
    });
    
}

-(void)linkedinGroupsList:(NSDictionary *)parsedGroups withLatestGroups:(NSNumber *)isLatestGroup;
{
    //[self.groupListObjects removeAllObjects];
    NSMutableArray *finalGroupsList = [[NSUserDefaults standardUserDefaults] valueForKey:@"allGroupList"];
//    
    //NSMutableArray *finalGroupsList = 
    NSArray *groupsListParsed = [parsedGroups valueForKey:@"values"];
    [groupsListParsed enumerateObjectsUsingBlock:^(NSDictionary *group, NSUInteger idx, BOOL *stop) {
        NSDictionary *groupInfo = [group valueForKey:@"group"];
        NSMutableDictionary *groupInfoMutable = [NSMutableDictionary dictionaryWithDictionary:groupInfo];
        [groupInfoMutable setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
        
        NSNumber *idNumber = [groupInfo valueForKey:@"id"];
        //NSString *name = [groupInfo valueForKey:@"name"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id == %@",idNumber];
        NSArray *filteredFinalGroupList = [finalGroupsList filteredArrayUsingPredicate:predicate];
        if (filteredFinalGroupList.count > 0) [groupInfoMutable setValue:[filteredFinalGroupList.lastObject valueForKey:@"enabled"] forKey:@"enabled"]; 
        else [groupInfoMutable setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
        [groupListObjectsForCollectAllGroups addObject:groupInfoMutable];
        //NSLog(@"SOCIAL NETWORKS AUTH: ADD NEW group name:%@ id:%@",idNumber,name);
        
    }];
//    [[NSUserDefaults standardUserDefaults] setValue:self.groupListObjects forKey:@"allGroupList"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (isLatestGroup.boolValue == YES) {
        // ok buffer is done now, time to check 
        [groupListObjects removeAllObjects];
        [groupListObjects addObjectsFromArray:groupListObjectsForCollectAllGroups];
        
        [[NSUserDefaults standardUserDefaults] setValue:self.groupListObjects forKey:@"allGroupList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [groupsList reloadData];
    } else [groupListObjectsForCollectAllGroups setValuesForKeysWithDictionary:parsedGroups];
}

#pragma mark - Linkedin methods

-(BOOL)isLinkedinAuthorized;
{
    if (linkedinController) return linkedinController.isAuthorized;
    else return NO;
}
-(void) postToLinkedinGroups:(NSArray *)managedObjectIDs;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"enabled = %@",[NSNumber numberWithBool:YES]];
    NSArray *enabledGroups = [groupListObjects filteredArrayUsingPredicate:predicate];
    NSString *postingTitle = [[NSUserDefaults standardUserDefaults] valueForKey:@"postingTitle"];
    NSNumber *includeRates = [[NSUserDefaults standardUserDefaults] valueForKey:@"includeRates"];
    NSString *bodyForEdit = [[NSUserDefaults standardUserDefaults] valueForKey:@"bodyForEdit"];
    NSString *signature = [[NSUserDefaults standardUserDefaults] valueForKey:@"signature"];

    [enabledGroups enumerateObjectsUsingBlock:^(NSMutableDictionary *group, NSUInteger idx, BOOL *stop) {
        NSString *groupID = [group valueForKey:@"id"];
        NSString *name = [group valueForKey:@"name"];

        NSMutableString *linkedinText = [[NSMutableString alloc] initWithCapacity:0];
        [linkedinText appendString:bodyForEdit];
        [linkedinText appendString:@"\n"];
        NSMutableString *finalDestinationsListString = [self stringFromObjectIDs:managedObjectIDs includeRates:includeRates.boolValue];
        [linkedinText appendString:finalDestinationsListString];
        [linkedinText appendString:@"\n"];
        [linkedinText appendString:@"\n"];

        [linkedinText appendString:signature];
        [linkedinText appendString:@"\n"];

        [linkedinText appendString:@"(posted from snow ixc)"];

        NSLog(@"SOCIAL NETWORK CONTROLLER: linkedin message for group:%@ to post:%@",linkedinText,name);

        if (linkedinController.isAuthorized) [linkedinController postToGroupID:groupID withTitle:postingTitle withSummary:linkedinText];        
    }];
}

#pragma mark - WebKit delegate

- (void)webViewDidFinishLoad:(UIWebView *)webViewCheck
{
    //NSLog(@"finished:%@",webViewCheck.request.URL);
    if ([webViewCheck.request.URL.absoluteString rangeOfString:@"https://api.twitter.com/oauth/authorize?oauth_token="].location != NSNotFound){
        //NSLog(@"SCROLL:%@",webViewCheck.request.URL);

        [webViewCheck.scrollView scrollRectToVisible:CGRectMake(0, 500, 100, 100) animated:YES];
    }
    if ([webViewCheck.request.URL.absoluteString rangeOfString:@"https://api.twitter.com/oauth/authorize"].location != NSNotFound){
        //NSLog(@"SCROLL:%@",webViewCheck.request.URL);
        
        [webViewCheck.scrollView scrollRectToVisible:CGRectMake(0, 350, 100, 100) animated:YES];
    }

    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        activity.hidden = YES;
        [activity stopAnimating];
    });
}
- (void)webViewDidStartLoad:(UIWebView *)webViewCheck
{
    NSLog(@"started:%@",webViewCheck.request.URL);

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

#pragma mark - UITextField delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 1) {
        saveChanges.hidden = NO;
    } 
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 0) {
        if ([textField.text isEqualToString:@""]) return NO;
        else {
            [textField resignFirstResponder];
            [self didTwitterAuthorization:self];
            return YES;
        }
    } 
    
    return YES;

}
#pragma mark - UITextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    saveChanges.hidden = NO;
    return YES;
}
#pragma mark - GroupList table view delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //NSLog(@"numberOfRowsInSection:%u",groupListObjects.count);
    if (isGroupToPostSelected) return groupListObjects.count;
    else return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"groups";
    
    LinkedinGroupsTableViewCell *cell = (LinkedinGroupsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UINib *quoteCellNib = [UINib nibWithNibName:@"LinkedinGroupsTableViewCell" bundle:nil];
        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = self.cellInfo;
        self.cellInfo = nil;
    }
    if (isGroupToPostSelected == YES) { 
        NSMutableDictionary *row = [groupListObjects objectAtIndex:indexPath.row];
        NSString *groupName = [row valueForKey:@"name"];
        NSNumber *enabled = [row valueForKey:@"enabled"];
        
        cell.groupName.text = groupName;
        if (cell.groupSwitch.on != enabled.boolValue) {
            if (enabled.boolValue == YES) {
                [cell.groupSwitch setOn:YES];
            } else {
                [cell.groupSwitch setOn:NO];
                
            }
        }
        cell.groupName.hidden = NO;
        cell.groupSwitch.hidden = NO;
        cell.bodyForEdit.hidden = YES;
        cell.signature.hidden = YES;
        cell.postingTitle.hidden = YES;
        cell.includeRates.hidden = YES;
        cell.routesList.hidden = YES;

    } else {
        cell.groupName.hidden = YES;
        cell.groupSwitch.hidden = YES;
        cell.bodyForEdit.hidden = NO;
        cell.signature.hidden = NO;
        cell.postingTitle.hidden = NO;
        cell.includeRates.hidden = NO;
        cell.routesList.hidden = NO;
        cell.bodyForEdit.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"bodyForEdit"];
        cell.signature.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"signature"];
        cell.postingTitle.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"postingTitle"];
        cell.includeRates.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"includeRates"] boolValue];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *row = [groupListObjects objectAtIndex:indexPath.row];
    NSNumber *enabled = [row valueForKey:@"enabled"];
//    LinkedinGroupsTableViewCell *cell = (LinkedinGroupsTableViewCell *)[groupsList cellForRowAtIndexPath:indexPath];
//    if (cell.groupSwitch.on != enabled.boolValue) {
//        if (enabled.boolValue == YES) {
//            [cell.groupSwitch setOn:YES];
//        } else {
//            [cell.groupSwitch setOn:NO];
//        }
//    }
    [row setValue:[NSNumber numberWithBool:!enabled.boolValue] forKey:@"enabled"];
    [groupsList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [[NSUserDefaults standardUserDefaults] setValue:self.groupListObjects forKey:@"allGroupList"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
@end
