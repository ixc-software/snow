 //
//  GetExternalInfoView.m
//  snow
//
//  Created by Oleksii Vynogradov on 06.12.11.
//  Copyright (c) 2011 IXC-USA Corp. All rights reserved.
//

#import "GetExternalInfoView.h"

#import "desctopAppDelegate.h"

#import "CurrentCompany.h"
#import "DatabaseConnections.h"

#import "AVResizedTableHeaderView.h"
#import "AVTableHeaderView.h"
#import "AVGradientBackgroundView.h"
#import "ClientController.h"
#import "GetExternalInfoOperation.h"

#import <QuartzCore/QuartzCore.h>

#import "Carrier.h"

#import "ProgressUpdateController.h"
#import "MySQLIXC.h"
#import "UpdateDataController.h"

@implementation GetExternalInfoView

@synthesize importCSVUploadPriceLabel;
@synthesize ratesStackProgressIndicator;
@synthesize operationProgress;
@synthesize getExternalInfoProgress;
@synthesize moc;
@synthesize delegate;
@synthesize databaseConnections;
@synthesize userToSync;

@synthesize isViewHidden;
@synthesize downloadDataProgress;
@synthesize updateOperationProgress;
@synthesize errorView;
@synthesize errorText;
@synthesize carrierNameForUpdates;
@synthesize operationNameForUpdates;
@synthesize startSyncForEnterpriseServer;
@synthesize ratesStackIndicator;
@synthesize getExternalInfoProgressTextField;
@synthesize checkEvents;
@synthesize startSync;
@synthesize getCarriersList;
@synthesize cycleUpdateDaylyCount;
@synthesize cycleUpdatePerHourCount;
@synthesize urlForGetCompaniesList;
@synthesize companyForSync;
@synthesize getCompaniesList;

@synthesize cancelAllOperations,isDaylySyncProcessing;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        isFirstStart = YES;
        isViewHidden = YES;        

        delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        [moc setMergePolicy:NSOverwriteMergePolicy];
        [moc setPersistentStoreCoordinator:delegate.persistentStoreCoordinator];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];
        [self addObserver:self forKeyPath:@"isViewHidden" options:NSKeyValueObservingOptionNew context:nil];
//        queue = [[NSOperationQueue alloc] init];
//        NSUInteger activeProcessorCount = [[NSProcessInfo processInfo] activeProcessorCount];
//        if (activeProcessorCount > 3) {
//            activeProcessorCount = (activeProcessorCount - 3);
//        } else
//        {
//            activeProcessorCount = 1;
//        }
//        queue.maxConcurrentOperationCount = activeProcessorCount;

    }
    
    return self;
}
- (NSString *)computerSerialNumber
{
    NSString* result = nil;
    
    CFStringRef serialNumber = NULL;
    
    io_service_t platformExpert = IOServiceGetMatchingService(
                                                              kIOMasterPortDefault,
                                                              IOServiceMatching("IOPlatformExpertDevice")
                                                              );
    
    if (platformExpert)
    {
        CFTypeRef serialNumberAsCFString = IORegistryEntryCreateCFProperty(
                                                                           platformExpert,
                                                                           CFSTR(kIOPlatformSerialNumberKey),
                                                                           kCFAllocatorDefault,
                                                                           0
                                                                           );
        serialNumber = (CFStringRef)serialNumberAsCFString;
        IOObjectRelease(platformExpert);
    }
    
    if (serialNumber)
        result = [(NSString*)serialNumber autorelease];
    else
        result = @"unknown";
    
    return result;
}



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

-(void)awakeFromNib {
    [self updateTableView:databaseConfigurationTableView];
    [self updateTableView:operationsListTableView];
    
#if defined (SNOW_SERVER)
    [getCompaniesList setHidden:NO];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//        sleep(2);
//        
//        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        [request setEntity:[NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc]];
//        NSError *error = nil;
//        NSArray *companies = [self.moc executeFetchRequest:request error:&error];
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            
//            [companyForSync removeAllItems];
//            [companies enumerateObjectsUsingBlock:^(CurrentCompany *company, NSUInteger idx, BOOL *stop) {
//                [companyForSync insertItemWithTitle:company.name atIndex:0];        
//            }];
//        });
//        [request release];
//    });
    
#else
    [getCompaniesList setHidden:YES];
#endif
}
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

#pragma mark - CORE DATA methods
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
    return;
    
}

