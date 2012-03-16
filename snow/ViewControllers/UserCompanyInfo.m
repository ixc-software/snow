//
//  UserCompanyInfo.m
//  snow
//
//  Created by Oleksii Vynogradov on 06.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import "UserCompanyInfo.h"
#import "desctopAppDelegate.h"
#import "ClientController.h"

#import "AVResizedTableHeaderView.h"
#import "AVTableHeaderView.h"
#import "AVGradientBackgroundView.h"
//#import "FirstAuthorizationSetupView.h"

#import <QuartzCore/QuartzCore.h>

#import "CurrentCompany.h"
#import "CompanyStuff.h"
#import "OperationNecessaryToApprove.h"

@interface UserCompanyInfo()

-(void)updateWellcomeTitle;
-(void)updateVerticalViewDataForObjectID:(NSManagedObjectID *)objectID;



@end

@implementation UserCompanyInfo
@synthesize moc,delegate;
@synthesize isLoginWasSuccesseful;
@synthesize isViewHidden;
@synthesize removeAwaitingApproveRegistration,addUser,changeToAdmin;

@synthesize companyStuffFirstPlusLastName;
@synthesize selectedUserID;
@synthesize addCompany;


-(void) updateTableView:(NSTableView *)tableView;
{
    NSTableHeaderView *currentTableHeader = [tableView headerView];
    //AVResizedTableHeaderView *newView = [[[AVResizedTableHeaderView alloc] init] autorelease];
    NSRect currentRect = [currentTableHeader frame];
    
    [currentTableHeader setFrame:NSRectFromCGRect(CGRectMake(currentRect.origin.x, currentRect.origin.y, currentRect.size.width, currentRect.size.height + 5))];
    [currentTableHeader setBounds:[currentTableHeader bounds]];
    [tableView setHeaderView:currentTableHeader];
    
    for (NSTableColumn *column in [tableView tableColumns]) {
        NSString *info = [[column headerCell] stringValue];
        NSFont *myFont = [NSFont systemFontOfSize:12];
        
        AVTableHeaderView *newHeader = [[[AVTableHeaderView alloc]
                                         initTextCell:info] autorelease];
        [newHeader setTextColor:[NSColor whiteColor]];
        [newHeader setFont:myFont];
        //NSSize myStringSize = [info sizeWithAttributes:nil];
        //NSSize cellSize = [[column headerCell] cellSize];
        //if (myStringSize.width > cellSize.width) NSLog(@"gare it for %@",info);
        
        [newHeader setControlSize:NSRegularControlSize];
        [newHeader setAlignment:NSCenterTextAlignment];
        
        //[column set
        [column setHeaderCell:newHeader];
        
    }
    [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleSourceList];
    [tableView setBackgroundColor:[NSColor colorWithDeviceRed:0.52 green:0.54 blue:0.70 alpha:1]];
    NSRect frame = [[tableView cornerView] frame];
    //NSLog(@"Corner frame:%@",NSStringFromRect(frame));
    
    [tableView setCornerView:nil];
    AVGradientBackgroundView *newView = [[[AVGradientBackgroundView alloc] initWithFrame:frame] autorelease];
    [tableView setCornerView:newView];
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        //[moc setMergePolicy:NSOverwriteMergePolicy];       
        [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

        
        //[moc setMergePolicy:NSRollbackMergePolicy];
        [moc setPersistentStoreCoordinator:delegate.persistentStoreCoordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];
        observedCompaniesIDs = [[NSMutableArray alloc] initWithCapacity:0];
        isViewHidden = YES;        
        [self addObserver:self forKeyPath:@"isViewHidden" options:NSKeyValueObservingOptionNew context:nil];
        isFirstStart = YES;
#if defined(SNOW_SERVER)
        [removeAwaitingApproveRegistration setHidden:NO];
        [removeUser setHidden:NO];
        [addUser setHidden:NO];
        [changeToAdmin setHidden:NO];
        [login setHidden:YES];
#endif
    }
    
    return self;
}

-(void)awakeFromNib
{
#if defined(SNOW_SERVER)
    [removeAwaitingApproveRegistration setHidden:NO];
    [removeUser setHidden:NO];
    [addUser setHidden:NO];
    [changeToAdmin setHidden:NO];
    [login setHidden:YES];
#endif
}

