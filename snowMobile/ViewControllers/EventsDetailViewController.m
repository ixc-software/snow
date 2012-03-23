//
//  EventsDetailViewController.m
//  snow
//
//  Created by Alex Vinogradov on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsDetailViewController.h"
#import <MessageUI/MessageUI.h>
//#import "UserDataController.h"
#import "Carrier.h"
#import "CompanyStuff.h"
#import "CurrentCompany.h"
#import "DestinationsListPushList.h"
#import "CountrySpecificCodeList.h"
#import "ClientController.h"
#import "mobileAppDelegate.h"

@class EventsDetailPopUpViewController;

@implementation EventsDetailViewController

@synthesize event,specifics,country,resolvedCell,popoverView,switchLabel,specificsStates,formatter,isErrorStillShowing;
//,date,dateAlarm,name,country;

#define NAME_SECTION 1
#define DATE_SECTION 2
#define DATE_ALARM_SECTION 3
#define CONFIG_SECTION 0
//#define ADDEDTOCALENDAR_SECTION 4
#define SPECIFIC_LIST_SECTION 5


- (void)dealloc
{
    [formatter release];
    [specificsStates release];
    [specifics release];
    [event release];
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
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM-yyyy"];
    UIBarButtonItem *optionsButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendMail:)];
    self.navigationItem.rightBarButtonItem = optionsButtonItem;
    [optionsButtonItem release];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.34 green:0.34 blue:0.57 alpha:1.0];
    
    UISegmentedControl *alert = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Your can't add: carrier and user isn't registered."]] autorelease];
    alert.segmentedControlStyle = UISegmentedControlStyleBar;
    alert.frame = CGRectMake(0, (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height)/2, self.navigationController.toolbar.bounds.size.width - (self.navigationController.toolbar.bounds.size.height - alert.frame.size.height), alert.frame.size.height);
    alert.userInteractionEnabled = NO;
    alert.selectedSegmentIndex = 0;
    alert.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];;
    
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithCustomView:alert] autorelease];
    
    
    [self setToolbarItems:[NSArray arrayWithObject:item]];
    self.navigationController.toolbar.translucent = YES;
    self.navigationController.toolbar.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.78 alpha:0.2];
    isErrorStillShowing = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of t==he main view.
    // e.g. self.myOutlet = nil;
}

