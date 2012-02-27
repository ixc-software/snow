//
//  DarkView.m
//  snow
//
//  Created by Oleksii Vynogradov on 07.11.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import "AuthorizationView.h"
#import "ClientController.h"
#import "mobileAppDelegate.h"
#import "InfoViewController.h"
#import "CompanyAndUserConfiguration.h"

#import "CompanyStuff.h"
#import "CurrentCompany.h"

#import <QuartzCore/QuartzCore.h>

@implementation AuthorizationView
@synthesize companyName;
@synthesize emailAndPassword;
@synthesize login;
@synthesize registration;
@synthesize logo;

//@synthesize email,password,company;

@synthesize countTremorAnimation;

@synthesize isEmailPasswordBlockMoved,isJoinStarted;
@synthesize loginActivity;
@synthesize errorMessage;
@synthesize firstSocialNetwork;

@synthesize emailLabel,passwordLabel,companyNameLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
        // Custom initialization
    }
    return self;
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
    [login removeAllSegments];
    [login insertSegmentWithTitle:@"Login" atIndex:0 animated:NO];
    [login addTarget:self action:@selector(login:) forControlEvents:UIControlEventValueChanged];

    [registration removeAllSegments];
    [registration insertSegmentWithTitle:@"Registration" atIndex:0 animated:NO];
    [registration addTarget:self action:@selector(registration:) forControlEvents:UIControlEventValueChanged];

    [emailAndPassword setBackgroundColor:self.view.backgroundColor];

//    logo.layer.shadowColor = [UIColor whiteColor].CGColor;
//    logo.layer.shadowOffset = CGSizeMake(5, 5);
//    logo.layer.shadowOpacity = 1;
//    logo.layer.shadowRadius = 5.0;
//
    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegate isPad]){
        [emailAndPassword setBackgroundView:nil];
        [emailAndPassword setBackgroundView:[[[UIView alloc] init] autorelease]];
        self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, 768.0, 1024.0);
        CGFloat delta = 220;
        logo.frame = CGRectMake(logo.frame.origin.x + delta, logo.frame.origin.y, logo.frame.size.width, logo.frame.size.height);
        companyName.frame = CGRectMake(companyName.frame.origin.x + delta, companyName.frame.origin.y, companyName.frame.size.width, companyName.frame.size.height);
        firstSocialNetwork.frame = CGRectMake(firstSocialNetwork.frame.origin.x + delta, firstSocialNetwork.frame.origin.y + 500, firstSocialNetwork.frame.size.width, firstSocialNetwork.frame.size.height);
        //NSLog(@"first:%@",NSStringFromCGPoint(firstSocialNetwork.frame.origin));
        login.frame = CGRectMake(login.frame.origin.x + 30 , login.frame.origin.y + 30, login.frame.size.width, login.frame.size.height);
        registration.frame = CGRectMake(registration.frame.origin.x + 420 , registration.frame.origin.y + 30, registration.frame.size.width, registration.frame.size.height);
        loginActivity.frame = CGRectMake(loginActivity.frame.origin.x + delta , loginActivity.frame.origin.y + 20, loginActivity.frame.size.width, loginActivity.frame.size.height);

    }
   
    [logo.layer setShadowOffset:CGSizeMake(0, 3)];
    [logo.layer setShadowOpacity:0.8];
    [logo.layer setShadowRadius:15.0f];
    [logo.layer setShouldRasterize:YES];
    
    [logo.layer setCornerRadius:15.0f];
    [logo.layer setShadowPath:
     [[UIBezierPath bezierPathWithRoundedRect:[logo.layer bounds]
                                 cornerRadius:15.0f] CGPath]];
    logo.layer.shadowColor = [UIColor whiteColor].CGColor;

    //    logo.layer.cornerRadius = 15.0;
//    logo.layer.borderColor = [UIColor blackColor].CGColor;
//    logo.layer.borderWidth = 1.0;

    // Do any additional setup after loading the view from its nib.