//- (IBAction) test
//{
//    NSLog(@"%@",currentCompany);
//}
//
//- (IBAction)test2:(id)sender {
//    
//    NSLog(@"%@",[currentCompany arrangedObjects]);
//
//}
#pragma mark -
#pragma mark CORE DATA methods
- (void)importerDidSave:(NSNotification *)saveNotification {
    NSLog(@"MERGE in UserCompanyInfo controller");
    if ([NSThread isMainThread]) {
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        
        [[delegate managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
    } else {
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
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

-(void) finalSaveForMoc:(NSManagedObjectContext *)mocForSave {
    if ([mocForSave hasChanges]) {
        @synchronized(self) {
            NSError *error = nil;
            if (![mocForSave save: &error]) {
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
    return;
    
}
-(id) userDefaultsObjectForKey:(NSString *)key;
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

-(NSString *)localStatusForObjectsWithRootGuid:(NSString *)rootObjectGUID;
{
    //NSString *objectGUID = [objects valueForKey:@"rootObjectGUID"];
    NSDictionary *objectStatus =[self userDefaultsObjectForKey:rootObjectGUID];
    NSString *status = nil;
    if (objectStatus) { 
        if ([objectStatus valueForKey:@"update"]) status = [objectStatus valueForKey:@"update"];
        if ([objectStatus valueForKey:@"new"]) status =  [objectStatus valueForKey:@"new"]; 
        if ([objectStatus valueForKey:@"login"]) status =  [objectStatus valueForKey:@"login"]; 
        
    }
    return status;
}

#pragma mark -
#pragma mark update interface element's methods
-(void)openView:(NSView *)viewToOpen fromPoint:(NSPoint)startPoint;
{
    NSRect viewRect =  [viewToOpen frame];
    viewToOpen.frame = NSMakeRect(self.view.frame.origin.x + self.view.frame.size.width / 2 - viewToOpen.frame.size.width / 2, self.view.frame.origin.y + self.view.frame.size.height / 2 - viewToOpen.frame.size.height / 2, 0, 0);
    [self.view addSubview:viewToOpen];

    CABasicAnimation *controlPosAnim = [CABasicAnimation animationWithKeyPath:@"position"];
    controlPosAnim.delegate = self;
    //controlPosAnim.duration = 3;
    
    //NSPoint startingPoint = viewRect.origin;
    //NSPoint endingPoint = startingPoint;
    CAAnimationGroup *group = [CAAnimationGroup animation]; 

    controlPosAnim.fromValue = [NSValue valueWithRect:NSMakeRect(startPoint.x, startPoint.y, viewToOpen.frame.size.width, viewToOpen.frame.size.height)];
    controlPosAnim.toValue = [NSValue valueWithRect:viewToOpen.frame];
    //[[viewToOpen layer] addAnimation:controlPosAnim forKey:@"position"];
    
    CABasicAnimation *controlBoundsAnim = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    controlBoundsAnim.delegate = self;
    //controlBoundsAnim.duration = 3;
  
    
    controlBoundsAnim.fromValue = [NSValue valueWithSize:NSMakeSize(viewToOpen.frame.size.width, viewToOpen.frame.size.height)];
    controlBoundsAnim.toValue = [NSValue valueWithSize:viewRect.size];
    //[[viewToOpen layer] addAnimation:controlBoundsAnim forKey:@"bounds"];
    [group setAnimations:[NSArray arrayWithObjects:controlBoundsAnim,controlPosAnim, nil]];
    group.duration = 0.5;
    group.delegate = self;
    group.removedOnCompletion = NO;
    
    [[viewToOpen layer] addAnimation:group forKey:@"savingAnimation"];
    
    viewToOpen.frame = NSMakeRect(viewToOpen.frame.origin.x , viewToOpen.frame.origin.y, viewRect.size.width, viewRect.size.height);
    CGRect newRect = CGRectMake(viewToOpen.frame.origin.x, viewToOpen.frame.origin.y, viewToOpen.frame.size.width, viewToOpen.frame.size.height);
    CGRect updatedRect = CGRectIntegral(newRect);
    
    [viewToOpen setFrame:NSRectFromCGRect(updatedRect)];
    
}

-(void)updateWellcomeTitle;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        
        CompanyStuff *admin = [clientController authorization];
        [clientController release];
        NSString *title = nil;
        if ([admin.GUID isEqualToString:admin.currentCompany.companyAdminGUID]) title = [NSString stringWithFormat:@"Welcome, %@ %@. With email %@ you are admin of the company %@",admin.firstName,admin.lastName,admin.email,admin.currentCompany.name];
        else title = [NSString stringWithFormat:@"Welcome, %@ %@. With email %@ you are part of the community of the company %@",admin.firstName,admin.lastName,admin.email,admin.currentCompany.name];
        if (!admin) title = nil;
        //        else {
        //            if (!isExternalCall) {
        //                NSArray *vertical = [self transformContentFromHorizontalToVerticalDataForBinding:admin];
        //                NSSet *allCompanyUser = admin.currentCompany.companyStuff;
        //                __block NSMutableArray *allUsers = [NSMutableArray arrayWithCapacity:[allCompanyUser count]];
        //                
        //                [allCompanyUser enumerateObjectsUsingBlock:^(CompanyStuff *stuff, BOOL *stop) {
        //                    BOOL localUser = [stuff isEqualTo:admin];
        //                    [allUsers addObjectsFromArray:[self transformContentFromSeparatedFirstAndLastNamesToSplitFrom:stuff isLocalUser:localUser]];
        //                }];
        //                
        //                
        //                
        //                //            dispatch_async(dispatch_get_main_queue(), ^(void) {
        //                [companyStuffFirstPlusLastName setContent:allUsers];
        //                [companyStuffVerticalView setContent:vertical];
        //                //            dispatch_async(dispatch_get_main_queue(), ^(void) {
        //                
        //                //            for (id verticalViewObject in [companyStuffVerticalView arrangedObjects]) [verticalViewObject addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:nil]; 
        //                //            });
        //            }
        //        }
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [delegate.currentUserInfoList setTitle:title];
        });
        
        
        
    });
}


-(void)showErrorBoxWithText:(NSString *)error
{
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    
    //[errorPanel setBackgroundColor:[NSColor colorWithDeviceRed:0.42 green:0.43 blue:0.64 alpha:1]];
    [errorText setStringValue:error];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [self openView:errorView fromPoint:delegate.window.frame.origin];
//        errorView.frame = NSMakeRect(self.view.frame.origin.x + self.view.frame.size.width / 2 - errorView.frame.size.width / 2, self.view.frame.origin.y + self.view.frame.size.height / 2 - errorView.frame.size.height / 2, errorView.frame.size.width, errorView.frame.size.height);

//        [NSApp beginSheet:errorPanel 
//           modalForWindow:delegate.window
//            modalDelegate:nil 
//           didEndSelector:nil
//              contextInfo:nil];
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        sleep(4);
        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            [errorPanel orderOut:delegate.window];
//            [NSApp endSheet:errorPanel];
            [errorView removeFromSuperview];
        });
    });
    
}
-(void)updateStatusButtonsForRow:(NSUInteger)row 
               isCompanySelected:(BOOL)isCompanySelected;
{
    //NSLog(@"USER COMPANY INFO: update buttons start");
    //AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    if (isCompanySelected) {
        //NSLog(@"USER COMPANY INFO: update buttons continue");
        //dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            CurrentCompany *selectedCompany = [[currentCompany arrangedObjects] objectAtIndex:row];
            //CompanyStuff *selectedStuff = [[companyStuff selectedObjects] lastObject];
            NSArray *currentCompanyArray = [currentCompany arrangedObjects];
            //NSArray *companyStuffArray = [companyStuff arrangedObjects];
            
            if (!selectedCompany && [currentCompanyArray count] != 0) selectedCompany = [currentCompanyArray objectAtIndex:0]; 
            //if (!selectedStuff && [companyStuffArray count] != 0) selectedStuff = [companyStuffArray objectAtIndex:0]; 
            
            
            if (!selectedCompany) return;
            NSString *selectedCompanyGUID = selectedCompany.GUID;
            if (!selectedCompanyGUID) { 
                NSLog(@"USER COMPANY INFO: guid for %@ not found",selectedCompany);
                return;
            }
            //[delegate.carrier setFilterPredicate:[NSPredicate predicateWithFormat:@"companyStuff == %@",selectedStuff]];
            
            NSString *statusForCompany = [self localStatusForObjectsWithRootGuid:selectedCompany.GUID];
            if ([statusForCompany isEqualToString:@"external server"]) {
                [makeVisible setHidden:YES];
                [removeCompany setHidden:YES];
                [registerButton setHidden:NO];
                [registerButton setTitle:@"Join"];
                [registerButton setAction:@selector(joinToCompany:)];
                [registerButton setTarget:self];
            } else 
            {
                
                [makeVisible setHidden:NO];
                [removeCompany setHidden:NO];
                if (![statusForCompany isEqualToString:@"registered"]) { 
                    [registerButton setTitle:@"Register"];
                    [registerButton setAction:@selector(registerCompany:)];
                    [registerButton setHidden:NO];
                    [registerButton setTarget:self];
                    
                } else [registerButton setHidden:YES];
                
            }
#if defined(SNOW_SERVER)
            [makeVisible setHidden:NO];
            [removeCompany setHidden:NO];
            [registerButton setHidden:YES];
            
#endif
            
            //NSString *statusForForStuff = [self localStatusForObjectsWithRootGuid:selectedStuff.GUID];
            [currentCompanyStatus setTitle:statusForCompany];
        //});
    } else {
        //        if ([statusForCompany isEqualToString:@"external server"]) {
        //            [makeVisible setHidden:YES];
        //            [removeCompany setHidden:YES];
        //            [registerButton setHidden:NO];
        //            [registerButton setTitle:@"Join"];
        //            [registerButton setAction:@selector(joinToCompany:)];
        //        } else 
        //        {
        //            
        //            [makeVisible setHidden:NO];
        //            [removeCompany setHidden:NO];
        //            if (![statusForCompany isEqualToString:@"registered"]) { 
        //                [registerButton setTitle:@"Register"];
        //                [registerButton setAction:@selector(registerCompany:)];
//                [registerButton setHidden:NO];
//                
//            } else [registerButton setHidden:YES];
//            
//        }
//
//        //NSString *statusForForStuff = [self localStatusForObjectsWithRootGuid:selectedStuff.GUID];
//        [currentCompanyStatus setTitle:statusForCompany];
        //[companyStuffStatus setTitle:statusForForStuff];
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
        //        [selectedStuff addObserver:self forKeyPath:@"firstName" options:NSKeyValueObservingOptionNew context:nil];
        //        [selectedStuff addObserver:self forKeyPath:@"lastName" options:NSKeyValueObservingOptionNew context:nil];
        //        [selectedStuff addObserver:self forKeyPath:@"email" options:NSKeyValueObservingOptionNew context:nil];
        //        [selectedStuff addObserver:self forKeyPath:@"password" options:NSKeyValueObservingOptionNew context:nil];
        
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//        
//        CompanyStuff *authorizedUser = [clientController authorization];
//        [clientController release];
        
//        if ([authorizedUser.GUID isEqualToString:selectedStuff.GUID]) [changePassword setHidden:NO];
//        else [changePassword setHidden:YES];        
#endif
    }
}
-(IBAction)updateCurrentRegistrationsList;
{
//    //NSLog(@"REGISTRATION AWAITING: start re-fresh");
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    NSManagedObjectContext *context =  [[NSManagedObjectContext alloc] init];
//    [context setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
//    [context setUndoManager:nil];
//    
//    NSError *error = nil;
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OperationNecessaryToApprove" inManagedObjectContext:context];
//    [fetchRequest setEntity:entity];
//    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//    if (fetchedObjects == nil) NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
//    
//    [fetchRequest release];
//    
//    NSMutableArray *new = [NSMutableArray arrayWithCapacity:0];
//    
//    [fetchedObjects enumerateObjectsUsingBlock:^(OperationNecessaryToApprove *operation, NSUInteger idx, BOOL *stop) {
//        NSMutableDictionary *necessaryObject = [NSMutableDictionary dictionaryWithCapacity:0];
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        NSEntityDescription *entity = [NSEntityDescription entityForName:operation.forEntity inManagedObjectContext:context];
//        [fetchRequest setEntity:entity];
//        NSString *currentCompanyGUID = nil;
//#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        
//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];    
//        CompanyStuff *authorizedUser = [clientController authorization];
//        [clientController release];
//        if ([delegate.loggingLevel intValue] == 1) NSLog(@"CLIENT:current authorized user:%@",authorizedUser.firstName);
//        CurrentCompany *necessaryCompany = authorizedUser.currentCompany;
//        currentCompanyGUID = necessaryCompany.GUID;
//#endif
//#if defined(SNOW_SERVER)
//        CurrentCompany *selectedCompany = (CurrentCompany *)[[currentCompany selectedObjects] lastObject];
//        if (selectedCompany) currentCompanyGUID = selectedCompany.GUID;
//        else NSLog(@"USER COMPANIES LIST: updateCurrentRegistrationsList warning, companiesList:%@ don't have selectedCompany inside",[currentCompany arrangedObjects]);
//
//#endif
//    
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@) and (currentCompany.GUID == %@)",operation.forGUID,currentCompanyGUID];
//        [fetchRequest setPredicate:predicate];
//        NSError *error = nil;
//        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
//        if (fetchedObjects == nil) NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
//        [fetchRequest release];
//        if ([fetchedObjects count] == 1) {
//            CompanyStuff *objectForApprove = [fetchedObjects lastObject];
//            [necessaryObject setValue:objectForApprove.firstName forKey:@"firstName"];
//            [necessaryObject setValue:objectForApprove.lastName forKey:@"lastName"];
//            [necessaryObject setValue:objectForApprove.phone forKey:@"phone"];
//            [necessaryObject setValue:objectForApprove.email forKey:@"email"];
//            [necessaryObject setValue:objectForApprove.currentCompany.name forKey:@"companyName"];
//            [necessaryObject setValue:operation.forGUID forKey:@"forGUID"];
//            [necessaryObject setValue:operation.forEntity forKey:@"forEntity"];
//            
//        }
//        [new addObject:necessaryObject];
//        
//        
//    }];
//    
//    //NSLog(@"ALL REGISTRATIONS:%@",new);
//    [recordsAwaitingApproveStack setContent:new];
//    [context release];
    
    //    [userController release];
    
}


#pragma mark -
#pragma mark data transform methods
-(void) prepareEveryArraysForFirstShow;
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

#if defined(SNOW_SERVER)
#else
 
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];    
    CompanyStuff *authorizedUser = [clientController authorization];
    //if ([delegate.loggingLevel intValue] == 1) NSLog(@"CLIENT:current authorized user:%@",authorizedUser.firstName);
    CurrentCompany *necessaryCompany = authorizedUser.currentCompany;
    [companyStuff setFilterPredicate:[NSPredicate predicateWithFormat:@"currentCompany.GUID == %@",necessaryCompany.GUID]];
    [self updateWellcomeTitle];
    [self updateVerticalViewDataForObjectID:authorizedUser.objectID];
        [clientController release];
    