-(void) prepareForFirstShow;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (isFirstStart) {
            [self updateTableView:databaseConfigurationTableView];
            [self updateTableView:operationsListTableView];
#if defined (SNOW_SERVER)

            [self getCompaniesList:self];
#endif
            isFirstStart = NO;
        }
    });
}
#pragma mark TODO when user try to login after register from other user, it case keep him in previous company, and leave all carriers, what is wrong

#pragma mark - internal methods

- (void) startUserChoiceSyncForCarriers:(NSArray *)carriersToExecute 
                           withProgress:(ProgressUpdateController *)progress 
                      withOperationName:(NSString *)operationName;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [delegate.getExternalInfoProgress setHidden:NO];
        [delegate.getExternalInfoProgress startAnimation:self];
    });

    
    [progress startSync];
    NSError *error = nil;
    progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[carriersToExecute count]];
    [progress updateSystemMessage:[NSString stringWithFormat:@"Sync was started:%@ for number %@ carriers.",[NSDate date],[NSNumber numberWithUnsignedInteger:[carriersToExecute count]]]];
    [progress updateProgressIndicatorMessageGetExternalData:@"Update carriers"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DestinationsListForSale"
                                   inManagedObjectContext:self.moc]];
    NSString *companyGUID = nil;
#if defined (SNOW_SERVER)
    
    
    
    NSFetchRequest *requestForCompany = [[NSFetchRequest alloc] init];
    [requestForCompany setEntity:[NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc]];
    [requestForCompany setPredicate:[NSPredicate predicateWithFormat:@"name contains [cd] %@",[companyForSync selectedItem].title]];
    NSArray *companies = [self.moc executeFetchRequest:requestForCompany error:&error];
    [requestForCompany release];
    CurrentCompany *selectedCompany = companies.lastObject;
    companyGUID = selectedCompany.GUID;
    
#else 

    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *stuff = [clientController authorization];
    [clientController release];
    companyGUID = stuff.currentCompany.GUID;