//    email = [[NSMutableString alloc] init];
//    password = [[NSMutableString alloc] init];
//    company = [[NSMutableString alloc] init];

    [emailAndPassword canBecomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setEmailAndPassword:nil];
    [self setRegistration:nil];
    [self setLogin:nil];
    [self setRegistration:nil];
    [self setLogo:nil];
    [self setCompanyName:nil];
    [self setLoginActivity:nil];
    [self setErrorMessage:nil];
    [self setFirstSocialNetwork:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [emailAndPassword release];
    [login release];
    [registration release];
    [logo release];
//    [email release];
//    [password release];
     
    [emailLabel release];
    [passwordLabel release];
    [companyNameLabel release];
     
    [companyName release];
    [loginActivity release];
    [errorMessage release];
    [firstSocialNetwork release];
    [super dealloc];
}



#pragma mark -
#pragma mark Table view delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 2;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    //NSLog(@"%@",indexPath);

    static NSString *SpecificsCellIdentifier = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:SpecificsCellIdentifier];

    if (!cell) {    
        cell = [[[UITableViewCell alloc] init] autorelease];
        cell.opaque = NO;

        UITextField *label = nil ;

        NSString *placeHolder = nil;
        BOOL isSecured = NO;
        if (indexPath.section == 0) {
            if (indexPath.row == 0) placeHolder = @"email (required)";
            if (indexPath.row == 1) { 
                placeHolder = @"password (required)";
                isSecured = YES;
            }
        }
        if (indexPath.section == 0) { 
            if (indexPath.row == 0) {
                if (!emailLabel) { 
                    emailLabel = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 260, 30)] ;
                    emailLabel.delegate = self;

                }
                label = emailLabel;
                
            }
            if (indexPath.row == 1) {
                if (!passwordLabel) { 
                    passwordLabel = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 260, 30)];
                    passwordLabel.delegate = self;

                }
                label = passwordLabel;
            }
        }

        
        if (indexPath.section == 1) { 
            if (!companyNameLabel) { 
                companyNameLabel = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, 260, 30)];
                companyNameLabel.delegate = self;
            }
            label = companyNameLabel;
 
            placeHolder = @"company name (required for registration)";
//            label = [[[UITextField alloc] initWithFrame:CGRectMake(20, 12, 260, 30)] autorelease];
            label.font = [UIFont systemFontOfSize:14];

        } //else label = [[[UITextField alloc] initWithFrame:CGRectMake(20, 10, 260, 30)] autorelease];

        label.autocorrectionType = UITextAutocorrectionTypeNo;
        label.autocapitalizationType = UITextAutocapitalizationTypeNone;
        label.secureTextEntry = isSecured;
        label.placeholder = placeHolder;

        [cell.contentView addSubview:label];

    }
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    //[emailAndPassword resignFirstResponder];
//    UITableViewCell *cellForEditing = [emailAndPassword cellForRowAtIndexPath:indexPath];
//    cellForEditing.editing = YES;
//    
//}

#pragma mark -
#pragma mark Animation block
-(void) showErrorMessage:(NSString *)message
{
    [errorMessage removeAllSegments];
    [errorMessage insertSegmentWithTitle:message atIndex:0 animated:NO];

    [UIView animateWithDuration:2 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         errorMessage.alpha = 1;
                         
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:2 
                                               delay:3 
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              errorMessage.alpha = 0;
                                          }
                                          completion:nil];
                     }];
}

-(void) minimizeLogoAndCompanyName
{
    if (!isEmailPasswordBlockMoved) {
        isEmailPasswordBlockMoved = YES;

        [UIView animateWithDuration:0.2 
                              delay:0 
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             [logo.layer setFrame:CGRectMake(logo.frame.origin.x - 100, logo.frame.origin.y, logo.frame.size.width / 2, logo.frame.size.height / 2)];
                             [companyName.layer setFrame:CGRectMake(companyName.frame.origin.x - 25, companyName.frame.origin.y - 75, companyName.frame.size.width / 2, companyName.frame.size.height / 2)];
                             [emailAndPassword.layer setFrame:CGRectMake(emailAndPassword.frame.origin.x, emailAndPassword.frame.origin.y - 80, emailAndPassword.frame.size.width, emailAndPassword.frame.size.height)];
                         } 
                         completion:^(BOOL finished){
                             [logo.layer setShadowOffset:CGSizeMake(0, 1)];
                             [logo.layer setShadowOpacity:0.4];
                             [logo.layer setShadowRadius:4.0f];
                             [logo.layer setShouldRasterize:YES];
                             
                             [logo.layer setCornerRadius:4.0f];
                             [logo.layer setShadowPath:
                              [[UIBezierPath bezierPathWithRoundedRect:[logo.layer bounds]
                                                          cornerRadius:4.0f] CGPath]];
                             logo.layer.shadowColor = [UIColor whiteColor].CGColor;
                         }];
    }
}