//    CompanyStuff *anyObject = nil;
//    if ([[currentCompany arrangedObjects] count] != 0) {
//        [self updateStatusButtonsForRow:0 isCompanySelected:NO];
//        
//        CurrentCompany *firstCompany = [[currentCompany arrangedObjects] objectAtIndex:0];
//        anyObject = firstCompany.companyStuff.anyObject;
//        [self updateVerticalViewDataForObjectID:anyObject.objectID];
//    } //else NSLog(@"USER COMPANIES LIST: prepareEveryArraysForFirstShow warning, companiesList:%@ don't have nothing inside",[currentCompany arrangedObjects]);
//    if (anyObject) selectedUserID = anyObject.objectID;
//    [delegate.addCarrierButton setEnabled:YES];

#endif
    
    if (isFirstStart) {
        [self updateTableView:companyStuffVerticalTableView];
        [self updateTableView:usersAwaitingApproveTableView];
        [self updateTableView:currentCompanyTableView];
        isFirstStart = NO;
//        if (anyObject) selectedUserID = anyObject.objectID;
//        [delegate.addCarrierButton setEnabled:YES];

#if defined(SNOW_SERVER)
        
//        if (anyObject) selectedUserID = anyObject.objectID;
//        [delegate.addCarrierButton setEnabled:YES];
#endif
    }
    
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
    [currentCompany setSelectionIndex:0];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];    
        CompanyStuff *authorizedUser = [clientController authorization];
        if (authorizedUser) {
            CurrentCompany *currentCompanyObj = (CurrentCompany *)[moc objectWithID:authorizedUser.currentCompany.objectID];
            NSArray *allCompanies = currentCompany.arrangedObjects;
            __block NSUInteger companyRow = 0;
            [allCompanies enumerateObjectsUsingBlock:^(CurrentCompany *company, NSUInteger idx, BOOL *stop) {
                if ([currentCompanyObj.objectID isEqualTo:company.objectID]) companyRow = idx;
            }];
            //NSUInteger rowIndexCompany = [allCompanies indexOfObject:currentCompanyObj];
            
            //if (rowIndexCompany != NSNotFound) 
            [self updateStatusButtonsForRow:companyRow isCompanySelected:YES];
            [self updateVerticalViewDataForObjectID:authorizedUser.objectID];

            NSUInteger rowIndexAdmin = [[currentCompany arrangedObjects] indexOfObject:[moc objectWithID:authorizedUser.objectID]];
            
            if (rowIndexAdmin != NSNotFound) [self updateStatusButtonsForRow:rowIndexAdmin isCompanySelected:NO];
        }
        [clientController release];
    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        
////        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//        
//        [clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:NO isUserAuthorized:NO];
//        [clientController release];
//    });
    
#endif
    
        
    });
}

- (NSArray *) transformContentFromSeparatedFirstAndLastNamesToSplitFrom:(NSManagedObject *)content isLocalUser:(BOOL)isLocalUser;
{
    
    NSMutableArray *columns = [NSMutableArray array];
    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //    [formatter setDateFormat:@"d MMM"];
    NSMutableDictionary *row = [NSMutableDictionary dictionary];
    NSString *firstName = [content valueForKey:@"firstName"];
    NSString *lastName = [content valueForKey:@"lastName"];
    NSManagedObjectID *objectID = [content objectID];

    if (isLocalUser) { 
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
        
        [row setValue:[NSString stringWithFormat:@"YOU"] forKey:@"data"]; 
#endif
#if defined (SNOW_SERVER)
        [row setValue:[NSString stringWithFormat:@"%@ %@",firstName,lastName] forKey:@"data"]; 
#endif
    }
    
    else [row setValue:[NSString stringWithFormat:@"%@ %@",firstName,lastName] forKey:@"data"]; 
    [row setObject:objectID forKey:@"objectID"];
    
    
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    
    
    NSString *currentStatusForObject = [clientController localStatusForObjectsWithRootGuid:[content valueForKey:@"GUID"]];
    
    NSString *status = nil;
    if ([currentStatusForObject isEqualToString:@"registered"]) {
        status = @"registered";
        //[registrationNotification setHidden:YES];
        
    } else { 
        status = @"waiting for registration";
        //[registrationNotification setHidden:NO];
    }
    
    [row setValue:status forKey:@"status"];
    [columns addObject:row];
    
    [clientController release];
    //    [formatter release];
    return [NSArray arrayWithArray:columns];
}


- (NSArray *) transformContentFromHorizontalToVerticalDataForBinding:(NSManagedObject *)content;
{
    
    NSMutableArray *columns = [NSMutableArray array];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMM"];
    NSArray *attributes = [[content entity] attributeKeys];
    NSManagedObjectID *objectID = [content objectID];
    NSString *guid = [content valueForKey:@"GUID"];
    for (NSString *attribute in attributes)
    {
        if ([attribute isEqualToString:@"firstName"] || [attribute isEqualToString:@"lastName"]  || [attribute isEqualToString:@"phone"] || [attribute isEqualToString:@"email"] || [attribute isEqualToString:@"password"]) {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            [row setValue:attribute forKey:@"attribute"];
            [row setValue:guid forKey:@"GUID"];
            [row setObject:objectID forKey:@"objectID"];            
            [row setValue:[content valueForKey:attribute] forKey:@"data"];
            [row addObserver:self forKeyPath:@"data" options:NSKeyValueObservingOptionNew context:nil]; 
            [columns addObject:row];
        }
    }
    [formatter release];
    return [NSArray arrayWithArray:columns];
}

-(void)updateCompaniesListScrollForUserWithObjectID:(NSManagedObjectID *)objectID;
{
    //NSManagedObjectContext *mainContext = [currentCompany managedObjectContext];
    CompanyStuff *findedObject = (CompanyStuff *)[self.delegate.managedObjectContext objectWithID:objectID];
    NSLog(@"COMPANY STUFF: user email to check:%@",findedObject.email);

    if ([[findedObject class] isSubclassOfClass:[CompanyStuff class]]) {
        CompanyStuff *authorizedStuff = (CompanyStuff *)findedObject;
        //NSLog(@"USER COMPANIES LIST:scroll to user with email:%@ and company name:%@",authorizedStuff.email, authorizedStuff.currentCompany.name);
        //[currentCompany rearrangeObjects];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            NSUInteger index = [[currentCompany arrangedObjects] indexOfObjectIdenticalTo:authorizedStuff.currentCompany];
            [companyStuff setFilterPredicate:[NSPredicate predicateWithFormat:@"currentCompany.GUID == %@",authorizedStuff.currentCompany.GUID]];
            
            if (index != NSNotFound) { 
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

                //NSLog(@"COMPANY STUFF: index for company:%@ is:%@",authorizedStuff.currentCompany.name,[NSNumber numberWithUnsignedInteger:index]);
                    
                    sleep(1);
                    dispatch_async(dispatch_get_main_queue(), ^(void) {
                        
                        [currentCompanyTableView deselectAll:self];
                        [currentCompanyTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:YES];
                        [currentCompanyTableView scrollRowToVisible:index];
                    });
                });
            } //else NSLog(@"COMPANY STUFF: index for company not found");
        });

    }
}

-(void)updateVerticalViewDataForObjectID:(NSManagedObjectID *)objectID;
{
    if (!objectID) return;
    [self updateCompaniesListScrollForUserWithObjectID:objectID];
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
    
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *admin = [clientController authorization];
    
    CompanyStuff *selectedUser = (CompanyStuff *)[self.delegate.managedObjectContext objectWithID:objectID];
    
    [clientController release];
    NSString *title = nil;
    if (!selectedUser) title = nil;
    else {
        NSArray *vertical = [self transformContentFromHorizontalToVerticalDataForBinding:selectedUser];
        NSSet *allCompanyUser = selectedUser.currentCompany.companyStuff;
        __block NSMutableArray *allUsers = [NSMutableArray arrayWithCapacity:[allCompanyUser count]];
        
        [allCompanyUser enumerateObjectsUsingBlock:^(CompanyStuff *stuff, BOOL *stop) {
            BOOL localUser = [stuff.objectID isEqualTo:admin.objectID];
            [allUsers addObjectsFromArray:[self transformContentFromSeparatedFirstAndLastNamesToSplitFrom:stuff isLocalUser:localUser]];
        }];
        NSArray *content = [NSArray arrayWithArray:allUsers];
        [companyStuffFirstPlusLastName setContent:content];
        selectedUserID = selectedUser.objectID;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectID == %@",selectedUserID];
        NSArray *allUsersInsideController = [companyStuffFirstPlusLastName arrangedObjects];
        
        NSArray *filteredAllUsers = [allUsersInsideController filteredArrayUsingPredicate:predicate];
        NSDictionary *currentSelectedUser = [filteredAllUsers lastObject];
        if (currentSelectedUser) [companyStuffFirstPlusLastName setSelectedObjects:[NSArray arrayWithObject:currentSelectedUser]];
        else NSLog(@"USER COMPANY INFO: warning, user with id:%@ not found in all users array:%@",selectedUserID,[companyStuffFirstPlusLastName arrangedObjects]);
        [companyStuffVerticalView setContent:vertical];
        
        
    }
    
    if ([admin.GUID isEqualToString:selectedUser.GUID]) {
        // only current user can edit yourself
        NSArray *tableColumn = [companyStuffVerticalTableView tableColumns];
        [tableColumn enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
            if (idx == 1) [column setEditable:YES];
        }];
    } else {
        NSArray *tableColumn = [companyStuffVerticalTableView tableColumns];
        [tableColumn enumerateObjectsUsingBlock:^(NSTableColumn *column, NSUInteger idx, BOOL *stop) {
            if (idx == 1) [column setEditable:NO];
        }];
        
    }
    
    
    //});
}