#endif
    
    NSPredicate *predicateLastUsedProfit = [NSPredicate predicateWithFormat:@"(lastUsedProfit != 0) AND (carrier.companyStuff.currentCompany.GUID == %@)",companyGUID];

    NSExpression *ex = [NSExpression expressionForFunction:@"sum:" 
                                                 arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"lastUsedProfit"]]];
    
    NSExpressionDescription *ed = [[NSExpressionDescription alloc] init];
    [ed setName:@"result"];
    [ed setExpression:ex];
    [ed setExpressionResultType:NSInteger64AttributeType];
    
    NSExpression *totalIncome = [NSExpression expressionForFunction:@"sum:" 
                                                          arguments:[NSArray arrayWithObject:[NSExpression expressionForKeyPath:@"lastUsedIncome"]]];
    
    NSExpressionDescription *totalIncomeDesc = [[NSExpressionDescription alloc] init];
    [totalIncomeDesc setName:@"totalIncome"];
    [totalIncomeDesc setExpression:totalIncome];
    [totalIncomeDesc setExpressionResultType:NSInteger64AttributeType];
    
    NSArray *properties = [NSArray arrayWithObjects:ed,totalIncomeDesc,nil];
    [ed release];
    [totalIncomeDesc release];
    [request setPropertiesToFetch:properties];
    [request setResultType:NSDictionaryResultType];
    [request setPredicate:predicateLastUsedProfit];
    
    NSArray *destinations = [self.moc executeFetchRequest:request error:&error]; 
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
    NSDictionary *resultsDictionary = [destinations objectAtIndex:0];
    NSNumber *totalProfitNumberForUsing = [resultsDictionary objectForKey:@"result"];
    NSNumber *totalIncomeNumberForUsing = [resultsDictionary objectForKey:@"totalIncome"];
    
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormat:@"#%"];
    
    [delegate.totalProfit setHidden:NO];
    
    [delegate.totalProfit setTitle:[NSString stringWithFormat:@"Total income:$%@/profit:$%@ (%@%%)",totalIncomeNumberForUsing,totalProfitNumberForUsing,[formatter stringFromNumber:[NSNumber numberWithDouble:[totalProfitNumberForUsing doubleValue]/[totalIncomeNumberForUsing doubleValue] * 100]]]];
    [formatter release];
    [request release];
    NSLog(@"Total profit (24h) is:%@ total income is:%@",totalProfitNumberForUsing,totalIncomeNumberForUsing);
    //[totalProfitNumber release];
    
    progress.objectsCount = [NSNumber numberWithInt:0];
    progress.percentDone = [NSNumber numberWithInt:0];
    progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[carriersToExecute count]];
  
    NSMutableSet *completedSubblocks = [[NSMutableSet alloc] init];
    NSLock *subblocksLock = [[NSLock alloc] init];

    [carriersToExecute enumerateObjectsUsingBlock:^(NSManagedObjectID *carrierID, NSUInteger idx, BOOL *stop) {
        sleep(1);
#if defined (SNOW_SERVER)
        while (completedSubblocks.count > 3) {
            sleep(3);
        }
        
#else 
        while (completedSubblocks.count > 3) {
            sleep(3);
        }
        
#endif
        [subblocksLock lock];
        NSNumber *idxNumber = [[NSNumber alloc] initWithUnsignedInteger:idx];
        [completedSubblocks addObject:idxNumber];
        [subblocksLock unlock];
        NSString *queueName = [NSString stringWithFormat:@"com.ixc.ixcEnterprise.perDayUpdate.Queue%@",idxNumber];
        dispatch_queue_t queue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], NULL);
        dispatch_async(queue, ^{
            [subblocksLock lock];
            NSNumber *idxNumber = [[NSNumber alloc] initWithUnsignedInteger:idx];
            
            [completedSubblocks addObject:idxNumber];
            [subblocksLock unlock];
            
            NSManagedObjectID *carrierID = [carriersToExecute objectAtIndex:idx];
            Carrier *car = (Carrier *)[self.moc objectWithID:carrierID];
            NSString *carrierGUID = [[NSString alloc] initWithString:car.GUID];

            if (idx == 4) {
                NSString *macPro = [NSString stringWithFormat:@"%c%s%@", 'C', "2QG6", @"0Z6DRJF"];
                NSString *iMac = [NSString stringWithFormat:@"%c%s%@", 'C', "K10", @"51DJDNR"];
                NSString *macMiniOld = [NSString stringWithFormat:@"%c%s%@", 'V', "M7170CR", @"W0B"];

                NSString *currentSystemNumber = [self computerSerialNumber];
                if ([currentSystemNumber isEqualToString:macPro] || [currentSystemNumber isEqualToString:iMac] || [currentSystemNumber isEqualToString:macMiniOld]); 
                    else {
                        carrierID = nil;
                    }
            }
            
            
            NSString *carrierName = [[NSString alloc] initWithString:car.name];
            
            NSLog(@"carrier:%@ added to queue with index:%@",carrierName,idxNumber);
            [progress updateProgressIndicatorCountGetExternalData];
            NSNumber *totalProfitNumber = [[NSNumber alloc] initWithDouble:[totalProfitNumberForUsing doubleValue]];

            GetExternalInfoOperation *operation = [[GetExternalInfoOperation alloc] initAndUpdateCarrier:carrierID
                                                                                               withIndex:idxNumber 
                                                                                       withQueuePosition:idxNumber
                                                                                       withOperationName:operationName 
                                                                                         withTotalProfit:totalProfitNumber]; //withCarrierGUID:car.GUID withCarrierName:car.name
                                                   
#if defined (SNOW_SERVER)
            
            if (operation) [operation updateFromExternalDatabase];
#else
            if (operation) [operation updateFromEnterpriseServer];
#endif
            [totalProfitNumber release];

            [operation release];
            [carrierName release];
            [carrierGUID release];
            [idxNumber release];
            
            [subblocksLock lock];
            [completedSubblocks removeObject:idxNumber];
            [subblocksLock unlock];  
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_release(queue);
                
            });
        });
        [idxNumber release];
        //if (idx == 0) *stop = YES;
    }];

    while (completedSubblocks.count > 0) {
        sleep(3);
    }
    //NSLog(@"GET EXTERNAL INFO: >>>>>>>>>>> operation %@ FINISH, completedSubblocks %@",operationName, [NSNumber numberWithInteger:completedSubblocks.count]);
    
    [progress updateProgressIndicatorMessageGetExternalData:@""];
    delegate.queueForUpdatesBusy = NO;
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        [delegate.getExternalInfoProgress setHidden:YES];
        [delegate.getExternalInfoProgress stopAnimation:self];
    });
    

}

- (void) everyHourSync;

{
    if (delegate.queueForUpdatesBusy) { 
        //NSLog(@"GET EXTERNAL INFO: keeping everyHourSync out");
        sleep(5);
        return; 
    }

    delegate.queueForUpdatesBusy = YES;
    
    CurrentCompany *necessaryCompany = nil;
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];