-(void) maximizeLogoAndCompanyName
{
    [UIView animateWithDuration:0.2 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [logo.layer setFrame:CGRectMake(logo.frame.origin.x + 100, logo.frame.origin.y, logo.frame.size.width * 2, logo.frame.size.height * 2)];
                         [companyName.layer setFrame:CGRectMake(companyName.frame.origin.x + 25, companyName.frame.origin.y + 75, companyName.frame.size.width * 2, companyName.frame.size.height * 2)];
                         [emailAndPassword.layer setFrame:CGRectMake(emailAndPassword.frame.origin.x, emailAndPassword.frame.origin.y + 80, emailAndPassword.frame.size.width, emailAndPassword.frame.size.height)];
                     } 
                     completion:^(BOOL finished){
                         [logo.layer setShadowOffset:CGSizeMake(0, 3)];
                         [logo.layer setShadowOpacity:0.8];
                         [logo.layer setShadowRadius:15.0f];
                         [logo.layer setShouldRasterize:YES];
                         
                         [logo.layer setCornerRadius:15.0f];
                         [logo.layer setShadowPath:
                          [[UIBezierPath bezierPathWithRoundedRect:[logo.layer bounds]
                                                      cornerRadius:15.0f] CGPath]];
                         logo.layer.shadowColor = [UIColor whiteColor].CGColor;
                         isEmailPasswordBlockMoved = NO;

                     }];
}


-(void) performEmailPasswordTremorIsMovingLeft:(BOOL)isMovingLeft isFirstStep:(BOOL)isFirstStep;
{
    if (isFirstStep) { 
        countTremorAnimation = 0;
    }
    [UIView animateWithDuration:0.05 
                          delay:0 
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         if (isMovingLeft) [emailAndPassword.layer setFrame:CGRectMake(emailAndPassword.frame.origin.x + 5, emailAndPassword.frame.origin.y, emailAndPassword.frame.size.width, emailAndPassword.frame.size.height)]; else [emailAndPassword.layer setFrame:CGRectMake(emailAndPassword.frame.origin.x - 5, emailAndPassword.frame.origin.y, emailAndPassword.frame.size.width, emailAndPassword.frame.size.height)];
                     } 
                     completion:^(BOOL finished){
                         countTremorAnimation++;
                         if (countTremorAnimation < 6) [self performEmailPasswordTremorIsMovingLeft:!isMovingLeft isFirstStep:NO]; 
     }];
    
}