- (void) fillCountrySpecificArrayForCountry:(NSString *)countryName;
{
//    NSDictionary *mycountryspecific = [[NSDictionary alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"countryspecific" withExtension:@"dict"]];
//    NSSet * mySet = [mycountryspecific keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
//        if([key compare:countryName options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//            return YES;
//        }
//            else
//            return NO;
//        }];
//    
//    NSArray *result = [mycountryspecific valueForKey:[mySet anyObject]];
//    self.specifics = result;
    
//    UserDataController *userDataController = [[UserDataController alloc] init];
//    userDataController.context = [event managedObjectContext];
    NSManagedObjectContext *moc = [event managedObjectContext];

    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[moc persistentStoreCoordinator] withSender:self withMainMoc:moc];

    CompanyStuff *currentStuff = [clientController authorization];
    [clientController release];
    //if (!currentStuff) currentStuff = [userDataController defaultUser];
    
    
    __block NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    __block NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    __block NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country CONTAINS[cd] %@",countryName];
    //[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"specific"]];
    __block NSError *error = nil;
    [fetchRequest setPredicate:predicate];
    NSArray *specificsForFill = [moc executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *allSpecifics = [NSMutableArray array];
    [specificsForFill enumerateObjectsUsingBlock:^(CountrySpecificCodeList *obj, NSUInteger idx, BOOL *stop) {
        [allSpecifics addObject:obj.specific];
    }];
    self.specifics = [NSArray arrayWithArray:allSpecifics];
    NSMutableArray *stateInPushList = [NSMutableArray arrayWithCapacity:[self.specifics count]];

    //__block NSArray *fetchedObjects = nil;
    
    entity = [NSEntityDescription entityForName:@"DestinationsListPushList" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    //[allSpecifics enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSString *specific, NSUInteger idx, BOOL *stop) {
    for (NSString *specific in allSpecifics) {
        predicate = [NSPredicate predicateWithFormat:@"(country CONTAINS[cd] %@) AND (specific == %@) and (carrier.companyStuff.currentCompany.GUID == %@)",country,specific,currentStuff.currentCompany.GUID];
        [fetchRequest setPredicate:predicate];
        NSUInteger result = [moc countForFetchRequest:fetchRequest error:&error];
        if (result > 0) [stateInPushList addObject:[NSNumber numberWithBool:YES]];
            else [stateInPushList addObject:[NSNumber numberWithBool:NO]];
    }
    //}];
    //[result release];

    self.specificsStates = [NSArray arrayWithArray:stateInPushList];
//    [mycountryspecific release],mycountryspecific = nil;
    
    [fetchRequest release];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSManagedObject *managedObject = self.event;
    NSString *necessaryData =  [managedObject valueForKey:@"necessaryData"];
    NSString *countryWithIdent =  [necessaryData stringByReplacingOccurrencesOfString:@"countriesEvent_" withString:@""];

    //NSString *countryName = [countryWithIdent stringByReplacingOccurrencesOfString:@"countriesEvent_" withString:@""];
    if (countryWithIdent) self.country = countryWithIdent;
    self.title = country;
    //[self performSelectorInBackground:@selector(fillCountrySpecificArrayForCountry:) withObject:countryWithIdent];
    [self performSelector:@selector(fillCountrySpecificArrayForCountry:) withObject:countryWithIdent];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        [self fillCountrySpecificArrayForCountry:countryWithIdent];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) { [self.tableView reloadData]; });
    });
    mobileAppDelegate *delegate = (mobileAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([delegate isPad]){
        [self.tableView setBackgroundView:nil];
        [self.tableView  setBackgroundView:[[[UIView alloc] init] autorelease]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
//    while (!isErrorStillShowing) {
//        sleep(1);
//    }
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 6;
}

/*- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    // Return a title or nil as appropriate for the section.
    switch (section) {
        case CONFIG_SECTION:
            title = @"Configure event";
            break;

        case NAME_SECTION:
            title = @"Event name";
            break;
        case DATE_SECTION:
            title = @"Date event";
            break;
        case DATE_ALARM_SECTION:
            title = @"Date alert";
            break;

//        case ADDEDTOCALENDAR_SECTION:
//            title = @"Add to calendar";
//            break;

        case SPECIFIC_LIST_SECTION:
            title = @"Country specific";
            break;

        default:
            break;
    }
    return title;
}*/
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* customView = [[[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 150.0, 44.0)]autorelease];
    NSString *title = nil;
    // Return a title or nil as appropriate for the section.
    switch (section) {
        case CONFIG_SECTION:
            title = @"Configure event";
            break;
            
        case NAME_SECTION:
            title = @"Event name";
            break;
        case DATE_SECTION:
            title = @"Date event";
            break;
        case DATE_ALARM_SECTION:
            title = @"Date alert";
            break;
            
            //        case ADDEDTOCALENDAR_SECTION:
            //            title = @"Add to calendar";
            //            break;
            
        case SPECIFIC_LIST_SECTION:
            title = @"Country specific";
            break;
            
        default:
            break;
    }
    UILabel * headerLabel = [[[UILabel alloc] initWithFrame:CGRectZero]autorelease] ;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.opaque = NO;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    //headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
    
    CGSize size;
    if (title) { 
        size = [title sizeWithFont:[UIFont boldSystemFontOfSize:20]];
        headerLabel.frame = CGRectMake(160.0 - size.width/2, 0.0, 300.0, 44.0);
    }
    // If you want to align the header text as centered
    //headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    
    headerLabel.text = title; // i.e. array element
    [customView addSubview:headerLabel];
    return customView;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;

    // Return the number of rows in the section.
    switch (section) {
        case NAME_SECTION:
            rows = 1;
            break;

        case DATE_SECTION:
            rows = 1;
            break;

        case DATE_ALARM_SECTION:
            rows = 1;
            break;

        case CONFIG_SECTION:
            rows = 2;
            break;
//        case ADDEDTOCALENDAR_SECTION:
//            rows = 1;
//            break;
        case SPECIFIC_LIST_SECTION:
            rows = [specifics count];
            //if (self.editing) {
            //    rows++;
           // }
            break;
		default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    if (indexPath.section == SPECIFIC_LIST_SECTION) {
        NSInteger row = indexPath.row;
        static NSString *SpecificsCellIdentifier = @"Specifics";
        
        cell = [tableView dequeueReusableCellWithIdentifier:SpecificsCellIdentifier];
        
        if (cell == nil) {
            // Create a cell to display an ingredient.
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SpecificsCellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        NSString *specific = [specifics objectAtIndex:row];
        //cell.textLabel.text = specific;
        NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
        for (UIView *subview in subviews) {
            [subview removeFromSuperview];
        }
        [subviews release];
        
        UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 94, 27)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 8, 212, 27)];
        
        //NSLog(@"Write to file:%@",theSwitch.on ? @"YES" : @"NO");
        
        label.text = specific;
        theSwitch.tag = row;
        theSwitch.on = [[self.specificsStates objectAtIndex:row] boolValue];
        [theSwitch addTarget:self action:@selector(addDeleteToPushList:) forControlEvents:UIControlEventValueChanged];

        [cell.contentView addSubview:label];
        [cell.contentView addSubview:theSwitch];
        [label release];
        [theSwitch release];
        return cell;
    }
    
        
    static NSString *MyIdentifier = @"GenericCell";
    static NSString *MyIdentifier2 = @"GenericCell2";

    
    NSString *text = nil;
    
    switch (indexPath.section) {
        case CONFIG_SECTION: // resolved -- should be define as custom cell
            if (cell == nil) {
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }

                NSArray *subviews = [[NSArray alloc] initWithArray:cell.contentView.subviews];
                for (UIView *subview in subviews) {
                    [subview removeFromSuperview];
                }
                [subviews release];
                
                UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(200, 8, 94, 27)];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(6, 8, 212, 27)];
                
                //NSLog(@"Write to file:%@",theSwitch.on ? @"YES" : @"NO");


                NSInteger row = indexPath.row;
                if (row == 0) {
                    label.text = @"Resolved:";
                    theSwitch.on = [[event valueForKey:@"resolved"] boolValue];
                    [theSwitch addTarget:self action:@selector(changeResolveState:) forControlEvents:UIControlEventValueChanged];
                }
                if (row == 1) {
                    label.text = @"Added to calendar:";
                    theSwitch.on = [[event valueForKey:@"addedToCalendar"] boolValue];
                    [theSwitch addTarget:self action:@selector(changeAddedToCalendarState:) forControlEvents:UIControlEventValueChanged];
                }
                [cell.contentView addSubview:label];
                [cell.contentView addSubview:theSwitch];
                [label release];
                [theSwitch release];

            }
            break;

        case NAME_SECTION:
            text = [event valueForKey:@"name"];
            //NSLog(@"%@",text);

            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            break;
        case DATE_SECTION:
            text = [formatter stringFromDate:[event valueForKey:@"date"]];
            //NSLog(@"%@",text);

            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
            cell.textLabel.textAlignment = UITextAlignmentCenter;

            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            break;
        case DATE_ALARM_SECTION:
            text = [formatter stringFromDate:[event valueForKey:@"dateAlarm"]];
            //NSLog(@"%@",text);

            cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier2];
            cell.textLabel.textAlignment = UITextAlignmentCenter;

            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            break;
        default:
            break;
    }
    
    cell.textLabel.text = text;

    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSIndexPath *rowToSelect = indexPath;
    NSInteger section = indexPath.section;
    BOOL isEditing = self.editing;
    
    // If editing, don't allow instructions to be selected
    // Not editing: Only allow instructions to be selected
    if ((isEditing && section == CONFIG_SECTION) || (!isEditing && section != CONFIG_SECTION)) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        rowToSelect = nil;    
    }
    
	return rowToSelect;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    // Only allow editing in the ingredients section.
    // In the ingredients section, the last row (row number equal to the count of ingredients) is added automatically (see tableView:cellForRowAtIndexPath:) to provide an insertion cell, so configure that cell for insertion; the other cells are configured for deletion.
    if (indexPath.section == NAME_SECTION) {
        // If this is the last item, it's the insertion row.
            style = UITableViewCellEditingStyleNone;
    }
    
    return style;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
}


