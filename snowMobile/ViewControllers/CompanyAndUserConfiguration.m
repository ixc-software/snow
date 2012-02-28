//
//  CompanyAndUserConfiguration.m
//  snow
//
//  Created by Oleksii Vynogradov on 02.05.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "CompanyAndUserConfiguration.h"
#import "InfoViewController.h"
#import "CompanyAndUserInfoCell.h"
#import "CompanyStuff.h"
#import "CurrentCompany.h"
//#import "UserDataController.h"
#import "CompanyAddController.h"
#import "Carrier.h"
//#import "UniversalDataExchangeController.h"
#import "RegistrationsAvaitingApproveDetailViewController.h"
#import "mobileAppDelegate.h"
#import "Carrier.h"
#import "OperationNecessaryToApprove.h"
#import "ClientController.h"
#import "HelpForInfoView.h"
#import "CarrierListConroller.h"

@interface CompanyAndUserConfiguration()
//@property (nonatomic, retain) UniversalDataExchangeController *controller;
@property (nonatomic, retain)  NSIndexPath *previousSelectedCell;

@property (readwrite)  BOOL isAuthorized;
@property (readwrite)  BOOL isRegistered;
@property (readwrite)  BOOL isEdited;


@property (nonatomic, retain) UISegmentedControl *infoConfigurationChoice;

@property (nonatomic, retain) NSMutableString *rightCornerInfoBoxString;
@property (nonatomic, retain) UIColor *rightCornerInfoBoxColor;

@property (nonatomic, retain) UIView *viewUnderUserCompanyInfo;
@property (nonatomic, retain) UISegmentedControl *rightButtonUnderUserCompanyInfo;
@property (nonatomic, retain) UISegmentedControl *leftButtonUnderUserCompanyInfo;
@property (readwrite)  BOOL isEmailUnhangedWarning;
@property (readwrite)  BOOL isCompanyUnchangedWarning;
@property (readwrite)  BOOL isUserUnregisteredWarning;
@property (readwrite)  BOOL isUserCompanyAdminWarning;


@property (nonatomic,readwrite)  BOOL isCompanyUnregisteredWarning;


@property (readwrite)  BOOL isEmailWarning;
@property (readwrite)  BOOL isRegistrationProcessed;
@property (readwrite)  BOOL isRegistrationDone;

@property (readwrite)  BOOL isUpdatesProcessingNow;

@property (readwrite) NSInteger currentOperation;
@property (readwrite) NSInteger currentOperationStatus;

@property (nonatomic, retain) NSMutableArray *updatedCarriersIDs;

@property (nonatomic, retain) UIActivityIndicatorView *activity;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

//@property (nonatomic, retain) UniversalDataExchangeController *exchangeController;

@property (nonatomic, retain) NSMutableArray *operationsToApprove;

- (NSFetchedResultsController *)fetchedResultsController;
-(void) safeSave;


@end

@implementation CompanyAndUserConfiguration
@synthesize managedObjectContext,infoController,cellInfo,previousSelectedCell,isAuthorized,isEmailWarning,isRegistrationProcessed,isRegistered,isEdited,isEmailUnhangedWarning,isEditedCarriers, fetchedResultsController,isCompanyUnchangedWarning,isCompanyUnregisteredWarning,isRegistrationDone,currentOperation,currentOperationStatus,isUserUnregisteredWarning,isUserCompanyAdminWarning,infoConfigurationChoice,rightCornerInfoBoxColor,rightCornerInfoBoxString,isEditingNow,isUpdatingCarriers,updatedCarriersIDs,activity,stuffID,operationsToApprove,rightButtonUnderUserCompanyInfo,leftButtonUnderUserCompanyInfo,isUpdatesProcessingNow,viewUnderUserCompanyInfo;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)dealloc
{
    [operationsToApprove release];
    [rightCornerInfoBoxString release];
//    [exchangeController release];
    [infoConfigurationChoice release];
    [updatedCarriersIDs release];
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{

    [super viewDidLoad];
    UIImage *preferences = [UIImage imageNamed:@"GeneralPreferences.tiff"];
    //UIBarButtonItem *config = [[UIBarButtonItem alloc] initWithImage:preferences style:UIBarButtonItemStylePlain target:self action:@selector(config:)];
    UIButton *preferencesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [preferencesButton setImage:preferences forState:UIControlStateNormal];
    [preferencesButton setImage:preferences forState:UIControlStateSelected];
    [preferencesButton addTarget:self action:@selector(config:) forControlEvents:UIControlEventTouchUpInside];
    preferencesButton.frame = CGRectMake(0,0,preferences.size.width,preferences.size.height);
    
    //config.width = preferences.size.width;
    UIBarButtonItem *config = [[UIBarButtonItem alloc] initWithCustomView:preferencesButton];
    
    self.navigationItem.leftBarButtonItem = config;
    [config release];

    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *activityBar = [[UIBarButtonItem alloc] initWithCustomView:activity];
    self.navigationItem.rightBarButtonItem = activityBar;
    [activityBar release];

    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.20 blue:0.52 alpha:1.0];
    
    infoConfigurationChoice =  [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Info",@"Configuration", nil]];
    [self.infoConfigurationChoice addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    self.infoConfigurationChoice.tintColor = [UIColor colorWithRed:0.2 green:0.20 blue:0.52 alpha:1.0];
    self.infoConfigurationChoice.segmentedControlStyle = UISegmentedControlStyleBar;
    self.infoConfigurationChoice.selectedSegmentIndex = 1;
    self.navigationItem.titleView = infoConfigurationChoice;
    self.rightCornerInfoBoxColor = [UIColor greenColor];
    rightCornerInfoBoxString = [[NSMutableString alloc] init];
    updatedCarriersIDs = [[NSMutableArray alloc] init];
    
    //self.tableView.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:0.8];
    //self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;

    self.tableView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.57 alpha:1.0];
    
    self.tableView.sectionHeaderHeight = 45;

    self.tableView.allowsSelectionDuringEditing = YES;
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];

    //self.stuff = [clientController authorization];
    
    self.stuffID = [[clientController authorization] objectID];
    [clientController release];

//    if (!self.stuff) {
//        self.stuff = [userController defaultUser]; 
//    } else isAuthorized = YES;
    NSAssert (stuffID != nil,@"can't find stuff");
//    isRegistrationProcessed = [stuff.isRegistrationProcessed boolValue];
//    isRegistered = [stuff.isRegistrationDone boolValue];

    NSError *error = nil;

    if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}	

//    if (!exchangeController) {
//        exchangeController = [[UniversalDataExchangeController alloc] init];
//        exchangeController.moc = self.managedObjectContext;
//    }

   /* NSArray *allObjects = [fetchedResultsController fetchedObjects];
    [allObjects enumerateObjectsWithOptions:NSSortStable usingBlock:^(Carrier *carrier, NSUInteger idx, BOOL *stop) {
     NSString *status = [userController localStatusForObjectsWithRootGuid:carrier.GUID];
     if (status && [status isEqualToString:@"object uploaded"] && [[userController localStatusForObjectsWithRootGuid:stuff.GUID] isEqualToString:@"finish"]) { 
         NSArray *keys = [[[stuff entity] attributesByName] allKeys];
         NSDictionary *dict = [stuff dictionaryWithValuesForKeys:keys];
         
         NSDictionary *opjectsForRegistration = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:carrier], @"new", carrier.GUID, @"rootObjectGUID", nil];

         [userController startRegistrationForObjects:opjectsForRegistration
                                        forTableView:self.tableView 
                                           forSender:self 
                                 clientStuffFullInfo:dict];
     }
    }];*/
    mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate isPad]) {
        [self.tableView setBackgroundView:nil];
        [self.tableView setBackgroundView:[[[UIView alloc] init] autorelease]];
    }
    operationsToApprove = [[NSMutableArray alloc] init];
//    CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
//    NSSet *operations = updated.currentCompany.operationNecessaryToApprove;
//    [operations enumerateObjectsUsingBlock:^(OperationNecessaryToApprove *operation, BOOL *stop) {
//        [operationsToApprove addObject:[operation objectID]]; 
//    }];
    
    isUpdatesProcessingNow = NO;
    if (!viewUnderUserCompanyInfo) viewUnderUserCompanyInfo = [[UIView alloc] initWithFrame:CGRectMake(100, 20, 30, 30)];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    
//    NSManagedObjectContext *mocForUpdates =  [[NSManagedObjectContext alloc] init];
//    [mocForUpdates setPersistentStoreCoordinator:[self.userController.context persistentStoreCoordinator]];
//    [mocForUpdates setUndoManager:nil];
    
    CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
//    NSString *updatedGUID = [NSString stringWithString:updated.GUID];
    CurrentCompany *currentCompany = updated.currentCompany;
    if ([updated.GUID isEqualToString:currentCompany.companyAdminGUID]) {
        NSSet *operations = currentCompany.operationNecessaryToApprove;
        [operationsToApprove removeAllObjects];
        [operations enumerateObjectsUsingBlock:^(OperationNecessaryToApprove *operation, BOOL *stop) {
            if (![operationsToApprove containsObject:[operation objectID]]) { 
                //NSLog(@"CompanyAndUserInfo: add operation:%@ for user with email:%@ GUID:%@ and company admin is user with GUID:%@",operation,updated.email,updated.GUID,updated.currentCompany.companyAdminGUID);
                [operationsToApprove addObject:[operation objectID]];
            }
        }];
    }
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
    self.stuffID = [[clientController authorization] objectID];
    [clientController release];