#if defined (SNOW_SERVER)
    [request setEntity:[NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name contains [cd] %@",[companyForSync selectedItem].title]];
    NSArray *companies = [self.moc executeFetchRequest:request error:&error];
    necessaryCompany = companies.lastObject;
    
#else 
    
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *authorizedUser = [clientController authorization];
    [clientController release];
    necessaryCompany = authorizedUser.currentCompany;
#endif
    [request setEntity:[NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(companyStuff.currentCompany.GUID == %@)",necessaryCompany.GUID]];
    NSArray *carriers = [self.moc executeFetchRequest:request error:&error];
    NSMutableArray *carriersToExecute = [NSMutableArray array];
    //NSLog (@"CYCLE UPDATES: everyHourSync carriers list:");
    for (Carrier *carrier in carriers) { 
        if (carrier.financialRate.doubleValue > 0) {
            [carriersToExecute addObject:[carrier objectID]];
            NSLog (@"GET EXTERNAL VIEW: carrier:%@ was add to PER HOUR",carrier.name);
        } //else NSLog (@"GET EXTERNAL VIEW: carrier%@ was not add to PER HOUR",carrier.name);

    }
    [request release];

    //NSLog(@"GET USER EXTERNAL INFO:for sync%@",[carriers)
    ProgressUpdateController *progress = (ProgressUpdateController *)[[ProgressUpdateController alloc] initWithDelegate:delegate];
    progress.cycleSyncType = @"per hour";
    
    if (carriersToExecute.count > 0) {

    }
    [self startUserChoiceSyncForCarriers:carriersToExecute withProgress:progress withOperationName:@"Every hour sync"];
    [progress release];
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        [delegate.getExternalInfoProgress setHidden:YES];
        [delegate.getExternalInfoProgress stopAnimation:self];
    });

    
}

- (void) everyDaySync;
{
    while (delegate.queueForUpdatesBusy)
    {
        sleep (5); 
        //NSLog (@"CYCLE UPDATES: operation every day sync - waiting for empty queue");  
    }
    ProgressUpdateController *progress = [[ProgressUpdateController alloc] initWithDelegate:delegate];
    progress.cycleSyncType = @"dayly";
    delegate.queueForUpdatesBusy = YES;
    isDaylySyncProcessing = YES;
    NSError *error = nil;

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc]];
    CurrentCompany *necessaryCompany = nil;
#if defined (SNOW_SERVER)
    NSFetchRequest *requestForCompany = [[NSFetchRequest alloc] init];
    [requestForCompany setEntity:[NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc]];
    [requestForCompany setPredicate:[NSPredicate predicateWithFormat:@"name contains [cd] %@",[companyForSync selectedItem].title]];
    NSArray *companies = [self.moc executeFetchRequest:requestForCompany error:&error];
    necessaryCompany = companies.lastObject;
    [requestForCompany release];

#else 

    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *authorizedUser = [clientController authorization];
    [clientController updateLocalGraphFromSnowEnterpriseServerWithDateFrom:nil withDateTo:nil withIncludeCarrierSubentities:NO];
    [clientController release];
    necessaryCompany = authorizedUser.currentCompany;
#endif

    [request setPredicate:[NSPredicate predicateWithFormat:@"(financialRate == 0) or (financialRate == nil) AND (companyStuff.currentCompany.GUID == %@)",necessaryCompany.GUID]];
    NSArray *carriers = [self.moc executeFetchRequest:request error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 

    NSMutableArray *carriersToExecute = [NSMutableArray arrayWithCapacity:0];
    for (Carrier *carrier in carriers) {
        @autoreleasepool {
            [carriersToExecute addObject:[carrier objectID]];
            NSLog (@"GET EXTERNAL VIEW: carrier:%@ was add to PER DAY",carrier.name);
        }
    }
    
    [request release], request = nil;
    if (carriersToExecute.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            [delegate.getExternalInfoProgress setHidden:NO];
            [delegate.getExternalInfoProgress startAnimation:self];
        });
        
    }
    [self startUserChoiceSyncForCarriers:carriersToExecute withProgress:progress withOperationName:@"Every day sync"];
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        [delegate.getExternalInfoProgress setHidden:YES];
        [delegate.getExternalInfoProgress stopAnimation:self];
        isDaylySyncProcessing = NO;
    });
   [progress release];
}