#pragma mark -
#pragma mark tableview methods
// tag 0 = left position table view in Users box (users list)
// tag 1 = rigth position table view in Users box (user data list)
// tag 2 = users awaiting for approve table view
// tag 3 = companies list table view

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)

    if ([aTableView tag] == 1) {
        if (rowIndex == 3 && [[[aTableColumn headerCell] title] isEqualToString:@"data"]) {
            [aCell setTitle:@"*******"];
        }
    }
#endif
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    
    //NSLog(@"test");
    
    if ([aTableView tag] == 0) return NO;
    if ([aTableView tag] == 1) return YES;
    if ([aTableView tag] == 2) { 
#ifdef SNOW_SERVER
        return YES;
#else
        return NO;
#endif
    }
    if ([aTableView tag] == 3) {
#ifdef SNOW_SERVER
        CurrentCompany *company = [[currentCompany arrangedObjects] objectAtIndex:rowIndex];
        NSLog(@"USER COMPANIES LIST: selected company name:%@ guid:%@ admin guid:%@",company.name,company.GUID,company.companyAdminGUID);
        return YES;
        
#endif

#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
        CurrentCompany *company = [[currentCompany arrangedObjects] objectAtIndex:rowIndex];
        
        NSString *statusForCompany = [self localStatusForObjectsWithRootGuid:company.GUID];
        
        if (![statusForCompany isEqualToString:@"external server"]) {
//            
//            [observedCompaniesIDs addObject:[company objectID]];
            [company addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
            [company addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
            observedCurrentCompany = company.objectID;
        }
        
        //NSLog(@"user guid:%@\n company admin guid:%@",[userController authorization].GUID,company.companyAdminGUID);
        if ([[self localStatusForObjectsWithRootGuid:company.GUID] isEqualToString:@"external server"]) 
        {
            NSLog(@"CLIENT:please edit only internal companies");
            [self showErrorBoxWithText:@"please edit only internal companies"];
            
            return NO;
            
        }
        
        if ([[[aTableColumn headerCell] title] isEqualToString:@"Company name"] || [[[aTableColumn headerCell] title] isEqualToString:@"rates email"] || [[[aTableColumn headerCell] title] isEqualToString:@"url"]) {
            return YES;
        } else {
            NSLog(@"CLIENT:wrong edited column");
            return NO;
        }
#endif
        

    }
    return NO;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{

    if ([aTableView tag] == 0) {
        // this is users list
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];

        NSArray *allFirstAndLastNames = [companyStuffFirstPlusLastName arrangedObjects];
        NSDictionary *person = [allFirstAndLastNames objectAtIndex:rowIndex];
        NSManagedObjectID *objectID = [person valueForKey:@"objectID"];
        NSManagedObject *object = [moc objectWithID:objectID];
        
        //dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
        [delegate.carriersView.carrier setFilterPredicate:nil];
//        [delegate.carriersView.carrier setFilterPredicate:[NSPredicate predicateWithFormat:@"companyStuff.GUID == %@",[object valueForKey:@"GUID"]]]
        
        [delegate.carriersView.carrier setFilterPredicate:[NSPredicate predicateWithFormat:@"companyStuff.GUID == %@",[object valueForKey:@"GUID"]]];
        
        //});
        
        [self updateStatusButtonsForRow:rowIndex isCompanySelected:NO];        
        NSManagedObjectID *userSelected = [person valueForKey:@"objectID"];
        [self updateVerticalViewDataForObjectID:userSelected];
        
#ifdef SNOW_SERVER
        
        CompanyStuff *userSelectedObject = (CompanyStuff *)[delegate.managedObjectContext objectWithID:userSelected];
        NSString *personGUID = userSelectedObject.GUID;
        NSString *personEmail = userSelectedObject.email;
        NSString *personPassword = userSelectedObject.password;
        NSURL *personURI = [[userSelectedObject objectID] URIRepresentation];
        NSString *personCompanyName = userSelectedObject.currentCompany.name;
        
        NSLog(@"COMPANY STUFF TABLE VIEW: selected user guid:%@ email:%@ password:%@ uri:%@ company:%@",personGUID,personEmail,personPassword,personURI,personCompanyName);
#endif
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
        
        //[self updateWellcomeTitle];
        //[self updateVerticalViewDataForObjectID:userSelected];
        
        //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        //        
        //        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        //        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        //        
        //        [clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:NO];
        //        [clientController release];
        //    });
#endif
        
    }
    
    if ([aTableView tag] == 1) {
        // this is users data list
    }
    
    if ([aTableView tag] == 3) {
        // this is companies list
        CurrentCompany *company = [[currentCompany arrangedObjects] objectAtIndex:rowIndex];
        [self updateStatusButtonsForRow:rowIndex isCompanySelected:YES];
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        //
        [delegate.carriersView.carrier setFilterPredicate:nil];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyStuff.currentCompany.GUID == %@",company.GUID];
        [delegate.carriersView.carrier setFilterPredicate:predicate];


#if defined(SNOW_SERVER)
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            NSSet *allUsers = company.companyStuff;
            
            NSDate *maximumDate = nil;
            for (CompanyStuff *stuff in allUsers) {
                NSDate *modificationDate = stuff.modificationDate;
                NSLog(@"modificationDate %@",modificationDate);

                if (!maximumDate) maximumDate = modificationDate;
                else {
                    if ([modificationDate timeIntervalSinceDate:maximumDate] > 0) {
                        maximumDate = modificationDate;
                        NSLog(@"maximumDate %@ earler than modificationDate %@",maximumDate,modificationDate);
                    }
                }
            };
            modifiedDate.title = maximumDate.description;
            //NSLog(@"maximumDate %@",maximumDate);
            [modifiedDate setHidden:NO];
            
            NSString *companyName = company.name;
            NSString *companyGUID = company.GUID;
            NSString *companyAdminGUID = company.companyAdminGUID;
            
            NSLog(@"USER COMPANIES LIST: selected company name:%@ guid:%@ admin guid:%@",companyName,companyGUID,companyAdminGUID);
            //[carrier setFilterPredicate:[NSPredicate predicateWithFormat:@"companyStuff.currentCompany == %@",company]];
            //[companyStuff setFilterPredicate:[NSPredicate predicateWithFormat:@"currentCompany == %@",company]];
            NSManagedObjectID *anyUserID = [[company.companyStuff anyObject] objectID];
            
            if (anyUserID) [self updateVerticalViewDataForObjectID:anyUserID];
            else { 
                NSLog(@"USER COMPANIES LIST: shit happend, user not found");
                [companyStuffFirstPlusLastName setContent:nil];
                [companyStuffVerticalView setContent:nil];
            }
        });
#endif
        
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
        if (!company.GUID) return NO;
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        
//        [companyStuffTableView deselectRow:0];
//        [companyStuffTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:YES];
//        [self updateStatusButtonsForRow:rowIndex isCompanySelected:YES];
        NSString *statusForCompany = [self localStatusForObjectsWithRootGuid:company.GUID];
        //[currentCompanyStatus setTitle:statusForCompany];
        
        if (statusForCompany && ![statusForCompany isEqualToString:@"external server"]) {
            CompanyStuff *currentAdmin = [clientController authorization];
            if (!currentAdmin) { 
                [clientController release];
                return NO;
            }
            CompanyStuff *newCurrentAdminInClientControllerMoc = (CompanyStuff *)[self.moc objectWithID:[currentAdmin objectID]];
            CurrentCompany *newCurrentCompanyInClientControllerMoc = (CurrentCompany *)[self.moc objectWithID:company.objectID];
            newCurrentAdminInClientControllerMoc.currentCompany = newCurrentCompanyInClientControllerMoc;
            company.companyAdminGUID = newCurrentAdminInClientControllerMoc.GUID;
            [self finalSaveForMoc:self.moc];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                sleep(2);
//                AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[newCurrentAdminInClientControllerMoc objectID]] mustBeApproved:NO];
                [clientController release];
            });
        }
        
//        if (![observedCompaniesIDs containsObject:[company objectID]] && ![statusForCompany isEqualToString:@"external server"]) {
//            [observedCompaniesIDs addObject:[company objectID]];
//            [company addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//            [company addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
//        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            [carrier setFilterPredicate:[NSPredicate predicateWithFormat:@"companyStuff.currentCompany == %@",company]];
            [companyStuff setFilterPredicate:[NSPredicate predicateWithFormat:@"currentCompany == %@",company]];
        });
        
        
        CompanyStuff *clientStuff = [clientController authorization];
        [clientController release];
        
//        if ([statusForCompany isEqualToString:@"external server"]) {
//            [makeVisible setHidden:YES];
//            [removeCompany setHidden:YES];
//            [registerButton setHidden:NO];
//            [registerButton setTitle:@"Join"];
//            [registerButton setAction:@selector(joinToCompany:)];
//        } else 
//        {
//            
//            [makeVisible setHidden:NO];
//            [removeCompany setHidden:NO];
//            if (![statusForCompany isEqualToString:@"registered"]) { 
//                [registerButton setTitle:@"Register"];
//                [registerButton setAction:@selector(registerCompany:)];
//                [registerButton setHidden:NO];
//                
//            } else [registerButton setHidden:YES];
//            
//        }
        
        
        
        
        NSData *currentStackData = [[self userDefaultsObjectForKey:clientStuff.GUID] valueForKey:@"recordsStack"];
        NSArray *currentStack = nil;
        if (currentStackData) currentStack = [NSKeyedUnarchiver unarchiveObjectWithData:currentStackData];
        NSMutableArray *new = [NSMutableArray arrayWithCapacity:0];
        
        [currentStack enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *externalStackObject, NSUInteger idx, BOOL *stop) {
            NSArray *newObjects = [externalStackObject valueForKey:@"new"];
            [new addObjectsFromArray:newObjects];
        }];
        //NSLog(@"ALL REGISTRATIONS:%@",new);
        [recordsAwaitingApproveStack setContent:new];
        // have to be show only selected company records pool
        [recordsAwaitingApproveStack setFilterPredicate:[NSPredicate predicateWithFormat:@"rootGUID == %@",company.GUID]];
        