//    [mocForUpdates release];
    //self.stuff = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
    //self.stuffID = [[userController authorization] objectID];
    //NSLog(@"STUFF is:%@",self.stuff);
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        //isRoutesListUpdated = YES;
//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
//        if ([[clientController localStatusForObjectsWithRootGuid:updatedGUID] isEqualToString:@"registered"]) {
//            [clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:NO isUserAuthorized:YES];
//        }
//        [clientController release];
//    });

    [super viewWillAppear:animated];
//    [self.tableView reloadData];
    HelpForInfoView *helpView = [[HelpForInfoView alloc] init];
    helpView.isConfigSheet = YES;
    if ([helpView isHelpNecessary]) {
        self.tableView.alpha = 0.7;
        helpView.delegate = self;
        [self.navigationController.view addSubview:helpView.view];
    } else [helpView release];

     
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    CompanyStuff *stuff = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];

    NSString *status = [clientController localStatusForObjectsWithRootGuid:stuff.GUID];
    if (status && [status isEqualToString:@"registered"]) [self.rightCornerInfoBoxString setString:@""];

    
    if ([stuff.GUID isEqualToString:stuff.currentCompany.companyAdminGUID]) { 
        [self.rightCornerInfoBoxString setString:@"You are admin"];
        self.rightCornerInfoBoxColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0]; 
    } else [self.rightCornerInfoBoxString setString:@""];

    status = [clientController localStatusForObjectsWithRootGuid:stuff.currentCompany.GUID];
    [clientController release];

    if (status && [status isEqualToString:@"external server"]) {
        [self.rightCornerInfoBoxString setString:@"you can only join"];
        self.rightCornerInfoBoxColor = [UIColor redColor]; 
    }

    //else isUserCompanyAdminWarning = NO;
    //NSLog(@"Stuff guid:%@",stuff.GUID);
    //NSLog(@"companyAdminGUID:%@",stuff.currentCompany.companyAdminGUID);
//    [self.tableView beginUpdates];
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:YES];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
//
//    [self.tableView endUpdates];
    [self.tableView reloadData];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self safeSave];

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) return 4;
    if (section == 1) return 1;
    if (section == 2) {
//        NSInteger count = [[[self fetchedResultsController] fetchedObjects] count];
//        if (isEditedCarriers) count = count + 1;
//        //NSLog(@"Rows in section 2:%@",[NSNumber numberWithInteger:count]);
//        return count;
        return [operationsToApprove count];

    }
//    if (section == 3) {
//        
//        return [operationsToApprove count];
//        
//    }
    
    
    
    return 0;
    
    
}
- (void)configureCell:(CompanyAndUserInfoCell *)cell atIndexPath:(NSIndexPath *)indexPath forTableView:(UITableView *)tableView;
{
    cell.attribute.text = @"Name";
    if (indexPath.row ==  [[[self fetchedResultsController] fetchedObjects] count]) { 
        cell.data.text = @"new carrier";
        cell.state.hidden = YES;
    }
    else {
        Carrier *carrier = [[self fetchedResultsController] objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        cell.data.text = carrier.name;
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];

        NSString *status  = [clientController localStatusForObjectsWithRootGuid:carrier.GUID];
        [clientController release];
//        NSLog(@"carrier company stuff guid:%@, local stuff guid:%@ for carrer:%@",carrier.companyStuff.GUID,stuff.GUID,carrier.name);
        //NSLog(@"status:%@ for carrier guid:%@",status,carrier.GUID);
        
        if (status) {
            
            cell.state.text = status;
            if ([status isEqualToString:@"registered"]) cell.state.textColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
            else cell.state.textColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;
        } else { 
            //NSLog(@"company stuff email:%@, local user email:%@ for carrer:%@",carrier.companyStuff.email,[[NSUserDefaults standardUserDefaults] objectForKey:@"email"],carrier.name);
//            NSLog(@"carrier company stuff guid:%@, local stuff guid:%@ for carrer:%@",carrier.companyStuff.GUID,stuff.GUID,carrier.name);
            CompanyStuff *stuff = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

            if (![carrier.companyStuff.GUID isEqualToString:stuff.GUID]) {

                cell.state.text = @"registered by you colleague";
                cell.state.textColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;

            }
            else {
                cell.state.text = @"new";
                cell.state.textColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];;
            }
        }
    }
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = nil;
    
    CompanyAndUserInfoCell *cell = (CompanyAndUserInfoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        UINib *quoteCellNib = [UINib nibWithNibName:@"CompanyAndUserInfoCell" bundle:nil];
        [quoteCellNib instantiateWithOwner:self options:nil];
        cell = self.cellInfo;
        self.cellInfo = nil;
        cell.delegate = self;
        cell.currentIndexPath = indexPath;
    }
    cell.data.enabled = NO;

    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) { 
            cell.attribute.text = @"First name";
            CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
            cell.data.text =  updated.firstName;
        }
        if (indexPath.row == 1) { 
            cell.attribute.text = @"Last name";
            CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
            cell.data.text =  updated.lastName;
        }
        if (indexPath.row == 2) {
            cell.attribute.text = @"email";
            CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
            cell.data.text =  updated.email;
        }
        if (indexPath.row == 3) { 
            CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
            cell.attribute.text = @"password";
            cell.data.text = updated.password;
            cell.data.secureTextEntry = YES;
        }
       // NSLog(@"%@",self.stuff);
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0) cell.attribute.text = @"Name";
        CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
        cell.data.text =  updated.currentCompany.name;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
//    if (indexPath.section == 2)
//    {
//        CompanyStuff *admin = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
//        NSSet *allAdmins = admin.currentCompany.companyStuff;
//        __block NSUInteger totalCompanies = 0;
//        [allAdmins enumerateObjectsUsingBlock:^(CompanyStuff *adminForCheck, BOOL *stop) {
//            totalCompanies += adminForCheck.carrier.count;
//        }];
//        cell.data.text =  [NSString stringWithFormat:@"Total:%@",[NSNumber numberWithUnsignedInteger:totalCompanies]];
//        cell.attribute.text = [NSString stringWithFormat:@"Yours: %@",[NSNumber numberWithUnsignedInteger:admin.carrier.count]];
//
//        //cell.attribute.hidden = YES;
//        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
//        cell.state.hidden = YES;
//        
////        cell.state.hidden = NO;
////        [self configureCell:cell atIndexPath:indexPath forTableView:tableView];
////        //NSLog(@"%@",cell.data.text);
//    }
    
    if (indexPath.section == 2)
    {
        cell.state.hidden = YES;
        //NSLog(@"%@",indexPath);
        if ([operationsToApprove count] > indexPath.row) {
            OperationNecessaryToApprove *updated = (OperationNecessaryToApprove *)[self.managedObjectContext objectWithID:[operationsToApprove objectAtIndex:indexPath.row]];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CompanyStuff" inManagedObjectContext:self.managedObjectContext];
            [fetchRequest setEntity:entity];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",updated.forGUID];
            [fetchRequest setPredicate:predicate];
            NSError *error = nil;
            NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
            [fetchRequest release];
            CompanyStuff *findedStuff = [fetchedObjects lastObject];
            if (!findedStuff) NSLog(@"COMPANY AND USER: warning, stuff for approve not found in local database");
            else {
                cell.attribute.text = @"last name";
                cell.approve.hidden = YES;
                [cell.approve removeAllSegments];
                cell.approve.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
                cell.approve.alpha = 0.8;
                [cell.approve insertSegmentWithTitle:@"OK" atIndex:0 animated:NO];
                cell.data.text =  findedStuff.lastName;
            }
        }
        
        //        CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
//        
//        NSSet *operations = updated.currentCompany.operationNecessaryToApprove;
        //NSArray *operationsArray = [NSArray arr
//        NSData *stackData = [[userController userDefaultsObjectForKey:stuff.GUID] valueForKey:@"recordsStack"];
//        NSArray *stack = [NSKeyedUnarchiver unarchiveObjectWithData:stackData];
//        NSLog(@"stack for registrations:%@",stack);
//        if ([stack count] > indexPath.row) {
//            NSDictionary *recordForCell = [stack objectAtIndex:indexPath.row];
//            cell.attribute.text = @"last name";
//            NSArray *updated = [recordForCell valueForKey:@"updated"];
//            if ([updated count] != 0) { 
//                // hz why but position in array can changed, so we cover all
//                NSDictionary *stuffObject = nil;
//                if (![[stuffObject valueForKey:@"entity"] isEqualToString:@"CompanyStuff"]) stuffObject = [updated objectAtIndex:0];
//                else stuffObject = [updated objectAtIndex:1];
//
//                
//                NSDictionary *clientStuff = [stuffObject valueForKey:@"clientStuffFullInfo"];
//                cell.approve.hidden = YES;
//                [cell.approve removeAllSegments];
//                cell.approve.tintColor = [UIColor colorWithRed:0.20 green:0.20 blue:0.52 alpha:1.0];
//                cell.approve.alpha = 0.8;
//                [cell.approve insertSegmentWithTitle:@"OK" atIndex:0 animated:NO];
//                //UIEvent
//                //[cell.approve sendAction:@selector(approveRegistration) to:self forEvent:(UIEvent *) 
//                
//                cell.currentData.text =  [clientStuff valueForKey:@"lastName"];
//            }
//        }
        //NSLog(@"%@",cell.data.text);
    }
    //cell.backgroundColor = [UIColor clearColor];