-(BOOL)checkIfEmailAndPasswordFilledForLogin:(BOOL)isLogin
{
    NSArray *emailParts = [emailLabel.text componentsSeparatedByString:@"@"];
    NSArray *secondPartEmailParts = nil;
    if ([emailParts count] > 1 ) {
        NSString *secondPartOfEmail = [emailParts objectAtIndex:1];
        if (secondPartOfEmail) secondPartEmailParts = [secondPartOfEmail componentsSeparatedByString:@"."];
    }
    if (isLogin) {
        if ([emailLabel.text isEqualToString:@""] || [emailParts count] < 2 || [passwordLabel.text isEqualToString:@""] || !secondPartEmailParts || [secondPartEmailParts count] < 2 ) [self performEmailPasswordTremorIsMovingLeft:NO isFirstStep:YES];  else return YES;
    } else {
        if ([companyNameLabel.text isEqualToString:@""] || [emailLabel.text isEqualToString:@""] || [emailParts count] < 2 || [passwordLabel.text isEqualToString:@""] || !secondPartEmailParts || [secondPartEmailParts count] < 2 ) [self performEmailPasswordTremorIsMovingLeft:NO isFirstStep:YES];  else return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark Control clock
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [login setEnabled:YES forSegmentAtIndex:0];
        [registration setEnabled:YES forSegmentAtIndex:0];
        loginActivity.hidden = YES;
        [loginActivity stopAnimating];

    }
    if (buttonIndex == 1) {
        // user like to join to company
        isJoinStarted = YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
            CompanyStuff *admin = [clientController authorization];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:clientController.moc];
            [fetchRequest setEntity:entity];
            NSError *error = nil;
            NSArray *fetchedObjects = [clientController.moc executeFetchRequest:fetchRequest error:&error];
            [fetchRequest release];
            //            if ([fetchedObjects count] > 1) {
            //NSLog(@"UIActionSheet starterd");
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@) AND (companyAdminGUID != %@)",companyNameLabel.text,admin.GUID];
            NSArray *filtered = [fetchedObjects filteredArrayUsingPredicate:predicate];
            CurrentCompany *companyForJoin = [filtered lastObject];
            if (companyForJoin && [filtered count] == 1) {
                admin.currentCompany = companyForJoin;
                [clientController finalSave:clientController.moc];
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:admin.objectID] mustBeApproved:YES];
            } else [self showErrorMessage:@"company for join don't finded"];
            [clientController release];
            

        });


    }
    if (buttonIndex == 2) {
        // user don't like to join to company, create company with same name
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
            CompanyStuff *admin = [clientController authorization];
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin.currentCompany objectID]] mustBeApproved:NO];
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin objectID]] mustBeApproved:NO];
            [clientController release];

        });
        
    }

}

-(void)finalizeRegisterIssuesForLogin:(BOOL)isLogin;
{
    
    [login setEnabled:NO forSegmentAtIndex:0];
    [registration setEnabled:NO forSegmentAtIndex:0];
    loginActivity.hidden = NO;
    [loginActivity startAnimating];
    [emailAndPassword resignFirstResponder];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        CompanyStuff *admin = [clientController authorization];
        if (admin) {
            admin.email = emailLabel.text;
            admin.password = passwordLabel.text;
            [clientController finalSave:clientController.moc];
            
            
            if (isLogin) {
                //NSString *returnString = [clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES];
                if ([clientController checkIfCurrentAdminCanLogin]) { 
                    // good, auth was passed
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        
                        [UIView animateWithDuration:3 
                                              delay:0 
                                            options:UIViewAnimationOptionBeginFromCurrentState
                                         animations:^{
                                             
                                             self.view.alpha = 0.0;
                                         } completion:nil];
                    });
                    
                    admin.isRegistrationDone = [NSNumber numberWithBool:YES];
                    [clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES isUserAuthorized:YES];
                    [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin objectID]] mustBeApproved:NO];
                }
            } else {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:delegate.managedObjectContext];
                [fetchRequest setEntity:entity];
                NSError *error = nil;
                NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                [fetchRequest release];
                //            if ([fetchedObjects count] > 1) {
                //NSLog(@"UIActionSheet starterd");
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@) AND (companyAdminGUID != %@)",companyNameLabel.text,admin.GUID];
                NSArray *filtered = [fetchedObjects filteredArrayUsingPredicate:predicate];
                if ([filtered count] > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:@"Company name already in list, do you like to join?" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@"Yes, i like to join,",@"No, i like to create company",nil] autorelease];
                        //iphoneAppDelegate *delegate = (iphoneAppDelegate *)[UIApplication sharedApplication].delegate;
                        
                        //[sheet showFromTabBar:delegate.tabBarController.tabBar];
                        [sheet showInView:self.view];
                    });
                    
                    //                }
                } else {
                    //                NSLog(@"registration starterd");
                    NSManagedObjectID *companyID = [admin.currentCompany objectID];
                    admin.currentCompany.name = companyNameLabel.text;
                    [clientController finalSave:clientController.moc];

                    [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:companyID] mustBeApproved:NO];
                    [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin objectID]] mustBeApproved:NO];
                }
            }
        } else { 
            [self showErrorMessage:@"please wait while first setup will done"];
            [login setEnabled:YES forSegmentAtIndex:0];
            [registration setEnabled:YES forSegmentAtIndex:0];
            loginActivity.hidden = YES;
            [loginActivity stopAnimating];
            [emailAndPassword resignFirstResponder];

        }
        [clientController release];
        
    });
    
}