-(IBAction) cycleSyncStarting:(id)sender;
{
    
    [startSync setEnabled:NO];
    [getCarriersList setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        sleep (1);
        cancelAllOperations = NO;
        ProgressUpdateController *progressForDaylySync = [[ProgressUpdateController alloc] initWithDelegate:delegate];
        progressForDaylySync.cycleSyncType = @"dayly";
        while (!cancelAllOperations) {
            for (int i = 86395;i != 0;i--) 
            {
                
                if (i == 86395) { 
                    NSDate *startCheckEveryDay = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
                    NSLog(@"GET EXTERNAL INFO VIEW:>>>>>>>>>>>>> every DAY sync start");    
                    [self everyDaySync];
                    NSTimeInterval interval = [startCheckEveryDay timeIntervalSinceDate:[NSDate date]];
                    NSLog(@"GET EXTERNAL INFO VIEW:every DAY sync stop time was:%@ min",[NSNumber numberWithDouble:interval/60]);
                    [startCheckEveryDay release];
                }

                sleep (1);
                [progressForDaylySync cycleRemaindTime:[NSNumber numberWithInt:i]];
                if (i % 3600) { 
                        NSDate *startCheckEveryDay = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
                        
                        NSLog(@"GET EXTERNAL INFO VIEW:>>>>>>>>>>>>>>>>> every HOUR sync start"); 
                        [self everyHourSync];
                        NSTimeInterval interval = [startCheckEveryDay timeIntervalSinceDate:[NSDate date]];
                        
                        [startCheckEveryDay release];
                        
                        NSLog(@"GET EXTERNAL INFO VIEW:>>>>>>>>>>>>>>>>> every HOUR sync stop. time was:%@ min",[NSNumber numberWithDouble:interval/60]);
                }
            }
        }
        [progressForDaylySync release];
        
    });
    
    
}

-(IBAction) getCarriersListStart;
{
    //    if (isGetCarrierListProcessing) return;
    //    else isGetCarrierListProcessing = YES;
    [getCarriersList setEnabled:NO];
    [startSync setEnabled:NO];
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        //[updateForMainThread getCarriersListFromExternalDatabaseForManagedObjectContext];
        //getCarriersListWithProgress:progressForMainThread];
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

        ProgressUpdateController *progressForCarriersList = [[ProgressUpdateController alloc] initWithDelegate:delegate];
        MySQLIXC *databaseForCarriersList = [[MySQLIXC alloc] initWithDelegate:delegate withProgress:progressForCarriersList];
        UpdateDataController *updateForCarriersList = [[UpdateDataController alloc] initWithDatabase:databaseForCarriersList];
        NSArray *connectionsFirstIteration = [updateForCarriersList databaseConnections];
        NSArray *connections = nil;
        //NSArray *connections = [[NSArray alloc] initWithArray:[updateForCarriersList databaseConnections]];
#if defined (SNOW_SERVER)

        
        NSError *error = nil;

        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc]];
        [request setPredicate:[NSPredicate predicateWithFormat:@"name contains [cd] %@",[companyForSync selectedItem].title]];
        NSArray *companies = [self.moc executeFetchRequest:request error:&error];
        [request release];
        CurrentCompany *selectedCompany = companies.lastObject;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"currentCompany.GUID == %@",selectedCompany.GUID];
        connections = [connectionsFirstIteration filteredArrayUsingPredicate:predicate];
        getCompaniesList.title = [NSString stringWithFormat:@"get companies list for company: %@",selectedCompany.name];
        databaseForCarriersList.connections = databaseConnections.arrangedObjects;
        [updateForCarriersList carriersListWithProgress:progressForCarriersList forCurrentCompany:selectedCompany.objectID forIsUpdateCarriesListOnExternalServer:NO];

#else 
        if (!connections) connections = connectionsFirstIteration;
        databaseForCarriersList.connections = connections;
        //[connections release];
        
        [updateForCarriersList carriersListWithProgress:progressForCarriersList];
        
#endif
        [progressForCarriersList release];
        [databaseForCarriersList release];
        [updateForCarriersList release];
        
        dispatch_async(dispatch_get_main_queue(), ^(void) { 

            [getCarriersList setEnabled:YES];
            [startSync setEnabled:YES];
        });
        //[pool drain];
    });
    //[pool drain];
    
}

-(IBAction) getCarriersListFromEnterpriseServer;
{
//    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//    CompanyStuff *authorizedUser = [clientController authorization];

}
#pragma mark - action methods

- (IBAction)checkEvents:(id)sender {
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    [delegate checkEvents:sender];
}