//    cell.contentView.backgroundColor = [UIColor clearColor];
//    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    return cell;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) return 0;
    else return 45;
}        

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    // create the parent view that will hold header Label
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)] autorelease];
    customView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.57 alpha:1.0];
    
    // create the button object
    UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    //THE COLOR YOU WANT:
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    //THE FONT YOU WANT:
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.shadowOffset = CGSizeMake(1, 1);
    
    
    // If you want to align the header text as centered
    // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    //THE TEXT YOU WANT:
    if (section == 0) {
        headerLabel.text = @"User info";
        //NSLog(@"string:%@",self.rightCornerInfoBoxString);
        if ([self.rightCornerInfoBoxString length] != 0) {   
            UISegmentedControl *rightCornerInfoBox = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:self.rightCornerInfoBoxString]] autorelease];
            rightCornerInfoBox.segmentedControlStyle = UISegmentedControlStyleBar;
            rightCornerInfoBox.enabled = NO;
            rightCornerInfoBox.tintColor = self.rightCornerInfoBoxColor;
            rightCornerInfoBox.frame = CGRectMake(150.0, 10.0, 150.0, 20.0);
            [customView addSubview:rightCornerInfoBox];
        } /*else
        {
            UILabel *fixRightCornerInfoBox = [[[UILabel alloc] initWithFrame:CGRectMake(150.0, 10.0, 150.0, 20.0)] autorelease];
            fixRightCornerInfoBox.backgroundColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
            [customView addSubview:fixRightCornerInfoBox];
        }*/
    }
    if (section == 1) { 
        headerLabel.text = @"Selected company";
    }
//    if (section == 2) { 
//        headerLabel.text = @"Carriers";    
//    }
    if (section == 2) {
        CompanyStuff *stuff = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

        NSData *recordsStackData = [[[NSUserDefaults standardUserDefaults] objectForKey:stuff.GUID] valueForKey:@"recordsStack"];
        if (recordsStackData) {
            NSArray *recordsStack = [NSKeyedUnarchiver unarchiveObjectWithData:recordsStackData];
            if ([recordsStack count] != 0) { 
                headerLabel.text = @"Registrations avaiting approve";
            }
        }

    }

    [customView addSubview:headerLabel];
    
    return customView;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *customView = [[[UIView alloc] initWithFrame:CGRectMake(100, 20, 30, 30)] autorelease];
    customView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.57 alpha:1.0];

    if (section == 1) { 
        
        CompanyStuff *stuff = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];

        NSString *status = [clientController localStatusForObjectsWithRootGuid:stuff.GUID];
        [clientController release];
        //NSLog(@"status:%@",status);
        
        if (status && [status isEqualToString:@"registered"]) {
//            [rightButtonUnderUserCompanyInfo removeFromSuperview];
//            [leftButtonUnderUserCompanyInfo removeFromSuperview];
 //BOOL isItNewRightButtonUnderUserCompanyInfo = NO;
            if (!rightButtonUnderUserCompanyInfo) { 
                rightButtonUnderUserCompanyInfo = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Update"]];
                //isItNewRightButtonUnderUserCompanyInfo = YES;
            } else {
                [rightButtonUnderUserCompanyInfo removeAllSegments];
                [rightButtonUnderUserCompanyInfo insertSegmentWithTitle:@"Update" atIndex:0 animated:NO];
            }
            rightButtonUnderUserCompanyInfo.segmentedControlStyle = UISegmentedControlStyleBar;
            //rightButtonUnderUserCompanyInfo.tintColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
            rightButtonUnderUserCompanyInfo.tintColor = [UIColor colorWithRed:0.2 green:0.20 blue:0.52 alpha:1.0];
            
            mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([delegate isPad]) {
                rightButtonUnderUserCompanyInfo.frame = CGRectMake(580.0, 10.0, 130.0, 35.0);
            } else rightButtonUnderUserCompanyInfo.frame = CGRectMake(170.0, 10.0, 130.0, 35.0);
            [rightButtonUnderUserCompanyInfo addTarget:self action:@selector(registerUser:) forControlEvents:UIControlEventValueChanged];
            
            //BOOL isItNewLeftButtonUnderUserCompanyInfo = NO;
            
            if (!leftButtonUnderUserCompanyInfo) { 
                leftButtonUnderUserCompanyInfo = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Login"]];
                //isItNewLeftButtonUnderUserCompanyInfo = YES;
            }
            leftButtonUnderUserCompanyInfo.segmentedControlStyle = UISegmentedControlStyleBar;
            //leftButtonUnderUserCompanyInfo.tintColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
            leftButtonUnderUserCompanyInfo.tintColor = [UIColor colorWithRed:0.2 green:0.20 blue:0.52 alpha:1.0];
            leftButtonUnderUserCompanyInfo.tag = 1;            
            
            if ([delegate isPad]) {
                leftButtonUnderUserCompanyInfo.frame = CGRectMake(60.0, 10.0, 130.0, 35.0);
            } else leftButtonUnderUserCompanyInfo.frame = CGRectMake(20.0, 10.0, 130.0, 35.0);
            [leftButtonUnderUserCompanyInfo addTarget:self action:@selector(registerUser:) forControlEvents:UIControlEventValueChanged];
            
            [customView addSubview:rightButtonUnderUserCompanyInfo];
            [customView addSubview:leftButtonUnderUserCompanyInfo];
        } else {
            //BOOL isItNewRightButtonUnderUserCompanyInfo = NO;

            if (!rightButtonUnderUserCompanyInfo) { 
                rightButtonUnderUserCompanyInfo = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"New user"]];
             //   isItNewRightButtonUnderUserCompanyInfo = YES;
            } else {
                [rightButtonUnderUserCompanyInfo removeAllSegments];
                [rightButtonUnderUserCompanyInfo insertSegmentWithTitle:@"New user" atIndex:0 animated:NO];
            }
            rightButtonUnderUserCompanyInfo.segmentedControlStyle = UISegmentedControlStyleBar;
            //rightButtonUnderUserCompanyInfo.tintColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
            rightButtonUnderUserCompanyInfo.tintColor = [UIColor colorWithRed:0.2 green:0.20 blue:0.52 alpha:1.0];
 
            mobileAppDelegate *delegate = (mobileAppDelegate *)[[UIApplication sharedApplication] delegate];
            if ([delegate isPad]) {
                rightButtonUnderUserCompanyInfo.frame = CGRectMake(580.0, 10.0, 130.0, 35.0);
            } else rightButtonUnderUserCompanyInfo.frame = CGRectMake(170.0, 10.0, 130.0, 35.0);
            
            [rightButtonUnderUserCompanyInfo addTarget:self action:@selector(registerUser:) forControlEvents:UIControlEventValueChanged];

            //BOOL isItNewLeftButtonUnderUserCompanyInfo = NO;

            if (!leftButtonUnderUserCompanyInfo) { 
                leftButtonUnderUserCompanyInfo = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Login"]];
                //isItNewLeftButtonUnderUserCompanyInfo = YES;
            }
            leftButtonUnderUserCompanyInfo.segmentedControlStyle = UISegmentedControlStyleBar;
            //leftButtonUnderUserCompanyInfo.tintColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
            leftButtonUnderUserCompanyInfo.tintColor = [UIColor colorWithRed:0.2 green:0.20 blue:0.52 alpha:1.0];
            leftButtonUnderUserCompanyInfo.tag = 1;            

            if ([delegate isPad]) {
                leftButtonUnderUserCompanyInfo.frame = CGRectMake(60.0, 10.0, 130.0, 35.0);
            } else leftButtonUnderUserCompanyInfo.frame = CGRectMake(20.0, 10.0, 130.0, 35.0);
            [leftButtonUnderUserCompanyInfo addTarget:self action:@selector(registerUser:) forControlEvents:UIControlEventValueChanged];
            [customView addSubview:rightButtonUnderUserCompanyInfo];
            [customView addSubview:leftButtonUnderUserCompanyInfo];
        }  
        //NSLog(@"COMPANY AND USER:return view is:%@",[viewUnderUserCompanyInfo description]);
        //return viewUnderUserCompanyInfo;

    }