#endif

    }

    return YES;
    
}

#pragma mark -
#pragma mark CompanyStuff action methods

- (IBAction)switchIsAdminState:(id)sender {
    NSArray *wholeStuff = [companyStuff arrangedObjects];
    NSArray *admins = [wholeStuff filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isCompanyAdmin == YES"]];
    [admins enumerateObjectsWithOptions:NSSortStable usingBlock:^(CompanyStuff *previousAdmin, NSUInteger idx, BOOL *stop) {
        previousAdmin.isCompanyAdmin = [NSNumber numberWithBool:NO];
    }];
    NSDictionary *selectedPerson = [[companyStuffFirstPlusLastName selectedObjects] lastObject];
    NSManagedObjectID *selectedObjectID = [selectedPerson valueForKey:@"objectID"];
    CompanyStuff *selectedStuffToUpdate = (CompanyStuff *)[moc objectWithID:selectedObjectID];
    
    selectedStuffToUpdate.isCompanyAdmin = [NSNumber numberWithBool:YES];
    selectedStuffToUpdate.currentCompany.companyAdminGUID = selectedStuffToUpdate.GUID;
    [self finalSaveForMoc:moc];
}



- (IBAction)addUserForSelectedCompany:(id)sender {
    // at first, we must add it in local stuff:
    if ([[companyStuff arrangedObjects] count] > 0) return;
    //AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    //NSManagedObjectContext *context = [delegate managedObjectContext];
    
    CompanyStuff *newStuff = (CompanyStuff *)[NSEntityDescription 
                                              insertNewObjectForEntityForName:@"CompanyStuff" 
                                              inManagedObjectContext:currentCompany.managedObjectContext];
    
    newStuff.firstName = @"new user";
    CurrentCompany *selected = [[currentCompany selectedObjects] lastObject];
    newStuff.email = @"newUser@newUser.ne";
    newStuff.currentCompany = selected;
//    NSError *error = nil;
//    [context save:&error];
//    if (error) NSLog(@"%@",[error localizedDescription]);
    [self finalSaveForMoc:moc];
    
    [self updateVerticalViewDataForObjectID:newStuff.objectID];
    
    
}

// password issues now direct in user data info

//- (IBAction)setPassword:(id)sender {
//    [setPassword setHidden:NO];
//    [sender setTitle:@"save password"];
//    [sender setAction:@selector(savePassword:)];
//}
//
//- (IBAction)savePassword:(id)sender {
//    [setPassword setHidden:YES];
//    [changePassword setTitle:@"change password"];
//    [changePassword setAction:@selector(setPassword:)];
//    if (!userSelected) userSelected = [[[companyStuff selectedObjects] lastObject] objectID];
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//    NSManagedObjectContext *context = [delegate managedObjectContext];
//    
//    CompanyStuff *user = (CompanyStuff *)[context objectWithID:userSelected];
//    user.password = [setPassword stringValue];
//    [self finalSaveForMoc:context];
//    
//#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
//    
//    userWithUsingForLogin = userSelected;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[user objectID]] mustBeApproved:NO];
//        [clientController release];
//    });
//    
//#endif
//    
//}

- (IBAction)login:(id)sender {
   //dispatch_async(dispatch_get_main_queue(), ^(void) {
    
    [login setEnabled:NO];
    if (![sender isEqualTo:self]) [loginInfo setStringValue:@""];
    //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    //FirstAuthorizationSetupView *viewForHideInterface = [[FirstAuthorizationSetupView alloc] initWithFrame:NSMakeRect(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //[delegate.window.contentView addSubview:(NSView *)viewForHideInterface];
    
    [authorization setBackgroundColor:[NSColor colorWithDeviceRed:0.42 green:0.43 blue:0.64 alpha:1]];
    CompanyStuff *selectedStuff = [[companyStuff selectedObjects] lastObject];
    
    if (selectedStuff) [loginField setStringValue:selectedStuff.email];
    //self.view.alphaValue = 0.2;

    [self openView:loginView fromPoint:login.frame.origin];
//    [self.view addSubview:loginView];
//    
//    loginView.frame = NSMakeRect(self.view.frame.origin.x + self.view.frame.size.width / 2 - loginView.frame.size.width / 2, self.view.frame.origin.y + self.view.frame.size.height / 2 - loginView.frame.size.height / 2, loginView.frame.size.width, loginView.frame.size.height);
    
//    [self.view addSubview:joinToCompanyView];
//    
//    joinToCompanyView.frame = NSMakeRect(self.view.frame.origin.x + self.view.frame.size.width / 2 - joinToCompanyView.frame.size.width / 2, self.view.frame.origin.y + self.view.frame.size.height / 2 - joinToCompanyView.frame.size.height / 2, joinToCompanyView.frame.size.width, joinToCompanyView.frame.size.height);
//    
    //[authorization.contentView center];
    
//        [NSApp beginSheet:authorization 
//           modalForWindow:delegate.window
//            modalDelegate:nil 
//           didEndSelector:nil
//              contextInfo:nil];
//});
}
- (IBAction)loginStart:(id)sender {
    [loginView removeFromSuperview];
//    [authorization orderOut:sender];
//    [NSApp endSheet:authorization];
    [loginProgressIndicator setHidden:NO];
    [loginProgressIndicator startAnimation:self];
    
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    //NSManagedObjectContext *context = [delegate managedObjectContext];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    
    CompanyStuff *previousAdmin = [clientController authorization];
    if (!previousAdmin) {
        [self showErrorBoxWithText:[NSString stringWithFormat:@"error with login, please inform developer"]];
        [clientController release];
        return;
    }
    
//    CompanyStuff *newStuffForLogin = (CompanyStuff *)[NSEntityDescription 
//                                                      insertNewObjectForEntityForName:@"CompanyStuff" 
//                                                      inManagedObjectContext:context];
//    
//    
//    
//    CurrentCompany *selectedFromMainMoc = (CurrentCompany *)[context objectWithID:[previousAdmin.currentCompany objectID]];
    
//    previousAdmin.email = [loginField stringValue];
//    previousAdmin.password = [passwordField stringValue];
//    [clientController finalSave:clientController.moc];
////    newStuffForLogin.currentCompany = selectedFromMainMoc;
    
    //[self finalSaveForMoc:context];
    //temporaryUserForLogin = [newStuffForLogin objectID];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        //NSString *keyAofAuthorized = @"authorizedUserGUID";
        
#if defined(SNOW_CLIENT_APPSTORE)
        //keyAofAuthorized = @"authorizedUserGUIDclient";
#endif
        
        //[clientController setUserDefaultsObject:newStuffForLogin.GUID forKey:keyAofAuthorized];
        //NSLog(@"COMPANY STUFF: admin for login is:%@",[clientController authorization]);
        //NSString *returnString = [loginField getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES ];
        [clientController processLoginForEmail:loginField.stringValue forPassword:passwordField.stringValue];

//        if ([clientController checkIfCurrentAdminCanLogin]) { 
//            // that means that login was succeseful
//            self.isLoginWasSuccesseful = YES;
//            //NSLog(@"HERE IS A GOOD PLACE TO START THINKING ABOUT SUCCESS LOGIN");
//            previousAdmin.isRegistrationDone = [NSNumber numberWithBool:YES];
//
//            //[clientController getAllObjectsForEntity:@"CurrentCompany" immediatelyStart:YES isUserAuthorized:YES];
//            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[previousAdmin objectID]] mustBeApproved:NO];
//        } else { 
//            
//            //[clientController setUserDefaultsObject:previousAdmin.GUID forKey:keyAofAuthorized];
//            //[context deleteObject:newStuffForLogin];
//            //[self finalSaveForMoc:context];
//            
//        }
        [clientController release];
    });
    
    //userWhichUsingForLogin = [newStuffForLogin objectID];
    
}

- (IBAction)cancelLogin:(id)sender {
//    [authorization orderOut:sender];
//    [NSApp endSheet:authorization];
    [loginView removeFromSuperview];  
    [login setEnabled:YES];
}

- (IBAction)removeUser:(id)sender {
    if ([[companyStuffFirstPlusLastName arrangedObjects] count] == 1) {
        [self showErrorBoxWithText:@"you can't remove last hero"];
        return;
    }
    NSDictionary *selectedPerson = [[companyStuffFirstPlusLastName selectedObjects] lastObject];
    
    NSManagedObjectID *selectedObjectID = [selectedPerson valueForKey:@"objectID"];
    CompanyStuff *selectedStuffToUpdate = (CompanyStuff *)[moc objectWithID:selectedObjectID];
    [moc deleteObject:selectedStuffToUpdate];
    [self finalSaveForMoc:moc];
    CurrentCompany *selectedCompany = [[currentCompany selectedObjects] lastObject];
    CompanyStuff *anyObject = selectedCompany.companyStuff.anyObject;
    [self updateVerticalViewDataForObjectID:anyObject.objectID];

}

#pragma mark - CurrentCompany action methods
- (IBAction)registerCompany:(id)sender {
    
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
    CurrentCompany *selected = [[currentCompany selectedObjects] lastObject];
    NSString *companyAdminGUID = selected.companyAdminGUID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",companyAdminGUID];
    NSSet *allCompanyStuff = selected.companyStuff;
    NSSet *filteredCompanyStuff = [allCompanyStuff filteredSetUsingPredicate:predicate];
    CompanyStuff *admin = nil;
    if ([filteredCompanyStuff count] == 1) admin = [filteredCompanyStuff anyObject];
    else 
    {
        [self showErrorBoxWithText:[NSString stringWithFormat:@"company admin is not found for company:%@",selected.name]];
        return;
    }
    if ([admin.email isEqualToString:@"you@email"]) {
        [self showErrorBoxWithText:[NSString stringWithFormat:@"default email is not allowed for add new companies"]];
        return;
    }
    
    //NSSet *currentStuff = selected.companyStuff;
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",selected.companyAdminGUID];
    //CompanyStuff *admin = [userController authorization];
    //if (!admin) [userController defaultUser];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[selected objectID]] mustBeApproved:NO];
        [clientController release];
    });