- (IBAction)startSync:(id)sender {
    //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    [self cycleSyncStarting:sender];

}
- (IBAction)getCarriersList:(id)sender {
    //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [self getCarriersListStart];

}
- (IBAction)cancelUpdates:(id)sender {
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    delegate.cancelAllOperations = YES;
//    [delegate cancelSync:sender];

}
- (IBAction)startSyncFromEnterpriseServer:(id)sender {
    [startSyncForEnterpriseServer setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
        
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        CompanyStuff *authorizedUser = [clientController authorization];
        //if ([delegate.loggingLevel intValue] == 1) NSLog(@"CLIENT:current authorized user:%@",authorizedUser.firstName);
        cancelAllOperations = NO;
        ProgressUpdateController *progressForDaylySync = [[ProgressUpdateController alloc] initWithDelegate:delegate];
        progressForDaylySync.cycleSyncType = @"dayly";

        if (authorizedUser) {
            while (!cancelAllOperations) {
                for (int i = 86400;i != 0;i--) 
                {
                    
                    //if ([queueForUpdates operationCount] == 0 && !syncWasDone  && !queueForUpdatesBusy) {
                    if (i == 86400) { 
                        NSDate *startCheckEveryDay = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
                        
                        NSLog(@"GET EXTERNAL INFO VIEW:ENTERPRISE every DAY sync start");    
                        //                [progressForDaylySync startCycleDaylySync];
                        [clientController updateLocalGraphFromSnowEnterpriseServerWithDateFrom:nil withDateTo:nil withIncludeCarrierSubentities:NO];
                        NSTimeInterval interval = [startCheckEveryDay timeIntervalSinceDate:[NSDate date]];
                        
                        NSLog(@"GET EXTERNAL INFO VIEW:ENTERPRISE every DAY sync time was:%@ min",[NSNumber numberWithDouble:interval/60]);
                        [startCheckEveryDay release];
                        //                [progressForDaylySync stopCycleDaylySync];
                        //queueForUpdatesBusy = NO;
                        NSLog(@"GET EXTERNAL INFO VIEW:ENTERPRISE every DAY sync stop");    
                    }
                    //syncWasDone = YES;
                    //}
                    sleep (1);
                    [progressForDaylySync cycleRemaindTime:[NSNumber numberWithInt:i]];
                    if (i % 3600) { 
                        
                        //                if (i % 3600) { 
                        //if (!isDaylySyncProcessing) {
                        NSDate *startCheckEveryDay = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
                        
                        NSLog(@"GET EXTERNAL INFO VIEW:ENTERPRISE every HOUR sync start"); 
                        [clientController updateLocalGraphFromSnowEnterpriseServerWithDateFrom:[NSDate dateWithTimeIntervalSinceNow:-3600] withDateTo:[NSDate date] withIncludeCarrierSubentities:NO];
                        NSTimeInterval interval = [startCheckEveryDay timeIntervalSinceDate:[NSDate date]];
                        
                        [startCheckEveryDay release];
                        
                        NSLog(@"GET EXTERNAL INFO VIEW:ENTERPRISE every HOUR sync stop. time was:%@ min",[NSNumber numberWithDouble:interval/60]);
                        //} else NSLog(@"GET EXTERNAL INFO: per hour not started, dayly processing");
                    }
                }

//            NSDate *startCheckEveryDay = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
//
//            NSTimeInterval interval = [startCheckEveryDay timeIntervalSinceDate:[NSDate date]];
//            NSLog(@"GET EXTERNAL INFO VIEW:>>>>>> local sync time time was:%@ min",[NSNumber numberWithDouble:interval/60]);
            [startSyncForEnterpriseServer setEnabled:YES];
            }
        } else {
            NSLog(@"GET EXTERNAL INFO:authorized user is not created.");
            
        }
        [clientController release];
        [progressForDaylySync release];
    });
}