//    if (section == 2) { 
//        UISegmentedControl *rightButtonUnderUserCarriersList = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Save"]] autorelease];
//        rightButtonUnderUserCarriersList.segmentedControlStyle = UISegmentedControlStyleBar;
//        rightButtonUnderUserCarriersList.tintColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
//        rightButtonUnderUserCarriersList.tintColor = [UIColor colorWithRed:0.2 green:0.20 blue:0.52 alpha:1.0];
//
//        rightButtonUnderUserCarriersList.opaque = NO;
//        iphoneAppDelegate *delegate = (iphoneAppDelegate *)[[UIApplication sharedApplication] delegate];
//        if ([delegate isPad]) {
//            rightButtonUnderUserCarriersList.frame = CGRectMake(580.0, 10.0, 130.0, 35.0);
//        } else rightButtonUnderUserCarriersList.frame = CGRectMake(170.0, 10.0, 130.0, 35.0);
//        [rightButtonUnderUserCarriersList addTarget:self action:@selector(saveCarriersList) forControlEvents:UIControlEventValueChanged];
//        
//        UISegmentedControl *leftButtonUnderCarriersList = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Edit"]] autorelease];
//        leftButtonUnderCarriersList.segmentedControlStyle = UISegmentedControlStyleBar;
//        //leftButtonUnderUserCompanyInfo.tintColor = [UIColor colorWithRed:0.12 green:0.73 blue:0.21 alpha:1.0];
//        leftButtonUnderCarriersList.tintColor = [UIColor colorWithRed:0.2 green:0.20 blue:0.52 alpha:1.0];
//
//        leftButtonUnderCarriersList.opaque = NO;
//        if ([delegate isPad]) {
//            leftButtonUnderCarriersList.frame = CGRectMake(60.0, 10.0, 130.0, 35.0);
//        } else leftButtonUnderCarriersList.frame = CGRectMake(20.0, 10.0, 130.0, 35.0);
//        [leftButtonUnderCarriersList addTarget:self action:@selector(editCarriersList) forControlEvents:UIControlEventValueChanged];
//        [customView addSubview:rightButtonUnderUserCarriersList];
//        [customView addSubview:leftButtonUnderCarriersList];
//
//    }
    
    return customView;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source

        NSFetchedResultsController *fetchController = [self fetchedResultsController];
        Carrier *carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
            [clientController removeObjectWithID:[carrier objectID]];
            [clientController release];
        });

//        NSMutableDictionary *deleteStatus = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"object deleted",@"delete", nil];
//        [userController setUserDefaultsObject:deleteStatus forKey:carrier.GUID];
//
//        NSArray *keys = [[[stuff entity] attributesByName] allKeys];
//        NSDictionary *dict = [stuff dictionaryWithValuesForKeys:keys];
//        
//        NSDictionary *opjectsForRegistration = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:[carrier objectID]], @"deleted", carrier.GUID, @"rootObjectGUID", nil];
//
//        [userController startRegistrationForObjects:opjectsForRegistration 
//                                       forTableView:self.tableView 
//                                          forSender:self 
//                                clientStuffFullInfo:dict];
//        [self.managedObjectContext deleteObject:carrier];
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewScrollPositionBottom];

    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {

        //CompanyAndUserInfoCell *newCarrier = (CompanyAndUserInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
        Carrier *carrier = (Carrier *)[NSEntityDescription 
                              insertNewObjectForEntityForName:@"Carrier" 
                              inManagedObjectContext:self.managedObjectContext];
        
        NSFetchedResultsController *fetchController = [self fetchedResultsController];
        NSArray *allObjects = [fetchController fetchedObjects];
        NSString *newCarrierName = [NSString stringWithFormat:@"new carrier%@",[NSNumber numberWithUnsignedInteger:[allObjects count]]];
        carrier.name = newCarrierName;
        //carrier.name = newCarrier.data.text;
        CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

        carrier.companyStuff = updated;
        //[controller updateObject:carrier operation:controller.objectOperationNew clientMainSystemGuid:[[NSUserDefaults standardUserDefaults] valueForKey:@"mainSystemGUID"]];
        //[self performSelectorOnMainThread:@selector(safeSave) withObject:nil waitUntilDone:YES];
        [self safeSave];
        
        [self.updatedCarriersIDs addObject:[carrier objectID]];

        //NSError *error = nil;
        
        /*if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }*/	
        
    }   
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // CompanyAndUserInfoCell *previousSelectedCellView = (CompanyAndUserInfoCell *)[tableView cellForRowAtIndexPath:self.previousSelectedCell];

    if (indexPath.section == 0)
    {
        
        isEditingNow = YES;
        //if (indexPath.row != previousSelectedCell.row && indexPath.section != previousSelectedCell.section) {
        if (previousSelectedCell) {
            CompanyAndUserInfoCell *previousSelectedCellView = (CompanyAndUserInfoCell *)[tableView cellForRowAtIndexPath:self.previousSelectedCell];
            //NSLog(@"TEST:%@, index:%@",previousSelectedCellView.data.text,self.previousSelectedCell);
            CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
            
            if (previousSelectedCell.row == 0 && ![previousSelectedCellView.data.text isEqualToString:@""]) updated.firstName = previousSelectedCellView.data.text;
            if (previousSelectedCell.row == 1 && ![previousSelectedCellView.data.text isEqualToString:@""]) updated.lastName = previousSelectedCellView.data.text;
            if (previousSelectedCell.row == 2 && ![previousSelectedCellView.data.text isEqualToString:@""]) { 
                
                updated.email = previousSelectedCellView.data.text;
            }
            if (previousSelectedCell.row == 3 && ![previousSelectedCellView.data.text isEqualToString:@""]) { 
                updated.password = previousSelectedCellView.data.text; 
            }
            //NSLog(@"TEST:%@, index:%@ updated object:%@",previousSelectedCellView.data.text,self.previousSelectedCell,self.stuff);
        
//            previousSelectedCellView.data.hidden = YES;
            [previousSelectedCellView resignFirstResponder];
            previousSelectedCellView.data.borderStyle = UITextBorderStyleNone;

            //previousSelectedCellView.selected = NO;
            [self.tableView deselectRowAtIndexPath:self.previousSelectedCell animated:YES];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousSelectedCell] withRowAnimation:UITableViewRowAnimationNone];
        }

        if (isEmailUnhangedWarning) {
            isEmailUnhangedWarning = NO;
        }
       
//        if ([self.stuff.isRegistrationProcessed boolValue] == YES) {
//            //NSLog(@"%@",self.stuff.isRegistrationProcessed);
//            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//            return;
//        }
        if (indexPath.row == previousSelectedCell.row && indexPath.section == previousSelectedCell.section && previousSelectedCell) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            isEditingNow = NO;
            return;
        }
        
        CompanyAndUserInfoCell *cell = (CompanyAndUserInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.data.borderStyle = UITextBorderStyleRoundedRect;
        cell.data.enabled = YES;

        [cell.data becomeFirstResponder];

        
//        if (cell.data.hidden) { 
////            if (indexPath.row == 3) cell.data.secureTextEntry = YES;
//            
//            cell.data.hidden = NO;
//            [cell.data becomeFirstResponder];
//        }
//        else { 
//            cell.data.hidden = YES;
//            [cell.data resignFirstResponder];
//            cell.selected = NO;
//        }
        self.previousSelectedCell = indexPath;

    }
    if (indexPath.section == 1)
    {
        isCompanyUnchangedWarning = NO;
        CompanyAddController *companyAdd = [[CompanyAddController alloc] initWithStyle:UITableViewStylePlain];
        //CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

        companyAdd.stuffID = self.stuffID;
        companyAdd.companyAndUserConfiguration = self;
//        companyAdd.userController = self.userController;
//        companyAdd.userController.context = self.managedObjectContext;
        companyAdd.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:companyAdd animated:YES];
        [companyAdd release];
    }
    if (indexPath.section == 2)
    {
        CarrierListConroller *detailViewController = [[CarrierListConroller alloc] initWithNibName:@"CarrierListConroller" bundle:nil];
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
 
//        if (isEditedCarriers) {
//            NSFetchedResultsController *fetchController = [self fetchedResultsController];
//            NSInteger numberOfRows = [tableView numberOfRowsInSection:2];
//            if (numberOfRows - 1 == indexPath.row) {
//                // last row is row for add not for edit
//                [tableView deselectRowAtIndexPath:indexPath animated:YES];
//                return;
//            }
//            Carrier *carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
//            [self.updatedCarriersIDs addObject:[carrier objectID]];
//            CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
//
//            if ([carrier.companyStuff.GUID isEqualToString:updated.GUID]) {
//                CompanyAndUserInfoCell *cell = (CompanyAndUserInfoCell *)[tableView cellForRowAtIndexPath:indexPath];
//                
////                cell.data.text = cell.currentData.text;
//                cell.state.hidden = YES;
//                cell.data.enabled = YES;
//
//                cell.data.borderStyle = UITextBorderStyleRoundedRect;
//                [cell.data becomeFirstResponder];
//
////                if (cell.data.hidden) { 
////                    
////                    cell.data.hidden = NO;
////                    [cell.data becomeFirstResponder];
////                }
////                else { 
////                    cell.data.hidden = YES;
////                    [cell.data resignFirstResponder];
////                    cell.selected = NO;
////                }
//                self.previousSelectedCell = indexPath;
//            } else {
//                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//                return;
//            }
//        } else {
//            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
//            return;
//        }
    }
    if (indexPath.section == 3)
    {   
        RegistrationsAvaitingApproveDetailViewController *detailViewController =[[RegistrationsAvaitingApproveDetailViewController alloc] initWithStyle:UITableViewStyleGrouped];
        CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

        detailViewController.stuff = updated;
        detailViewController.companyAndUsedConfiguration = self;
//        detailViewController.userController = self.userController;
        
        OperationNecessaryToApprove *operation = (OperationNecessaryToApprove *)[self.managedObjectContext objectWithID:[operationsToApprove objectAtIndex:indexPath.row]];
        detailViewController.operationObjectID = [operation objectID];
//        NSData *stackData = [[userController userDefaultsObjectForKey:stuff.GUID] valueForKey:@"recordsStack"];
//        NSArray *stack = [NSKeyedUnarchiver unarchiveObjectWithData:stackData];
//        //NSLog(@"stack for registrations:%@",stack);
//        NSDictionary *record = [stack objectAtIndex:indexPath.row];
//        //NSArray *new = [record valueForKey:@"new"];
//        //NSDictionary *stuffObject = [new lastObject];
//        //NSDictionary *clientStuff = [stuffObject valueForKey:@"clientStuffFullInfo"];
//
//        detailViewController.stackRecord = record;
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];
    }

}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        CompanyAddController *companyAdd = [[CompanyAddController alloc] initWithStyle:UITableViewStylePlain];
//        CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

        companyAdd.stuffID = self.stuffID;
        companyAdd.companyAndUserConfiguration = self;