#endif
    
}

- (IBAction)changeVisibelStatus:(id)sender {
    CurrentCompany *selectedCompanyFromMainMoc = [[currentCompany selectedObjects] lastObject];
    CurrentCompany *selectedCompany = (CurrentCompany *)[self.moc objectWithID:selectedCompanyFromMainMoc.objectID];
    
    selectedCompany.isVisibleForCommunity = [NSNumber numberWithBool:![selectedCompany.isVisibleForCommunity boolValue]];
    //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [self finalSaveForMoc:self.moc];
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        sleep(2);
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[selectedCompany objectID]] mustBeApproved:NO];
        [clientController release];
    });
#endif
    
    
    //[currentCompanyTableView reloadData]; 
    //    NSManagedObjectContext *moc =  [[NSManagedObjectContext alloc] init];
    //    [moc setPersistentStoreCoordinator:[self.userController.context persistentStoreCoordinator]];
    //    [moc setUndoManager:nil];
    //    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
    //    [nc addObserver:self
    //           selector:@selector(mergeChanges:) 
    //               name:NSManagedObjectContextDidSaveNotification
    //             object:moc];
    //    
    //    
    //    userController.context = moc;
    //    [moc release];
    //    
    //    [userController makeRemoteChangesForObjectWithID:[selectedCompany objectID] withAdminID:[[userController authorization] objectID]];
    
}


- (IBAction)removeCompany:(id)sender {
    
    // check if local companies list have any users as well
    CurrentCompany *selectedCompany = [[currentCompany selectedObjects] lastObject];
#if defined(SNOW_SERVER)
    if (selectedCompany) [currentCompany removeObject:selectedCompany];
    [self finalSaveForMoc:[currentCompany managedObjectContext]];
    return;
#endif
    
    
    if ([[self localStatusForObjectsWithRootGuid:selectedCompany.GUID] isEqualToString:@"external server"]) {
        //NSLog(@"you can't remove server registered companies");
        [self showErrorBoxWithText:[NSString stringWithFormat:@"you can't remove server registered companies"]];
        
        return;
    }
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    
    CompanyStuff *admin = [clientController authorization];
    if (![selectedCompany.companyAdminGUID isEqualToString:admin.GUID]) {
        //NSLog(@"you can't remove companies where u not admin");
        [self showErrorBoxWithText:[NSString stringWithFormat:@"you can't remove companies where u not admin"]];
        [clientController release];
        return;
    } else
    {
        // remove company but save companystuff authorized
        NSArray *allCompanies = [currentCompany arrangedObjects];
        NSArray *allCompaniesWhereLocalStuffIsAdmin = [allCompanies filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"companyAdminGUID == %@",admin.GUID]];
        if ([allCompaniesWhereLocalStuffIsAdmin count] == 1) { 
            //NSLog(@"can't remove last company, nothing to connect to current admin");
            [self showErrorBoxWithText:[NSString stringWithFormat:@"can't remove last company, nothing to connect to current admin"]];
            [clientController release];
            return;
        }
        else {
            [allCompaniesWhereLocalStuffIsAdmin enumerateObjectsWithOptions:NSSortStable usingBlock:^(CurrentCompany *companyForChoice, NSUInteger idx, BOOL *stop) {
                CurrentCompany *companyForChoiceFromClientController = (CurrentCompany *)[clientController.moc objectWithID:[companyForChoice objectID]];
                if (companyForChoice != selectedCompany) admin.currentCompany = companyForChoiceFromClientController;
                *stop = YES;
            }];
        }
        
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        // when company removed, we must update relaionship of current admin, and do this before company will removed on server
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:admin.objectID] mustBeApproved:NO];
        [clientController removeObjectWithID:[selectedCompany objectID]];
    });
    [clientController release];
    
    
}

- (IBAction)addCompany:(id)sender {
    //    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    //
    //    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    //    CompanyStuff *admin = [clientController authorization];
    //    [clientController release];
    //    if ([admin.email isEqualToString:@"you@email"]) {
    //        [self showErrorBoxWithText:[NSString stringWithFormat:@"default email is not allowed for add new companies"]];
    //        return;
    //    }
    
    
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        CompanyStuff *currentAdmin = [clientController authorization];
        if ([currentAdmin.email isEqualToString:@"you@email"]) {
            [clientController release];
            [self showErrorBoxWithText:[NSString stringWithFormat:@"default email is not allowed for add new companies"]];
            return;
        }
        NSManagedObjectContext *contextForAdd = self.moc;//[delegate managedObjectContext];
        
        CurrentCompany *newCompany = (CurrentCompany *)[NSEntityDescription 
                                                        insertNewObjectForEntityForName:@"CurrentCompany" 
                                                        inManagedObjectContext:contextForAdd];
        newCompany.name = [NSString stringWithFormat:@"new company %@",[NSNumber numberWithInteger:[[currentCompany arrangedObjects] count]]];
        
        CompanyStuff *newCurrentAdminInClientControllerMoc = (CompanyStuff *)[contextForAdd objectWithID:[currentAdmin objectID]];
        newCurrentAdminInClientControllerMoc.currentCompany = newCompany;
        newCompany.companyAdminGUID = newCurrentAdminInClientControllerMoc.GUID;
        [self finalSaveForMoc:contextForAdd];
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObjects:[newCompany objectID],[currentAdmin objectID],nil] mustBeApproved:NO];
        [clientController release];
    });
    
#endif 
    
#if defined (SNOW_SERVER)
    //AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    
    //NSManagedObjectContext *contextForAdd = [delegate managedObjectContext];
    //NSManagedObjectContext *contextForAdd = userController.context;
    
    CurrentCompany *newCompany = (CurrentCompany *)[NSEntityDescription 
                                                    insertNewObjectForEntityForName:@"CurrentCompany" 
                                                    inManagedObjectContext:moc];
    newCompany.name = [NSString stringWithFormat:@"new company %@",[NSNumber numberWithInteger:[[currentCompany arrangedObjects] count]]];
    [self finalSaveForMoc:moc];
#endif
    
}



- (IBAction)joinToCompany:(id)sender {
    [registerButton setEnabled:NO];
    [self openView:joinToCompanyView fromPoint:addCompany.frame.origin];

}         
- (IBAction)joinRequestStartJoin:(id)sender {
    [joinToCompanyView removeFromSuperview];

    [loginProgressIndicator setHidden:NO];
    [loginProgressIndicator startAnimation:self];

    CurrentCompany *selected = [[currentCompany selectedObjects] lastObject];
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSManagedObjectContext *contextForAdd = moc;
    
    CompanyStuff *newStuff = (CompanyStuff *)[NSEntityDescription 
                                              insertNewObjectForEntityForName:@"CompanyStuff" 
                                              inManagedObjectContext:contextForAdd];
    
    newStuff.firstName = [joinRequestFirstName stringValue];
    newStuff.lastName = [joinRequestLastName stringValue];
    newStuff.email = [joinRequestEmail stringValue];
    newStuff.password = [joinRequestPassword stringValue];
    
    newStuff.currentCompany = selected;
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    NSString *keyAofAuthorized = @"authorizedUserGUID";
    
#if defined(SNOW_CLIENT_APPSTORE)
    keyAofAuthorized = @"authorizedUserGUIDclient";
#endif
    [clientController setUserDefaultsObject:newStuff.GUID forKey:keyAofAuthorized];
    
    // bcs this is join, we must send this new user as update (core will check if user not present, this is join request.
    [self finalSaveForMoc:contextForAdd];
    [clientController release];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[newStuff objectID]] mustBeApproved:YES];
        [clientController release];
    });
}

- (IBAction)joinRequestCancel:(id)sender {
    [joinToCompanyView removeFromSuperview];
    [registerButton setEnabled:YES];

}

#pragma mark - User's approve action methods

- (IBAction)refreshUsersAvaitingApproveList:(id)sender {
    //NSLog(@"REGISTRATION AWAITING: start re-fresh");
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.moc];
//    [moc release];
//    moc = [[NSManagedObjectContext alloc] init];
//    [moc setUndoManager:nil];
//    [moc setMergePolicy:NSOverwriteMergePolicy];
//    //[moc setMergePolicy:NSRollbackMergePolicy];
//    [moc setPersistentStoreCoordinator:delegate.persistentStoreCoordinator];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];

    NSManagedObjectContext *context =  moc;
    //[context setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
    //[context setUndoManager:nil];
    
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"OperationNecessaryToApprove" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
    
    [fetchRequest release];
    
    NSMutableArray *new = [NSMutableArray arrayWithCapacity:0];
    
    [fetchedObjects enumerateObjectsUsingBlock:^(OperationNecessaryToApprove *operation, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *necessaryObject = [NSMutableDictionary dictionaryWithCapacity:0];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:operation.forEntity inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        //NSString *currentCompanyGUID = nil;
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        
//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];    
//        CompanyStuff *authorizedUser = [clientController authorization];
//        [clientController release];
        //if ([delegate.loggingLevel intValue] == 1) NSLog(@"CLIENT:current authorized user:%@",authorizedUser.firstName);
        //CurrentCompany *necessaryCompany = authorizedUser.currentCompany;
        //currentCompanyGUID = necessaryCompany.GUID;
#endif
#if defined(SNOW_SERVER)
//        CurrentCompany *selectedCompany = (CurrentCompany *)[[currentCompany selectedObjects] lastObject];
//        if (selectedCompany) currentCompanyGUID = selectedCompany.GUID;
//        else 
//        NSLog(@"USER COMPANIES LIST: updateCurrentRegistrationsList warning, companiesList:%@ don't have selectedCompany inside",[currentCompany arrangedObjects]);
        
#endif
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",operation.forGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil) NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        if ([fetchedObjects count] > 0) {
            CompanyStuff *objectForApprove = [fetchedObjects lastObject];
            [necessaryObject setValue:objectForApprove.firstName forKey:@"firstName"];
            [necessaryObject setValue:objectForApprove.lastName forKey:@"lastName"];
            [necessaryObject setValue:objectForApprove.phone forKey:@"phone"];
            [necessaryObject setValue:objectForApprove.email forKey:@"email"];
            [necessaryObject setValue:objectForApprove.currentCompany.name forKey:@"companyName"];
            [necessaryObject setValue:operation.forGUID forKey:@"forGUID"];
            [necessaryObject setValue:operation.forEntity forKey:@"forEntity"];
            [necessaryObject setValue:operation.objectID forKey:@"objectID"];
            [new addObject:necessaryObject];

        }
        
        
    }];
    if ([new count] > 0) [recordsAwaitingApproveStack setContent:new];
    //else NSLog(@"USER COMPANIES LIST: updateCurrentRegistrationsList warning,%@",new);
    //[recordsAwaitingApproveStack setContent:new];
    //[context release];
}