- (IBAction)login:(id)sender {
    if ([self checkIfEmailAndPasswordFilledForLogin:YES]) {
        //do job here
        [emailLabel resignFirstResponder];
        [passwordLabel resignFirstResponder];
        [companyNameLabel resignFirstResponder];

        [self finalizeRegisterIssuesForLogin:YES];
    }

}

- (IBAction)registration:(id)sender {
    if ([self checkIfEmailAndPasswordFilledForLogin:NO]) {
        //do job here
        [emailLabel resignFirstResponder];
        [passwordLabel resignFirstResponder];
        [companyNameLabel resignFirstResponder];

        [self finalizeRegisterIssuesForLogin:NO];

    }

}

#pragma mark -
#pragma mark UITextField delegate
-(void) setNecessaryStringsForTextField:(UITextField *)textField
{
//    if ([textField.placeholder isEqualToString:@"email (required)"]) {
//        NSString *emailString = textField.text;
//        if (emailString) [email setString:emailString];
//                //NSLog(@"AUTHORIZATION: email changed to:%@",emailString);
//    }
//    if ([textField.placeholder isEqualToString:@"password (required)"]) {
//        NSString *passwordString = textField.text;
//        if (passwordString) [password setString:passwordString];
//                //NSLog(@"AUTHORIZATION: password changed to:%@",passwordString);
//        
//    }
//    if ([textField.placeholder isEqualToString:@"company name (required for registration)"]) {
//        NSString *companyString = textField.text;
//        if (companyString) [company setString:companyString];
//                //NSLog(@"AUTHORIZATION: companyString changed to:%@",companyString);
//        
//    }

}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self setNecessaryStringsForTextField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self setNecessaryStringsForTextField:textField];

    if ([self checkIfEmailAndPasswordFilledForLogin:YES]) {
        [textField resignFirstResponder];
        mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;

        if (![delegate isPad]) [self maximizeLogoAndCompanyName];
        return YES;
    } else return NO;
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;

    if (![delegate isPad]) [self minimizeLogoAndCompanyName];
    return YES;
}

#pragma mark -
#pragma mark - external reload methods

-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    //NSLog(@"AUTHORIZATION: data:%@",data);
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSManagedObjectID *objectID = nil;
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {             
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [login setEnabled:YES forSegmentAtIndex:0];
            [registration setEnabled:YES forSegmentAtIndex:0];
            loginActivity.hidden = YES;
            [loginActivity stopAnimating];
           
            [self showErrorMessage:status];
        });

    }
    
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    
    if (objectID) {
        mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
        NSManagedObject *updatedObject = [delegate.managedObjectContext objectWithID:objectID];

        if ([[[updatedObject entity] name] isEqualToString:@"CompanyStuff"]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (![isItLatestMessage boolValue])
                {
                    loginActivity.hidden = NO;
                    [loginActivity startAnimating];
                } else {
                    loginActivity.hidden = YES;
                    [loginActivity stopAnimating];
                    
                    if ([status isEqualToString:@"put object finish"] && ![isError boolValue] && isJoinStarted) { 
                        [self showErrorMessage:@"you request was sent to admin"];
                        [UIView animateWithDuration:3 
                                              delay:4 
                                            options:UIViewAnimationOptionBeginFromCurrentState
                                         animations:^{
                                             
                                             self.view.alpha = 0.0;
                                         } completion:nil];
                        
                    } else {
                        
                       [UIView animateWithDuration:3 
                                              delay:0 
                                            options:UIViewAnimationOptionBeginFromCurrentState
                                         animations:^{
                                             
                                             self.view.alpha = 0.0;
                                         } completion:nil];
                    }

                }
            });
        }
            
        }
}


@end