//        companyAdd.userController = self.userController;
//        companyAdd.userController.context = self.managedObjectContext;
        companyAdd.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:companyAdd animated:YES];
        [companyAdd release];
    }
    
    if (indexPath.section == 2)
    {
        CarrierListConroller *detailViewController = [[CarrierListConroller alloc] initWithNibName:@"CarrierListConroller" bundle:nil];
        [self.navigationController pushViewController:detailViewController animated:YES];
        [detailViewController release];

    }

}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSIndexPath *selected = [tableView indexPathForSelectedRow];
//    if (indexPath.section == 2) return YES;
//    else 
        return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isEditedCarriers && indexPath.row == [[[self fetchedResultsController] fetchedObjects] count]) {
        return UITableViewCellEditingStyleInsert;
    } 
    return UITableViewCellEditingStyleDelete;

}

#pragma mark - Change view methods

-(void) changeView:(id)sender;
{
    //NSLog(@"isEdited finish2 = %@",isEdited);

    UISegmentedControl *control = sender;
    if ([control selectedSegmentIndex] == 0) {
        //NSLog(@"plu00000");
        self.infoController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self dismissModalViewControllerAnimated:YES];
        
        //[self presentModalViewController:self.infoController.parentViewController animated:YES];
        control.selectedSegmentIndex = 1;

    }
    if ([control selectedSegmentIndex] == 1) {
        //NSLog(@"plu1");
    }
    
}

#pragma mark - Data methods

-(void) updateData:(NSString *)dataText forCellAtIndexPath:(NSIndexPath *)indexPath;
{
    //NSLog(@"UPDATE: data:%@ at indextPath:%@",dataText,indexPath);
    if (!previousSelectedCell) previousSelectedCell = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    //NSLog(@"UPDATE: data:%@ at previousSelectedCell indextPath:%@",dataText,previousSelectedCell);

    if (previousSelectedCell.section == 0)
    {
       // NSLog(@"isEdited before = %@",isEdited);
        CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

        if (previousSelectedCell.row == 0) 
            if (![updated.firstName isEqualToString:dataText])
            { 
                updated.firstName = dataText;
                //isEdited = YES; 
            }
        if (previousSelectedCell.row == 1) 
            if (![updated.lastName isEqualToString:dataText]) {
                updated.lastName = dataText; 
                //isEdited = YES; 
            }
        if (previousSelectedCell.row == 2) {
            if (![updated.email isEqualToString:dataText]) {
                updated.email = dataText;
                [self.rightCornerInfoBoxString setString:@""];
                isEdited = YES; 
            }
        }
        if (previousSelectedCell.row == 3)  
            if (![updated.password isEqualToString:dataText]) { 
                updated.password = dataText;
                isEdited = YES; 
            }
       // NSLog(@"isEdited after = %@",isEdited);

        //[self performSelectorOnMainThread:@selector(safeSave) withObject:nil waitUntilDone:YES];
        //NSLog(@"%@",[self.stuff changedValues]);
        
        if (previousSelectedCell.row == 2 || previousSelectedCell.row == 3) {
            //NSLog(@"email:%@",self.stuff.email);
//            [userController setUserDefaultsObject:updated.email forKey:@"email"];
//            [userController setUserDefaultsObject:updated.password forKey:@"password"];

            
            /*NSError *error = nil;
            if (![[self fetchedResultsController] performFetch:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }	*/
        }
        [self.tableView beginUpdates]; 
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];

        /*[self.tableView beginUpdates]; 
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates]; */

        previousSelectedCell = nil;
        isEditingNow = NO;
        [self safeSave];
        return;

    }
    if (previousSelectedCell.section == 2)
    {
        //isEditedCarriers = NO;
        NSFetchedResultsController *fetchController = [self fetchedResultsController];
        Carrier *carrier = nil;
        NSArray *allObjects = [[self fetchedResultsController] fetchedObjects];
        
        
        if (indexPath.row == [allObjects count]){
            /*carrier = (Carrier *)[NSEntityDescription 
                                           insertNewObjectForEntityForName:@"Carrier" 
                                           inManagedObjectContext:self.managedObjectContext];
            carrier.companyStuff = stuff;
            NSString *newCarrierName = [NSString stringWithFormat:@"new carrier%@",[NSNumber numberWithUnsignedInteger:[allObjects count]]];
            carrier.name = newCarrierName;*/

        } else carrier = [fetchController objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",dataText];
        if ([[allObjects filteredArrayUsingPredicate:predicate] count] == 0 ) carrier.name = dataText;
        [self safeSave];

    }
    
    //[self performSelectorOnMainThread:@selector(safeSave) withObject:nil waitUntilDone:YES];
    //NSLog(@"Company stuff is:%@",self.stuff);
    //[self.tableView reloadData];
    [self.tableView beginUpdates];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES]; 
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    previousSelectedCell = nil;

}

/*-(void) startRegistration;
{
    isEdited = NO;
    NSArray *keys = [[[stuff entity] attributesByName] allKeys];
    NSDictionary *dict = [stuff dictionaryWithValuesForKeys:keys];
    NSString *statusForStuff = [userController localStatusForObjectsWithRootGuid:stuff.GUID];
    NSString *statusForCompany = [userController localStatusForObjectsWithRootGuid:stuff.currentCompany.GUID];

    NSString *operationKeyForCompany = nil;
    NSString *operationKeyForStuff = nil;
    
    if (statusForCompany && [statusForCompany isEqualToString:@"finish"]) operationKeyForCompany = @"updated";
    else operationKeyForCompany = @"new";

    if (statusForStuff && [statusForStuff isEqualToString:@"finish"]) operationKeyForStuff = @"updated";
    else operationKeyForStuff = @"new";
    
    NSDictionary *opjectsForRegistration = nil;
    NSArray *finalArray = [NSArray arrayWithObjects:[stuff.currentCompany objectID],[stuff objectID],nil];
    if ([operationKeyForCompany isEqualToString:operationKeyForStuff]) opjectsForRegistration = [NSDictionary dictionaryWithObjectsAndKeys:finalArray, operationKeyForCompany, stuff.GUID, @"rootObjectGUID", nil];
    else opjectsForRegistration = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:[stuff.currentCompany objectID]], operationKeyForCompany, [stuff objectID],operationKeyForStuff, stuff.GUID, @"rootObjectGUID", nil];
    
    
    [userController startRegistrationForObjects:opjectsForRegistration forTableView:self.tableView forSender:self clientStuffFullInfo:dict];
}*/