-(IBAction) changeResolveState:(id)sender;
{
    UISwitch *theSwitch = sender;
    NSManagedObject *mo = self.event;
    [mo setValue:[NSNumber numberWithBool:theSwitch.on] forKey:@"resolved"];
    
    
    NSManagedObjectContext *context = [mo managedObjectContext];
    NSError *error;
    if (![context save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}
-(IBAction) addDeleteToPushList:(id)sender;
{
    UISwitch *senderr = sender;
    NSLog(@"Events detail:switch state is:%@",senderr.on ? @"YES" : @"NO");
    //if (!senderr.on) return;
    NSInteger tag = [sender tag];
    NSString *specific = [specifics objectAtIndex:tag];
    
    NSManagedObjectContext *moc = [event managedObjectContext];
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[moc persistentStoreCoordinator] withSender:self withMainMoc:moc];
    CompanyStuff *currentStuff = [clientController authorization];
//    if (!currentStuff) currentStuff = [userDataController defaultUser];
    NSSet *carriers = currentStuff.carrier;
    
    NSString *statusForCarrier = nil;
    Carrier *carrier = nil;
    
    for (Carrier *obj in carriers) {
        statusForCarrier = [clientController localStatusForObjectsWithRootGuid:obj.GUID];
        if (statusForCarrier) {
            carrier = obj;
            break;
        }
    }
    
    if (!carrier) carrier = [carriers anyObject];
    
    if (!carrier) {
        [clientController release];
        [senderr setOn:NO animated:YES];
        self.isErrorStillShowing = YES;
        [self.navigationController setToolbarHidden:NO animated:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            sleep(3);
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [self.navigationController setToolbarHidden:YES animated:YES]; 
                self.isErrorStillShowing = NO;

            });
        });
        
        return; 

    }
    //NSString *statusForCarrier = [userDataController localStatusForObjectsWithRootGuid:carrier.GUID];
    NSString *statusForCompany = [clientController localStatusForObjectsWithRootGuid:carrier.companyStuff.currentCompany.GUID];
    NSString *statusForStuff = [clientController localStatusForObjectsWithRootGuid:carrier.companyStuff.GUID];
    
    if (!statusForCarrier || !statusForCompany || !statusForStuff) {
        //NSLog(@"u can't add routes while not register other");
        [clientController release];
        self.isErrorStillShowing = YES;

        
        [senderr setOn:NO animated:YES];
        
        [self.navigationController setToolbarHidden:NO animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
            sleep(5);
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
                [self.navigationController setToolbarHidden:YES animated:YES]; 
                self.isErrorStillShowing = NO;

            });
        });
        
        return; 
    }

    
    
    //Carrier *carrier = [currentStuff.carrier anyObject];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"country CONTAINS[cd] %@",country];
    //[fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"specific"]];
    NSError *error = nil;
    [fetchRequest setPredicate:predicate];
    NSArray *specificsForFill = [moc executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
    NSString *correctCountry = [[specificsForFill lastObject] valueForKey:@"country"];
    
    DestinationsListPushList *newDestination = (DestinationsListPushList *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListPushList" inManagedObjectContext:clientController.moc];
    newDestination.carrier = carrier;
    newDestination.country = correctCountry;
    newDestination.specific = specific;
    
//    NSArray *keys = [[[currentStuff entity] attributesByName] allKeys];
//    NSDictionary *dict = [currentStuff dictionaryWithValuesForKeys:keys];
    

    [clientController.moc save:&error];
    if (error) NSLog(@"%@",[error localizedDescription]);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        sleep(3);
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[event managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[event managedObjectContext]];
        
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[newDestination objectID]] mustBeApproved:YES];
        
        [clientController release];
    });

    