- (IBAction)removeAwatingApproveUsers:(id)sender {
    [approveUser setEnabled:NO];
    [declineUser setEnabled:NO];
    [removeAwaitingApproveRegistration setEnabled:NO];
    
    NSManagedObjectContext *context = moc;//[delegate managedObjectContext];
    
    NSArray *selectedUsers = [recordsAwaitingApproveStack selectedObjects];
    
    __block NSMutableArray *findedOperationIDs = [NSMutableArray array];
    
    [selectedUsers enumerateObjectsUsingBlock:^(NSDictionary *approvedUser, NSUInteger idx, BOOL *stop) {
        NSManagedObjectID *objectID = [approvedUser valueForKey:@"objectID"];
        [findedOperationIDs addObject:objectID];
        
    }];
    
    [self finalSaveForMoc:context];
    
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
    
    NSArray *finalIDs = [NSArray arrayWithArray:findedOperationIDs];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[context persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        [finalIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [clientController removeObjectWithID:[NSArray arrayWithObject:obj]];
        }];
        [clientController release];
    });
#endif

    [findedOperationIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *idForRemove, NSUInteger idx, BOOL *stop) {
        [self.moc deleteObject:[moc objectWithID:idForRemove]];
    }];
    [self finalSaveForMoc:context];
    [self refreshUsersAvaitingApproveList:self];

#if defined (SNOW_SERVER)

    [approveUser setEnabled:YES];
    [declineUser setEnabled:YES];
    [removeAwaitingApproveRegistration setEnabled:YES];
    

#endif
}

- (IBAction)approveUserRegistration:(id)sender {
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    
    CompanyStuff *admin = [clientController authorization];
    if (![admin.currentCompany.companyAdminGUID isEqualToString:admin.GUID]) {
        NSLog(@"you can't remove companies where u not admin");
        [self showErrorBoxWithText:[NSString stringWithFormat:@"you can't approve registrations, bse u r not admin"]];
        [clientController release];
        return;
    } 
    [clientController release];

    
    [approveUser setEnabled:NO];
    [declineUser setEnabled:NO];
    [removeAwaitingApproveRegistration setEnabled:NO];
    
    //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSManagedObjectContext *context = moc;//[delegate managedObjectContext];
    
    NSArray *selectedUsers = [recordsAwaitingApproveStack selectedObjects];
    
    __block NSMutableArray *findedStuffIDs = [NSMutableArray array];
    __block NSMutableArray *findedOperationIDs = [NSMutableArray array];

    [selectedUsers enumerateObjectsUsingBlock:^(NSDictionary *approvedUser, NSUInteger idx, BOOL *stop) {
        NSString *forGUID = [approvedUser valueForKey:@"forGUID"];
        NSString *forEntity = [approvedUser valueForKey:@"forEntity"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:forEntity inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",forGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        CompanyStuff *findedStuff = [fetchedObjects lastObject];
        findedStuff.isRegistrationDone = [NSNumber numberWithBool:YES];
        findedStuff.isRegistrationProcessed = [NSNumber numberWithBool:NO];
        [findedStuffIDs addObject:[findedStuff objectID]];
        [findedOperationIDs addObject:[approvedUser valueForKey:@"objectID"]];

    }];
    
    [self finalSaveForMoc:context];
    
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)

    NSArray *finalIDs = [NSArray arrayWithArray:findedStuffIDs];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[context persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        [finalIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:obj] mustBeApproved:NO];
        }];
        [clientController release];
    });
    
#endif
    
    [findedOperationIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *idForRemove, NSUInteger idx, BOOL *stop) {
        [self.moc deleteObject:[moc objectWithID:idForRemove]];
    }];
    [self finalSaveForMoc:context];
    [self refreshUsersAvaitingApproveList:self];

#if defined (SNOW_SERVER)
    
    [approveUser setEnabled:YES];
    [declineUser setEnabled:YES];
    [removeAwaitingApproveRegistration setEnabled:YES];
    

#endif
  
}

- (IBAction)declineUserRegistration:(id)sender {
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    
    CompanyStuff *admin = [clientController authorization];
    [clientController release];
    
    if (![admin.currentCompany.companyAdminGUID isEqualToString:admin.GUID]) {
        NSLog(@"you can't remove companies where u not admin");
        [self showErrorBoxWithText:[NSString stringWithFormat:@"you can't decline registrations, bse u r not admin"]];
        return;
    } 

    [approveUser setEnabled:NO];
    [declineUser setEnabled:NO];
    [removeAwaitingApproveRegistration setEnabled:NO];
 
    //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    NSManagedObjectContext *context = moc;//[delegate managedObjectContext];
    
    NSArray *selectedUsers = [recordsAwaitingApproveStack selectedObjects];
    
    __block NSMutableArray *findedStuffIDs = [NSMutableArray arrayWithCapacity:0];
    __block NSMutableArray *findedOperationIDs = [NSMutableArray array];

    
    [selectedUsers enumerateObjectsUsingBlock:^(NSDictionary *approvedUser, NSUInteger idx, BOOL *stop) {
        NSString *forGUID = [approvedUser valueForKey:@"forGUID"];
        NSString *forEntity = [approvedUser valueForKey:@"forEntity"];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:forEntity inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(GUID == %@)",forGUID];
        [fetchRequest setPredicate:predicate];
        NSError *error = nil;
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
        if (fetchedObjects == nil)  NSLog(@"Failed to executeFetchRequest:%@ to data store: %@ in function:%@",fetchRequest, [error localizedDescription],NSStringFromSelector(_cmd));
        [fetchRequest release];
        CompanyStuff *findedStuff = [fetchedObjects lastObject];
        findedStuff.isRegistrationDone = [NSNumber numberWithBool:NO];
        findedStuff.isRegistrationProcessed = [NSNumber numberWithBool:NO];
        [findedStuffIDs addObject:[findedStuff objectID]];
        [findedOperationIDs addObject:[approvedUser valueForKey:@"objectID"]];

    }];
    
    [self finalSaveForMoc:context];
    
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
    // for client server must remove it, after receive approve

    NSArray *finalIDs = [NSArray arrayWithArray:findedStuffIDs];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[context persistentStoreCoordinator] withSender:self withMainMoc:delegate.managedObjectContext];
        [finalIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:obj] mustBeApproved:NO];
        }];
        
        [clientController release];
    });
#endif
    [findedOperationIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *idForRemove, NSUInteger idx, BOOL *stop) {
        [self.moc deleteObject:[moc objectWithID:idForRemove]];
    }];
    [self finalSaveForMoc:context];
    [self refreshUsersAvaitingApproveList:self];
  
#if defined (SNOW_SERVER)
    // for server we just remove operations
    [approveUser setEnabled:YES];
    [declineUser setEnabled:YES];
    [removeAwaitingApproveRegistration setEnabled:YES];

#endif
    
 }

#pragma mark - change user data control methods


- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog( @">>>> USER COMPANY INFO:Detected Change in keyPath: %@", keyPath );
    
    // here is changes in company:
    if ([keyPath isEqual:@"name"] || [keyPath isEqual:@"url"]) {
        id new = [change valueForKey:@"new"];
        id old = [change valueForKey:@"old"];
        if (observedCurrentCompany) {            
            [object removeObserver:self forKeyPath:@"name"];
            [object removeObserver:self forKeyPath:@"url"];
        }
        observedCurrentCompany = nil;
        if ([new isEqualTo:old]) { 
            //NSLog(@"nothing to change, return");
            return;
        }
        
        //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
        CurrentCompany *companyFromMainMoc = object;
        
        CurrentCompany *company = (CurrentCompany *)[self.moc objectWithID:companyFromMainMoc.objectID];
        [company setValue:new forKey:keyPath];
        NSString *companyGUID = company.GUID;    
        NSString *companyAdminGUID = company.companyAdminGUID;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",companyAdminGUID];
        NSSet *allCompanyStuff = company.companyStuff;
        NSSet *filteredCompanyStuff = [allCompanyStuff filteredSetUsingPredicate:predicate];
        CompanyStuff *admin = nil;
        if ([filteredCompanyStuff count] == 1) admin = [filteredCompanyStuff anyObject];
        else 
        {
            [self showErrorBoxWithText:[NSString stringWithFormat:@"company admin is not found for company:%@",company.name]];
            return;
        }
        if ([admin.email isEqualToString:@"you@email"]) {
            [self showErrorBoxWithText:[NSString stringWithFormat:@"default email is not allowed for add new companies, please change email at start"]];
            return;
        }
        
        if (companyGUID && ![[self localStatusForObjectsWithRootGuid:company.GUID] isEqualToString:@"external server"]) {
            [self finalSaveForMoc:self.moc];
//            AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
            NSString *companyAdminGUID = company.companyAdminGUID;
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",companyAdminGUID];
            NSSet *allCompanyStuff = company.companyStuff;
            NSSet *filteredCompanyStuff = [allCompanyStuff filteredSetUsingPredicate:predicate];
            CompanyStuff *admin = nil;
            if ([filteredCompanyStuff count] == 1) admin = [filteredCompanyStuff anyObject];
            else 
            {
                [clientController release];
                [self showErrorBoxWithText:[NSString stringWithFormat:@"company admin is not found for company:%@",company.name]];
                //                NSLog(@"COMPANY:company admin not found for company:%@",company.name);
                return;
            }
            
            if ([admin.email isEqualToString:@"you@email"]) {
                [clientController release];
                
                [self showErrorBoxWithText:[NSString stringWithFormat:@"default email is not allowed for registration"]];
                return;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                sleep(2);

                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[company objectID]] mustBeApproved:NO];
                //[clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin objectID]] mustBeApproved:NO];
                
            });
            [clientController release];
        }