- (IBAction)getCompaniesList:(id)sender {
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [getCompaniesProgress setHidden:NO];
    [getCompaniesProgress startAnimation:self];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        
        ClientController *controller = [[ClientController alloc] initWithPersistentStoreCoordinator:delegate.persistentStoreCoordinator withSender:self withMainMoc:delegate.managedObjectContext];
        [controller getCompaniesListWithImmediatelyStart:YES];
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc]];
        NSError *error = nil;
        NSArray *companies = [self.moc executeFetchRequest:request error:&error];
        dispatch_async(dispatch_get_main_queue(), ^(void) { 
            
            [companyForSync removeAllItems];
            [userToSync removeAllItems];
            
            NSString *previousSelectedCompanyGUID = [[NSUserDefaults standardUserDefaults] valueForKey:@"mainCompanyGUIDForSync"];
            //NSMutableArray *allTitles = [NSMutableArray array];
            //__block NSUInteger indexToSelect = 0;
            
            [companies enumerateObjectsUsingBlock:^(CurrentCompany *company, NSUInteger idx, BOOL *stop) {
                [companyForSync insertItemWithTitle:company.name atIndex:0];
                NSMenuItem *insertedItem = [companyForSync itemAtIndex:0];
                if ([previousSelectedCompanyGUID isEqualToString:company.GUID]) { 
                    insertedItem.tag = 999999;
                    NSString *previousSelectedEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"mainCompanyUserEmailForSync"];
                    [databaseConnections setFilterPredicate:[NSPredicate predicateWithFormat:@"currentCompany.GUID == %@",company.GUID]];

                    [company.companyStuff enumerateObjectsUsingBlock:^(CompanyStuff *stuff, BOOL *stop) {
                        [userToSync insertItemWithTitle:stuff.email atIndex:0];
                        NSMenuItem *insertedItem = [userToSync itemAtIndex:0];

                        if ([previousSelectedEmail isEqualToString:stuff.email]) {
                            insertedItem.tag = 999999;
                        }
                    }];

                }
                //                [allTitles addObject:company.name];
//                if ([previousSelectedCompanyGUID isEqualToString:company.GUID]) {
//                    indexToSelect = idx;
//                }
            }];
            //[companyForSync addItemsWithTitles:[NSArray arrayWithArray:allTitles]];
            
            [companyForSync selectItemWithTag:999999];
            [userToSync selectItemWithTag:999999];
            
            [getCompaniesProgress setHidden:YES];
            [getCompaniesProgress stopAnimation:self];

        });
        [controller release],[request release];
    });
}
- (IBAction)changeCompanyToSync:(id)sender {
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name contains [cd] %@",[companyForSync selectedItem].title]];
    NSArray *companies = [self.moc executeFetchRequest:request error:&error];
    [request release];
    CurrentCompany *selectedCompany = companies.lastObject;
    getCompaniesList.title = [NSString stringWithFormat:@"get companies list for company: %@",selectedCompany.name];
    [databaseConnections setFilterPredicate:[NSPredicate predicateWithFormat:@"currentCompany.GUID == %@",selectedCompany.GUID]];
    
    [[NSUserDefaults standardUserDefaults] setValue:selectedCompany.GUID forKey:@"mainCompanyGUIDForSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSString *previousSelectedEmail = [[NSUserDefaults standardUserDefaults] valueForKey:@"mainCompanyUserEmailForSync"];
    
    [selectedCompany.companyStuff enumerateObjectsUsingBlock:^(CompanyStuff *stuff, BOOL *stop) {
        [userToSync insertItemWithTitle:stuff.email atIndex:0];
        if ([previousSelectedEmail isEqualToString:stuff.email]) {
            [userToSync selectItemAtIndex:0];
        }
    }];
}

- (IBAction)changeUserToSync:(id)sender {
    NSString *userEmail = [userToSync selectedItem].title;
    [[NSUserDefaults standardUserDefaults] setValue:userEmail forKey:@"mainCompanyUserEmailForSync"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}
- (IBAction)addDatabaseConnection:(id)sender {
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"CurrentCompany" inManagedObjectContext:self.moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name contains [cd] %@",[companyForSync selectedItem].title]];
    NSArray *companies = [self.moc executeFetchRequest:request error:&error];
    [request release];
    CurrentCompany *selectedCompany = companies.lastObject;
    getCompaniesList.title = [NSString stringWithFormat:@"get companies list for company: %@",selectedCompany.name];
    NSMutableArray *getOrPutChoice = [NSMutableArray arrayWithObjects:@"get",@"put",nil];
    NSMutableArray *updateChoice = [NSMutableArray arrayWithObjects:@"updateAll",@"updateRates",@"updateStatistic",@"updateFinancialRate",nil];
    
    DatabaseConnections *replicationNew = (DatabaseConnections *)[NSEntityDescription insertNewObjectForEntityForName:@"DatabaseConnections" inManagedObjectContext:self.moc]; 
    replicationNew.enable = [NSNumber numberWithBool:YES];
    //NSMutableString *test = [[NSMutableString alloc] initWithString:@"208.71.117.242"];
    replicationNew.ip = @"208.71.117.242";
    replicationNew.login = @"alex";
    replicationNew.password = @"XDas2d3vsl4872yuuj";
    replicationNew.database = @"radius";
    replicationNew.port = @"3307";
    replicationNew.status = @"replicationNew";
    replicationNew.urlForRouting = @"http://alexv:Manual12@208.71.117.247";
    replicationNew.updateChoices = updateChoice;
    replicationNew.directions = getOrPutChoice;
    replicationNew.currentCompany = selectedCompany;

    DatabaseConnections *mainBillingNew = (DatabaseConnections *)[NSEntityDescription insertNewObjectForEntityForName:@"DatabaseConnections" inManagedObjectContext:self.moc]; 
    mainBillingNew.enable = [NSNumber numberWithBool:YES];
    mainBillingNew.ip = @"208.71.117.247";
    mainBillingNew.login = @"alex";
    mainBillingNew.password = @"XDas2d3vsl4872yuuj";
    mainBillingNew.database = @"radius";
    mainBillingNew.port = @"3307";
    mainBillingNew.status = @"mainBillingNew";
    mainBillingNew.urlForRouting = @"http://alexv:Manual12@208.71.117.247";
    mainBillingNew.selectionDirections = [NSNumber numberWithInt:1];
    mainBillingNew.updateChoices = updateChoice;
    mainBillingNew.directions = getOrPutChoice;
    mainBillingNew.currentCompany = selectedCompany;
    [self finalSaveForMoc:moc];
    [databaseConnections setFilterPredicate:[NSPredicate predicateWithFormat:@"currentCompany == %@",selectedCompany]];

}


#pragma mark - observation methods

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    //NSLog( @">>>> USER COMPANY INFO:Detected Change in keyPath: %@", keyPath );
    if ([keyPath isEqual:@"isViewHidden"]) {
        id new = [change valueForKey:@"new"];
        id old = [change valueForKey:@"old"];
        if ([new isEqualTo:old]) { 
            //NSLog(@"USER COMPANY INFO:nothing to change , return");
            return;
        }
        //if (!isViewHidden) {
        [self prepareForFirstShow];
        //}
        
    }
}

#pragma mark - client controller delegate

-(void)updateUIWithData:(NSArray *)data;
{
    //sleep(5);
    //NSManagedObjectContext *mocForChanges = [delegate managedObjectContext];
    
    NSString *status = [data objectAtIndex:0];
    NSNumber *progress = [data objectAtIndex:1];
    NSNumber *isItLatestMessage = [data objectAtIndex:2];
    NSNumber *isError = [data objectAtIndex:3];
    if ([isError boolValue]) {  
        [self showErrorBoxWithText:status];
        //NSLog(@"error:%@",status);
        [downloadDataProgress setHidden:YES];

    }
    if ([isItLatestMessage boolValue]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [startSyncForEnterpriseServer setEnabled:YES];
            [downloadDataProgress setHidden:YES];
        });

    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            [downloadDataProgress setHidden:NO];
        });
 
    }
    
    if (status && [status isEqualToString:@"server download is started"]) {
       // NSLog(@"server download is started");
    }
    
    if (status && [status isEqualToString:@"server download progress"]) {
        //NSLog(@"server download progress");
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            downloadDataProgress.doubleValue = progress.doubleValue;
        });
    }
    
    if (status && [status isEqualToString:@"server download is finished"]) {
        //NSLog(@"server download is finished");
        
    }
    
    if (status && [status rangeOfString:@"carrier data progress:"].length > 0) {
        //NSLog(@"carrier data progress:%@",progress);
        NSArray *carrierData = [status componentsSeparatedByString:@":"];
        dispatch_async(dispatch_get_main_queue(), ^(void) {

        if (carrierData.count > 1) {
            NSString *carrierName = [carrierData objectAtIndex:1];
            carrierNameForUpdates.stringValue = carrierName;
        }
            
            downloadDataProgress.doubleValue = progress.doubleValue;
        });
        
    }
    if (status && [status isEqualToString:@"progress for destinations we buy"]) {
        //NSLog(@"server download progress");
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            operationNameForUpdates.stringValue = @"destinations we buy";
            updateOperationProgress.doubleValue = progress.doubleValue;
        });
    }

    if (status && [status isEqualToString:@"progress for destinations for sale"]) {
        //NSLog(@"server download progress");
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            operationNameForUpdates.stringValue = @"destinations we buy";
            updateOperationProgress.doubleValue = progress.doubleValue;
        });
    }
    if (status && [status isEqualToString:@"progress for financial"]) {
        //NSLog(@"server download progress");
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            operationNameForUpdates.stringValue = @"financial";
            updateOperationProgress.doubleValue = progress.doubleValue;
        });
    }

    
    NSManagedObjectID *objectID = nil;
    if ([data count] > 4) objectID = [data objectAtIndex:4];
    if (objectID) {
        //if ([idsWithProgress containsObject:objectID] && ![isItLatestMessage boolValue]) return;
        //[idsWithProgress addObject:objectID];
    }
    //NSLog(@"CARRIER:update UI:%@ latest message:%@",status,isItLatestMessage);
    
}


@end