//    NSDictionary *opjectsForRegistration = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObject:[newDestination objectID]], @"new", newDestination.GUID, @"rootObjectGUID", nil];
//    
//    [userDataController startRegistrationForObjects:opjectsForRegistration 
//                                   forTableView:nil
//                                      forSender:self 
//                            clientStuffFullInfo:dict];
    [clientController release];

    
}

#pragma mark - EventKit methods

-(IBAction) changeAddedToCalendarState:(id)sender;
{
    
    UISwitch *theSwitch = sender;
    NSManagedObject *mo = self.event;
    [mo setValue:[NSNumber numberWithBool:theSwitch.on] forKey:@"addedToCalendar"];
    eventStore = [[EKEventStore alloc] init];
    
    if (theSwitch.on == NO) {
       // NSLog(@"REMOVE FROM CALENDAR");
        NSString *eventIdentifier = [mo valueForKey:@"eventIdentifier"];
        //if (eventIdentifier || [eventStore eventWithIdentifier:eventIdentifier]) {
        EKEvent *eventExist = [eventStore eventWithIdentifier:eventIdentifier];
        NSError *error;
        
        BOOL removed = [eventStore removeEvent:eventExist span:EKSpanThisEvent error:&error];
        if (!removed && error) {
            NSLog(@"%@",[error localizedDescription]);
        } 
        [mo setValue:nil forKey:@"eventIdentifier"];
        [eventStore release];
        return;        
    //}
    }
    if (theSwitch.on == YES) {
       // NSLog(@"ADD TO CALENDAR");

        EKEvent *newEvent = [EKEvent eventWithEventStore:eventStore];
        newEvent.calendar = eventStore.defaultCalendarForNewEvents;
        NSString *titleForEvent = [NSString stringWithFormat:@"In country:%@ will be:\n%@ event",[mo valueForKey:@"name"],[mo valueForKey:@"necessaryData"]];
        newEvent.title = titleForEvent;
        newEvent.allDay = YES;
        
        NSDate *date = [mo valueForKey:@"date"];
        NSDate *dateAlarm = [mo valueForKey:@"dateAlarm"];
        EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:[dateAlarm timeIntervalSinceDate:date]];

        if (dateAlarm < [NSDate date]){
            
            dateAlarm = [NSDate dateWithTimeIntervalSinceNow:+18000];
            NSDateFormatter *dateForm = [[NSDateFormatter alloc]init];
            [dateForm setDateFormat:@"%HH"];
            NSString *hourOfAlarm = [dateForm stringFromDate:dateAlarm];
            [dateForm release];
            NSNumberFormatter *numberForm = [[NSNumberFormatter alloc] init];
            NSNumber *hour = [numberForm numberFromString:hourOfAlarm];
            [numberForm release];
            int difference = 0;
            if ([hour intValue] < 9) difference = (9 - [hour intValue]) *3600;
            if ([hour intValue] > 17) difference = (17 - [hour intValue]) *3600;
            if (difference != 0) {
                NSTimeInterval interval = 18000 + difference;
                dateAlarm = [NSDate dateWithTimeIntervalSinceNow:interval];
            }
            alarm = [EKAlarm alarmWithRelativeOffset:[dateAlarm timeIntervalSinceDate:date]];
        }   
        newEvent.startDate = date;
        newEvent.endDate = date;
        
        //EKAlarm *alarm = [EKAlarm alarmWithRelativeOffset:[dateAlarm timeIntervalSinceDate:date]];
        newEvent.alarms = [NSArray arrayWithObject:alarm];
        
        NSError *error;
        
        BOOL saved = [eventStore saveEvent:newEvent span:EKSpanThisEvent error:&error];
        if (!saved && error) {
            NSLog(@"%@",[error localizedDescription]);
        } else [mo setValue:newEvent.eventIdentifier forKey:@"eventIdentifier"];
        
        NSManagedObjectContext *context = [mo managedObjectContext];
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    [eventStore release];
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
    NSString *subject = [NSString stringWithFormat:@"holiday notification for %@ country",self.country];
    [picker setSubject:subject];
    //NSLog(@"%@",subject);

    NSMutableString *emailBody = [NSMutableString stringWithFormat:@"This email is notified you that in country:%@\n with specifics:\n",self.country];
                           
    for (NSString *specific in self.specifics)
      {
          [emailBody appendFormat:@"%@\n",specific];
      }
    NSDate *date = [event valueForKey:@"date"];
    //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //[formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formatter stringFromDate:date];
    //[formatter release];

    [emailBody appendFormat:@"a holiday with name:%@\n will start at %@.\n You receive this email from application SNOW IXC, which you can download from App Store for free.",[event valueForKey:@"necessaryData"],dateString];

    [picker setMessageBody:emailBody isHTML:NO];
    //NSLog(@"%@",emailBody);

    [self presentModalViewController:picker animated:YES];

}
#pragma mark -
#pragma mark - UIActionSheetDelegate
/*- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    return;
}*/
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked send mail button
	if (buttonIndex == 0)
	{
        [self sendMailCompose];
		//NSLog(@"ok");
	}
}

#pragma mark - Send mail methods

-(void)sendMail:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Send event by mail",nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    //[actionSheet showInView:self.parentViewController.tabBarController.view];
	//[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet showFromTabBar:self.tabBarController.tabBar];
    [actionSheet release];

}

#pragma mark - external reload methods

-(void) reloadLocalDataFromUserDataControllerForObject:(id)object;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:selected animated:YES scrollPosition:UITableViewScrollPositionNone];
    });
}

@end