-(void) registerUser:(id)sender;
{
    previousSelectedCell = nil;
    [rightButtonUnderUserCompanyInfo setEnabled:NO forSegmentAtIndex:0];
//    rightButtonUnderUserCompanyInfo.selectedSegmentIndex = 0;
    
    //NSLog(@"REGISTER:%@",[stuff changedValues]);
    CompanyStuff *stuff = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

    if ([stuff.email isEqualToString:@"you@email"]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            UISegmentedControl *alert = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"email is unchanged"]] autorelease];
            alert.segmentedControlStyle = UISegmentedControlStyleBar;
            alert.frame = CGRectMake(0, (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height)/2, self.navigationController.toolbar.bounds.size.width - (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height), alert.frame.size.height);
            alert.userInteractionEnabled = NO;
            //alert.selectedSegmentIndex = 0;
            alert.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];;
            
            UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:alert] autorelease];
            
            
            [self setToolbarItems:[NSArray arrayWithObject:item]];
            self.navigationController.toolbar.translucent = YES;
            self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
            
            self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
            [self.navigationController setToolbarHidden:NO animated:YES];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(10);
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [self.navigationController setToolbarHidden:YES animated:YES]; 
            });
        });
        
        [self.rightCornerInfoBoxString setString:@"email is unchanged"];
        self.rightCornerInfoBoxColor = [UIColor redColor];
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        return;
    } 
    
    if ([sender tag] != 1 && [stuff.currentCompany.name isEqualToString:@"you company"]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            UISegmentedControl *alert = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"company is unchanged"]] autorelease];
            alert.segmentedControlStyle = UISegmentedControlStyleBar;
            alert.frame = CGRectMake(0, (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height)/2, self.navigationController.toolbar.bounds.size.width - (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height), alert.frame.size.height);
            alert.userInteractionEnabled = NO;
            //alert.selectedSegmentIndex = 0;
            alert.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];;
            
            UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:alert] autorelease];
            
            
            [self setToolbarItems:[NSArray arrayWithObject:item]];
            self.navigationController.toolbar.translucent = YES;
            self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
            
            self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
            [self.navigationController setToolbarHidden:NO animated:YES];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(10);
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [self.navigationController setToolbarHidden:YES animated:YES]; 
            });
        });

        [self.rightCornerInfoBoxString setString:@"company is unchanged"];
        self.rightCornerInfoBoxColor = [UIColor redColor];
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];

        return;
    } 
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];

    NSString *status = [clientController localStatusForObjectsWithRootGuid:stuff.currentCompany.GUID];
    [clientController release];
    
    if ([sender tag] != 1 && status && [status isEqualToString:@"external server"]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            UISegmentedControl *alert = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"you can only join"]] autorelease];
            alert.segmentedControlStyle = UISegmentedControlStyleBar;
            alert.frame = CGRectMake(0, (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height)/2, self.navigationController.toolbar.bounds.size.width - (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height), alert.frame.size.height);
            alert.userInteractionEnabled = NO;
            //alert.selectedSegmentIndex = 0;
            alert.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];;
            
            UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:alert] autorelease];
            
            
            [self setToolbarItems:[NSArray arrayWithObject:item]];
            self.navigationController.toolbar.translucent = YES;
            self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
            
            self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
            [self.navigationController setToolbarHidden:NO animated:YES];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(10);
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [self.navigationController setToolbarHidden:YES animated:YES]; 
            });
        });
   
        [self.rightCornerInfoBoxString setString:@"you can only join"];
        self.rightCornerInfoBoxColor = [UIColor redColor];
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        return;

    }
    [self safeSave];
    //if (!isUpdatesProcessingNow) {
    [activity startAnimating];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//            isUpdatesProcessingNow = YES;
            BOOL isMustBeApproved = NO;
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
            
            if ([sender tag] == 1) { 
            
                // while login pressing, we are checking and authorization and when it not failed, do this as well;
                //CompanyStuff *admin = [clientController authorization];
                if ([clientController checkIfCurrentAdminCanLogin]) {
                    [clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES isUserAuthorized:YES];
                    [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[stuff objectID]] mustBeApproved:isMustBeApproved];
                }
                    
            }
            else {
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[stuff.currentCompany objectID]] mustBeApproved:NO];
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[stuff objectID]] mustBeApproved:NO];
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [rightButtonUnderUserCompanyInfo setEnabled:YES forSegmentAtIndex:0];
                [leftButtonUnderUserCompanyInfo setEnabled:YES forSegmentAtIndex:0];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                [activity stopAnimating];

            });
            
            [clientController release];
//            isUpdatesProcessingNow = NO;
        });
    //}
    
    [self.rightCornerInfoBoxString setString:@""];
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];

    //[self performSelectorOnMainThread:@selector(safeSave) withObject:nil waitUntilDone:YES];

    //if (![self.userController addUser:stuff]) NSLog(@"Something wrong with add user");

        
}

-(void)loginUser
{
    NSLog (@"LOGIN");
}

-(void) cancelRegistration;
{
    //if ([userController.registrationsInProcessNow containsObject:stuff]) [userController.canceledRegistrations addObject:stuff];
}

-(void)editCarriersList;
{
//    isEditedCarriers = YES;

    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView setEditing:YES animated:YES];
    [self.tableView endUpdates];

}

-(void)saveCarriersList;
{
    isEditedCarriers = NO;
    isUpdatingCarriers = YES;
    //dispatch_async(dispatch_get_main_queue(), ^(void) { [self.managedObjectContext save:nil]; });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator] withSender:self withMainMoc:self.managedObjectContext];
        
//        NSFetchedResultsController *fetchController = [self fetchedResultsController];
//        NSArray *allObjects = [fetchController fetchedObjects];
//        //    __block BOOL isSomethingAdded = NO;
//        __block NSMutableArray *allIDs = [NSMutableArray arrayWithCapacity:[allObjects count]];
//        
//        
//        [allObjects enumerateObjectsWithOptions:NSSortStable usingBlock:^(Carrier *carrier, NSUInteger idx, BOOL *stop) {
//            [allIDs addObject:[carrier objectID]];
            
            //        //if (![carrierGUIDs containsObject:carrier.GUID]) {
            //            NSString *stuffStatus = [userController localStatusForObjectsWithRootGuid:stuff.GUID];
            //            if (stuffStatus && [stuffStatus isEqualToString:@"finish"]) {
            //                // any updates to server only if stuff registered
            //                isUserUnregisteredWarning = NO;
            //                NSLog(@"Carrier: %@ uri:%@",carrier.name,[[carrier objectID] URIRepresentation]);
            //                NSString *status = [userController localStatusForObjectsWithRootGuid:carrier.GUID];
            //                NSMutableDictionary *objectsForRegistration = [NSMutableDictionary dictionaryWithCapacity:0];
            //                NSMutableArray *new = [NSMutableArray arrayWithCapacity:0];
            //                NSMutableArray *updated = [NSMutableArray arrayWithCapacity:0];
            //                if (status) [updated addObject:[carrier objectID]];
            //                else [new addObject:[carrier objectID]];
            //                /*if (status) [update addObject:carrier];
            //                else [new addObject:carrier];*/
            //                [objectsForRegistration setValue:carrier.GUID forKey:@"rootObjectGUID"];
            //                [objectsForRegistration setValue:new forKey:@"new"];
            //                [objectsForRegistration setValue:updated forKey:@"updated"];
            //                if ([self.updatedCarriersIDs containsObject:[carrier objectID]]) { 
            //                    [userController.registrationsForMakeInFuture addObject:objectsForRegistration]; 
            //                    [self.updatedCarriersIDs removeObject:[carrier objectID]];
            //                }
            //                isSomethingAdded = YES;
            //
            //           } else isUserUnregisteredWarning = YES;
//        }];
        NSArray *arrayToSend = [NSArray arrayWithArray:self.updatedCarriersIDs];
        [updatedCarriersIDs removeAllObjects];
        [arrayToSend enumerateObjectsUsingBlock:^(NSManagedObjectID *objectID, NSUInteger idx, BOOL *stop) {
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:objectID] mustBeApproved:NO];
        }];
        [clientController release];
        //    if (isSomethingAdded) [userController startRegistrationForAllObjectsInFutureArrayForTableView:self.tableView sender:self clientStuffGUID:self.stuff.GUID];
        
    });
    
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView setEditing:NO animated:YES];
    [self.tableView endUpdates];
}

-(void) approveRegistrationForCellAtIndexPath:(NSIndexPath *)indexPath;
{
//    NSData *stackData = [[userController userDefaultsObjectForKey:stuff.GUID] valueForKey:@"recordsStack"];
//    NSArray *stack = [NSKeyedUnarchiver unarchiveObjectWithData:stackData];
//    //NSIndexPath *selected = [self.tableView 
//    //
////    NSDictionary *recordForCell = [stack objectAtIndex:indexPath.row];
//
////    [self.userController startProcessingtFor:recordForCell toStatus:self.userController.controller.objectStatusFinish sender:self];
//    
//                                //forTableView:self.tableView 
//                                    //toStatus:self.userController.controller.objectStatusFinish] ;
//    NSMutableArray *stackMutable = [NSMutableArray arrayWithArray:stack];
//    [stackMutable removeObjectAtIndex:indexPath.row];
//    NSData *finalStackData = [NSKeyedArchiver archivedDataWithRootObject:stackMutable];
//    [[userController userDefaultsObjectForKey:stuff.GUID] setValue:finalStackData forKey:@"recordsStack"];
    //NSLog(@"approve");
}
-(void)config:(id)sender
{

    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:@"Debug menu" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"Cancel" otherButtonTitles:@"clear all data",@"email info to developer",@"start instructions again.",nil] autorelease];
    //iphoneAppDelegate *delegate = (iphoneAppDelegate *)[UIApplication sharedApplication].delegate;
    
    //[sheet showFromTabBar:delegate.tabBarController.tabBar];
    [sheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];

}