#endif
    }
    
    // here is changes in companyStuff    
    if ([keyPath isEqual:@"data"]) {
        
        NSManagedObjectID *objectID = [object objectForKey:@"objectID"];
        if (!objectID) {
            NSLog(@"USER COMPANY INFO: warning, object:%@ don't have objectID",object);
            return;
        }
        id new = [change valueForKey:@"new"];
        id old = [change valueForKey:@"old"];
        if ([new isEqualTo:old]) { 
            //NSLog(@"USER COMPANY INFO:nothing to change , return");
            return;
        }
        
        CompanyStuff *admin = (CompanyStuff *)[self.moc objectWithID:objectID];
        [admin setValue:new forKey:[object valueForKey:@"attribute"]];
        [self finalSaveForMoc:self.moc];
        
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
//        AppDelegate *delegate = [[NSApplication sharedApplication] delegate];

        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        
        CompanyStuff *currentAdmin = [clientController authorization];
        if (![currentAdmin.GUID isEqualToString:admin.GUID]) {
            [self showErrorBoxWithText:[NSString stringWithFormat:@"please edit only yourself"]];
            [clientController release];
            return;
        }
        NSString *currentStatusForCompany = [clientController localStatusForObjectsWithRootGuid:currentAdmin.currentCompany.GUID];
        if ([currentStatusForCompany isEqualToString:@"registered"]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin objectID]] mustBeApproved:NO];
                [clientController release];
            });
        } else { 
            NSLog(@"COMPANY STUFF: root company don't registered");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[currentAdmin.currentCompany objectID]] mustBeApproved:NO];
                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[admin objectID]] mustBeApproved:NO];
                
                [clientController release];
            });
            
        }
#endif
        
    }
    // here is changes when view is showing
    
    if ([keyPath isEqual:@"isViewHidden"]) {
        id new = [change valueForKey:@"new"];
        id old = [change valueForKey:@"old"];
        if ([new isEqualTo:old]) { 
            //NSLog(@"USER COMPANY INFO:nothing to change , return");
            return;
        }
        if (!isViewHidden) {
            //NSLog(@"USER COMPANY INFO:update will start");

            [self prepareEveryArraysForFirstShow];
        }
        
    }
    
}

#pragma mark - external reload methods
-(void)localMocMustUpdate;
{
    
//    NSLog(@"USER COMPANY INFO VIEW:local moc will update");
    
//    NSManagedObject *selectedObject = [[carrier selectedObjects] lastObject];
//    NSManagedObjectID *selectedDestinationsID = selectedObject.objectID;
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {  
    // >>>>>>>>>>>>>>
//    [self finalSaveForMoc:moc];

//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
//    if (observedCurrentCompany) {
//        NSManagedObject *observedCompany = [moc objectWithID:observedCurrentCompany];
//        [observedCompany removeObserver:self forKeyPath:@"name"];
//        [observedCompany removeObserver:self forKeyPath:@"url"];
//        observedCurrentCompany = nil;
//    }
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
//    currentCompany.managedObjectContext = nil;
//    companyStuff.managedObjectContext = nil;
//    
//    [moc release];
//    moc = [[NSManagedObjectContext alloc] init];
//    [moc setUndoManager:nil];
//    [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
//    [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
//    
//    currentCompany.managedObjectContext = moc;
//    companyStuff.managedObjectContext = moc;
    
    //>>>>>>>>>>>>>>>
//  });
    
//        [currentCompany bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//        [companyStuff bind:@"managedObjectContext" toObject:self withKeyPath:@"moc" options:nil];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//            
//            sleep(1);
//            NSArray *allObjects = [carrier arrangedObjects];
//            if (selectedDestinationsID) {
//                NSInteger selectionsIndex = [allObjects indexOfObject:[moc objectWithID:selectedDestinationsID]];
//                dispatch_async(dispatch_get_main_queue(), ^(void) {
//                    
//                    [carrier setSelectionIndex:selectionsIndex];
//                });
//            }
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//                
//                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//                CompanyStuff *admin = [clientController authorization];
//                if (admin) {
//                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyStuff.currentCompany.GUID == %@",admin.currentCompany.GUID];
//                    carrier.filterPredicate = predicate;
//                } 
//                [clientController release];
//            });
//        });
//    });
    
}


-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
    //NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    NSString *status = [data objectAtIndex:0];
    //NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {  
        [self showErrorBoxWithText:status];
        //NSLog(@"error:%@",status);
    }
    if (![isItLatestMessage boolValue])
    {    
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [loginProgressIndicator setHidden:NO];
            [loginProgressIndicator startAnimation:self];
            //            [networkProgress setHidden:NO];
            //[networkProgress startAnimation:self];
        });
        
    } else {
        //NSLog(@"USER COMPANY INFO >>>>>>>>>>>>>>>> updates local moc's");
        [delegate.carriersView localMocMustUpdate];
        [delegate.destinationsView localMocMustUpdate];
        [self localMocMustUpdate];
        [delegate updateWellcomeTitle];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            //            [networkProgress setHidden:YES];
            //[networkProgress stopAnimation:self];
            [loginProgressIndicator setHidden:YES];
            [loginProgressIndicator stopAnimation:self];
            [login setEnabled:YES];
            [approveUser setEnabled:YES];
            [declineUser setEnabled:YES];
            [removeAwaitingApproveRegistration setEnabled:YES];
            [registerButton setEnabled:YES];
            
            [self updateCurrentRegistrationsList];

            //NSLog(@"HERE IS A GOOD PLACE TO UPDATE UI FOR LOGIN:");
            
            //            if (self.isLoginWasSuccesseful) {
            //                self.isLoginWasSuccesseful = NO;
            
            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
            
            CompanyStuff *authorizedStuffFromClientController = [clientController authorization];
            if (!authorizedStuffFromClientController) { 
                [clientController release];
                return;
            }
            //[self updateWellcomeTitle];
            [self updateVerticalViewDataForObjectID:authorizedStuffFromClientController.objectID];
            
            [clientController release];
//            NSManagedObjectContext *mainContext = [currentCompany managedObjectContext];
//            CompanyStuff *authorizedStuff = (CompanyStuff *)[mainContext objectWithID:[authorizedStuffFromClientController objectID]];
//            //NSLog(@"HERE IS A GOOD PLACE TO UPDATE UI FOR NEW ADMIN EMAIL:%@ and company name:%@",authorizedStuff.email, authorizedStuff.currentCompany.name);
//            [currentCompany rearrangeObjects];
//            NSUInteger index = [[currentCompany arrangedObjects] indexOfObjectIdenticalTo:authorizedStuff.currentCompany];
//            [companyStuff setFilterPredicate:[NSPredicate predicateWithFormat:@"currentCompany.GUID == %@",authorizedStuff.currentCompany.GUID]];
//            
//            if (index != NSNotFound) { 
//                //NSLog(@"COMPANY STUFF: index for company:%@ is:%@",authorizedStuff.currentCompany.name,[NSNumber numberWithUnsignedInteger:index]);
//                [currentCompanyTableView deselectAll:self];
//                [currentCompanyTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:YES];
//                [currentCompanyTableView scrollRowToVisible:index];
//            } //else NSLog(@"COMPANY STUFF: index for company not found");
            
//            index = [[companyStuff arrangedObjects] indexOfObjectIdenticalTo:authorizedStuffFromClientController];
//            if (index != NSNotFound) { 
                //NSLog(@"COMPANY STUFF: index for stuff with email:%@ is:%@",authorizedStuff.email,[NSNumber numberWithUnsignedInteger:index]);
//                [companyStuffTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:YES];
//                [companyStuffTableView scrollRowToVisible:index];
//            } //else NSLog(@"COMPANY STUFF: indext for stuff not found");
            //                [companyStuffTableView reloadData];
            //                [currentCompanyTableView reloadData];
            //            }
        });
        
    }
    
    NSManagedObjectID *objectID = nil;
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    if (objectID) {
        //if ([idsWithProgress containsObject:objectID] && ![isItLatestMessage boolValue]) return;
        //[idsWithProgress addObject:objectID];
        
        if ([[[[moc objectWithID:objectID] entity] name] isEqualToString:@"CompanyStuff"]) {
        }
        if ([[[[moc objectWithID:objectID] entity] name] isEqualToString:@"CurrentCompany"]) {
            if ([status isEqualToString:@"remove object finish"] || [status isEqualToString:@"company for removing not found"]) { 
                [moc deleteObject:[moc objectWithID:objectID]];
                [self finalSaveForMoc:moc];
            }
        }

    }
    //NSLog(@"COMPANY STUFF:update UI:%@ latest message:%@",status,isItLatestMessage);
}

@end