-(NSDictionary *) clearNullKeysForDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj class] == [NSNull class]) [result removeObjectForKey:key];
    }];
    return [NSDictionary dictionaryWithDictionary:result];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

//        if (buttonIndex == 1)
//        {
//            // clear records pool
//            [userController removeUserDefaultsObjectForKey:@"processingPool"];
//            abort();
//            
//        }
        if (buttonIndex == 1)
        {
            // clear all data
            mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
            NSString *storePath = [[delegate applicationDocumentsDirectory].path stringByAppendingPathComponent:@"snow_iph.sqlite"];
            NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"processingPool"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"recordsStack"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastGraphUpdatingTime"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"showAgain"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authorizedUserGUID"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"help"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSFileManager defaultManager] removeItemAtURL:storeUrl error:nil];

            exit(0);

        }
        
        if (buttonIndex == 2)
        {
            NSMutableArray *finalData = [NSMutableArray array];
            // email to developer
            CompanyStuff *stuff = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

            __block NSArray *keys = [[[stuff entity] attributesByName] allKeys];
            __block NSDictionary *volumes = [stuff dictionaryWithValuesForKeys:keys];
            NSDictionary *cleaned = [self clearNullKeysForDictionary:volumes];
            [finalData addObject:cleaned];
            
            keys = [[[stuff.currentCompany entity] attributesByName] allKeys];
            volumes = [stuff.currentCompany dictionaryWithValuesForKeys:keys];
            cleaned = [self clearNullKeysForDictionary:volumes];
            [finalData addObject:cleaned];
            
            NSSet *stuffs = stuff.currentCompany.companyStuff;
            [stuffs enumerateObjectsUsingBlock:^(CompanyStuff *stuffForDebug, BOOL *stop) {
                keys = [[[stuffForDebug entity] attributesByName] allKeys];
                volumes = [stuffForDebug dictionaryWithValuesForKeys:keys];
                NSDictionary *cleaned = [self clearNullKeysForDictionary:volumes];
                [finalData addObject:cleaned];
            }];

            NSSet *carriers = stuff.carrier;
            [carriers enumerateObjectsUsingBlock:^(Carrier *carrier, BOOL *stop) {
                keys = [[[carrier entity] attributesByName] allKeys];
                volumes = [carrier dictionaryWithValuesForKeys:keys];
                NSDictionary *cleaned = [self clearNullKeysForDictionary:volumes];
                [finalData addObject:cleaned];
                NSSet *destinations = carrier.destinationsListPushList;
                [destinations enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                    keys = [[[carrier entity] attributesByName] allKeys];
                    volumes = [carrier dictionaryWithValuesForKeys:keys];
                    NSDictionary *cleaned = [self clearNullKeysForDictionary:volumes];
                    [finalData addObject:cleaned];

                }];
            }];
            
            //iphoneAppDelegate *delegate = (iphoneAppDelegate *)[UIApplication sharedApplication].delegate;
            //NSString *storePath = [[delegate applicationDocumentsDirectory] stringByAppendingPathComponent:@"debug.info"];
            //[finalData writeToFile:storePath atomically:YES];
            //NSData *finalDataToSend = [
            
                NSMutableString *error;
                NSData *data = [NSPropertyListSerialization dataFromPropertyList:[NSArray arrayWithArray:finalData] format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
            dispatch_async(dispatch_get_main_queue(), ^(void) {

                MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
                picker.mailComposeDelegate = self;
                NSString *subject = [NSString stringWithFormat:@"debug information for snow mobile"];
                [picker setSubject:subject];
                [picker setMessageBody:[NSString stringWithFormat:@"This is debug info:"] isHTML:NO];
                [picker setToRecipients:[NSArray arrayWithObjects:@"iphone@ixcglobal.com", nil]];
                [picker addAttachmentData:data mimeType:@"application/zip" fileName:@"debugInfo.bin"];

                [self presentModalViewController:picker animated:YES];
                [picker release];
            });
        }
        if (buttonIndex == 3)
        {
            NSMutableDictionary *help = [[NSUserDefaults standardUserDefaults] objectForKey:@"help"];
            NSMutableDictionary *helpMutable = [NSMutableDictionary dictionaryWithDictionary:help];

            [helpMutable setValue:[NSNumber numberWithBool:YES] forKey:@"isInfoSheet"];
            [helpMutable setValue:[NSNumber numberWithBool:YES] forKey:@"isConfigSheet"];
            [helpMutable setValue:[NSNumber numberWithBool:YES] forKey:@"isEventsSheet"];
            [helpMutable setValue:[NSNumber numberWithBool:YES] forKey:@"isAddRoutesSheet"];
            [helpMutable setValue:[NSNumber numberWithBool:YES] forKey:@"isRoutesListSheet"];
            [helpMutable setValue:[NSNumber numberWithBool:YES] forKey:@"isCarriersListSheet"];
            [[NSUserDefaults standardUserDefaults] setObject:helpMutable forKey:@"help"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }           
    });   
}


- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - FetchedResultsController methods


- (NSFetchedResultsController *)fetchedResultsController;
{
    if (fetchedResultsController != nil) 
    {
        return fetchedResultsController;
    }
    //isEdited = NO;
    //NSLog(@"fetch:%@",isEdited);

    
    
    CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"(companyStuff.currentCompany.GUID == %@)",updated.currentCompany.GUID];;

    
    
    //if (![updated.GUID isEqualToString:updated.currentCompany.companyAdminGUID]) filterPredicate = [NSPredicate predicateWithFormat:@"(companyStuff.GUID == %@)",updated.GUID];
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:filterPredicate];
    
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:20];
    //[fetchRequest setFetchLimit:20];
    //if (!isEditedCarriers) {
       // NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
       // NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        //[fetchRequest setSortDescriptors:sortDescriptors];
        //[sortDescriptor release];[sortDescriptors release];
    //} else
    //{
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptors release];

    //}
   
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:nil];
    aFetchedResultsController.delegate = self;
    
    [fetchRequest release];
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error]) 
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    fetchedResultsController =  aFetchedResultsController;
    return [[fetchedResultsController retain] autorelease];

}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    //if (indexPath.section == 0) {
    
//    UITableView *tableView = self.tableView;
//    [tableView beginUpdates];
//    
//	
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//        {
//            //NSLog(@"COMPANY AND USER:fetchControllerDidChanges insert");
//            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:newIndexPath.row inSection:2];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndex] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        }
//        case NSFetchedResultsChangeDelete:
//        {
//            //NSLog(@"COMPANY AND USER:fetchControllerDidChanges delete");
//            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:2];
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndex] withRowAnimation:UITableViewRowAnimationFade];
//            //if ([userController.registrationsInProcessNow containsObject:anObject]) [userController.canceledRegistrations addObject:anObject];
//            break;
//        }
//        case NSFetchedResultsChangeUpdate:
//        {
//            //NSLog(@"COMPANY AND USER:fetchControllerDidChanges update");
//
//            NSIndexPath *newIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:2];
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:newIndex] withRowAnimation:UITableViewRowAnimationFade];
//            //[self configureCell:(CompanyAndUserInfoCell *)[tableView cellForRowAtIndexPath:newIndex] atIndexPath:newIndex forTableView:tableView];
//            break;
//        }
//        case NSFetchedResultsChangeMove:
//        {
//            //NSLog(@"COMPANY AND USER:fetchControllerDidChanges move");
//            NSIndexPath *newIndexStart = [NSIndexPath indexPathForRow:indexPath.row inSection:2];
//            NSIndexPath *newIndexStop = [NSIndexPath indexPathForRow:newIndexPath.row inSection:2];
//            
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexStart] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexStop] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//        }
//    }
////    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
    
//    [tableView endUpdates];


}
- (void)logError:(NSError*)error;
{
    id sub = [[error userInfo] valueForKey:@"NSUnderlyingException"];
    
    if (!sub) {
        sub = [[error userInfo] valueForKey:NSUnderlyingErrorKey];
    }
    
    if (!sub) {
        NSLog(@"%@:%@ Error Received: %@", [self class], NSStringFromSelector(_cmd), 
              [error localizedDescription]);
        return;
    }
    
    if ([sub isKindOfClass:[NSArray class]] || 
        [sub isKindOfClass:[NSSet class]]) {
        for (NSError *subError in sub) {
            NSLog(@"%@:%@ SubError: %@", [self class], NSStringFromSelector(_cmd), 
                  [subError localizedDescription]);
        }
    } else {
        NSLog(@"%@:%@ exception %@", [self class], NSStringFromSelector(_cmd), [sub description]);
    }
}


-(void) safeSave;
{
    //NSLog(@"SAVED");
//    NSError *error = nil;
//    [self.managedObjectContext save:&error];
//    if (error) NSLog(@"%@",[error localizedDescription]);
    
    if ([self.managedObjectContext hasChanges]) {
        NSError *error = nil;
        if (![self.managedObjectContext save: &error]) {
            NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
            NSArray* detailedErrors = [[error userInfo] objectForKey:NSDetailedErrorsKey];
            if(detailedErrors != nil && [detailedErrors count] > 0)
            {
                for(NSError* detailedError in detailedErrors)
                {
                    NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                }
            }
            else
            {
                NSLog(@"  %@", [error userInfo]);
            }
            [self logError:error];
        }
    }
    
}

#pragma mark - external reload methods

-(void) reloadLocalDataFromUserDataControllerForObject:(id)object;
{
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        NSDictionary *status = [userController userDefaultsObjectForKey:stuff.GUID];
//        
//        NSString *finalResult = [status valueForKey:@"new"];
//        if (!finalResult) finalResult = [status valueForKey:@"update"];
//        if (!finalResult) finalResult = [status valueForKey:@"login"];
//
//        //NSLog(@"COMPANY AND USER:status is:%@",status);
//        
//        if ([status valueForKey:@"login"]) { 
//            NSString *finalResultForLogin = [status valueForKey:@"login"];
//           //NSLog(@"COMPANY AND USER:final result for login is:%@",finalResultForLogin);
//
//            if ([finalResultForLogin isEqualToString:@"finish"]) {
//                
//                //NSManagedObjectID *authorizedStuffID = [userController.controller changeLocalGraffForPreviousUser:self.stuff forUserController:userController];
//                // we must clear company status bcs it was external server but now login successed and this is registered company and set unhide status bcs i can't see it in future
//                CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
//
//                NSManagedObjectID *authorizedStuffID = [userController.controller changeLocalGraffForPreviousUser:updated forUserController:userController];
//
//                if (authorizedStuffID) { 
//                    CompanyStuff *authorizedStuff = (CompanyStuff *)[self.managedObjectContext objectWithID:authorizedStuffID];
//
//                    self.stuff = authorizedStuff;
//                    
//                    
//                    [userController setUserDefaultsObject:[NSDictionary dictionaryWithObjectsAndKeys:@"finish",@"update", nil] forKey:authorizedStuff.currentCompany.GUID];
//                   // authorizedStuff.currentCompany.isInvisibleForCommunity = [NSNumber numberWithBool:YES];
//                    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
//                }
//            }
//
//            if ([finalResultForLogin isEqualToString:@"failed"]) {
//                NSString *error = [object valueForKey:@"error"];
//                [self.rightCornerInfoBoxString setString:error];
//                self.rightCornerInfoBoxColor = [UIColor redColor];
//
//            } 
//
//            
//            
//
//        }
//        
//        
//        if (finalResult) [self.rightCornerInfoBoxString setString:finalResult];
//        //else [self.rightCornerInfoBoxString setString:@""];
//        
//        self.rightCornerInfoBoxColor = [UIColor colorWithRed:0.42 green:0.43 blue:0.64 alpha:1.0];
//        
//        //NSLog(@"COMPANY AND USER:RELOAD DATA for stuff:%@ ",self.stuff);
//        if (!isEditedCarriers) [self.tableView reloadData];
//        if ([finalResult isEqualToString:@"finish"] || [finalResult isEqualToString:@"failed"]) { 
//            isUpdatingCarriers = NO;
//            [activity stopAnimating];
//
//        } else [activity startAnimating];
//
//
//    });
}

-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSManagedObjectID *objectID = nil;
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            UISegmentedControl *alert = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:status]] autorelease];
            alert.segmentedControlStyle = UISegmentedControlStyleBar;
            alert.frame = CGRectMake(0, (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height)/2, self.navigationController.toolbar.bounds.size.width - (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height), alert.frame.size.height);
            alert.userInteractionEnabled = NO;
            //alert.selectedSegmentIndex = 0;
            alert.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];;
            
            UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:alert] autorelease];
            
            
            [self setToolbarItems:[NSArray arrayWithObject:item]];
            self.navigationController.toolbar.translucent = YES;
            self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
            self.navigationController.toolbar.barStyle = UIBarStyleBlack;
            
            self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
            [self.navigationController setToolbarHidden:NO animated:YES];
        });
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            sleep(4);
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [self.navigationController setToolbarHidden:YES animated:YES]; 
            });
        });
        
        // present modal
    }

    if ([data count] > 4) objectID = [data objectAtIndex:4];
    
    if (objectID) {
        
        NSManagedObject *updatedObject = [self.managedObjectContext objectWithID:objectID];
        if ([[[updatedObject entity] name] isEqualToString:@"CompanyStuff"]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (![isItLatestMessage boolValue])
                {
                    [activity startAnimating];
                } else {
                    [activity stopAnimating];
                    // at first, check it if approve registration
                    CompanyStuff *findedStuff = (CompanyStuff *)updatedObject;

                    CompanyStuff *stuff = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];

                    if (![findedStuff.GUID isEqualToString:stuff.GUID])
                    {
                        //second, find and delete operation (of course, we can receive company graph, but this is too long for good guys
                        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                        NSEntityDescription *entity = [NSEntityDescription entityForName:@"OperationNecessaryToApprove" inManagedObjectContext:self.managedObjectContext];
                        [fetchRequest setEntity:entity];
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(forGUID == %@)",findedStuff.GUID];
                        [fetchRequest setPredicate:predicate];
                        NSError *error = nil;
                        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
                        [fetchRequest release];
                        OperationNecessaryToApprove *findedOperation = [fetchedObjects lastObject];
                        if (!findedOperation) NSLog(@"REGISTRATION AWAITING:operation not found");
                        else [self.managedObjectContext deleteObject:findedOperation];
                        CompanyStuff *updated = (CompanyStuff *)[self.managedObjectContext objectWithID:self.stuffID];
                        CurrentCompany *currentCompany = updated.currentCompany;
                        NSSet *operations = currentCompany.operationNecessaryToApprove;
                        [operationsToApprove removeAllObjects];
                        [operations enumerateObjectsUsingBlock:^(OperationNecessaryToApprove *operation, BOOL *stop) {
                            if (![operationsToApprove containsObject:[operation objectID]]) [operationsToApprove addObject:[operation objectID]];
                        }];

                        [self safeSave];
                        
                        // third, update ui
                        [operationsToApprove removeObject:[findedOperation objectID]];
                        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
                    }
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:0],[NSIndexPath indexPathForRow:1 inSection:0],nil] withRowAnimation:UITableViewRowAnimationFade];

                }

            });

            
        }
        
        if ([[[updatedObject entity] name] isEqualToString:@"Carrier"]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (![isItLatestMessage boolValue])
                {
                    NSIndexPath *objectPath = [fetchedResultsController indexPathForObject:updatedObject];
                    CompanyAndUserInfoCell *cell = (CompanyAndUserInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:objectPath.row inSection:2]];
                    cell.activity.hidden = NO;
                    [cell.activity startAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

                    //[activity startAnimating];
                } else { 
                    //[activity stopAnimating];
                    NSIndexPath *objectPath = [fetchedResultsController indexPathForObject:updatedObject];
                    CompanyAndUserInfoCell *cell = (CompanyAndUserInfoCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:objectPath.row inSection:2]];
                    cell.activity.hidden = NO;
                    [cell.activity startAnimating];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

                    
//                    NSString *status = [[[NSUserDefaults standardUserDefaults] objectForKey:[updatedObject valueForKey:@"GUID"]] valueForKey:@"update"];
//                    cell.state.text = status;
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:objectPath.row inSection:2]] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];

                    if ([status isEqualToString:@"remove object finish"]) { 
                        [self.managedObjectContext deleteObject:updatedObject];
                        [self safeSave];
                    }

                    //NSLog(@"COMPANY AND USER:updated object:%@ for guid:%@ with object:%@",[[NSUserDefaults standardUserDefaults] objectForKey:[updatedObject valueForKey:@"GUID"]],[updatedObject valueForKey:@"GUID"],updatedObject);
                    //[self.tableView reloadData];
                    
                }
            });

        }
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]withSender:self withMainMoc:self.managedObjectContext];
        self.stuffID = [[clientController authorization] objectID];
        [clientController release];

        //if ([idsWithProgress containsObject:objectID] && ![isItLatestMessage boolValue]) return;
        //[idsWithProgress addObject:objectID];
//        CurrentCompany *updatedCompany = (CurrentCompany *)[self.managedObjectContext objectWithID:objectID];
//        NSIndexPath *objectIndexPath = [self.fetchedResultsController indexPathForObject:updatedCompany];
//        CompanyInfoDetailCell *cell = (CompanyInfoDetailCell *)[self.tableView cellForRowAtIndexPath:objectIndexPath];
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) { 
//            
//            
//            if (![isItLatestMessage boolValue]) {
//                [cell.activity startAnimating];
//                cell.activity.hidden = NO;
//                
//            } else {
//                
//                [cell.activity stopAnimating];
//                cell.activity.hidden = YES;
//            }
//            
//        });
    }
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    });

    //withProgressEnabled:(BOOL)isProgressEnabled forObjectID:(NSManagedObjectID *)objectID andPercent:(NSNumber *)percent
    //NSLog(@"COMPANY AND USER:update UI:%@ latest message:%@",status,isItLatestMessage);
    
    
    
}

-(void)helpShowingDidFinish;
{
    self.tableView.alpha = 1.0;
}

@end
