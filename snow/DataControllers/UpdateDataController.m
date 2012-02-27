//
//  InitUpdateIXC.m
//  snow
//
//  Created by Alex Vinogradov on 28.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//
#include <runetype.h>
#import "UpdateDataController.h"
#import "MySQLIXC.h"
#import "ProjectArrays.h"
#import "ParseCSV.h"
#import "Mail.h"
#import "libxl.h"
#import "CalendarStore/CalendarStore.h"
#import "Carrier.h"
#import "DestinationsListForSale.h"
#import "DestinationsListWeBuy.h"
#import "DatabaseConnections.h"
#import "CurrentCompany.h"
#import "DestinationRouting.h"
#import "DestinationsClassController.h"
//#import "VerticalViewData.h"
#import "CompanyAccounts.h"
#import "MainSystem.h"
//#import "AppDelegate.h"
#import "NormalizedCountryTransformer.h"

#import "CompanyStuff.h"
#import "CodesvsDestinationsList.h"
#import "DestinationsListWeBuyResults.h"
#import "DestinationsListWeBuyTesting.h"
#import "DestinationsListTargets.h"
#import "Financial.h"
#import "InvoicesAndPayments.h"
#import "CodesList.h"
#import "CountrySpecificCodeList.h"
#import "ClientController.h"
#import "CarrierStuff.h"
#import "Events.h"

//#define kCarrier @"Carrier"
//#define kkurl @"url"
//#define kkratesEmail @"ratesEmail"
//#define kkphoneList @"phoneList"
//#define kkname @"name"
//#define kklatestUpdateTime @"latestUpdateTime"
//#define kkfinancialRate @"financialRate"
//#define kkemailList @"emailList"
//#define kkaddress @"address"
//
//#define kCarrierStuff @"CarrierStuff"
//#define kkskype @"skype"
//#define kkposition @"position"
//#define kkphoneList @"phoneList"
//#define kkotherIMs @"otherIMs"
//#define kkmsn @"msn"
//#define kklastName @"lastName"
//#define kkfirstName @"firstName"
//#define kkemailList @"emailList"
//
//#define kCodesvsDestinationsList @"CodesvsDestinationsList"
//#define kkspecific @"specific"
//#define kkrateSheetName @"rateSheetName"
//#define kkrateSheetID @"rateSheetID"
//#define kkrate @"rate"
//#define kkprefix @"prefix"
//#define kkpeerID @"peerID"
//#define kkoriginalCode @"originalCode"
//#define kkinternalChangedDate @"internalChangedDate"
//#define kkexternalChangedDate @"externalChangedDate"
//#define kkenabled @"enabled"
//#define kkcountry @"country"
//#define kkcode @"code"
//
//#define kCompanyStuff @"CompanyStuff"
//#define kkphone @"phone"
//#define kkpassword @"password"
//#define kklogin @"login"
//#define kklastName @"lastName"
//#define kkfirstName @"firstName"
//#define kkemail @"email"
//
//
//
//#define kCurrentCompany @"CurrentCompany"
//#define kkurl @"url"
//#define kkratesEmail @"ratesEmail"
//#define kkname @"name"
//#define kklogoURL @"logoURL"
//#define kklocalPhoneList @"localPhoneList"
//#define kkaddress @"address"
//#define kkadditionalInformation @"additionalInformation"
//
//#define kDestinationPerHourStat @"DestinationPerHourStat"
//#define kkprofit @"profit"
//#define kkminutesLenght @"minutesLenght"
//#define kkexternalDate @"externalDate"
//#define kkdate @"date"
//#define kkcallAttempts @"callAttempts"
//#define kkasr @"asr"
//#define kkacd @"acd"
//
//#define kDestinationRouting @"DestinationRouting"
//#define kkspecific @"specific"
//#define kkrate @"rate"
//#define kkpriority @"priority"
//#define kkprefix @"prefix"
//#define kklastUsedProfit @"lastUsedProfit"
//#define kklastUsedMinutesLenght @"lastUsedMinutesLenght"
//#define kklastUsedDate @"lastUsedDate"
//#define kklastUsedCallAttempts @"lastUsedCallAttempts"
//#define kklastUsedASR @"lastUsedASR"
//#define kklastUsedACD @"lastUsedACD"
//#define kkdesc @"desc"
//#define kkcarrier @"carrier"
//#define kkASRmin @"ASRmin"
//#define kkASRmax @"ASRmax"
//#define kkACDmin @"ACDmin"
//#define kkACDmax @"ACDmax"
//
//#define kDestinationsListForSale @"DestinationsListForSale"
//#define kkspecific @"specific"
//#define kkrateSheet @"rateSheet"
//#define kkrate @"rate"
//#define kkprefix @"prefix"
//#define kkpostInSalesChat @"postInSalesChat"
//#define kklastUsedProfit @"lastUsedProfit"
//#define kklastUsedMinutesLenght @"lastUsedMinutesLenght"
//#define kklastUsedDate @"lastUsedDate"
//#define kklastUsedCallAttempts @"lastUsedCallAttempts"
//#define kklastUsedASR @"lastUsedASR"
//#define kklastUsedACD @"lastUsedACD"
//#define kkipAddressesList @"ipAddressesList"
//#define kkenabled @"enabled"
//#define kkcountry @"country"
//#define kkchangeDate @"changeDate"
//
//#define kDestinationsListPushList @"DestinationsListPushList"
//#define kkspecific @"specific"
//#define kkrate @"rate"
//#define kkprefix @"prefix"
//#define kkpostInSalesChat @"postInSalesChat"
//#define kkminutesLenght @"minutesLenght"
//#define kkcountry @"country"
//#define kkcallAttempts @"callAttempts"
//#define kkasr @"asr"
//#define kkacd @"acd"
//
//#define kDestinationsListTargets @"DestinationsListTargets"
//#define kkspecific @"specific"
//#define kkrate @"rate"
//#define kkprefix @"prefix"
//#define kkpostInSalesChat @"postInSalesChat"
//#define kkminutesLenght @"minutesLenght"
//#define kkcountry @"country"
//#define kkcallAttempts @"callAttempts"
//#define kkasr @"asr"
//#define kkacd @"acd"
//
//#define kDestinationsListWeBuy @"DestinationsListWeBuy"
//#define kkspecific @"specific"
//#define kkrateSheet @"rateSheet"
//#define kkrate @"rate"
//#define kkprefix @"prefix"
//#define kkpostInSalesChat @"postInSalesChat"
//#define kklastUsedProfit @"lastUsedProfit"
//#define kklastUsedMinutesLenght @"lastUsedMinutesLenght"
//#define kklastUsedDate @"lastUsedDate"
//#define kklastUsedCallAttempts @"lastUsedCallAttempts"
//#define kklastUsedASR @"lastUsedASR"
//#define kklastUsedACD @"lastUsedACD"
//#define kkipAddressesList @"ipAddressesList"
//#define kkenabled @"enabled"
//#define kkcountry @"country"
//#define kkchangeDate @"changeDate"
//
//#define kEvents @"Events"
//#define kktype @"type"
//#define kknecessaryData @"necessaryData"
//#define kkname @"name"
//#define kkdateAlarm @"dateAlarm"
//#define kkdate @"date"
//
//#define kVerticalViewData @"VerticalViewData"
//#define kkdata @"data"
//#define kkattribute @"attribute"


@implementation UpdateDataController

@synthesize database;
@synthesize moc,delegate;
//@synthesize autorizedUserID;
//@synthesize autorizedUserCompanyID;

- (id)init {
    if ((self = [super init])) {

    }
    
    return self;
}

- (id)initWithDatabase:(MySQLIXC *)_database; 
{
    if ((self = [super init])) {
        [self setDatabase:_database];
        delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

//        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//        CompanyStuff *authorizedUser = [clientController authorization];
//        CurrentCompany *authorizedUserCompany = authorizedUser.currentCompany;
//        self.autorizedUserID = [authorizedUser objectID];
//        self.autorizedUserCompanyID = [authorizedUserCompany objectID];
//        [clientController release];

        moc = [[NSManagedObjectContext alloc] init];
        [moc setUndoManager:nil];
        [moc setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];

        //[moc setMergePolicy:NSOverwriteMergePolicy];
        [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.moc];

    }
    return self;
}
- (void)dealloc {
    //NSLog(@"This dealloc occurred in %@ (current object class %@) at line %d in file %s in function %s in pretty function %s",
    //     NSStringFromSelector(_cmd), NSStringFromClass([self class]), __LINE__, __FILE__, __FUNCTION__, __PRETTY_FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:self.moc];
    //[mainMoc release];
    [moc release];

    [super dealloc];

}

- (void)importerDidSave:(NSNotification *)saveNotification {
    
    NSManagedObjectContext *mainMoc = [delegate managedObjectContext];
    [mainMoc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
                              withObject:saveNotification
                           waitUntilDone:NO];

    
//    if ([NSThread isMainThread]) {
////        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    //dispatch_async(dispatch_get_main_queue(), ^(void) { 
//    //@synchronized (delegate) {
////        [[delegate managedObjectContext] performSelectorInBackground:<#(SEL)#> withObject:<#(id)#>:@selector(mergeChangesFromContextDidSaveNotification:) withObject:saveNotification waitUntilDone:YES];
//        [[delegate managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
//        
////        NSManagedObjectContext *mainMoc = delegate.managedObjectContext;
////        [mainMoc mergeChangesFromContextDidSaveNotification:saveNotification];
////    if (saveNotification.object != self.moc) {
////        NSLog(@"MERGE in update data");
//
////        [moc mergeChangesFromContextDidSaveNotification:saveNotification];
////        [delegate.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
////                                          withObject:saveNotification
////                                        waitUntilDone:YES];
////    }
//        //        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"isCurrentUpdateProcessing"];
//    //}
//    //});
//    
////        
//    } else {
//        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
//    }
}


#pragma mark -
#pragma mark  FINANCIAL methods

-(void) updateCompanyAccountsWithProgress:(ProgressUpdateController *)progress;
{
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *authorizedUser = [clientController authorization];
    CurrentCompany *companyFromClientMoc = authorizedUser.currentCompany;
    [clientController release];
    CurrentCompany *company = (CurrentCompany *)[self.moc objectWithID:companyFromClientMoc.objectID];

    NSSet *currentAccounts = company.companyAccounts;

    __block NSPredicate *predicate = nil;

    [progress updateProgressIndicatorMessageGetExternalData:@"Update company accounts(get list from database)."];

    NSArray *accounts = [self.database getCompanyAccounts];
    
    NSArray *updatedAccounts = [accounts arrayByAddingObject:[NSDictionary dictionaryWithObjectsAndKeys:@"NONE",@"name", nil]];
    
    [progress updateProgressIndicatorMessageGetExternalData:@"Update company accounts."];
    progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[updatedAccounts count]];
    
    
    //    [updatedAccounts enumerateObjectsWithOptions:NSSortStable usingBlock:^(id account, NSUInteger idx, BOOL *stop) {
    for (NSDictionary *account in updatedAccounts) {
        [progress updateProgressIndicatorCountGetExternalData];
        
        predicate = [NSPredicate predicateWithFormat:@"name == %@",[account valueForKey:@"name"]];
        if ([[currentAccounts filteredSetUsingPredicate:predicate] count] == 0)
        {
            CompanyAccounts *newAccount = (CompanyAccounts *)[NSEntityDescription insertNewObjectForEntityForName:@"CompanyAccounts" inManagedObjectContext:self.moc];
            newAccount.name = [account valueForKey:@"name"];
            newAccount.bankAccountNumber = [account valueForKey:@"accountNumber"];
            newAccount.bankName = [account valueForKey:@"bankName"];
            newAccount.bankAddress = [account valueForKey:@"bankAddress"];
            newAccount.bankABA = [account valueForKey:@"aba"];
            newAccount.bankSwift = [account valueForKey:@"swift"];
            newAccount.externalID = [account valueForKey:@"id"];
            newAccount.currentCompany = company;
        }
    }
//    }];
    
}


-(void) getInvoicesAndPaymentsForCarrier:(NSManagedObjectID *)carrierName;
{
    NSError *error = nil; 
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    __block Carrier *carrier = (Carrier *)[self.moc objectWithID:carrierName];
    __block NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(financial.carrier.GUID == %@)",carrier.GUID];
    [request setEntity:[NSEntityDescription entityForName:@"InvoicesAndPayments" inManagedObjectContext:self.moc]];
    [request setPredicate:predicate];
    NSArray *result = [self.moc executeFetchRequest:request error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
    
//    __block Carrier *carrier = nil;
    __block Financial *financial = nil;
    
    if ([result count] == 0)
    {
        predicate = [NSPredicate predicateWithFormat:@"(carrier.GUID == %@)",carrier.GUID];
        [request setEntity:[NSEntityDescription entityForName:@"Financial" inManagedObjectContext:self.moc]];
        [request setPredicate:predicate];
        NSArray *result = [self.moc executeFetchRequest:request error:&error];
        if ([result count] == 0)
        {
            NSLog(@"FINANSIAL: warning, financial entity not here");
            financial = (Financial *)[NSEntityDescription insertNewObjectForEntityForName:@"Financial" inManagedObjectContext:self.moc];
            financial.carrier = carrier;
            financial.name = [NSString stringWithFormat:@"%@'s account",carrier.name];

        } else
        {
            financial = [result lastObject];
            carrier = financial.carrier;
            //financial.name = [NSString stringWithFormat:@"%@'s account",carrier.name];

        }
        
    } else
    {
        InvoicesAndPayments *anyInvoice = [result lastObject];
        carrier = anyInvoice.financial.carrier;
        financial = anyInvoice.financial;
    }
    [request release];

    NSSet *currentInvoicesAndPayments = [NSSet setWithSet:financial.invoicesAndPayments];
    
    /*[currentInvoicesAndPayments enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, BOOL *stop) {
        [moc deleteObject:obj];
    }];*/
    
    NSSet *companyAccounts = carrier.companyStuff.currentCompany.companyAccounts;
    
    //if ([companyAccounts count] == 0) { 
    //    [self updateCompanyAccounts];
    //    companyAccounts = carrier.companyStuff.currentCompany.companyAccounts;
   // }
    if ([companyAccounts count] == 0) {
        NSArray *accounts = [self.database getCompanyAccounts];
        
        NSArray *updatedAccounts = [accounts arrayByAddingObject:[NSDictionary dictionaryWithObjectsAndKeys:@"NONE",@"name", nil]];
        
//        [progress updateProgressIndicatorMessageGetExternalData:@"Update company accounts."];
//        progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[updatedAccounts count]];
        
        
        //    [updatedAccounts enumerateObjectsWithOptions:NSSortStable usingBlock:^(id account, NSUInteger idx, BOOL *stop) {
        for (NSDictionary *account in updatedAccounts) {
//            [progress updateProgressIndicatorCountGetExternalData];
            
            predicate = [NSPredicate predicateWithFormat:@"name == %@",[account valueForKey:@"name"]];
            if ([[companyAccounts filteredSetUsingPredicate:predicate] count] == 0)
            {
                CompanyAccounts *newAccount = (CompanyAccounts *)[NSEntityDescription insertNewObjectForEntityForName:@"CompanyAccounts" inManagedObjectContext:self.moc];
                newAccount.name = [account valueForKey:@"name"];
                newAccount.bankAccountNumber = [account valueForKey:@"accountNumber"];
                newAccount.bankName = [account valueForKey:@"bankName"];
                newAccount.bankAddress = [account valueForKey:@"bankAddress"];
                newAccount.bankABA = [account valueForKey:@"aba"];
                newAccount.bankSwift = [account valueForKey:@"swift"];
                newAccount.externalID = [account valueForKey:@"id"];
                newAccount.currentCompany = carrier.companyStuff.currentCompany;
            }
        }

    }
    

    NSArray *invoices = [NSArray arrayWithArray:[self.database getInvoicesAndPaymentsForCarrier:carrier.name]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setDecimalSeparator:@"."];
    
    [invoices enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *invoice, NSUInteger idx, BOOL *stop) {
        predicate = [NSPredicate predicateWithFormat:@"(externalID == %@)",[invoice valueForKey:@"id"]];
        InvoicesAndPayments *newInvoice = nil;
        NSSet *filteredInvoices = [currentInvoicesAndPayments filteredSetUsingPredicate:predicate];
        if ([filteredInvoices count] == 0) 
        {
            newInvoice = (InvoicesAndPayments *)[NSEntityDescription insertNewObjectForEntityForName:@"InvoicesAndPayments" inManagedObjectContext:self.moc];
        } else newInvoice = [filteredInvoices anyObject];
            
        newInvoice.externalID = [invoice valueForKey:@"id"];
        newInvoice.date = [formatter dateFromString:[invoice valueForKey:@"oDate"]];
        newInvoice.usagePeriodStart = [formatter dateFromString:[invoice valueForKey:@"sDate"]];
        
        NSString *toAcccount = [invoice valueForKey:@"toAccount"];
        NSString *fromAccount = [invoice valueForKey:@"fromAccount"];
        
        predicate = [NSPredicate predicateWithFormat:@"(externalID == %@)",toAcccount];
        CompanyAccounts *necessaryAccount = [[companyAccounts filteredSetUsingPredicate:predicate] anyObject];
        if (!necessaryAccount) {
            predicate = [NSPredicate predicateWithFormat:@"(externalID == %@)",fromAccount];
            necessaryAccount = [[companyAccounts filteredSetUsingPredicate:predicate] anyObject];
        }
        if (!necessaryAccount)
        {
            predicate = [NSPredicate predicateWithFormat:@"(name == %@)",@"NONE"];
            necessaryAccount = [[companyAccounts filteredSetUsingPredicate:predicate] anyObject];
        }
        if (!necessaryAccount)
        {
            NSLog(@"FINANCIAL:warning, necessary account don't found for carrier:%@",carrier);
        }
        if (!carrier.companyStuff)
        {
            NSLog(@"FINANCIAL:warning, companyStuff don't found for carrier:%@",carrier);
        }
        if (!financial)
        {
            NSLog(@"FINANCIAL:warning, financial don't found for carrier:%@",carrier);
        }
        
        newInvoice.financial = financial;
        newInvoice.companyAccounts = necessaryAccount;
        CompanyStuff *currentStuff = carrier.companyStuff;
        
        newInvoice.companyStuff = currentStuff;
        
        
        // fucking buggy grossbook, in/out can be revert!!!
//        NSString *direction = [invoice valueForKey:@"direction"];
//
//        if ([direction isEqualToString:@"In"])  newInvoice.isReceived = [NSNumber numberWithBool:YES];
//        else newInvoice.isReceived = [NSNumber numberWithBool:NO];

        if ([[invoice valueForKey:@"what"] isEqualToString:@"Inv"]) newInvoice.isInvoice = [NSNumber numberWithBool:YES];
        else newInvoice.isInvoice = [NSNumber numberWithBool:NO];

        
        if ([toAcccount isEqualToString:@"0"]) {
            newInvoice.isReceived = [NSNumber numberWithBool:NO];
        } else newInvoice.isReceived = [NSNumber numberWithBool:YES];

        
        NSNumber *externalAmount = [numberFormatter numberFromString:[invoice valueForKey:@"defSum"]];
        newInvoice.amountOurSide = externalAmount;
        newInvoice.amountCarrierSide = externalAmount;
        newInvoice.amountConfirmed = externalAmount;
        
        newInvoice.details = [invoice valueForKey:@"comment"];
            
    }] ;
    [formatter release],formatter = nil;
    [numberFormatter release],numberFormatter = nil;
    //NSLog(@"FINANCIAL:updated for carrier:%@",carrier.name);
    [self finalSave];
}



#pragma mark -
#pragma mark  STATISTIC methods


-(void)  updateStatisticforCarrierGUID:(NSString *)carrierGUID 
                        andCarrierName:(NSString *)carrierName
                   destinationType:(NSInteger)destinationType
      withProgressUpdateController:(ProgressUpdateController *)progress;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableArray *usedCodesWithStatistic = [NSMutableArray arrayWithCapacity:0];
    NSString *entityName = nil;
    
    NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400.0];
    
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyyMMddHH"];
    NSString *yesterdayStr = [inputFormatter stringFromDate:yesterday];
    [inputFormatter release],inputFormatter = nil;
    
    // we r looking for last date inPeer stat and used codes for last 24h. and then collect stat for it.
    if (destinationType == 0) { 
        [progress updateOperationName:@"STATISTIC:get used codes DestinationsListForSale"];
        [progress updateOperationNameForMsyqlQueryStart];
        entityName = @"DestinationsListForSale";

        NSArray *usedCodesWithStatisticForAdd = [database inStatUsedCodesWithStatisticForCarrier:carrierName day:yesterdayStr];
        [usedCodesWithStatistic addObjectsFromArray:usedCodesWithStatisticForAdd];
        
    }
    if (destinationType == 1) { 
        [progress updateOperationName:@"STATISTIC:get used codes DestinationsListWeBuy"];
        [progress updateOperationNameForMsyqlQueryStart];
        
        entityName = @"DestinationsListWeBuy";

        NSArray *usedCodesWithStatisticForAdd = [database outStatUsedCodesWithStatisticForCarrier:carrierName day:yesterdayStr];
        [usedCodesWithStatistic addObjectsFromArray:usedCodesWithStatisticForAdd];

    }
    NSLog (@"STAT:date %@ usedCodesWithStatistic:%@ for carrier %@",yesterdayStr,usedCodesWithStatistic, carrierName);

    [progress updateOperationNameForMsyqlQueryFinish];
    
    if ([usedCodesWithStatistic count] != 0) {
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        DestinationsClassController *destination = [[DestinationsClassController alloc] initWithMainMoc:[delegate managedObjectContext]];
        destination.carriers = [NSArray arrayWithObject:carrierGUID];
        destination.usedCodesWithStatistic = [NSArray arrayWithArray:usedCodesWithStatistic];
        destination.progress = progress;
        [destination updateStatisticForEntity:entityName];
        usedCodesWithStatistic = nil;
        
        [destination release],destination = nil;
    }
    [pool drain],pool = nil;
    return;
}

-(void)  updatePerHourStatisticforCarrierGUID:(NSString *)carrierGUID
                                  carrierName:(NSString *)carrierName
                          destinationType:(NSInteger)destinationType
             withProgressUpdateController:(ProgressUpdateController *)progress;
{
    NSArray *usedCodesWithStatistic = nil;
    NSString *entityName = nil;
    
    NSDate *oneHourAgo = [NSDate dateWithTimeIntervalSinceNow:-3600.0]; //-7776000.0];-86400.0
     
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyyMMddHH"];
    NSString *oneHourAgoStr = [inputFormatter stringFromDate:oneHourAgo];
    [inputFormatter release],inputFormatter = nil;
    
    // we r looking for last date inPeer stat and used codes for last 24h. and then collect stat for it.
    if (destinationType == 0) { 
        [progress updateOperationName:@"STATISTIC/HOUR:get used codes DestinationsListForSale"];
        [progress updateOperationNameForMsyqlQueryStart];

        entityName = @"DestinationsListForSale";
        usedCodesWithStatistic = [NSArray arrayWithArray:[database inStatUsedCodesWithStatisticForCarrier:carrierName day:oneHourAgoStr]];
        
    }
    if (destinationType == 1) { 
        [progress updateOperationName:@"STATISTIC/HOUR:get used codes DestinationsListForSale"];
        [progress updateOperationNameForMsyqlQueryStart];

        entityName = @"DestinationsListWeBuy";
        usedCodesWithStatistic = [NSArray arrayWithArray:[database outStatUsedCodesWithStatisticForCarrier:carrierName day:oneHourAgoStr]];
    }

    NSLog (@"STAT:date %@ usedCodesWithStatistic:%@ for carrier %@",oneHourAgoStr,usedCodesWithStatistic, carrierName);

    [progress updateOperationNameForMsyqlQueryFinish];

    if ([usedCodesWithStatistic count] != 0) {
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        DestinationsClassController *destination = [[DestinationsClassController alloc] initWithMainMoc:[delegate managedObjectContext]];
        destination.carriers = [NSArray arrayWithObject:carrierGUID];
        destination.usedCodesWithStatistic = usedCodesWithStatistic;
        destination.progress = progress;
        [destination updateEntity:entityName];
        [destination release];
    }
    [self finalSave];
    
}

#pragma mark -
#pragma mark  DESTINATIONS methods

- (BOOL) processUpdateDestinationForSaleForCodes:(NSSet *)codes 
                                        withRate:(NSNumber *)rate 
                          withDatabaseConnection:(MySQLIXC *)databaseForUpdate;

{
    NSNumberFormatter *form = [[[NSNumberFormatter alloc] init] autorelease];
    [form setFormat:@"#0.0####"];
    [form setDecimalSeparator:@"."];
    NSString *rateStr = [form stringFromNumber:rate];
    
    NSDateFormatter *changeDate = [[NSDateFormatter alloc] init];
    [changeDate setDateFormat:@"yyyy-MM-dd"];
    NSString *todayDateStr = [changeDate stringFromDate:[NSDate date]];
    
    for (CodesvsDestinationsList *code in codes)
    {
        [code setValue:[NSDate date] forKey:@"internalChangedDate"];
        if (![databaseForUpdate   updateForCode:[code valueForKey:@"code"] 
                               forDate:todayDateStr 
                               forRate:rateStr 
                                   forRateSheet:[code valueForKey:@"rateSheetID"] 
                                     forCountry:code.destinationsListForSale.country 
                                    forSpecific:code.destinationsListForSale.specific]) { 
            [changeDate release];
            return NO;
        }
        NSLog (@"SUCCESEFUL REPLACE data for code:%@ prefix:%@ rate:%@",[code valueForKey:@"code"],[code valueForKey:@"prefix"],rateStr);
    }
    [changeDate release];

    return YES;
}


-(void) insertOrUpdateGroupsInInternalDatabaseForGroups:(NSArray *)groupsForAdd 
                                              inCountry:(NSString *)country 
                                             inSpecific:(NSString *)specific
{
    for (NSDictionary *group in groupsForAdd)
    {
        NSString *groupName = [group valueForKey:@"name"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",country,specific];
        NSMutableDictionary *countrySpecific = [[[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:predicate] lastObject];
        NSMutableArray *currentGroups = [countrySpecific valueForKey:@"outGroups"];
        
        predicate = [NSPredicate predicateWithFormat:@"(name == %@)",groupName];
        if ([[currentGroups filteredArrayUsingPredicate:predicate] count] == 0) [currentGroups addObject:group];
        
        NSArray *outPeersInGroup = [group valueForKey:@"outPeerList"];
        predicate = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool:YES]];

        NSArray *enabledPeers = [outPeersInGroup filteredArrayUsingPredicate:predicate];
        predicate = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool:NO]];

        NSArray *disabledPeers = [outPeersInGroup filteredArrayUsingPredicate:predicate];
        
        if (![group valueForKey:@"id"]) {
            // create new group
            NSMutableDictionary *outPeerGroup = [NSMutableDictionary dictionaryWithCapacity:0];
            [outPeerGroup setValue:[group valueForKey:@"name"] forKey:@"name"];
            NSArray *outPeersList = [group valueForKey:@"outPeerList"];
            NSMutableArray *outPeersListUpdatedOurPeerId = [NSMutableArray array];
            
            [outPeersList enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *outPeer, NSUInteger idx, BOOL *stop) {
                [outPeersListUpdatedOurPeerId addObject:[NSDictionary dictionaryWithObjectsAndKeys:[outPeer valueForKey:@"outId"],@"peerID", nil]];
            }];
            [outPeerGroup setValue:[group valueForKey:@"name"] forKey:@"name"];
            [outPeerGroup setValue:outPeersListUpdatedOurPeerId forKey:@"outPeerList"];
            NSNumber *newGroupId = [database createNewGroup:outPeerGroup];
            
            predicate = [NSPredicate predicateWithFormat:@"(name == %@)",groupName];
            NSArray *updatedGroup = [currentGroups filteredArrayUsingPredicate:predicate];
            NSDictionary *updatedGroupFinal = [updatedGroup lastObject];
            NSMutableDictionary *updatedGroupMutable = [NSMutableDictionary dictionaryWithDictionary:updatedGroupFinal];
            [updatedGroupMutable setValue:[newGroupId stringValue]forKey:@"id"];
            [currentGroups removeObject:updatedGroupFinal];
            [currentGroups addObject:updatedGroupMutable];
            [countrySpecific setValue:currentGroups forKey:@"outGroups"];
            
        } else [database updateOutGroupsListWithOutPeersListInsideForOutGroup:[group valueForKey:@"id"] forEnabledOutPeers:enabledPeers forDisabledOutPeers:disabledPeers];
         
    }
    //NSLog(@"countrySpecificNew:%@",countrySpecificNew);
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    NSString *pathForSaveArray = [[delegate applicationFilesDirectory].path stringByAppendingString:@"/myCountrySpecificCodeList.ary"];
    BOOL success = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList writeToFile:pathForSaveArray atomically:YES];
    if (!success) NSLog(@"Write to file insertOrUpdateGroupsInInternalDatabaseForGroups was failed");

}


- (NSMutableDictionary *) getIVRConfigurationTable;
{
    ParseCSV *parser = nil;
    parser = [[[ParseCSV alloc] init] autorelease];
    NSString *oldPath = @"/Users/alex/DropBoxTest/rules.txt";
    [parser openFile:oldPath];
    NSMutableArray *parsed = [parser parseFile];
    if ([parsed count] == 0) return nil;
    NSMutableDictionary *tableOfIVRConfig = [self parseRulesForIVRforResults:parsed];
    
    return tableOfIVRConfig;
}

- (void) updateIVRConfigurationTableForCarrier:(NSString *)carrierName 
                                    forCountry:(NSString *)country 
                                   forSpecific:(NSString *)specific 
                                    forPercent:(NSNumber *)percent 
                         forLinesForActivation:(NSNumber *)lines
{
    NSMutableDictionary *tableOfIVRConfig = [self getIVRConfigurationTable];

    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:@"yyyy-MM-dd-HH-mm"];
    NSString *oldPath = @"/Users/alex/DropBoxTest/rules.txt";
    NSString *newPath = [NSString stringWithFormat:@"/Users/alex/DropBoxTest/rules%@.txt",[formatter stringFromDate:[NSDate date]]];

    [fileManager moveItemAtPath:oldPath toPath:newPath error:&error];
    if (error) NSLog(@"Error moveItemAtPath : %@",error);


    NSMutableDictionary *carrierDestinationsList = [tableOfIVRConfig valueForKey:carrierName];
    NSString *destinationCountryAndSpecific = [NSString stringWithFormat:@"%@/%@",country,specific];
    
    //NSMutableString *currentLinesAndPercent = [carrierDestinationsList valueForKey:destinationCountryAndSpecific];
    
    NSNumber *percentForFile = [NSNumber numberWithDouble:([percent doubleValue] * 100)];
    NSNumberFormatter *formatterNumber = [[[NSNumberFormatter alloc] init] autorelease];
    [formatterNumber setFormat:@"#0"];
    
    
    NSMutableString *currentLinesAndPercent = [NSMutableString stringWithFormat:@"%@|%@",[lines stringValue],[formatterNumber stringFromNumber:percentForFile]];
    [carrierDestinationsList setValue:currentLinesAndPercent forKey:destinationCountryAndSpecific];
    [tableOfIVRConfig setValue:carrierDestinationsList forKey:carrierName];
    
    NSMutableString *finalFile = [self parseInternalDataToRulesForIVR:tableOfIVRConfig];
    [finalFile writeToFile:oldPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
    
    
}

-(NSArray *) inserDestinationsForCarriers:(NSArray *)carrierListForAdd 
                          andDestinations:(NSArray *)destinationsListForAdd 
                                forEntity:(NSString *)entity 
                              withPercent:(NSNumber *)percent 
                   withLinesForActivation:(NSNumber *)lines;
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool:YES]];
    NSMutableArray *addedIDS = [NSMutableArray arrayWithCapacity:0];
       for (NSDictionary *carrier in carrierListForAdd)
        {
            NSArray *rateSheetsAndPrefixes = [carrier valueForKey:@"rateSheetsAndPrefixes"];
            NSArray *rateSheetsAndPrefixesSelected = nil;
            if ([rateSheetsAndPrefixes count] == 1) rateSheetsAndPrefixesSelected = rateSheetsAndPrefixes;
            else rateSheetsAndPrefixesSelected = [rateSheetsAndPrefixes filteredArrayUsingPredicate:predicate];
            
            NSString *carrierName = [carrier valueForKey:@"name"];
            NSString *carrierGUID = [carrier valueForKey:@"GUID"];
            if ([entity isEqualToString:@"DestinationsListPushList"]) {
//                AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                DestinationsClassController *destination = [[DestinationsClassController alloc] initWithMainMoc:[delegate managedObjectContext]];
                destination.carriers = [NSArray arrayWithObject:carrierGUID];
                destination.destinations = destinationsListForAdd;
                [addedIDS addObjectsFromArray:[destination insertDestinationsForEntity:entity]];
                [destination release];
                
            } else {            
                for (NSDictionary *destination in destinationsListForAdd)
                {
                    NSString *countryForAdd = [destination valueForKey:@"country"];
                    NSString *specificForAdd = [destination valueForKey:@"specific"];
                    //NSNumber *rateForAdd = [destination valueForKey:@"rate"];
                    NSNumber *rateForAdd = nil;
                    id rateToCheck = [destination valueForKey:@"rate"];
                    if ([[rateToCheck class] isSubclassOfClass:[NSNumber class]]) {
                        rateForAdd = rateToCheck;
                    } else {
                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                        rateForAdd = [formatter numberFromString:rateToCheck];
                        if (!rateForAdd) {
                            rateToCheck = [rateToCheck stringByReplacingOccurrencesOfString:@"," withString:@"."];
                            rateForAdd = [formatter numberFromString:rateToCheck];
                            if (!rateForAdd) { 
                                rateToCheck = [rateToCheck stringByReplacingOccurrencesOfString:@"." withString:@","];
                                rateForAdd = [formatter numberFromString:rateToCheck];
                            }
                        }
                        [formatter release];
                    }

                    NSArray *groupsForAdd = [[destination valueForKey:@"outGroups"] filteredArrayUsingPredicate:predicate];
                    if ([entity isEqualToString:@"DestinationsListForSale"]) [self insertOrUpdateGroupsInInternalDatabaseForGroups:groupsForAdd inCountry:countryForAdd inSpecific:specificForAdd];
                    
                    for (NSDictionary *rateSheetAndPrefix in rateSheetsAndPrefixesSelected) { 
                        NSString *prefix = [rateSheetAndPrefix valueForKey:@"prefix"];
                        NSString *rateSheetID = [rateSheetAndPrefix valueForKey:@"rateSheetID"];
                        NSString *inPeerId = nil;
                        
                        if ([entity isEqualToString:@"DestinationsListForSale"]) {
                            NSArray *result;
                            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(carrier.name == %@) AND (prefix == %@)",carrierName,prefix];
                            //NSManagedObjectContext *moc = [self managedObjectContext];
                            NSError *error = nil; 
                            NSFetchRequest *requestDestinations = [[[NSFetchRequest alloc] init] autorelease];
                            [requestDestinations setEntity:[NSEntityDescription entityForName:@"DestinationsListForSale" inManagedObjectContext:moc]];
                            [requestDestinations setPredicate:predicate];
                            result = [moc executeFetchRequest:requestDestinations error:&error];
                            if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
                            if ([result count] == 0) NSLog(@"ADD DESTINATION WARNING - don't find other destinations to get ips");
                            DestinationsListForSale *destination = [result lastObject];
                            NSString *ips = destination.ipAddressesList;
                            NSArray *codesList = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@)",countryForAdd,specificForAdd]];
                            NSArray *codesListWithOutSpecific = [[codesList lastObject] valueForKey:@"code"];
                            
                            inPeerId = [database insertNewInpeerForCarrier:carrierName withRateSheetID:[rateSheetAndPrefix valueForKey:@"rateSheetID"] withIPAddresses:ips withPrefix:prefix withCountry:countryForAdd withSpecific:specificForAdd withCodeList:codesListWithOutSpecific withOutPeersGroups:groupsForAdd forRate:[rateForAdd stringValue]];
                            
                            [self updateIVRConfigurationTableForCarrier:carrierName 
                                                             forCountry:countryForAdd 
                                                            forSpecific:specificForAdd 
                                                             forPercent:percent 
                                                  forLinesForActivation:lines];
                        }
                        
                        NSDictionary *destinationForAdd = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           countryForAdd,@"country",
                                                           specificForAdd,@"specific", 
                                                           prefix,@"prefix",
                                                           rateSheetID,@"rateSheetID",
                                                           rateForAdd,@"rate",groupsForAdd,@"groups",
                                                           inPeerId, @"inPeerId",
                                                           nil];
                        
                        NSArray *destinationsForAdd = [NSArray arrayWithObject:destinationForAdd];
//                        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                        DestinationsClassController *destination = [[DestinationsClassController alloc] initWithMainMoc:[delegate managedObjectContext]];
                        destination.carriers = [NSArray arrayWithObject:carrierGUID];
                        destination.destinations = destinationsForAdd;
                        [addedIDS addObjectsFromArray:[destination insertDestinationsForEntity:entity]];
                        [destination release];
                        
                        
                        
                    }
                }
                
            }
        }
    NSArray *finalResult = [NSArray arrayWithArray:addedIDS];
    return finalResult;
}

- (BOOL) checkIfRatesWasUpdatedforCarrierForRateSheetAndPrefix:(NSDictionary *)rateSheetAndPrefix 
                                                    andCarrierName:(NSString *)carrierName
                                                    andCarrierID:(NSManagedObjectID *)carrierID
                                           andRelationShipName:(NSString *)relationshipName;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *rateSheetID = [rateSheetAndPrefix valueForKey:@"rateSheetID"];
    NSFetchRequest *requestCodesForSale = [[NSFetchRequest alloc] init];
    [requestCodesForSale setEntity:[NSEntityDescription entityForName:@"CodesvsDestinationsList"
                                               inManagedObjectContext:self.moc]];
    [requestCodesForSale setPredicate:[NSPredicate predicateWithFormat:@"(%K.carrier == %@)",relationshipName,carrierID]];
    NSError *error = nil; 
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"externalChangedDate"];
    NSExpression *maxSalaryExpression = [NSExpression expressionForFunction:@"max:"
                                                                  arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"maxExternalChangedDate"];
    [expressionDescription setExpression:maxSalaryExpression];
    [expressionDescription setExpressionResultType:NSDecimalAttributeType];
    [requestCodesForSale setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
//    [maxSalaryExpression release];
    [requestCodesForSale setResultType:NSDictionaryResultType];
    //NSLog(@"UPDATE DATA CONTROLLER: >>>>>>>>>> get max date start");
    NSArray *result = [self.moc executeFetchRequest:requestCodesForSale error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
    NSDate *maxExternalChangedDate = result.lastObject;
    
    //NSLog(@"UPDATE DATA CONTROLLER: >>>>>>>>>> get max date result:%@",result);

//    NSNumber *count = [codes valueForKeyPath:@"@count.externalChangedDate"];
//    if (count == 0) { 
//        [requestCodesForSale release];
//        [pool drain], pool = nil;
//        return YES;
//    }
//    NSDate *maxExternalChangedDate = [codes valueForKeyPath:@"@max.externalChangedDate"];
//    codes = nil;
    
    NSDateFormatter *changeDate = [[NSDateFormatter alloc] init];
    [changeDate setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [changeDate stringFromDate:maxExternalChangedDate];
    [changeDate release],changeDate = nil;
    [requestCodesForSale release],requestCodesForSale = nil;

    if (!date) {
        [pool drain], pool = nil;

        return YES;
    }
    NSLog(@"UPDATE DATA CONTROLLER: >>>>>>>>>> get max date MYSQL start");

    if ([database checkIfPriceWasChangesWithRateSheetID:rateSheetID withDate:date]) { 
        //NSLog(@"UPDATE DATA CONTROLLER: >>>>>>>>>> get max date MYSQL stop");

        [pool drain], pool = nil;

        return YES;
    }
    return NO;
}

- (NSNumber *) checkIfRatesWasUpdatedforCarrierGUID:(NSManagedObjectID *)carrierID andCarrierName:(NSString *)carrierName;

{
    BOOL destinationsListForSaleNeedUpdate = NO;
    BOOL destinationsListWeBuyNeedUpdate = NO;
    //NSLog(@"UPDATE DATA CONTROLLER: >>>>>>>>>> get locat ratesheets and prefixes start");

    NSArray *rateSheetsAndPrefixes = [self getRateSheetsAndPrefixListToChoiceByUserForCarrierID:carrierID withRelationShipName:@"destinationsListForSale"];
    // ,@"rateSheetName",@"prefix",@"rateSheetID"
    if ([rateSheetsAndPrefixes count] == 0) destinationsListForSaleNeedUpdate = YES;
    for (NSDictionary *rateSheetAndPrefix in rateSheetsAndPrefixes) if ([self checkIfRatesWasUpdatedforCarrierForRateSheetAndPrefix:rateSheetAndPrefix andCarrierName:carrierName andCarrierID:carrierID andRelationShipName:@"destinationsListForSale"]) destinationsListForSaleNeedUpdate = YES;

    rateSheetsAndPrefixes = [self getRateSheetsAndPrefixListToChoiceByUserForCarrierID:carrierID withRelationShipName:@"destinationsListWeBuy"];
    if ([rateSheetsAndPrefixes count] == 0) destinationsListWeBuyNeedUpdate = YES;
    for (NSDictionary *rateSheetAndPrefix in rateSheetsAndPrefixes) if ([self checkIfRatesWasUpdatedforCarrierForRateSheetAndPrefix:rateSheetAndPrefix andCarrierName:carrierName andCarrierID:carrierID andRelationShipName:@"destinationsListWeBuy"]) destinationsListWeBuyNeedUpdate = YES;

    if (destinationsListWeBuyNeedUpdate && destinationsListForSaleNeedUpdate) return [NSNumber numberWithInt:3];
    if (destinationsListWeBuyNeedUpdate) return [NSNumber numberWithInt:2];
    if (destinationsListForSaleNeedUpdate) return [NSNumber numberWithInt:1];
    return [NSNumber numberWithInt:0];
}


-(NSMutableDictionary *)findCountrySpecificForCode:(NSString *)code
{
    // find in local database parameters for current code
    NSUInteger maxCodesDeep = 11;
    if ([code length] < maxCodesDeep) maxCodesDeep = [code length];
    NSMutableDictionary *countrySpecific = [[ProjectArrays sharedProjectArrays].dictionaryDictionaryesForCountryCodes valueForKey:code];
   // NSLog(@"Destination parameters:/%@/",code);
    //NSLog(@"Destination parameters:%@",[ProjectArrays sharedProjectArrays].dictionaryDictionaryesForCountryCodes);
    
    NSMutableDictionary *destinationParameters = [NSMutableDictionary dictionaryWithDictionary:countrySpecific];

    //NSLog(@"Destination parameters:%@ for code :%@",destinationParameters, code);
    if ([destinationParameters count] == 0)
    {
        NSString *currentCode = [NSString stringWithString:code];
        NSRange currentRange = NSMakeRange(0,[currentCode length]);
        
        if (maxCodesDeep > 1) {
            for (int codesDeep = 0; codesDeep < maxCodesDeep;codesDeep++)
            {
                currentRange.length = currentRange.length - 1;
                NSString *changedCode = [currentCode substringWithRange:currentRange];
                //NSLog(@"search for code :%@", changedCode);
                destinationParameters = [NSMutableDictionary dictionaryWithDictionary:[[ProjectArrays sharedProjectArrays].dictionaryDictionaryesForCountryCodes valueForKey:changedCode]];
                if ([destinationParameters count] != 0){
                    [destinationParameters setValue:changedCode forKey:@"code"];
                    [destinationParameters setValue:code forKey:@"originalCode"];
                    break;
                }            
            }
        } 
        
    } else {
        [destinationParameters setValue:code forKey:@"code"];
        [destinationParameters setValue:@"" forKey:@"originalCode"];
    }
    if (![destinationParameters valueForKey:@"specific"] || ![destinationParameters valueForKey:@"country"]) {
        [destinationParameters setValue:@"UNDEFINDED" forKey:@"country"];
        [destinationParameters setValue:@"UNDEFINDED" forKey:@"specific"];
        NSLog(@"WARNING: Country/specific for code:%@ not found in array with object:%@",code, destinationParameters);
    }
    if (![destinationParameters valueForKey:@"code"]) [destinationParameters setValue:@"" forKey:@"code"];
    code = nil;
    
    return destinationParameters;
    
}

-(void)insertCodeWithObject:(NSDictionary *)code;
{
    NSManagedObject *codeNew = [NSEntityDescription 
                                insertNewObjectForEntityForName:@"CodesvsDestinationsList" 
                                inManagedObjectContext:self.moc];
    [codeNew setValuesForKeysWithDictionary:code];
}


-(void)insertDestinationWithObject:(NSDictionary *)destination;
{
    NSString *entity = [destination valueForKey:@"entity"];
    NSManagedObject *objectDestination = [NSEntityDescription 
                                insertNewObjectForEntityForName:entity 
                                inManagedObjectContext:self.moc];
    [objectDestination setValuesForKeysWithDictionary:destination];
}


-(BOOL)  updateDestinationListforCarrier:(NSManagedObjectID *)carrierID 
                         destinationType:(NSInteger)destinationType
            withProgressUpdateController:(ProgressUpdateController *)progress;
{
    NSString *destinationTypeString = nil;  
    __block NSArray *externalDestinationsList = nil;
    Carrier *necessaryCarrier = (Carrier *)[moc objectWithID:carrierID];
    NSString *carrierGUID = necessaryCarrier.GUID;
    NSString *carrierName = necessaryCarrier.name;

    // type of destination 0 - we sold, 1 - we buy
    if (destinationType == 0)  {
        [progress updateOperationName:@"IMPORT DESTINATIONS:DestinationsListForSale"];

        [progress updateOperationNameForMsyqlQueryStart];
        destinationTypeString = @"DestinationsListForSale";
        //externalDestinationsList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.ary",[delegate applicationSupportDirectory],destinationTypeString]];
        //if (!externalDestinationsList) 
            externalDestinationsList = [database destinationsForSaleList:carrierName];
        //[externalDestinationsList writeToFile:[NSString stringWithFormat:@"%@/%@.ary",[delegate applicationSupportDirectory],destinationTypeString] atomically:YES];
        [progress updateOperationNameForMsyqlQueryFinish];
    }    
    if (destinationType == 1)  {
        [progress updateOperationName:@"IMPORT DESTINATIONS:DestinationsListWeBuy"];
        [progress updateOperationNameForMsyqlQueryStart];
        destinationTypeString = @"DestinationsListWeBuy";        
        //externalDestinationsList = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.ary",[delegate applicationSupportDirectory],destinationTypeString]];
        //if (!externalDestinationsList) 
        externalDestinationsList = [database destinationsWeAreBuyList:carrierName];
        //[externalDestinationsList writeToFile:[NSString stringWithFormat:@"%@/%@.ary",[delegate applicationSupportDirectory],destinationTypeString] atomically:YES];

        [progress updateOperationNameForMsyqlQueryFinish];
    }
    /*NSUInteger count = [externalDestinationsList count];
    if (count > 10000) {
        __block NSUInteger quarter = count/4;
        //[self finalSave];
        // first quater
        NSRange rangeForFirstQuarter = NSMakeRange(0,quarter);
        NSArray *firstQuarter = [externalDestinationsList objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:rangeForFirstQuarter]];
        NSRange rangeForSecondQuarter = NSMakeRange(quarter,quarter);
        NSArray *secondQuarter = [externalDestinationsList objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:rangeForSecondQuarter]];
        NSRange rangeForThirdQuarter = NSMakeRange(quarter*2,quarter);
        NSArray *thirdQuarter = [externalDestinationsList objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:rangeForThirdQuarter]];
        NSRange rangeForFourthQuarter = NSMakeRange(quarter+quarter*2,quarter-1);
        NSArray *fourthQuarter = [externalDestinationsList objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:rangeForFourthQuarter]];
        externalDestinationsList = nil;
        
        *NSManagedObjectContext *mocForFirstQuarter = [[NSManagedObjectContext alloc] init];
        [mocForFirstQuarter setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
        [mocForFirstQuarter setUndoManager:nil];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
        [nc addObserver:self
               selector:@selector(mergeChanges:) 
                   name:NSManagedObjectContextDidSaveNotification
                 object:mocForFirstQuarter];*

        DestinationsClassController *destinationForFirstQuarter = [[DestinationsClassController alloc] init];
        destinationForFirstQuarter.carriers = [NSArray arrayWithObject:carrierName];
        //destinationForFirstQuarter.context = mocForFirstQuarter;
        destinationForFirstQuarter.externalDataCodes = firstQuarter;
        destinationForFirstQuarter.additionalMessageForUser = @"1/4";
        destinationForFirstQuarter.progress = progress;
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

        [destinationForFirstQuarter updateEntity:destinationTypeString];
        firstQuarter = nil;
        destinationForFirstQuarter.externalDataCodes = nil;
        
        //NSError *error = nil;

        //if (![mocForFirstQuarter save: &error]) NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
        //});
        [destinationForFirstQuarter release],destinationForFirstQuarter = nil;
  
        // second quater
        *NSManagedObjectContext *mocForSecondQuarter = [[NSManagedObjectContext alloc] init];
        [mocForSecondQuarter setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
        [mocForSecondQuarter setUndoManager:nil];
        //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
        [nc addObserver:self
               selector:@selector(mergeChanges:) 
                   name:NSManagedObjectContextDidSaveNotification
                 object:mocForSecondQuarter];*

        DestinationsClassController *destinationForSecondQuarter = [[DestinationsClassController alloc] init];
        destinationForSecondQuarter.carriers = [NSArray arrayWithObject:carrierName];
        //destinationForSecondQuarter.context = mocForSecondQuarter;
        destinationForSecondQuarter.externalDataCodes = secondQuarter;
        destinationForSecondQuarter.additionalMessageForUser = @"2/4";
        destinationForSecondQuarter.progress = progress;
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

        [destinationForSecondQuarter updateEntity:destinationTypeString];
        secondQuarter = nil;
        destinationForSecondQuarter.externalDataCodes = nil;
        
        //NSError *error = nil;

        //if (![mocForSecondQuarter save: &error]) NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
        //});
        [destinationForSecondQuarter release],destinationForSecondQuarter = nil;
        // third quater
        *NSManagedObjectContext *mocForThirdQuarter = [[NSManagedObjectContext alloc] init];
        [mocForThirdQuarter setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
        [mocForThirdQuarter setUndoManager:nil];
        //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
        [nc addObserver:self
               selector:@selector(mergeChanges:) 
                   name:NSManagedObjectContextDidSaveNotification
                 object:mocForThirdQuarter];*

        DestinationsClassController *destinationForThirdQuarter = [[DestinationsClassController alloc] init];
        destinationForThirdQuarter.carriers = [NSArray arrayWithObject:carrierName];
        //destinationForThirdQuarter.context = mocForThirdQuarter;
        destinationForThirdQuarter.externalDataCodes = thirdQuarter;
        destinationForThirdQuarter.additionalMessageForUser = @"3/4";
        destinationForThirdQuarter.progress = progress;
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

        [destinationForThirdQuarter updateEntity:destinationTypeString];
        thirdQuarter = nil;
        destinationForThirdQuarter.externalDataCodes = nil;
        
        //if (![mocForThirdQuarter save: &error]) NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
        [destinationForThirdQuarter release],destinationForThirdQuarter = nil;
       // NSError *error = nil;

       //     if (![mocForThirdQuarter save: &error]) NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
       // });

        // fourth quater
        NSManagedObjectContext *mocForFourthQuarter = [[NSManagedObjectContext alloc] init];
        [mocForFourthQuarter setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
        [mocForFourthQuarter setUndoManager:nil];
        //NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
        *[nc addObserver:self
               selector:@selector(mergeChanges:) 
                   name:NSManagedObjectContextDidSaveNotification
                 object:mocForFourthQuarter];*

        DestinationsClassController *destinationForFourthQuarter = [[DestinationsClassController alloc] init];
        destinationForFourthQuarter.carriers = [NSArray arrayWithObject:carrierName];
        //destinationForFourthQuarter.context = mocForFourthQuarter;
        destinationForFourthQuarter.externalDataCodes = fourthQuarter;
        destinationForFourthQuarter.additionalMessageForUser = @"4/4";
        destinationForFourthQuarter.progress = progress;
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {

        [destinationForFourthQuarter updateEntity:destinationTypeString];
        fourthQuarter = nil;
        destinationForFourthQuarter.externalDataCodes = nil;
        
        //if (![mocForFourthQuarter save: &error]) NSLog(@"Failed to save to data store: %@", [error localizedDescription]);
        //});
        [destinationForFourthQuarter release],destinationForFourthQuarter = nil;
        externalDestinationsList = nil;
        
    } else {*/
    BOOL result= YES;
    if ([externalDestinationsList count] != 0) {
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        DestinationsClassController *destination = [[DestinationsClassController alloc] initWithMainMoc:[delegate managedObjectContext]];
        destination.carriers = [NSArray arrayWithObject:carrierGUID];
        destination.externalDataCodes = externalDestinationsList;
        destination.progress = progress;
        result = [destination updateEntity:destinationTypeString];
        externalDestinationsList = nil;
        [destination release],destination = nil;
    }
    return result;
}


- (NSArray *)getDestinationsListAndOutGroupsForDestinationsList:(NSArray *)selectedDestinations;
{
    NSMutableArray *addedSpecifics = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *checkDestinationsForAddByEventContent = [NSMutableArray arrayWithCapacity:0];

    for (DestinationsListForSale *destinationForSale in selectedDestinations)
    {
        NSString *countryForAdd = destinationForSale.country; 
        NSString *specificForAdd = destinationForSale.specific;
        NSPredicate *specifics = [NSPredicate predicateWithFormat:@"(specific contains[cd] %@)",specificForAdd];
        NSArray *allSpecifics = [selectedDestinations filteredArrayUsingPredicate:specifics];
        NSNumber *rateForAdd = [allSpecifics valueForKeyPath:@"@min.rate"];
        
        if ([addedSpecifics containsObject:specificForAdd]) continue;
        else {
            
            NSArray *outGroupsWithOutPeers = [database getOutGroupsListWithOutPeersListInsideForCountry:countryForAdd forSpecific:specificForAdd];
            // final result:id,name,routePrio, outPeerList -> Array(outId, routePrio, firstName, secondName, tag )
            
            NSMutableArray *checkOutGroupsForAddByEventContentSetToDestinations = [NSMutableArray arrayWithCapacity:0];
            
            for (NSDictionary *outGroup in outGroupsWithOutPeers)
            {
                NSMutableDictionary *outGroupsWithSelected = [NSMutableDictionary dictionaryWithDictionary:outGroup];
                [outGroupsWithSelected setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
                [checkOutGroupsForAddByEventContentSetToDestinations addObject:outGroupsWithSelected];
            }
            
            [addedSpecifics addObject:specificForAdd];
            NSMutableDictionary *destinationsContentForAdd = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"selected",countryForAdd,@"country",specificForAdd,@"specific",rateForAdd,@"rate",checkOutGroupsForAddByEventContentSetToDestinations,@"outGroups", nil];
            [checkDestinationsForAddByEventContent addObject:destinationsContentForAdd];
        }
    }
    return checkDestinationsForAddByEventContent;
}

//- (void)getDestinationsListAndOutGroupsForSelectedDestinations:(NSArray *)selectedDestinations;
//{
////    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//
//    [delegate.checkDestinationsForAddByEvent setContent:[self getDestinationsListAndOutGroupsForDestinationsList:selectedDestinations]];
//}


- (void)getDestinationsListAndOutGroupsForAddInCountry:(NSString *)country;
{
    // some limitations - if destination have different routing for different codes, it code have to be updated
    NSFetchRequest *requestDestinationsForSale = [[NSFetchRequest alloc] init];
    [requestDestinationsForSale setEntity:[NSEntityDescription entityForName:@"DestinationsListForSale"
                                                      inManagedObjectContext:moc]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(country contains[cd] %@)",country];
    [requestDestinationsForSale setPredicate:predicate];
    
    NSError *error = nil; 
    NSArray *destinationsForSaleAlreadyInserted = [moc executeFetchRequest:requestDestinationsForSale error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
    
    //NSLog (@"destinations:%@",destinationsForSale);
    
    NSMutableArray *checkDestinationsForAddByEventContent = [NSMutableArray arrayWithArray:[self getDestinationsListAndOutGroupsForDestinationsList:destinationsForSaleAlreadyInserted]];
    
    NSArray *destinatinationsForSaleInCountrySpecificList = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:predicate];
    NSMutableArray *specificsWhichWasNotAddedBeforeInDatabase = [NSMutableArray arrayWithArray:destinatinationsForSaleInCountrySpecificList];
    
    NSArray *addedSpecifics = [checkDestinationsForAddByEventContent valueForKeyPath:@"@distinctUnionOfObjects.specific"];
    for (NSString *addedSpecific in addedSpecifics)
    {
        NSPredicate *specifics = [NSPredicate predicateWithFormat:@"NOT (specific contains[cd] %@)",addedSpecific];
        [specificsWhichWasNotAddedBeforeInDatabase filterUsingPredicate:specifics];
    }
    [checkDestinationsForAddByEventContent addObjectsFromArray:specificsWhichWasNotAddedBeforeInDatabase];
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    [delegate.checkDestinationsForAddByEvent setContent:checkDestinationsForAddByEventContent];
    [requestDestinationsForSale release];
}

-(void) updateRoutingTableForDestinations:(NSArray *)destinations;
{
    
    NSString *carrierName = [[[destinations lastObject] valueForKey:@"carrier"] valueForKey:@"name"];
    
    NSLog(@"ROUTING: update for carrier:%@ with queue status process:%@",carrierName, [ProjectArrays sharedProjectArrays].queryProgress);
    
    for (DestinationsListForSale *destinationForSale in destinations)
    {
        NSSet *codes = [destinationForSale valueForKey:@"codesvsDestinationsList"];
        CodesvsDestinationsList *code = [codes anyObject];
        NSString *codeStr = [code.code stringValue];
        NSString *countryStr = destinationForSale.country;
        NSString *specificStr = destinationForSale.specific;
        NSString *prefixStr = destinationForSale.prefix;
        NSArray *routingTable = [database receiveRoutingTableForCode:codeStr 
                                                              prefix:prefixStr 
                                                             carrier:carrierName];
        /*NSLog (@"Routing for Code: %@ for Destination:%@/%@ for Carrier: %@ with prefix:%@ is:%@",
               codeStr,
               countryStr,
               specificStr,
               carrierName,
               prefixStr,
               routingTable
               );*/
        // add new routing table
        /* routingTable array format:
         (
         {
         company = "KT Corporation";
         prefix = 2843;
         routePrio = "-1";
         }
         )
         */
        
        for (NSDictionary *routesOut in routingTable)
        {
            NSString *routePrio = [NSString stringWithString:[routesOut valueForKey:@"routePrio"]];
            NSString *outCarrierName = [routesOut valueForKey:@"company"];
            NSString *outCarrierPrefixStr = [routesOut valueForKey:@"prefix"];
            NSString *outCarrierRateSheet = [routesOut valueForKey:@"rateSheet"];
            NSString *outCarrierRateSheetID = [NSString stringWithString:[routesOut valueForKey:@"rateSheetId"]];
            
            NSString *minProfitAbsStr = [routesOut valueForKey:@"minProfitAbs"];
            NSString *minProfitRelStr = [routesOut valueForKey:@"minProfitRel"];
            NSNumberFormatter *numberTransfer = [[[NSNumberFormatter alloc] init] autorelease];
            NSNumber *minProfitAbs = [numberTransfer numberFromString:minProfitAbsStr];
            NSNumber *minProfitRel = [numberTransfer numberFromString:minProfitRelStr];
            NSLog(@"ROUTING: minProfitAbs: %@ \n minProfitAbs:%@\n",minProfitAbs,minProfitRel);
            
            DestinationsListWeBuy *destinationWeBuy = nil;
            NSFetchRequest *requestDestinationWeBuy = [[[NSFetchRequest alloc] init] autorelease];
            [requestDestinationWeBuy setEntity:[NSEntityDescription entityForName:@"DestinationsListWeBuy"
                                                           inManagedObjectContext:moc]];
            NSError *error = nil; 
            [requestDestinationWeBuy setPredicate:
             [NSPredicate predicateWithFormat:
              @"carrier.name == %@ and (country == %@) and (specific == %@) and (prefix == %@) and (enabled == YES) and ((rateSheet == %@) OR (rateSheet == %@))",
              outCarrierName,
              countryStr,
              specificStr,
              outCarrierPrefixStr,
              outCarrierRateSheet,
              @"Price table"]];
            NSArray *destinationWeBuyList = nil;
            [requestDestinationWeBuy setResultType:NSManagedObjectIDResultType];
            destinationWeBuyList = [moc executeFetchRequest:requestDestinationWeBuy error:&error];
            if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
            
            if ([destinationWeBuyList count] > 1)
            {
                for (NSManagedObjectID *destinationWeBuy in destinationWeBuyList)
                {
                    NSLog(@"ROUTING ALERT: DESTINATIONS WE BUY HAVE MORE THAN ONE CHOICE");
                    DestinationsListWeBuy *destinationWeBuyObject = (DestinationsListWeBuy *)[moc objectWithID:destinationWeBuy];
                    
                    NSLog(@"Outgoing routing: country:%@ specific:%@ prefix :%@,rate:%@",countryStr,specificStr,prefixStr,destinationWeBuyObject.rate);
                }
                continue;
                
            }
            
            
            if ([destinationWeBuyList count] == 0 ) {
                NSLog(@"ROUTING: DESTINATIONS WE BUY EMPTY \n for company %@\n country:%@\n specific:%@\n prefix %@\n with request:%@\n",
                      outCarrierName,
                      countryStr,
                      specificStr,
                      [routesOut valueForKey:@"prefix"],
                      requestDestinationWeBuy);
                
                
                NSUInteger maxCodeDeep = 8; 
                if ([codeStr length] < maxCodeDeep) maxCodeDeep = [[NSNumber numberWithUnsignedInteger:[codeStr length]] intValue] - 1;
                
                NSRange codeStrRange = NSMakeRange(0,[codeStr length]);
                BOOL huntingWasSuccess = NO;
                for (NSUInteger codeDeep = 0; codeDeep < maxCodeDeep;codeDeep++) 
                {
                    codeStrRange.length = codeStrRange.length - 1;
                    NSString *changedCode = [codeStr substringWithRange:codeStrRange];
                    NSFetchRequest *compareCode = [[[NSFetchRequest alloc] init] autorelease];
                    [compareCode setEntity:[NSEntityDescription entityForName:@"CodesvsDestinationsList"
                                                       inManagedObjectContext:moc]];
                    NSString *codeRelationshipName = @"destinationsListWeBuy";
                    [compareCode setPredicate:[NSPredicate predicateWithFormat:@"(%K.carrier.name == %@) and ((code == %@) OR (originalCode == %@)) and (%K.prefix == %@) and (enabled == YES) and ((rateSheetID == %@) OR (rateSheetID == %@))",codeRelationshipName, outCarrierName,changedCode,changedCode, codeRelationshipName, outCarrierPrefixStr,outCarrierRateSheetID,@"65535"]];
                    
                    [compareCode setResultType:NSManagedObjectIDResultType];
                    
                    NSArray *codeAfterComparing = [moc executeFetchRequest:compareCode error:&error];
                    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 

                    if ([codeAfterComparing count] == 0) {
                        NSLog(@"ROUTING: Compare was unsucceseful with parameters:%@",compareCode);
                        continue;
                    }
                    else {
                        CodesvsDestinationsList *anyCode = [codeAfterComparing lastObject];
                        destinationWeBuy = anyCode.destinationsListWeBuy;
                        
                        NSLog(@"ROUTING: Compare was succeseful with parameters:%@\n and destination object:%@\n Carrier name is %@ ",compareCode,destinationWeBuy,carrierName);
                        
                        //destinationWeBuy = [destinationWeBuyObj objectID];
                        huntingWasSuccess = YES;
                        break;
                    }
                }
                if (!huntingWasSuccess) continue;
            } else {
                DestinationsListWeBuy *anyDestinaton = [destinationWeBuyList lastObject];
                destinationWeBuy = (DestinationsListWeBuy *)[moc objectWithID:anyDestinaton.objectID];
                //NSLog(@"ROUTING: destinationWeBuy enabled:%@",destinationWeBuy.enabled);
                if ([destinationWeBuy.enabled boolValue] == NO) {
                    //NSLog(@"ROUTING: destinationWeBuy enabled2:%@",destinationWeBuy.enabled);
                    
                    continue;
                }
            }
            
            if (code.destinationsListForSale == nil || destinationWeBuy == nil) {
                NSLog(@"ROUTING: we don't have both part of routing table, create nothing");
            } else {
                
                DestinationRouting *newOutpeerInRouting = [NSEntityDescription 
                                                           insertNewObjectForEntityForName:@"DestinationRouting"
                                                           inManagedObjectContext:moc];
                NSNumber *routePrioNum = [numberTransfer numberFromString:routePrio];
                newOutpeerInRouting.priority = (NSDecimalNumber *)routePrioNum;
                
                NSNumber *lastUsedACD = destinationWeBuy.lastUsedACD;
                NSNumber *lastUsedASR = destinationWeBuy.lastUsedASR;
                NSNumber *lastUsedCallAttempts = destinationWeBuy.lastUsedCallAttempts;
                NSDate *lastUsedDate = destinationWeBuy.lastUsedDate;
                NSNumber *lastUsedMinutesLenght = destinationWeBuy.lastUsedMinutesLenght;
                NSNumber *lastUsedProfit = destinationWeBuy.lastUsedProfit;
                NSString *prefix = destinationWeBuy.prefix;
                NSNumber *rate = destinationWeBuy.rate;
                NSString *specific = destinationWeBuy.specific;
                
                
                newOutpeerInRouting.lastUsedACD = lastUsedACD;
                newOutpeerInRouting.lastUsedASR = lastUsedASR;
                newOutpeerInRouting.lastUsedCallAttempts = lastUsedCallAttempts;
                newOutpeerInRouting.lastUsedDate = lastUsedDate;
                newOutpeerInRouting.lastUsedMinutesLenght = lastUsedMinutesLenght;
                newOutpeerInRouting.lastUsedProfit = lastUsedProfit;
                newOutpeerInRouting.prefix = prefix;
                newOutpeerInRouting.rate = rate;
                newOutpeerInRouting.specific = specific;
                newOutpeerInRouting.carrier = outCarrierName;
                newOutpeerInRouting.destinationsListForSale = destinationForSale;
                newOutpeerInRouting.destinationsListWeBuy = destinationWeBuy;
                
                NSLog(@"ROUTING: create succeseful \n for company %@\n country:%@\n specific:%@\n prefix %@\n have outgoing routing:%@\n with outgoing routing object\n",
                      carrierName,
                      countryStr,
                      specificStr,
                      outCarrierPrefixStr,
                      outCarrierName);
            }
        }
    }
}

- (void) testDestinations:(NSArray *)destinations;
{
    for (NSManagedObjectID *destinationID in destinations)
    {
//        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DestinationsListWeBuy" inManagedObjectContext:self.moc];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@", destination.GUID];
        DestinationsListWeBuy *destinationReceived = (DestinationsListWeBuy *)[self.moc objectWithID:destinationID];
        
        NSString *carrier = destinationReceived.carrier.name;
        NSString *rateSheetName = destinationReceived.rateSheet;
        
        // in CTP have to be same peer out names as rateSheetName
        NSNumber *peerId = [database getCTPpeerIdForCarrier:carrier andPeerName:rateSheetName];
        if (!peerId) { 
            destinationReceived.testingRestultInfo = @"peerId not found, please add";
            NSLog(@"TEST DESTINATION: peerId not found, please add"); 
            [self finalSave];

            return;
        }

        NSError *error = nil;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",destinationReceived.country,destinationReceived.specific];
        [fetchRequest setPredicate:predicate];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList"
                             inManagedObjectContext:self.moc];
        [fetchRequest setEntity:entity];
        NSArray *codesListFixed = [self.moc executeFetchRequest:fetchRequest error:&error];
        [fetchRequest release];

        NSArray *destinationNumbers = [database getCTPdestinationsNumberForPrefix:codesListFixed];
        
        if ([destinationNumbers count] == 0) { 
            //NSMutableArray *testingView = [NSMutableArray arrayWithObject:@"numbers not found, please add"];
            //destination.testingResult = testingView;
            destinationReceived.testingRestultInfo = @"numbers not found, please add";

            NSLog(@"TEST DESTINATION: numbers not found, please add"); 
            [self finalSave];

            return ;}
        
        NSString *destinationsNumbersFormed = [destinationNumbers componentsJoinedByString:@";"];
        DestinationsListWeBuyTesting *newTest = (DestinationsListWeBuyTesting *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListWeBuyTesting" inManagedObjectContext:self.moc]; 
        newTest.dstnums = destinationsNumbersFormed;
        newTest.peerId = peerId;
        newTest.destinationsListWeBuy = destinationReceived;
        newTest.date = [NSDate date];
        
        
        NSNumber *requestId = [database putCTPtestingTaskWithNumbers:destinationsNumbersFormed withCTPPeerId:[peerId stringValue]];
        if ([requestId intValue] == 0)  { NSLog(@"TEST DESTINATION:put for destination %@ was not success", destinationReceived); return; };
        newTest.iD = requestId;
        
//        NSMutableArray *testingView = [NSMutableArray arrayWithObject:@"Testing..."];
//        destination.testingResult = testingView;
        destinationReceived.testingRestultInfo = @"Testing...";
        [self finalSave];
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        [delegate.destinationsView localMocMustUpdate];

        BOOL success = NO;
            do {
                success = [database getCTPtestingCheckResultForRequestID:requestId];
                sleep (10);
                //NSLog(@"check success testing for %@/%@ for carrier:%@",destination.country,destination.specific,destination.carrier.name );
        } while (!success);
        
        NSArray *testingResults = [database getCTPtestingResultForRequestID:requestId];
        NSLog(@"Testing results:%@, database:%@",testingResults,database);
        
        //NSMutableArray *testingResultView = [NSMutableString string];
//        [testingView removeAllObjects];
//        [testingView addObject:[NSString stringWithFormat:@"Tested %@",[[NSDate date] description]]];
        
        int fas_calls = 0;
        int failed_calls = 0;
        int success_calls = 0;

        //NSMutableArray *testingMedia = [NSMutableArray arrayWithCapacity:0];

        for (NSDictionary *testingResult in testingResults)
        {
            
            // view issues 
//            [testingView addObject:@"----------------------------"];
            __block int ts_ok;
            __block int ts_release;
            __block NSString *number;
            __block NSString *cause;

            [testingResult enumerateKeysAndObjectsWithOptions:NSSortStable usingBlock:^(id key, id obj, BOOL *stop) {
                if ([key isEqualToString:@"ts_ok"]) { 
                    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
                    ts_ok = [[formatter numberFromString:obj] intValue];
                };

                if ([key isEqualToString:@"ts_release"]) { 
                    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
                    ts_release = [[formatter numberFromString:obj] intValue];
                };
                
                if ([key isEqualToString:@"dstnum"])  number = obj;
                if ([key isEqualToString:@"disconnect_cause"])  cause = obj;
            }];
            int duration = ts_release - ts_ok;
            if (ts_release == 0 || ts_ok == 0) duration = 0;
            /*double durationInMinutes = duration/60;

            NSString *finalDuration = nil;
            if (duration  != 0) {
                if (duration > 55) fas_calls++;
                NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
                NSNumber *durationNumber = [NSNumber numberWithDouble:durationInMinutes];
                [formatter setFormat:@"#,##0.00"];
                finalDuration = [formatter stringFromNumber:durationNumber];
            } else {
                finalDuration = @"0";
                failed_calls++;
            }*/
            if (duration == 0) failed_calls++;
            else {
                if (duration > 55) fas_calls++;
                else success_calls++;
            }
//            [testingView addObject:[NSString stringWithFormat:@"Call to +%@ duration %@sec disconnect cause is %@",number,[NSNumber numberWithInt:duration],cause]];
            // save issues
            DestinationsListWeBuyResults *newTestResult = (DestinationsListWeBuyResults *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListWeBuyResults" inManagedObjectContext:self.moc]; 
            newTestResult.call_id = [testingResult valueForKey:@"call_id"];
            newTestResult.disconnect_cause = [testingResult valueForKey:@"disconnect_cause"];
            newTestResult.dstnum = [testingResult valueForKey:@"dstnum"];
            //NSData *log = [testingResult valueForKey:@"log"];
            //NSString *logFinal = [[[NSString alloc] initWithData:log encoding:NSISOLatin1StringEncoding] autorelease];
            newTestResult.log = [testingResult valueForKey:@"log"];
            newTestResult.media_ogg = [testingResult valueForKey:@"media_ogg"];
            newTestResult.media_ogg_ring = [testingResult valueForKey:@"media_ogg_ring"];
            newTestResult.media_g729 = [testingResult valueForKey:@"media_g729"];
            newTestResult.media_g729_ring = [testingResult valueForKey:@"media_g729_ring"];
            
            NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
            newTestResult.iD = [formatter numberFromString:[testingResult valueForKey:@"id"]];
            newTestResult.outpack = [formatter numberFromString:[testingResult valueForKey:@"outpack"]];
            newTestResult.inpack = [formatter numberFromString:[testingResult valueForKey:@"inpack"]];
            newTestResult.srcnum = [formatter numberFromString:[testingResult valueForKey:@"srcnum"]];
            newTestResult.disconnect_code = [formatter numberFromString:[testingResult valueForKey:@"disconnect_code"]];
            newTestResult.ts_invite = [formatter numberFromString:[testingResult valueForKey:@"ts_invite"]];
            newTestResult.ts_ringing = [formatter numberFromString:[testingResult valueForKey:@"ts_ringing"]];
            newTestResult.ts_ok = [formatter numberFromString:[testingResult valueForKey:@"ts_ok"]];
            newTestResult.ts_trying = [formatter numberFromString:[testingResult valueForKey:@"ts_trying"]];
            newTestResult.ts_release = [formatter numberFromString:[testingResult valueForKey:@"ts_release"]];
            newTestResult.duration = [NSNumber numberWithDouble:duration];
            int tryingRinging = 0;
            int ts_ringing = [[formatter numberFromString:[testingResult valueForKey:@"ts_ringing"]] intValue];
            if (ts_ringing != 0) tryingRinging = ts_ringing - [[formatter numberFromString:[testingResult valueForKey:@"ts_trying"]] intValue];
            newTestResult.tryingRinging = [NSNumber numberWithInt:tryingRinging];

            int ringingOK = 0;
            if (ts_ok != 0) ringingOK = ts_ringing - [[formatter numberFromString:[testingResult valueForKey:@"ts_trying"]] intValue];
            newTestResult.ringingOK = [NSNumber numberWithInt:ringingOK];
            
            newTestResult.destinationsListWeBuyTesting = newTest;
        }

        NSString *finalTestingInfo = nil;
            
        if (success_calls > 0) {
            NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
            NSNumber *durationNumber = [NSNumber numberWithDouble:success_calls/(failed_calls + success_calls) * 100 ];
            [formatter setFormat:@"#,##0.00"];
            NSString *asr = [formatter stringFromNumber:durationNumber];
            //NSLog(@"success calls:%@ failed calls:%@",[NSNumber numberWithDouble:success_calls],[NSNumber numberWithDouble:failed_calls]);

            finalTestingInfo = [NSString stringWithFormat:@"OK:%@%% ASR",asr];
//            [testingView replaceObjectAtIndex:0 withObject:finalTestingInfo];
//            destinationReceived.testingRestultInfo = finalTestingInfo;
         }
        if (fas_calls > 0) { 
            finalTestingInfo = [NSString stringWithFormat:@"fail:%@%% FAS",[NSNumber numberWithDouble:([[NSNumber numberWithInt:fas_calls] doubleValue]/5 * 100)]];
            
//            [testingView replaceObjectAtIndex:0 withObject:finalTestingInfo];
//            destinationReceived.testingRestultInfo = finalTestingInfo;

        }
        if (success_calls == 0) { 
//            [testingView replaceObjectAtIndex:0 withObject:@"fail:0% ASR"];
            finalTestingInfo = @"fail:0% ASR";
        }
        //NSLog(@"final result:%@",finalTestingInfo);
        destinationReceived.testingRestultInfo = finalTestingInfo;

        //destinationReceived.testingResult = testingView;
//        [self performSelectorOnMainThread:@selector(finalSave) withObject:nil waitUntilDone:YES];
    }
    [self finalSave];

}

- (void) testResultMailToCustomer:(NSArray *)testsForSend;
{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
     
    for (DestinationsListWeBuyTesting *test in testsForSend)
    {
        NSMutableString *letterBody = [NSMutableString stringWithFormat:
        @"Dear %@ team.\nDuring the testing of your routes to %@ - %@ we have discovered problems,\nwhich prevents placing you in routing.\n\nTesting results:\n\n",test.destinationsListWeBuy.carrier.name,test.destinationsListWeBuy.country, test.destinationsListWeBuy.specific];
        NSMutableArray *filePaths = [NSMutableArray arrayWithCapacity:0];
        for (DestinationsListWeBuyResults *result in test.destinationsListWeBuyResults)
        {
            [letterBody appendFormat:@"B-Number:+%@\n",result.dstnum];
            [letterBody appendFormat:@"Prefix:%@\n",result.destinationsListWeBuyTesting.destinationsListWeBuy.prefix];
            [letterBody appendFormat:@"Destination:%@\n",result.destinationsListWeBuyTesting.destinationsListWeBuy.rateSheet];
            [letterBody appendFormat:@"A-number:+%@\n",result.srcnum];
            [letterBody appendFormat:@"SetupTime:%@\n",[NSDate dateWithTimeIntervalSince1970:[result.ts_ok intValue]]];
            [letterBody appendFormat:@"Duration:%@ min\n",result.duration];
            [letterBody appendFormat:@"Disconnect cause:%@ (code:%@)\n",result.disconnect_cause,result.disconnect_code];
            [letterBody appendFormat:@"In/Out: %@/%@ packets\n ",result.inpack,result.outpack];
            
            NSString *fileName = [NSString stringWithFormat:@"%@/VoiceFiles/%@_voice_%@.ogg",[delegate applicationFilesDirectory],result.dstnum,[NSDate dateWithTimeIntervalSince1970:[result.ts_ok intValue]]];
            [result.media_ogg writeToFile:fileName atomically:YES];
            [filePaths addObject:fileName];
            //fileName = [NSString stringWithFormat:@"%@/%@_ring_%@.ogg",[appDelegate applicationSupportDirectory],result.dstnum,[NSDate dateWithTimeIntervalSince1970:[result.ts_ok intValue]]];
            //[result.media_ogg_ring writeToFile:fileName atomically:YES];
            //[filePaths addObject:fileName];
            [letterBody appendFormat:@"\n\n"];

        }
        [letterBody appendFormat:@"Audio records of RTP incoming media streams could be attached to this letter.\n(You may get notes on playing OGG audio files from http://www.vorbis.com)\n\nPlease, kindly notify us as soon as possible when the problem will be solved!\n\n--------\nKind regards,\n\nTechnical Team\nIXC Global Inc.\n801 Brickell Avenue, Suite 900, Miami, FL 33131\ntel: +1305-789-6636\nfax: +1305-789-6636 \nemail: noc@ixc-usa.com\n"];

        NSString *emailList = test.destinationsListWeBuy.carrier.emailList;
        NSString *emailFrom = test.destinationsListWeBuy.carrier.companyStuff.currentCompany.ratesEmail;
        
        [self sendEmailMessageTo:emailList 
                     withSubject:@"Testing results from IXC Global Inc." 
                     withContent:letterBody 
                        withFrom:emailFrom 
                   withFilePaths:[NSArray arrayWithArray:filePaths]];
    }
}

- (NSString *) testResultWriteLogToFile:(DestinationsListWeBuyResults *)result;
{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    NSError *error = nil;
    NSString *log = result.log;
    NSString *path = [NSString stringWithFormat:@"%@/VoiceFiles/%@_log_%@.txt",[delegate applicationFilesDirectory],result.dstnum,[NSDate date]];
    [log writeToFile:path atomically:YES encoding:NSUTF16StringEncoding error:&error];    
    if (error) NSLog(@"TEST: write to file log's is wrong with error:%@",[error localizedDescription]);
    else return path;
    return nil;
}

- (NSDictionary *) testResultWriteMediaToFile:(DestinationsListWeBuyResults *)result;
{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    NSData *media = result.media_ogg;
    NSData *mediaRing = result.media_ogg_ring;
    NSMutableDictionary *paths = [NSMutableDictionary dictionaryWithCapacity:0];

    NSString *fileName = [NSString stringWithFormat:@"%@/VoiceFiles/%@_voice_%@.ogg",[delegate applicationFilesDirectory],result.dstnum,[NSDate date]];
    if (![media writeToFile:fileName atomically:YES]) NSLog(@"TEST: write to file media is wrong");
    [paths setValue:fileName forKey:@"media_ogg"];
    fileName = [NSString stringWithFormat:@"%@/VoiceFiles/%@_ring_%@.ogg",[delegate applicationFilesDirectory],result.dstnum,[NSDate date]];
    if (![mediaRing writeToFile:fileName atomically:YES]) NSLog(@"TEST: write to file media ring is wrong");
    [paths setValue:fileName forKey:@"media_ogg_ring"];
    return [NSDictionary dictionaryWithDictionary:paths];
}

#pragma mark -
#pragma mark CARRIER methods

- (void)updateCarrierContactforCarrier:(Carrier *)carrier;
{
    NSDate *currentDate = [NSDate date];
    carrier.latestUpdateTime = currentDate;
    
    //NSLog(@"current Stuff:%@",[carrier valueForKey:@"carrierStuff"]);
    // we don't need any updates if we already have someone.
    NSSet *carrierStuffold = carrier.carrierStuff;
    
    if ([carrierStuffold count] != 0) { 
        NSSet *carrierStuff = carrier.carrierStuff;
        [carrierStuff enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, BOOL *stop) {
            [self.moc deleteObject:obj];
        }];
    }
    NSArray *carrierStuff = [database carrierStuff:carrier.name];  
    NSDictionary *stuffListNoMutable = [carrierStuff lastObject];
    NSMutableDictionary *stuffList = [NSMutableDictionary dictionaryWithDictionary:stuffListNoMutable];
    if (![[stuffList valueForKey:@"admname"] isEqualToString:@""]) [stuffList setValue:@"undefined" forKey:@"admname"];
    if (![[stuffList valueForKey:@"techname"] isEqualToString:@""]) [stuffList setValue:@"undefined" forKey:@"techname"];
    
    CarrierStuff *stuffAdmin = [NSEntityDescription 
                                   insertNewObjectForEntityForName:@"CarrierStuff" 
                                   inManagedObjectContext:self.moc];
    NSString *admname = [stuffList valueForKey:@"admname"];
    NSString *admemail = [stuffList valueForKey:@"admemail"];
    stuffAdmin.lastName = admname;
    stuffAdmin.emailList = admemail;

    carrier.ratesEmail = admemail;
    stuffAdmin.carrier = carrier;
}

- (void) updateResponsibleContactforCarrier:(Carrier *)carrier forCurrentCompany:(CurrentCompany *)currentCompany;
{
    carrier.latestUpdateTime = [NSDate date];
    CompanyStuff *currentStuff = carrier.companyStuff;
    if (!currentStuff) {
        CompanyStuff *authorizedUser = nil;
#if defined (SNOW_SERVER)
        NSString *selectedCompanyStuffEmail = delegate.getExternalInfoView.userToSync.selectedItem.title;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email contains [cd] %@",selectedCompanyStuffEmail];
        NSSet *allCompanyStuff = currentCompany.companyStuff;
        NSSet *filteredCompanyStuff = [allCompanyStuff filteredSetUsingPredicate:predicate];
        authorizedUser = filteredCompanyStuff.anyObject;
#else 

        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        CompanyStuff *authorizedUserFromClientMoc = [clientController authorization];
        [clientController release];
        authorizedUser = (CompanyStuff *)[self.moc objectWithID:authorizedUserFromClientMoc.objectID];
        
#endif
        if (!authorizedUser) {
            NSLog(@"UPDATE DATA CONTROLLER: warning, company stuff not found for company:%@",currentCompany);
        }
        carrier.companyStuff = authorizedUser;

    }
}

-(void) updateCarriersFinancialRatingAndLastUpdatedTimeForCarrierGUID:(NSManagedObjectID *)carrierID withTotalProfit:(NSNumber *)totalProfitNumber;
{
    Carrier *necessaryCarrier = (Carrier *)[self.moc objectWithID:carrierID];

    NSError *error = nil; 
    double financialRate = 0;

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DestinationsListForSale"
                                   inManagedObjectContext:moc]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"carrier == %@",necessaryCarrier]];
    NSArray *destinationsForLocalCarrier = [moc executeFetchRequest:request error:&error];
    [request release], request = nil;

    if (destinationsForLocalCarrier.count > 0) {
        if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
        NSNumber *carrierProfitNumber = [destinationsForLocalCarrier valueForKeyPath:@"@sum.lastUsedProfit"];
        
        if ([carrierProfitNumber doubleValue] == 0) financialRate = 0;
        else financialRate = carrierProfitNumber.doubleValue / totalProfitNumber.doubleValue;
//        [request setEntity:[NSEntityDescription entityForName:@"Carrier"
//                                       inManagedObjectContext:moc]];
//        [request setPredicate:[NSPredicate predicateWithFormat:@"GUID == %@",carrierGUID]];
//        NSArray *carriersArray = [delegate.managedObjectContext executeFetchRequest:request error:&error];
//        if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
//        Carrier *carrier = [carriersArray lastObject];
        NSNumber *financialRateNumber = [NSNumber numberWithDouble:financialRate];
        necessaryCarrier.financialRate = financialRateNumber;
        
        NSDate *currentDate = [NSDate date];
        necessaryCarrier.latestUpdateTime = currentDate;
//        financialRateNumber = nil;
//        
//        destinationsForLocalCarrier = nil;
//        
//        totalProfitNumber = nil;
//        carrierProfitNumber = nil;
        [self finalSave];
        NSLog(@"Financial Rate: %f for carrier:%@ with carrier profit:%@ for total profit:%@ is:%@",financialRate,necessaryCarrier.name,carrierProfitNumber,totalProfitNumber,necessaryCarrier.financialRate);
    } else {
        
        NSDate *currentDate = [NSDate date];
        necessaryCarrier.latestUpdateTime = currentDate;
        [self finalSave];

//        [request setEntity:[NSEntityDescription entityForName:@"Carrier"
//                                       inManagedObjectContext:delegate.managedObjectContext]];
//        [request setPredicate:[NSPredicate predicateWithFormat:@"GUID == %@",carrierGUID]];
//        NSArray *carriersArray = [delegate.managedObjectContext executeFetchRequest:request error:&error];
//        if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
//        Carrier *carrier = [carriersArray lastObject];
//        [request release], request = nil;
        NSLog(@"Financial Rate:0 for carrier:%@ for totalProfit:%@ ",necessaryCarrier.name,totalProfitNumber);
    }
}
-(void) carriersListWithProgress:(ProgressUpdateController *)progress 
               forCurrentCompany:(NSManagedObjectID *)currentCompanyID 
forIsUpdateCarriesListOnExternalServer:(BOOL)isUpdateCarriesListOnExternalServer
{
    CurrentCompany *currentCompany = (CurrentCompany *)[moc objectWithID:currentCompanyID];

    NSArray *companyListArrays = [database carriersList];

    NSError *error = nil;
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];

    [request setEntity:[NSEntityDescription entityForName:@"Carrier"
                                   inManagedObjectContext:self.moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"companyStuff.currentCompany.GUID == %@",currentCompany.GUID]];
    
    NSArray *currentCarriersList = [self.moc executeFetchRequest:request error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
    
    NSMutableArray *companyListForRemove = [NSMutableArray array];     
    
    for (Carrier *carrier in currentCarriersList)  {
        NSString *carrierNameInternal = carrier.name;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@",carrierNameInternal];
        NSArray *currentCarriersListFiltered = [companyListArrays filteredArrayUsingPredicate:predicate];
        if ([currentCarriersListFiltered count] > 0) [companyListForRemove addObject:carrierNameInternal]; 
    }        
    
    NSMutableArray *companyListForAdd  = [NSMutableArray arrayWithArray:companyListArrays];
    [companyListForAdd removeObjectsInArray:companyListForRemove];
    NSLog(@"UPDATE DATA CONTROLLER:companyListForAdd:%@",companyListForAdd);
    
    [progress updateProgressIndicatorMessageGetExternalData:@"Update carriers list"];
    progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[companyListForAdd count]];
    progress.countObjects = 0;
    for (NSString *carrierName in companyListForAdd)
    {
        
        Carrier *carrier = [NSEntityDescription 
                            insertNewObjectForEntityForName:@"Carrier" 
                            inManagedObjectContext:self.moc];
        carrier.name = carrierName;
        [self updateResponsibleContactforCarrier:carrier forCurrentCompany:currentCompany];
        [self updateCarrierContactforCarrier:carrier];
        Financial *financial = (Financial *)[NSEntityDescription insertNewObjectForEntityForName:@"Financial" inManagedObjectContext:self.moc];
        financial.carrier = carrier;
        financial.name = [NSString stringWithFormat:@"%@'s account",carrierName];
        
        [progress updateProgressIndicatorCountGetExternalData];
        if ([self finalSave]) {
            if (isUpdateCarriesListOnExternalServer) {
                sleep(4);
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                    
                    //                AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                    [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[carrier objectID]] mustBeApproved:NO];
                    [clientController release];
                });
            }
        }
        
        
    }
    //[progress updateProgressIndicatorMessageGetExternalData:@"Update company accounts"];
    
    [self updateCompanyAccountsWithProgress:progress];
    [progress updateProgressIndicatorMessageGetExternalData:@""];
    [progress stopGetCarriersList];
    
    [self finalSave];

}

- (void) carriersListWithProgress:(ProgressUpdateController *)progress;
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [progress startGetCarriersList];
    [progress updateProgressIndicatorMessageGetExternalData:@"Get carriers list"];

//    NSArray *companyListArrays = [database carriersList];
//    NSError *error = nil;
//    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *authorizedUser = [clientController authorization];
    [clientController release];

    CurrentCompany *companyOfAuthorizedStuff = authorizedUser.currentCompany;
    [self carriersListWithProgress:progress 
                 forCurrentCompany:companyOfAuthorizedStuff.objectID 
forIsUpdateCarriesListOnExternalServer:YES];

//    [request setEntity:[NSEntityDescription entityForName:@"Carrier"
//                                   inManagedObjectContext:self.moc]];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"companyStuff.currentCompany.GUID == %@",companyOfAuthorizedStuff.GUID]];
//
//    NSArray *currentCarriersList = [self.moc executeFetchRequest:request error:&error];
//    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
//    
//    NSMutableArray *companyListForRemove = [NSMutableArray array];     
//    
//    for (Carrier *carrier in currentCarriersList)  {
//        NSString *carrierNameInternal = carrier.name;
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains [cd] %@",carrierNameInternal];
//        NSArray *currentCarriersListFiltered = [companyListArrays filteredArrayUsingPredicate:predicate];
//        if ([currentCarriersListFiltered count] > 0) [companyListForRemove addObject:carrierNameInternal]; 
//        //if ([companyListArrays containsObject:carrierNameInternal]) [companyListForRemove addObject:carrierNameInternal];
////        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
////            
////            AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
////            ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
////            [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[carrier objectID]] mustBeApproved:NO];
////            [clientController release];
////        });
//
//    }        
//    
//    NSMutableArray *companyListForAdd  = [NSMutableArray arrayWithArray:companyListArrays];
//    [companyListForAdd removeObjectsInArray:companyListForRemove];
//    NSLog(@"UPDATE DATA CONTROLLER:companyListForAdd:%@",companyListForAdd);
//    
//    [progress updateProgressIndicatorMessageGetExternalData:@"Update carriers list"];
//    progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[companyListForAdd count]];
//    progress.countObjects = 0;
//    for (NSString *carrierName in companyListForAdd)
//    {
//
//        Carrier *carrier = [NSEntityDescription 
//                                   insertNewObjectForEntityForName:@"Carrier" 
//                                   inManagedObjectContext:self.moc];
//        carrier.name = carrierName;
//        
//        [self updateResponsibleContactforCarrier:carrier];
//        [self updateCarrierContactforCarrier:carrier];
//        Financial *financial = (Financial *)[NSEntityDescription insertNewObjectForEntityForName:@"Financial" inManagedObjectContext:self.moc];
//        financial.carrier = carrier;
//        financial.name = [NSString stringWithFormat:@"%@'s account",carrierName];
//        
//        [progress updateProgressIndicatorCountGetExternalData];
//        if ([self finalSave]) {
//            sleep(4);
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
//                
////                AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//                ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
//                [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:[carrier objectID]] mustBeApproved:NO];
//                [clientController release];
//            });
//        }
//
//        
//    }
//    //[progress updateProgressIndicatorMessageGetExternalData:@"Update company accounts"];
//
//    [self updateCompanyAccountsWithProgress:progress];
//    [progress updateProgressIndicatorMessageGetExternalData:@""];
//    [progress stopGetCarriersList];
//
//    [self finalSave];
    //[pool drain];
}

- (void) removeFromMainDatabaseCarrier:(NSString *)carrierName;
{
    NSError *error = nil;
    NSFetchRequest *requestCarrier = [[NSFetchRequest alloc] init];
    [requestCarrier setEntity:[NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:moc]];
    [requestCarrier setPredicate:[NSPredicate predicateWithFormat:@"(name == %@)", carrierName]];
    [requestCarrier setResultType:NSManagedObjectIDResultType];
    NSArray *carriers = [moc executeFetchRequest:requestCarrier error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));   
    
    NSManagedObjectID *carrier = [carriers lastObject]; 
    [moc deleteObject:[moc objectWithID:carrier]];
    [requestCarrier release], requestCarrier = nil;
    return;
}

- (void) removeFromMainDatabaseDestinationsForCarrier:(NSString *)carrierName 
                                       withEntityName:(NSString *)entityName;
{
    NSError *error = nil;
    NSFetchRequest *requestDestinations = [[NSFetchRequest alloc] init];
    [requestDestinations setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [requestDestinations setPredicate:[NSPredicate predicateWithFormat:@"(carrier.name == %@)", carrierName]];
    [requestDestinations setResultType:NSManagedObjectIDResultType];
    NSArray *destinations = [moc executeFetchRequest:requestDestinations error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
    
    for (NSManagedObjectID *destination in destinations) [moc deleteObject:[moc objectWithID:destination]];
    [requestDestinations release], requestDestinations = nil;destinations = nil;
    return;
}

#pragma TODO here is remove stat for any destinations - we buy and for sell. better solution is separate

- (void) removeFromMainDatabaseDestinations24hStatisticForCarrier:(NSString *)carrierName 
                                                   withEntityName:(NSString *)entityName;
{
    NSError *error = nil;
    NSFetchRequest *requestDestinations = [[NSFetchRequest alloc] init];
    [requestDestinations setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:moc]];
    [requestDestinations setPredicate:[NSPredicate predicateWithFormat:@"(carrier.name == %@)", carrierName]];
    [requestDestinations setResultType:NSManagedObjectIDResultType];
    NSArray *destinations = [moc executeFetchRequest:requestDestinations error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
    
    for (NSManagedObjectID *destination in destinations)
    {
        NSManagedObject *dest = [moc objectWithID:destination];
        [dest setValue:nil forKey:@"lastUsedACD"];
        [dest setValue:nil forKey:@"lastUsedASR"];
        [dest setValue:nil forKey:@"lastUsedCallAttempts"];
        [dest setValue:nil forKey:@"lastUsedDate"];
        [dest setValue:nil forKey:@"lastUsedMinutesLenght"];
        [dest setValue:nil forKey:@"lastUsedProfit"];
    }
    [requestDestinations release], requestDestinations = nil;
    return;
}

- (void) removeFromMainDatabaseDestinations3monthStatisticForCarrier:(NSString *)carrierName 
                                               withRelationShipsName:(NSString *)relationShipsName;
{
    NSError *error = nil;
    NSFetchRequest *requestThreMonthStat = [[NSFetchRequest alloc] init];
    [requestThreMonthStat setEntity:[NSEntityDescription entityForName:@"DestinationPerHourStat" inManagedObjectContext:moc]];
    [requestThreMonthStat setPredicate:[NSPredicate predicateWithFormat:@"(%K.carrier.name == %@)",relationShipsName, carrierName]];
    [requestThreMonthStat setResultType:NSManagedObjectIDResultType];
    NSArray *threeMonthstat = [moc executeFetchRequest:requestThreMonthStat error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));  
    
    for (NSManagedObjectID *stat in threeMonthstat) [moc deleteObject:[moc objectWithID:stat]];
    [requestThreMonthStat release], requestThreMonthStat = nil;
    return;
}

- (NSArray *)getRateSheetsAndPrefixListToChoiceByUserForCarrierID:(NSManagedObjectID *)carrierID withRelationShipName:(NSString *)relationShipName;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSMutableArray *rateSheetsAndPrefixes = [[NSMutableArray alloc] init];
    NSFetchRequest *requestDestinationsForSale = [[NSFetchRequest alloc] init];
 
    Carrier *necessaryCarrier = (Carrier *)[self.moc objectWithID:carrierID];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(carrier.GUID == %@)",necessaryCarrier.GUID];

    //NSManagedObjectContext *moc = self.managedObjectContext;
    if ([relationShipName isEqualToString:@"destinationsListForSale"]) {
        [requestDestinationsForSale setEntity:[NSEntityDescription entityForName:@"DestinationsListForSale"
                                                          inManagedObjectContext:self.moc]];
    }
    if ([relationShipName isEqualToString:@"destinationsListWeBuy"]) {
        [requestDestinationsForSale setEntity:[NSEntityDescription entityForName:@"DestinationsListWeBuy"
                                                          inManagedObjectContext:self.moc]];
    }
    if ([relationShipName isEqualToString:@"destinationsListPushList"] || [relationShipName isEqualToString:@"destinationsListTargets"]) {
        [rateSheetsAndPrefixes release];
        
        [requestDestinationsForSale release],requestDestinationsForSale = nil;

        return nil;
    }

    [requestDestinationsForSale setPredicate:predicate];    
    NSError *error = nil; 
    NSArray *destinations = [moc executeFetchRequest:requestDestinationsForSale error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));     
    
    NSArray *rateSheetIDsMutable = [destinations valueForKeyPath:@"@distinctUnionOfObjects.rateSheetID"];
    if (rateSheetIDsMutable.count == 0) {
        NSManagedObject *lastDestination = destinations.lastObject;
        CodesvsDestinationsList *anyCode = [[lastDestination valueForKey:@"codesvsDestinationsList"] anyObject];
        if (anyCode && anyCode.rateSheetID) rateSheetIDsMutable = [NSArray arrayWithObject:anyCode.rateSheetID];
    }
    
    NSArray *prefixesMutable = [destinations valueForKeyPath:@"@distinctUnionOfObjects.prefix"];
    //NSLog(@"rateSheetIDsMutable:%@/nprefixesMutable:%@",rateSheetIDsMutable,prefixesMutable);

    if ([rateSheetIDsMutable count] > 0) {
        for (NSString *rateSheetID in rateSheetIDsMutable) {
            for (NSString *prefix in prefixesMutable) {
                NSPredicate *rateSheetLook = [NSPredicate predicateWithFormat:@"(rateSheetID == %@) AND (prefix == %@)",rateSheetID,prefix];
                NSSet *allCodes = [[destinations lastObject] valueForKey:@"codesvsDestinationsList"];
                NSSet *codes = [allCodes filteredSetUsingPredicate:rateSheetLook];
                //NSLog(@"Code:%@\n",code);
                
                if ([codes count] != 0) {
                    
                    CodesvsDestinationsList *codeObject = [codes anyObject];
                    NSString *rateSheetName = codeObject.rateSheetName;
                    NSDictionary *mix = [NSDictionary dictionaryWithObjectsAndKeys:prefix,@"prefix",rateSheetID,@"rateSheetID", rateSheetName,@"rateSheetName",nil];
                    //NSLog(@"object%@",mix);
                    
                    [rateSheetsAndPrefixes addObject:mix];
                    // NSLog(@"Add object%@",rateSheetsAndPrefixes);
                    
                }
            }
        }   
    } else {
        for (NSString *prefix in prefixesMutable) {
            NSPredicate *rateSheetLook = [NSPredicate predicateWithFormat:@"(prefix == %@)",prefix];
            NSSet *allCodes = [[destinations lastObject] valueForKey:@"codesvsDestinationsList"];
            NSSet *codes = [allCodes filteredSetUsingPredicate:rateSheetLook];
            //NSLog(@"Code:%@\n",code);
            
            if ([codes count] != 0) {
                
                CodesvsDestinationsList *codeObject = [codes anyObject];
                NSString *rateSheetName = codeObject.rateSheetName;
                NSDictionary *mix = [NSDictionary dictionaryWithObjectsAndKeys:prefix,@"prefix", rateSheetName,@"rateSheetName",nil];
                //NSLog(@"object%@",mix);
                
                [rateSheetsAndPrefixes addObject:mix];
                // NSLog(@"Add object%@",rateSheetsAndPrefixes);
                
            }
        }

    }
    
    //NSLog(@"%@",rateSheetsAndPrefixes);
    [pool drain], pool = nil;

    [requestDestinationsForSale release],requestDestinationsForSale = nil;
    NSArray *result = [NSArray arrayWithArray:rateSheetsAndPrefixes];
    [rateSheetsAndPrefixes release];

    return result;
}

-(void) addCarrierWithGUID:(NSManagedObjectID *)carrierID 
                  withName:(NSString *)carrierName 
                   toArray:(NSMutableArray *)array 
      withRelationShipName:(NSString *)relationShipName 
                isSelected:(BOOL)isSelected;
{
    Carrier *necessaryCarrier = (Carrier *)[self.moc objectWithID:carrierID];
    
    NSMutableDictionary *entry = [NSMutableDictionary dictionary];
    [entry setValue:[NSNumber numberWithBool:isSelected] forKey:@"selected"];
    [entry setValue:carrierName forKey:@"name"];
    [entry setValue:necessaryCarrier.GUID forKey:@"GUID"];
    [entry setValue:necessaryCarrier.objectID forKey:@"objectID"];
    
    NSArray *rateSheetsAndPrefixes = [self getRateSheetsAndPrefixListToChoiceByUserForCarrierID:carrierID withRelationShipName:relationShipName];
    // format :                NSDictionary *mix = [NSDictionary dictionaryWithObjectsAndKeys:prefix,@"prefix",rateSheetID,@"rateSheetID", rateSheetName,@"rateSheetName",nil];
    // [rateSheetsAndPrefixes addObject:mix];
    if ([rateSheetsAndPrefixes count] == 0) {
        rateSheetsAndPrefixes = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"prefix",@"",@"rateSheetID", @"",@"rateSheetName",nil]];
    }
    
    NSMutableArray *rateSheetsAndPrefixesTogether = [NSMutableArray arrayWithCapacity:0];
    [rateSheetsAndPrefixes enumerateObjectsUsingBlock:^(NSDictionary *rateSheetAndPrefix, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *rateSheetAndPrefixMut = [NSMutableDictionary dictionaryWithDictionary:rateSheetAndPrefix];
        if (idx == 0) [rateSheetAndPrefixMut setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
        else [rateSheetAndPrefixMut setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
        [rateSheetsAndPrefixesTogether addObject:rateSheetAndPrefixMut];
    }];
    
//    for (NSDictionary *rateSheetAndPrefix in rateSheetsAndPrefixes)
//    {
//        NSMutableDictionary *rateSheetAndPrefixMut = [NSMutableDictionary dictionaryWithDictionary:rateSheetAndPrefix];
//        [rateSheetAndPrefixMut setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
//        [rateSheetsAndPrefixesTogether addObject:rateSheetAndPrefixMut];
//    }
    [entry setValue:rateSheetsAndPrefixesTogether forKey:@"rateSheetsAndPrefixes"];
    [array addObject:entry];

}

- (NSArray *)fillCarriersForAddArrayForCarriers:(NSArray *)carriers 
                           withRelationShipName:(NSString *)relationShipName 
                              forCurrentContent:(NSArray *)currentContent;
{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    NSArray *currentContent = [delegate.carriersForAddNewDestinationsController arrangedObjects];
    
//    NSString *pathFileToSave = [[delegate applicationSupportDirectory] stringByAppendingString:@"/carrierListForAddDestination.ary"];
//    if ([currentContent count] == 0) {
//        currentContent = [NSArray arrayWithContentsOfFile:pathFileToSave];
//        NSLog(@"UPDATE DATA CONTROLLER:carriers list was restored from file.");
//    } else NSLog(@"UPDATE DATA CONTROLLER:carriers list was created from egg.");

    __block NSMutableArray *carriersForAddNewDestinations = [NSMutableArray array];
    NSMutableArray *carriersForSelectGUIDs = [NSMutableArray arrayWithCapacity:0];
    
    for (Carrier *carrier in carriers)
    {
        [carriersForSelectGUIDs addObject:carrier.GUID];
    }
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *admin = [clientController authorization];
//    CurrentCompany *mainCompany = admin.currentCompany;

    [clientController release];

    
//    NSError *error = nil;
//    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc];
//    [request setEntity:entity];
////    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyStuff.currentCompany.GUID == %@",mainCompany.GUID];
////    [request setPredicate:predicate];
//    NSArray *allCarriers = [self.moc executeFetchRequest:request error:&error];
    
//    NSMutableArray *allCarriersMutable = [NSMutableArray arrayWithArray:allCarriers];
//    
//    [currentContent enumerateObjectsUsingBlock:^(NSDictionary *currentCarrierFromList, NSUInteger idx, BOOL *stop) {
//        NSString *carrierFromListGUID = [currentCarrierFromList valueForKey:@"GUID"];
//        NSPredicate *predicateReverce = [NSPredicate predicateWithFormat:@"GUID != %@",carrierFromListGUID];
//        [allCarriersMutable filterUsingPredicate:predicateReverce];
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",carrierFromListGUID];
//        NSArray *filteredCarriersForSelect = [carriersForSelectGUIDs filteredArrayUsingPredicate:predicate];
//        if ([filteredCarriersForSelect count] == 0) [currentCarrierFromList setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
//        else [currentCarrierFromList setValue:[NSNumber numberWithBool:YES] forKey:@"selected"];
//    }];
    
//    CompanyStuff *admin = (CompanyStuff *)[moc objectWithID:autorizedUserID];
    NSSet *allCompanyStuff = admin.currentCompany.companyStuff;
    
    [allCompanyStuff enumerateObjectsUsingBlock:^(CompanyStuff *obj, BOOL *stop) {
        NSSet *allCarriersOfStuff = obj.carrier;
        [allCarriersOfStuff enumerateObjectsUsingBlock:^(Carrier *carrier, BOOL *stop) {
            
#if defined(SNOW_CLIENT_APPSTORE)
            NSString *carrierAdminGUID = carrier.companyStuff.GUID;
            NSString *adminGUID = admin.GUID;
            //NSLog(@"2 carrier name: %@ guid:%@",carrier.name,carrier.GUID);
            
            if ([carrierAdminGUID isEqualToString:adminGUID]) {
#endif
                NSString *carrierFromListGUID = [carrier valueForKey:@"GUID"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",carrierFromListGUID];
                BOOL isSelected = NO;
                if ([[carriersForSelectGUIDs filteredArrayUsingPredicate:predicate] count] > 0) isSelected = YES;
                [self addCarrierWithGUID:carrier.objectID withName:[carrier valueForKey:@"name"] toArray:carriersForAddNewDestinations withRelationShipName:relationShipName isSelected:isSelected];
#if defined(SNOW_CLIENT_APPSTORE)
                
            }
#endif
        }];
        //NSLog(@"carrier name: %@ guid:%@",obj.name,obj.GUID);
    }];
    
//    [allCarriers enumerateObjectsUsingBlock:^(Carrier *carrier, NSUInteger idx, BOOL *stop) {
//#if defined(SNOW_CLIENT_APPSTORE)
//        CompanyStuff *adminCarrier = carrier.companyStuff;
//
//        NSString *carrierAdminGUID = adminCarrier.GUID;
//        NSString *adminGUID = admin.GUID;
//        NSLog(@"2 carrier name: %@ guid:%@",carrier.name,carrier.GUID);
//
//        if ([carrierAdminGUID isEqualToString:adminGUID]) {
//#endif
//            NSString *carrierFromListGUID = [carrier valueForKey:@"GUID"];
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF == %@",carrierFromListGUID];
//            BOOL isSelected = NO;
//            if ([[carriersForSelectGUIDs filteredArrayUsingPredicate:predicate] count] > 0) isSelected = YES;
//            [self addCarrierWithGUID:carrierFromListGUID withName:[carrier valueForKey:@"name"] toArray:carriersForAddNewDestinations withRelationShipName:relationShipName isSelected:isSelected];
//#if defined(SNOW_CLIENT_APPSTORE)
//
//        }
//#endif
//    }];
//    [carriersForAddNewDestinations addObjectsFromArray:currentContent];

//    NSSet *allAdminCarriers = admin.carrier;
//    
//    [allAdminCarriers enumerateObjectsUsingBlock:^(Carrier *carrier, BOOL *stop) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"GUID == %@",carrier.GUID];
//        if ([[carriersForAddNewDestinations filteredArrayUsingPredicate:predicate] count] == 0) [self addCarrierWithGUID:carrier.GUID withName:[carrier valueForKey:@"name"] toArray:carriersForAddNewDestinations withRelationShipName:relationShipName isSelected:NO];
//
//    }];
    
//    [carriersForAddNewDestinations writeToFile:pathFileToSave atomically:YES];
    
    //NSLog(@"Write to file:%@",success ? @"YES" : @"NO");
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"selected" ascending:NO];
    

//    [delegate.carriersForAddNewDestinationsController setContent:[carriersForAddNewDestinations sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    NSArray *finalResult = [carriersForAddNewDestinations sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    
    return finalResult;
    
}


- (void) startUserChoiceSyncForCarriers:(NSArray *)carriersToExecute 
                           withProgress:(ProgressUpdateController *)progress 
                      withOperationName:(NSString *)operationName;
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    [progress startSync];
    NSError *error = nil;
    //NSNumber *index = nil;
    progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[carriersToExecute count]];
    [progress updateSystemMessage:[NSString stringWithFormat:@"Sync was started:%@ for number %@ carriers.",[NSDate date],[NSNumber numberWithUnsignedInteger:[carriersToExecute count]]]];
    [progress updateProgressIndicatorMessageGetExternalData:@"Update carriers"];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DestinationsListForSale"
                                   inManagedObjectContext:self.moc]];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *stuff = [clientController authorization];
    [clientController release];

//    CompanyStuff *stuff = (CompanyStuff *)[self.moc objectWithID:self.autorizedUserID];
    
    NSPredicate *predicateLastUsedProfit = [NSPredicate predicateWithFormat:@"(lastUsedProfit > 0) AND (carrier.companyStuff.currentCompany.GUID == %@)",stuff.currentCompany.GUID];
    //[request setPredicate:predicateLastUsedProfit];
    
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
    
    NSNumber *totalProfitNumber = [[NSNumber alloc] initWithDouble:[totalProfitNumberForUsing doubleValue]];
    //NSNumber *totalProfitNumber = [NSNumber numberWithDouble:[totalProfitNumberForUsing doubleValue]];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormat:@"#%"];
    
    [delegate.totalProfit setTitle:[NSString stringWithFormat:@"Total income:$%@/profit:$%@ (%@%)",totalIncomeNumberForUsing,totalProfitNumberForUsing,[formatter stringFromNumber:[NSNumber numberWithDouble:[totalProfitNumberForUsing doubleValue]/[totalIncomeNumberForUsing doubleValue]]]]];
    [formatter release];
    [request release];
    NSLog(@"Total profit (24h) is:%@ total income is:%@",totalProfitNumberForUsing,totalIncomeNumberForUsing);
    //[totalProfitNumber release];

    //[pool drain],pool = nil;
    progress.objectsCount = [NSNumber numberWithInt:0];
    progress.percentDone = [NSNumber numberWithInt:0];
    progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[carriersToExecute count]];
  
    

//    dispatch_group_t group = dispatch_group_create();
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    //NSUInteger processorCount = [[NSProcessInfo processInfo] processorCount];
    NSUInteger activeProcessorCount = [[NSProcessInfo processInfo] activeProcessorCount];
    
    //    dispatch_semaphore_t semaphore = dispatch_semaphore_create(activeProcessorCount);
    __block NSUInteger correntProcessNumber = 0;

    for (NSManagedObjectID *carrierID in carriersToExecute) {
        //        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        if (delegate.cancelAllOperations) break;
        NSUInteger idx = 0;
        while (correntProcessNumber > activeProcessorCount) {
            NSLog(@"UPDATE DATA CONTROLLER: waiting for empty processes");
            sleep(3);
        }
        correntProcessNumber++;
        [progress updateProgressIndicatorCountGetExternalData];
        
        //[carriersToExecute enumerateObjectsUsingBlock:^(NSManagedObjectID *carrierID, NSUInteger idx, BOOL *stop) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
            
            
            
            //        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            //        
            //        dispatch_group_async(group, queue, ^{
            //            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
            NSNumber *totalProfit = [[NSNumber alloc] initWithDouble:[totalProfitNumber doubleValue]];
            NSNumber *idxNumber = [[NSNumber alloc] initWithUnsignedInteger:idx];
            
            //            GetExternalInfo *operation = [[GetExternalInfo alloc] initAndUpdateCarrier:carrierID 
            //                                                                            identifier:idxNumber 
            //                                                                             withIndex:idxNumber 
            //                                                                     withUpdatePerHour:NO 
            //                                                                     withOperationName:operationName 
            //                                                                       withTotalProfit:totalProfit];
            //            
            //            //                    [operation addObserver:self
            //            //                                forKeyPath:@"isFinished"
            //            //                                   options:NSKeyValueObservingOptionNew
            //            //                                   context:NULL];   
            //            
            //            if (operation) { 
            //                [operation main];
            //                [operation release];
            //            }
            Carrier *necessaryCarrier = (Carrier *)[moc objectWithID:carrierID];
            
            ProgressUpdateController *progress = [[ProgressUpdateController alloc]  
                                                  initWithDelegate:delegate 
                                                  withQueuePosition:idxNumber 
                                                  withIndexOfUpdatedObject:idxNumber];
            
            MySQLIXC *databaseForUsing = [[MySQLIXC alloc] initWithQuene:idxNumber.unsignedIntegerValue 
                                                              andCarrier:necessaryCarrier.objectID 
                                                            withProgress:progress 
                                                            withDelegate:nil];
            
            //[self setDatabase:databaseForUsing];
            
            UpdateDataController *update = [[UpdateDataController alloc] initWithDatabase:databaseForUsing];
            
            @synchronized (self) {  
                databaseForUsing.connections = [self databaseConnections];
            }
            //[databaseForUsing release];
            
            [progress updateCarrierName:necessaryCarrier.name];
            progress.operationName = operationName;
            
            //0 - dont need update 1 - destinationsListForSale 2 - destinationsListWeBuy 3 - both
            
            NSNumber *updateRates = [update checkIfRatesWasUpdatedforCarrierGUID:necessaryCarrier.objectID andCarrierName:necessaryCarrier.name];
            NSLog(@"STAT:Carrier %@ need rates update: %@", necessaryCarrier.name, updateRates);
            
            if (updateRates.intValue != 0) {
                BOOL outgoingDestinationsListIsEmpty;
                BOOL incomingDestinationsListIsEmpty;
                NSLog(@"STAT:Carrier %@ rates will update", necessaryCarrier.name);
                
                incomingDestinationsListIsEmpty = [update updateDestinationListforCarrier:carrierID destinationType:0 withProgressUpdateController:progress];
                outgoingDestinationsListIsEmpty = [update updateDestinationListforCarrier:carrierID destinationType:1 withProgressUpdateController:progress];
                if ([operationName isEqualToString:@"Every hour sync"]) {
                    if (!incomingDestinationsListIsEmpty) { 
                        NSLog(@"STAT:Carrier %@ per hour incoming stat will update", necessaryCarrier.name);
                        
                        [update updatePerHourStatisticforCarrierGUID:necessaryCarrier.GUID carrierName:necessaryCarrier.name destinationType:0 withProgressUpdateController:progress];
                    }
                    if (!outgoingDestinationsListIsEmpty) { 
                        NSLog(@"STAT:Carrier %@ per hour outgoing stat will update", necessaryCarrier.name);
                        
                        [update updatePerHourStatisticforCarrierGUID:necessaryCarrier.GUID carrierName:necessaryCarrier.name destinationType:1 withProgressUpdateController:progress];
                    }
                    
                } else {
                    if (!incomingDestinationsListIsEmpty) { 
                        NSLog(@"STAT:Carrier %@ pre dayly incoming stat will update", necessaryCarrier.name);
                        
                        [update updateStatisticforCarrierGUID:necessaryCarrier.GUID andCarrierName:necessaryCarrier.name destinationType:0 withProgressUpdateController:progress];
                        
                    }
                    if (!outgoingDestinationsListIsEmpty) { 
                        NSLog(@"STAT:Carrier %@ pre dayly outgoing stat will update", necessaryCarrier.name);
                        [update updateStatisticforCarrierGUID:necessaryCarrier.GUID andCarrierName:necessaryCarrier.name destinationType:1 withProgressUpdateController:progress];
                    }
                }
            }
            
            [update updateCarriersFinancialRatingAndLastUpdatedTimeForCarrierGUID:necessaryCarrier.objectID withTotalProfit:totalProfit];
            [update getInvoicesAndPaymentsForCarrier:necessaryCarrier.objectID];
            
            [progress release];
            [databaseForUsing reset];
            [databaseForUsing release];
            [update release];
            
            [totalProfit release];
            [idxNumber release];
            //            [pool drain],pool = nil;
            
            //            dispatch_semaphore_signal(semaphore);
            
            //        });
            //index = [NSNumber numberWithInt:([index intValue] +1)];
            //        [pool drain],pool = nil;
            correntProcessNumber--;

        });
        idx++;
        
    };
    
//    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//    dispatch_release(group);
//    dispatch_release(semaphore);
//
    
    [progress clearPoll];
    [progress updateProgressIndicatorMessageGetExternalData:@""];
    
    [progress stopSync];
    [progress updateSystemMessage:[NSString stringWithFormat:@"Sync was finished:%@ for number %@ carriers.",[NSDate date],[NSNumber numberWithUnsignedInteger:[carriersToExecute count]]]];
    delegate.queueForUpdatesBusy = NO;
    [totalProfitNumber release];
    //[pool drain];

}

#pragma mark -
#pragma mark INTERNAL ARRAYS methods
- (NSArray *) transformContentFromHorizontalToVerticalDataForBinding:(NSManagedObject *)content;
{
        NSMutableArray *columns = [NSMutableArray array];

        for (NSString *attribute in [[content entity] attributeKeys])
        {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            [row setValue:attribute forKey:@"attribute"];
            [row setValue:[content valueForKey:attribute] forKey:@"data"];
            [columns addObject:row];
        }
    return [NSArray arrayWithArray:columns];
}

-(NSArray *) databaseConnectionCTP;
{
    NSError *error = nil;
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:@"DatabaseConnections"
                                   inManagedObjectContext:self.moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"status contains[c] 'ctp'"]];
    NSArray *connections = [self.moc executeFetchRequest:request error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
    //NSLog(@"%@",connections);
    return connections;
}


-(NSArray *) databaseConnections;
{
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"DatabaseConnections"
                                   inManagedObjectContext:self.moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"enable == YES"]];
    [request setResultType:NSDictionaryResultType];
    NSArray *connections = [self.moc executeFetchRequest:request error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
    //NSLog(@"%@",connections);
    [request release];
    return connections;
}

-(void) setupDefaultDatabaseConnections
{
#if defined (SNOW_CLIENT_ENTERPRISE) || defined(SNOW_SERVER)


    NSError *error = nil;
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:[NSEntityDescription entityForName:@"DatabaseConnections"
                                          inManagedObjectContext:self.moc]];
    NSUInteger countConnections = [self.moc countForFetchRequest:request error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
  
    if (countConnections == 0)
    {
        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
        CompanyStuff *authorizedUser = [clientController authorization];
        [clientController release];

        CurrentCompany *currentCompanyFromAnotherMoc = authorizedUser.currentCompany;
        CurrentCompany *currentCompany = (CurrentCompany *)[moc objectWithID:currentCompanyFromAnotherMoc.objectID];
        
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
        replicationNew.currentCompany = currentCompany;

        //NSMutableDictionary *replicationOld = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"selected",[NSMutableString stringWithString:@"208.71.117.242"],@"ip",@"alex",@"login",@"ASaqMXkc3",@"password",@"radius",@"database",@"3308",@"port",[getOrPutChoice mutableCopy],@"directions",[updateChoice mutableCopy],@"updateChoices",@"",@"status",nil]; 

        DatabaseConnections *replicationOld = (DatabaseConnections *)[NSEntityDescription insertNewObjectForEntityForName:@"DatabaseConnections" inManagedObjectContext:self.moc]; 
        replicationOld.enable = [NSNumber numberWithBool:NO];
        replicationOld.ip = @"208.71.117.242";
        replicationOld.login = @"alex";
        replicationOld.password = @"ASaqMXkc3";
        replicationOld.database = @"radius";
        replicationOld.port = @"3308";
        replicationOld.status = @"replicationOld";
        replicationOld.urlForRouting = @"http://alexv:Manual12@avoiceweb.interexc.com";
        replicationOld.updateChoices = updateChoice;
        replicationOld.directions = getOrPutChoice;
        replicationOld.currentCompany = currentCompany;
        
        //NSMutableDictionary *local = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"selected",[NSMutableString stringWithString:@"localhost"],@"ip",@"root",@"login",@"",@"password",@"test2",@"database",@"3306",@"port",[getOrPutChoice mutableCopy],@"directions",[updateChoice mutableCopy],@"updateChoices",@"",@"status",nil]; 

        
        //NSMutableDictionary *mainBillingNew = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"selected",[NSMutableString stringWithString:@"208.71.117.247"],@"ip",@"alex",@"login",@"1ceec5f43fa65ecd",@"password",@"radius",@"database",@"3307",@"port",[getOrPutChoice mutableCopy],@"directions",[updateChoice mutableCopy],@"updateChoices",@"",@"status",nil]; 
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
        mainBillingNew.currentCompany = currentCompany;
        
        DatabaseConnections *mainBillingOld = (DatabaseConnections *)[NSEntityDescription insertNewObjectForEntityForName:@"DatabaseConnections" inManagedObjectContext:self.moc]; 
         mainBillingOld.enable = [NSNumber numberWithBool:NO];
         mainBillingOld.ip = @"208.71.117.243";
         mainBillingOld.login = @"alex";
         mainBillingOld.password = @"ASaqMXkc3";
         mainBillingOld.database = @"radius";
         mainBillingOld.port = @"3307";
         mainBillingOld.status = @"mainBillingOld";
         mainBillingOld.urlForRouting = @"http://alexv:Manual12@208.71.117.247";
         mainBillingOld.selectionDirections = [NSNumber numberWithInt:1];
         mainBillingOld.updateChoices = updateChoice;
         mainBillingOld.directions = getOrPutChoice;
         mainBillingOld.currentCompany = currentCompany;
        

        //NSMutableDictionary *mainBillingOld = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"selected",[NSMutableString stringWithString:@"208.71.117.243"],@"ip",@"alex",@"login",@"ASaqMXkc3",@"password",@"radius",@"database",@"3307",@"port",[getOrPutChoice mutableCopy],@"directions",[updateChoice mutableCopy],@"updateChoices",@"",@"status",nil]; 

        //NSMutableDictionary *diall = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"selected",[NSMutableString stringWithString:@"195.26.84.147"],@"ip",@"alex",@"login",@"hukmatCawckOofna",@"password",@"radius",@"database",@"3307",@"port",[getOrPutChoice mutableCopy],@"directions",[updateChoice mutableCopy],@"updateChoices",@"",@"status",nil];
        DatabaseConnections *diallGet = (DatabaseConnections *)[NSEntityDescription insertNewObjectForEntityForName:@"DatabaseConnections" inManagedObjectContext:self.moc]; 
        diallGet.enable = [NSNumber numberWithBool:NO];
        //NSMutableString *test = [[NSMutableString alloc] initWithString:@"208.71.117.242"];
        diallGet.ip = @"195.26.84.147";
        diallGet.login = @"alex";
        diallGet.password = @"hukmatCawckOofna";
        diallGet.database = @"radius";
        diallGet.port = @"3307";
        diallGet.status = @"diallGet";
        diallGet.urlForRouting = @"http://alexv:Manual12@195.26.84.147";
        diallGet.updateChoices = updateChoice;
        diallGet.directions = getOrPutChoice;
        diallGet.currentCompany = currentCompany;
        
        DatabaseConnections *diallPut = (DatabaseConnections *)[NSEntityDescription insertNewObjectForEntityForName:@"DatabaseConnections" inManagedObjectContext:self.moc]; 
        diallPut.enable = [NSNumber numberWithBool:NO];
        //NSMutableString *test = [[NSMutableString alloc] initWithString:@"208.71.117.242"];
        diallPut.ip = @"195.26.84.147";
        diallPut.login = @"alex";
        diallPut.password = @"hukmatCawckOofna";
        diallPut.database = @"radius";
        diallPut.port = @"3307";
        diallPut.status = @"diallPut";
        diallPut.urlForRouting = @"http://alexv:Manual12@195.26.84.147";
        diallPut.updateChoices = updateChoice;
        diallPut.selectionDirections = [NSNumber numberWithInt:1];
        diallPut.directions = getOrPutChoice;
        diallPut.currentCompany = currentCompany;

        DatabaseConnections *ctp = (DatabaseConnections *)[NSEntityDescription insertNewObjectForEntityForName:@"DatabaseConnections" inManagedObjectContext:self.moc]; 
        ctp.enable = [NSNumber numberWithBool:NO];
        //NSMutableString *test = [[NSMutableString alloc] initWithString:@"208.71.117.242"];
        ctp.ip = @"77.91.169.130";
        ctp.login = @"alex";
        ctp.password = @"XDas2d3vsl4872yuuj";
        ctp.database = @"ctp";
        ctp.port = @"3306";
        ctp.status = @"ctp";
        //ctp.urlForRouting = @"http://alexv:Manual12@195.26.84.147";
        ctp.updateChoices = updateChoice;
        ctp.selectionDirections = [NSNumber numberWithInt:0];
        ctp.directions = getOrPutChoice;
        ctp.currentCompany = currentCompany;
       
        DatabaseConnections *ctpPut = (DatabaseConnections *)[NSEntityDescription insertNewObjectForEntityForName:@"DatabaseConnections" inManagedObjectContext:self.moc]; 
         ctpPut.enable = [NSNumber numberWithBool:NO];
         //NSMutableString *test = [[NSMutableString alloc] initWithString:@"208.71.117.242"];
         ctpPut.ip = @"77.91.169.130";
         ctpPut.login = @"alex";
         ctpPut.password = @"XDas2d3vsl4872yuuj";
         ctpPut.database = @"ctp";
         ctpPut.port = @"3306";
         ctpPut.status = @"ctpPut";
         //ctp.urlForRouting = @"http://alexv:Manual12@195.26.84.147";
         ctpPut.updateChoices = updateChoice;
         ctpPut.selectionDirections = [NSNumber numberWithInt:1];
         ctpPut.directions = getOrPutChoice;
         ctpPut.currentCompany = currentCompany;
        [self finalSave];

    } else return;
    
#endif
    
}

- (void) readExternalCountryCodesListWithProgressUpdateController:(ProgressUpdateController *)progress;
{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
 
    NSArray *myCountrySpecificCodeList = [NSArray arrayWithContentsOfFile:[[delegate applicationFilesDirectory].path stringByAppendingString:@"/myCountrySpecificCodeList.ary"]];
    NSDictionary *dictionaryDictionaryesForCountryCodes = [NSDictionary dictionaryWithContentsOfFile:[[delegate applicationFilesDirectory].path stringByAppendingString:@"/dictionaryDictionaryesForCountryCodes.dic"]];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    

    if (!myCountrySpecificCodeList || !dictionaryDictionaryesForCountryCodes)
    {    
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"codeList" ofType:@"txt" ];
        NSAssert(path != nil, @"Unable to find codeList.txt in main bundle"); 
        ParseCSV *parser = [[ParseCSV alloc] init];
        [parser openFile:path];
        NSMutableArray *codesFromFile = [parser parseFile];
        [parser release], parser = nil;
        path = nil;
        [progress updateProgressIndicatorMessageGetExternalData:@"Get country,specific,codes,outgroups from file"];
        progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[codesFromFile count]];
        
        
        [codesFromFile enumerateObjectsWithOptions:NSSortStable usingBlock:^(id code, NSUInteger idx, BOOL *stop) {
            [progress updateProgressIndicatorMessageGetExternalData:[NSString stringWithFormat:@"Get country,specific:%lu",idx]];
            
            [progress updateProgressIndicatorCountGetExternalData];
            
            NSMutableDictionary *codesFromFileListNew = [NSMutableDictionary dictionary];
            [codesFromFileListNew setValue:[code objectAtIndex:0] forKey:@"country"];
            [codesFromFileListNew setValue:[code objectAtIndex:1] forKey:@"specific"];
            
            
            [[ProjectArrays sharedProjectArrays].dictionaryDictionaryesForCountryCodes setValue:codesFromFileListNew forKey:[code objectAtIndex:2]];
            codesFromFileListNew = nil;
            
            //        NSLog (@"codesFromFileLists before array  %@",codesFromFileLists);
            
            NSMutableArray *filteredResult = [NSMutableArray arrayWithArray:[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList];
            [filteredResult filterUsingPredicate:[NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",[code objectAtIndex:0],[code objectAtIndex:1]]];
            
            if ([filteredResult count] != 0)
            {
                // NSLog (@"We find a simular country: %@ specific %@ and code %@ Total destinations:%ld",[code objectAtIndex:0],[code objectAtIndex:1], [code objectAtIndex:2], [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList count]);
                NSMutableDictionary *lastObject = [[NSArray arrayWithArray:[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList] lastObject];
                NSMutableArray *codes = [lastObject valueForKey:@"code"];
                [codes addObject:[code objectAtIndex:2]];
                [lastObject setValue:codes forKey:@"code"];
                [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList removeLastObject];
                [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList addObject:lastObject];
                lastObject = nil;
                codes = nil;
            } else
            {
                //NSLog (@"Add country: %@ specific %@ and code %@ Total destinations:%ld",[code objectAtIndex:0],[code objectAtIndex:1], [code objectAtIndex:2],[[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList count]);
                NSMutableDictionary *codesFromFileList = [NSMutableDictionary dictionary];
                NSString *countryBefore = [code objectAtIndex:0];
                NSString *specificBefore = [code objectAtIndex:1];
                NSString *country = [countryBefore stringByReplacingOccurrencesOfString:@"'" withString:@"~"];
                NSString *specific = [specificBefore stringByReplacingOccurrencesOfString:@"'" withString:@"~"];
                
                [codesFromFileList setValue:country forKey:@"country"];
                [codesFromFileList setValue:specific forKey:@"specific"];
                [codesFromFileList setValue:[NSMutableArray arrayWithObject:[code objectAtIndex:2]] forKey:@"code"];
                [codesFromFileList setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
                NSArray *outGroups = nil;
#ifdef SNOW_SERVER
                
#else
                outGroups = [database getOutGroupsListWithOutPeersListInsideForCountry:country forSpecific:specific];
#endif
                
                //NSMutableSet *outGroupsSet = [NSMutableSet setWithArray:outGroups];
                [codesFromFileList setValue:outGroups forKey:@"outGroups"];
                [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList addObject:codesFromFileList];
                codesFromFileList = nil;
            }
            if ([[result valueForKey:[code objectAtIndex:0]] count] == 0) [result setValue:[NSMutableArray arrayWithObject:[code objectAtIndex:1]] forKey:[code objectAtIndex:0]];
            else {
                if ([[result valueForKey:[code objectAtIndex:0]] containsObject:[code objectAtIndex:1]]);
                else [[result valueForKey:[code objectAtIndex:0]] addObject:[code objectAtIndex:1]];
            }
        }];
        
        NSString *pathForSaveArray = [[delegate applicationFilesDirectory].path stringByAppendingString:@"/myCountrySpecificCodeList.ary"];
        BOOL success = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList writeToFile:pathForSaveArray atomically:YES];
        NSLog(@"Write to file:%@",success ? @"YES" : @"NO");
        [[ProjectArrays sharedProjectArrays].dictionaryDictionaryesForCountryCodes writeToFile:[[delegate applicationFilesDirectory].path stringByAppendingString:@"/dictionaryDictionaryesForCountryCodes.dic"] atomically:YES];
        pathForSaveArray = [[delegate applicationFilesDirectory].path stringByAppendingString:@"/countryspecific.dict"];
        success = [result writeToFile:pathForSaveArray atomically:YES];
        NSLog(@"Write to file:%@",success ? @"YES" : @"NO");

        
    } else {
        [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList addObjectsFromArray:myCountrySpecificCodeList];
        [[ProjectArrays sharedProjectArrays].dictionaryDictionaryesForCountryCodes addEntriesFromDictionary:dictionaryDictionaryesForCountryCodes];
    }
    
    
    
    //[delegate.countryCodeslist setContent:myCountrySpecificCodeList];
    
    if ([delegate.loggingLevel intValue] > 0) {
//        NSLog(@"INIT: result with dict :%@",[[ProjectArrays sharedProjectArrays].dictionaryDictionaryesForCountryCodes valueForKey:@"38066"]);
//        NSLog(@"INIT: result with array :%@",[[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList lastObject]);
//        
//        NSLog(@"INIT: result with array :%@",[result valueForKey:@"Ukraine"]);
    }
    
    NSMutableArray *ratesStack = [NSMutableArray arrayWithContentsOfFile:[[delegate applicationFilesDirectory].path stringByAppendingString:@"/ratesStack.ary"]];
//    [delegate.ratesStack setContent:[NSArray arrayWithArray:ratesStack]];
    [progress changeIndicatorRatesStackWithObjectsQuantity:[NSNumber numberWithUnsignedInteger:[ratesStack count]]];
    [progress updateProgressIndicatorMessageGetExternalData:@""];
}

#pragma mark -
#pragma mark PARSE methods
-(void) checkCalendarsForCountryListAndFutureEvents:(NSArray *)calendars;
{
    NSLog(@"CALENDAR:supported countries");
    CalCalendarStore *myStore = [CalCalendarStore defaultCalendarStore];
    NSMutableString *finalResult = [NSMutableString string];

    for (CalCalendar *calendar in calendars)
    {
        NSString *_country = [NSString stringWithString:calendar.title];
        NSString *countryString = [_country stringByReplacingOccurrencesOfString:@"_" withString:@""];
        [finalResult appendFormat:@"%@\n",countryString];
        
        NSDate *startDateDate = [NSCalendarDate dateWithTimeIntervalSinceNow:+12096000];
        NSDate *endDateNextYear = [NSCalendarDate dateWithTimeIntervalSinceNow:+31536000];
        
        NSPredicate *eventsForNextTwoWeeks = [CalCalendarStore eventPredicateWithStartDate:startDateDate endDate:endDateNextYear calendars:[NSArray arrayWithObject:calendar]];
        NSArray *eventsNextYear = [myStore eventsWithPredicate:eventsForNextTwoWeeks];
        if ([eventsNextYear count] == 0) [finalResult appendFormat:@"CALENDAR:WARNING country :%@ don't have events\n",countryString];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(country contains[cd] %@)",countryString];
        
        
        NSArray *destinatinationsForSaleInCountrySpecificList = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:predicate];
        if ([destinatinationsForSaleInCountrySpecificList count] == 0) [finalResult appendFormat:@"CALENDAR:WARNING country :%@ don't have internal accordance(specific list empty)",countryString];
    }
    NSLog(@"CALENDAR:supported countries result:\n%@",finalResult);

}

-(void) fillEventsListInternallyAndSaveToDiskForExternalUsing:(NSArray *)filteredEvents;
{
    NSError *error = nil;
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];

    [request setEntity:[NSEntityDescription entityForName:@"MainSystem"
                                          inManagedObjectContext:self.moc]];
    [request setPredicate:nil];
    NSArray *result = [self.moc executeFetchRequest:request error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
    MainSystem *mainSystem = [result lastObject];
    NSAssert(mainSystem !=nil,@"can tFind mainSystem");
    
    for (CalEvent *titleEvent in filteredEvents)
    {
        NSString *_country = [NSString stringWithString:titleEvent.calendar.title];
        NSString *countryString = [_country stringByReplacingOccurrencesOfString:@"_" withString:@""];
        NSString *eventTitle = titleEvent.title;
        NSDate *dateEvent = titleEvent.startDate;
        NSDate *dateAlarm = [dateEvent dateByAddingTimeInterval:-475200];
        NSString *necessaryData = [NSString stringWithFormat:@"countriesEvent_%@",countryString];
        
        NSFetchRequest *compareWithCurrentEvents = [[[NSFetchRequest alloc] init] autorelease];
        [compareWithCurrentEvents setEntity:[NSEntityDescription entityForName:@"Events" inManagedObjectContext:self.moc]];
        [compareWithCurrentEvents setPredicate:[NSPredicate predicateWithFormat:@"(mainSystem == %@) and (date == %@) and (necessaryData == %@)",mainSystem, dateEvent,necessaryData]];
        
        if ([self.moc countForFetchRequest:compareWithCurrentEvents error:&error] != 0) continue; 

        Events *newEvent = [NSEntityDescription 
                                                insertNewObjectForEntityForName:@"Events" 
                                                inManagedObjectContext:self.moc];
        
        newEvent.name = eventTitle;
        newEvent.date = dateEvent;
        newEvent.dateAlarm = dateAlarm;
        newEvent.necessaryData = necessaryData;
        newEvent.mainSystem = mainSystem;
        NSLog(@"UPDATE DATA CONTROLLER: created event:%@",newEvent);

    }
    [self finalSave];
//     if (![savedData writeToFile:[[delegate applicationSupportDirectory] stringByAppendingString:@"/nextTwoWeekEvents.ary"] atomically:YES]) NSLog(@"WARNING: events was not save well");
    
}

- (NSArray *)destinationsArrayDictionariesToArrayArrays:(NSArray *)destinations;
{
    NSMutableArray *prepearedContext = [NSMutableArray arrayWithCapacity:0];
    for (NSManagedObject *destination in destinations)
    {
        for (CodesvsDestinationsList *code in [destination valueForKey:@"codesvsDestinationsList"])
        {
            NSDate *internalChangedDate = code.internalChangedDate;
            if (!internalChangedDate) internalChangedDate = [NSDate date];
            NSArray *prepearedRow = [NSArray arrayWithObjects:[code.code stringValue],[NSString stringWithFormat:@"%@/%@",code.country,code.specific],[code.rate stringValue], [internalChangedDate description],nil];
            [prepearedContext addObject:prepearedRow];
        }
    }
    return [NSArray arrayWithArray:prepearedContext];
}

-(BOOL)isXLSXformatForFileWithPath:(NSString *)path
{
    //NSData *file = [NSData dataWithContentsOfFile:path];
//    if (!file) {
//        NSLog(@"UPDATE DATE CONTROLLER: warning, file not found for check xls/xlsx");
//        return NO;
//    }
//    FILE *file = fopen([path UTF8String], "rb");
//    if(file == NULL) {
//        NSLog(@"UPDATE DATE CONTROLLER: warning, file not found for check xls/xlsx");
//        return NO;
//    }
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData * buffer = nil;
    BOOL isFirstByteMatched = NO;
    NSUInteger idx = 0;
    while ((buffer = [fileHandle readDataOfLength:1])) {
        if (idx > 2) break;
        //NSLog(@"%@",[buffer description]);
        if ([[buffer description] isEqualToString:@"<50>"] && idx == 0) isFirstByteMatched = YES;
        if ([[buffer description] isEqualToString:@"<4b>"] && idx == 1 && isFirstByteMatched) {  
            NSLog(@"UPDATE DATA CONTROLLER: this is xlsx file");
            return YES;
        }
        idx++;
        //do something with the buffer
    }    
    return NO;
}

-(NSArray *)allExcelBookSheetsForUSR:(NSString *)saveURL;
{
    NSMutableArray *finalArray = [NSMutableArray array];

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];   
    //NSString *fullPath = [saveURL path];
    //NSLog(@"PARSE:save url is:%@",saveURL);
    
    BookHandle book;
    if ([self isXLSXformatForFileWithPath:saveURL]) book = xlCreateXMLBook();
    else book = xlCreateBook();

    xlBookSetKey(book,"Oleksii Vynogradov", "mac-f607070b1f1920acb45f697746dfc194");
    if(book) 
    {
        const char *filePath = [saveURL UTF8String];
        //NSLog(@"file path string:%s",filePath);
        
        if(xlBookLoad(book, filePath)) 
        {
            int sheetsQuantity = xlBookSheetCount(book);
            for (int sheetsCount = 0; sheetsCount < sheetsQuantity; sheetsCount++)
            {
                SheetHandle sheet = xlBookGetSheet(book, sheetsCount);
                const char *s = xlSheetName(sheet);
                NSString *sheetName = [[NSString alloc] initWithCString:s encoding:NSUTF8StringEncoding];
                [finalArray addObject:sheetName];
                [sheetName release];
                
            }
            
        }
    }
    [pool drain],pool = nil;
    
    return finalArray;
}

-(NSMutableArray *) parseToExcelwithSaveUrl:(NSString *)fullPath 
                             forSheetNumber:(int) sheetNumber;
{
    //NSString *fullPath = [saveUrl path];
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *weekdayComponents =
    [gregorian components:NSYearCalendarUnit fromDate:today];
    NSInteger currentYear = [weekdayComponents year];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    BookHandle book;
    if ([self isXLSXformatForFileWithPath:fullPath]) book = xlCreateXMLBook();
    else book = xlCreateBook();
    
    xlBookSetKey(book,"Oleksii Vynogradov", "mac-f607070b1f1920acb45f697746dfc194");
    NSMutableArray *finalArray = [NSMutableArray array];

    if(book) 
    {
        if(xlBookLoad(book, [fullPath UTF8String])) 
        {
            SheetHandle sheet = xlBookGetSheet(book, sheetNumber);
            if(sheet)
            {

                for(int row = xlSheetFirstRow(sheet); row < xlSheetLastRow(sheet); ++row)
                {
                    NSMutableArray *rowArray = [NSMutableArray array];
                    
                    for(int col = xlSheetFirstCol(sheet); col <  xlSheetLastCol(sheet); ++col)
                    {
                        NSString *dataForCurrentColumn = nil;

                        int cellType = xlSheetCellType(sheet,row,col);
                        if (cellType == CELLTYPE_STRING) {
                            const char *s = xlSheetReadStr(sheet, row, col, NULL);
                            if (s) dataForCurrentColumn = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
                            else dataForCurrentColumn = @"";
                        }
                        
                        if (cellType == CELLTYPE_NUMBER) {
                            double d = xlSheetReadNum(sheet, row, col, NULL);
                            NSNumber *number = [NSNumber numberWithDouble:d];
                            dataForCurrentColumn = [number stringValue];
                            if (xlSheetIsDate(sheet, row,col) != 0) { 

                                int year, month, day;
                                int hour, min, sec, msec;

                                int result = xlBookDateUnpack(book,d,&year,&month, &day, &hour,&min,&sec,&msec);
                                if (result != 0 && currentYear == year) { 
                                    [weekdayComponents setMonth:month];
                                    [weekdayComponents setYear:year];
                                    [weekdayComponents setDay:day];

                                    NSDate *date = [gregorian dateFromComponents:weekdayComponents];

                                    //NSLog(@"%@",date);
                                    dataForCurrentColumn = [dateFormatter stringFromDate:date];
                                }
                            }
                        }
                       
                        if (!dataForCurrentColumn) dataForCurrentColumn = @"";
                        [rowArray addObject:dataForCurrentColumn];

                        //if(s) NSLog(@"%s|", s);
                        
                    }
                    [finalArray addObject:rowArray];
                    
                }
                //NSLog(@"Final array:%@",finalArray);

                
            }
        }  
        xlBookRelease(book);

    }
    
    [gregorian release];
    [dateFormatter release];
    return finalArray;
}

-(void) parseToExcelArray:(NSArray *)array 
              withSaveUrl:(NSString *)saveUrl;
{
    
    BookHandle book = xlCreateBook();
    xlBookSetKey(book,"Oleksii Vynogradov", "mac-f607070b1f1920acb45f697746dfc194");

    SheetHandle sheet = xlBookAddSheet(book, "Sheet1", NULL);

    int rowNumber = 0;
    for (NSArray *row in array)
    {
        rowNumber++;
        int columnNumber = 0;
        for (NSString *column in row)
        {
            columnNumber++;
            xlSheetWriteStr(sheet, rowNumber, columnNumber, [column UTF8String], NULL);
        }
    }
    //xlSheetWriteStr(sheet, 3, 1, "Hello World !", NULL);
    //xlSheetWriteNum(sheet, 4, 1, 1000, NULL);
    xlBookSave(book, [saveUrl UTF8String]);
    xlBookRelease(book);
}

- (void) sendEmailMessageTo:(NSString *)to 
                withSubject:(NSString *)subject 
                withContent:(NSString *)content 
                   withFrom:(NSString *)from 
              withFilePaths:(NSArray *)filePaths;
{
    
    /* create a Scripting Bridge object for talking to the Mail application */
    MailApplication *mail = [SBApplication
                             applicationWithBundleIdentifier:@"com.apple.Mail"];
    
    /* create a new outgoing message object */

   // NSData *data = [NSData dataWithContentsOfFile:@"/Users/alex/test.rtf"];
    //NSMutableDictionary *attrib = [[NSMutableDictionary alloc] initWithCapacity:0]; 
    //NSAttributedString *attributed = [[NSAttributedString alloc] initWithPath:@"/Users/alex/test.rtf" documentAttributes:nil];
    
    MailOutgoingMessage *emailMessage =
    [[[mail classForScriptingClass:@"outgoing message"] alloc]
     initWithProperties:
     [NSDictionary dictionaryWithObjectsAndKeys:
      subject, @"subject",
      content , @"content",
      nil]];
    
    /* add the object to the mail app  */
    [[mail outgoingMessages] addObject: emailMessage];
    
    /* set the sender, show the message */
    emailMessage.sender = from;
    emailMessage.visible = YES;
    
    /* create a new recipient and add it to the recipients list */
   MailToRecipient *theRecipient =
    [[[mail classForScriptingClass:@"to recipient"] alloc]
     initWithProperties:
     [NSDictionary dictionaryWithObjectsAndKeys:
      to, @"address",
      nil]];
    [emailMessage.toRecipients addObject: theRecipient];
    [theRecipient release];
     
    
    /* add an attachment, if one was specified */
    for (NSString *attachmentFilePath in filePaths)
    {
    //NSString *attachmentFilePath = filePath;
        if ( [attachmentFilePath length] > 0 ) {
            /* create an attachment object */
            MailAttachment *theAttachment = [[[mail
                                               classForScriptingClass:@"attachment"] alloc]
                                             initWithProperties:
                                             [NSDictionary dictionaryWithObjectsAndKeys:
                                              attachmentFilePath, @"fileName",
                                              nil]];
            
            /* add it to the list of attachments */
            [[emailMessage.content attachments] addObject: theAttachment];
        }
    }
    /* send the message */
    [emailMessage send];
    [emailMessage release];
}


- (void) parseChoicesFillingForCarrier:(NSString *)carrier 
                  withRelationshipName:(NSString *)relationshipName;
{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    // importCSVUserChoices have dictionary with carriersNames keys, which have dictionary with relationships, which have arrays of user selection
    //[[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"importCSVUserChoices"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    NSDictionary *savedDefaultSelectionsForAllCarrier = [[NSUserDefaults standardUserDefaults] valueForKey:@"importCSVUserChoices"];
    NSDictionary *savedDefaultSelectionsForCarrerWithRelationships = [savedDefaultSelectionsForAllCarrier valueForKey:carrier];
    NSArray *savedDefaultSelectionsForCarrer = [savedDefaultSelectionsForCarrerWithRelationships valueForKey:relationshipName];
    
    NSArray *choices = [NSArray arrayWithObjects:@"NONE",@"Price",@"code",@"ACD",@"ASR",@"Country",@"Specific",@"Minutes",@"Attemps",@"Date",@"subcode", nil];
    //NSArray *targets = [NSArray arrayWithObjects:@"Price update",@"Add to target list",@"Add to pushlist", nil];

    NSArray *defaultSelections = nil;
    
    if (savedDefaultSelectionsForCarrer) defaultSelections = savedDefaultSelectionsForCarrer;
    else defaultSelections = [NSArray arrayWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:6],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:1],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],nil];
    NSMutableDictionary *objectsForSelect = [NSMutableDictionary dictionaryWithCapacity:0];
    for (int column = 0;column <10 ;column++)
    {
        NSNumber *defaultSelection = nil;
        NSUInteger defaultSelectionsCount = [defaultSelections count];
        if (column >= defaultSelectionsCount) defaultSelection = [NSNumber numberWithInt:0];
        else defaultSelection = [defaultSelections objectAtIndex:column];

        NSString *columnName = [NSString stringWithFormat:@"column%@",[NSNumber numberWithInt:column]];
        NSString *selectionName = [NSString stringWithFormat:@"selection%@",[NSNumber numberWithInt:column]];
        [objectsForSelect setValue:choices forKey:columnName];
        [objectsForSelect setValue:defaultSelection forKey:selectionName];
    }
    //[objectsForSelect setValue:targets forKey:@"choices"]; // selectionChoises is keypath for selection
//    [objectsForSelect setValue:[[[delegate.importedCSVselections arrangedObjects] lastObject] valueForKey:@"selectionChoices"] forKey:@"selectionChoices"]; // selectionChoises is keypath for selection
//    
//    [delegate.importedCSVselections setContent:[NSArray arrayWithObject:objectsForSelect]];
    
    //return [NSArray arrayWithObject:objectsForSelect];
}

- (NSArray *) parseCVSimported:(NSArray *)array 
               forCarrier:(NSString *)carrier 
     withRelationshipName:(NSString *)relationshipName;
{
    //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
    [self parseChoicesFillingForCarrier:carrier withRelationshipName:relationshipName];
    for (NSArray *row in array)
    {    
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSMutableDictionary *rowNumbered = [NSMutableDictionary dictionaryWithCapacity:0];
        int columnNumber = 0;
        BOOL rowIsEmpty = NO;
        
        for (NSString *column in row)
        {
            if ([column length] > 0) rowIsEmpty = YES;
            NSString *key = [NSString stringWithFormat:@"column%@",[NSNumber numberWithInt:columnNumber]];
            [rowNumbered setValue:column forKey:key];
            columnNumber++;
        }
        if (rowIsEmpty) [result addObject:rowNumbered];
        [pool drain], pool = nil;
    }
    //[delegate.importedCSVfile setContent:result];
    //[delegate.importRatesView.importRatesFirsParserResult setContent:result];
    return result;
}

// target = selection index @"Price update",@"Add to target list",@"Add to pushlist"

- (void) importCSVforArray:(NSArray *)array 
           forChoiceTarget:(NSNumber *)choiceTarget 
           forChoiceColumn:(NSArray *)choiceColumn
       forRelationshipName:(NSString *)relationshipName;

{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    //NSDictionary *carrier = [[delegate.carriersForAddNewDestinationsController arrangedObjects] lastObject];
    NSString *carrierName = delegate.importRatesView.importRatesCarrierName;
    
    // importCSVUserChoices have dictionary with carriersNames keys, which have dictionary with relationships, which have arrays of user selection
    NSMutableDictionary *importRatesUserChoices = [NSMutableDictionary dictionary];
    [importRatesUserChoices addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationFilesDirectory]]]];
    NSMutableDictionary *carrierChoisesList = [importRatesUserChoices valueForKey:carrierName];
    NSArray *allColumns = [carrierChoisesList valueForKey:relationshipName];

//    NSDictionary *savedDefaultSelectionsForAllCarrier = [[NSUserDefaults standardUserDefaults] valueForKey:@"importCSVUserChoices"];
//    
//    NSMutableDictionary *savedDefaultSelectionsForAllCarrierMutable = [NSMutableDictionary dictionaryWithDictionary:savedDefaultSelectionsForAllCarrier];
//    
//    NSDictionary *savedDefaultSelectionsForCarrerWithRelationships = [savedDefaultSelectionsForAllCarrier valueForKey:carrierName];
//    
//    NSMutableDictionary *savedDefaultSelectionsForCarrerWithRelationshipsMutable = [NSMutableDictionary dictionaryWithDictionary:savedDefaultSelectionsForCarrerWithRelationships];
//    
//    
//    [savedDefaultSelectionsForCarrerWithRelationshipsMutable setValue:choiceColumn forKey:relationshipName];
//    [savedDefaultSelectionsForAllCarrierMutable setValue:savedDefaultSelectionsForCarrerWithRelationshipsMutable forKey:carrierName];
//    
//    
//    [[NSUserDefaults standardUserDefaults] setValue:savedDefaultSelectionsForAllCarrierMutable forKey:@"importCSVUserChoices"];
//    [savedDefaultSelectionsForAllCarrierMutable writeToFile:[NSString stringWithFormat:@"%@/importCSVUserChoices.dict",[delegate applicationSupportDirectory]] atomically:YES];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    

    NSMutableArray *parsedResult = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *row in array)
    {
        NSMutableDictionary *updatedResults = [NSMutableDictionary dictionaryWithCapacity:0];
        BOOL codeIsNumber = YES;
        NSDate *effectiveDate = delegate.importRatesView.importRatesEffectiveDate.dateValue;
        [updatedResults setValue:effectiveDate forKey:@"effectiveDate"]; 
        
        BOOL isCodeWasInsideFile = NO;
        
        for (int column = 0;column < 8 ;column++)
        {
            NSString *columnName = [allColumns objectAtIndex:column];
            
            //NSNumber *choicedColumn = [choiceColumn objectAtIndex:column];
            NSString *key = [NSString stringWithFormat:@"column%@",[NSNumber numberWithInt:column]];
            NSMutableString *volume = [row valueForKey:key];
            if ([columnName isEqualToString:@"Price"])
            {
                // this is a rate
                
                NSString *newVolumeWithourDollar = [volume stringByReplacingOccurrencesOfString:@"." withString:@","];
                NSString *newVolumeWithChangeDot = [newVolumeWithourDollar stringByReplacingOccurrencesOfString:@"$" withString:@""];
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                NSNumber *rate = [formatter numberFromString:newVolumeWithChangeDot];
                if (!rate) {
                    newVolumeWithChangeDot = [newVolumeWithChangeDot stringByReplacingOccurrencesOfString:@"," withString:@"."];
                    rate = [formatter numberFromString:newVolumeWithChangeDot];
                }
                [formatter release];
                [updatedResults setValue:rate forKey:@"rate"];
                
                [updatedResults setValue:rate forKey:@"price"];
            }
            if ([columnName isEqualToString:@"Code"])
            {
                // this is a code
                NSArray *codes = [volume componentsSeparatedByString:@","];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                NSNumber *code = [formatter numberFromString:[codes lastObject]];
                [formatter release];
                if (!code) codeIsNumber = NO;
                else {
                    NSMutableArray *codesParsed = [NSMutableArray arrayWithCapacity:0];
                    for (NSString *code in codes)
                    {
                        NSMutableString *codeMutable = [NSMutableString stringWithString:code];
                        [codeMutable replaceOccurrencesOfString:@" " withString:@"" options:NSBackwardsSearch range: NSMakeRange(0, [codeMutable length])];
                        
                        //NSString *codeClean = [code stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSString *choice = [delegate.importRatesView.importRatesPrefix stringValue];
                        
                        if ([choice length] > 0)  [codeMutable replaceOccurrencesOfString:choice withString:@"" options:NSBackwardsSearch range: NSMakeRange(0, [codeMutable length])];
                        
                        NSDictionary *codeDict = [NSDictionary dictionaryWithObjectsAndKeys:codeMutable,@"code", nil];
                        [codesParsed addObject:codeDict];
                    }
                    [updatedResults setValue:codesParsed forKey:@"codes"];
                    isCodeWasInsideFile = YES;
                }
            }
            
            if ([columnName isEqualToString:@"ACD"])
            {
                // this is a ACD
                
                [volume stringByReplacingOccurrencesOfString:@"," withString:@"."];
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                NSNumber *acd = [formatter numberFromString:volume];
                if (!acd) {
                    NSString *newVolumeWithoutDot = [volume stringByReplacingOccurrencesOfString:@"," withString:@"."];
                    acd = [formatter numberFromString:newVolumeWithoutDot];
                    if (!acd) {
                        newVolumeWithoutDot = [volume stringByReplacingOccurrencesOfString:@"." withString:@","];
                        acd = [formatter numberFromString:newVolumeWithoutDot];
                        
                    }
                }
                [formatter release];
                [updatedResults setValue:acd forKey:@"acd"];
            }
            if ([columnName isEqualToString:@"ASR"])
            {
                // this is a ASR
                NSString *newVolumeWithourPercent = [volume stringByReplacingOccurrencesOfString:@"%" withString:@""];
                //NSString *newVolumeWithChangeDot = [newVolumeWithourPercent stringByReplacingOccurrencesOfString:@"." withString:@","];
                
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                NSNumber *asrAbsolute = [formatter numberFromString:newVolumeWithourPercent];
                if (!asrAbsolute) {
                    NSString *newVolumeWithChangeDot = [newVolumeWithourPercent stringByReplacingOccurrencesOfString:@"." withString:@","];
                    asrAbsolute = [formatter numberFromString:newVolumeWithChangeDot];
                    if (!asrAbsolute) {
                        newVolumeWithChangeDot = [newVolumeWithourPercent stringByReplacingOccurrencesOfString:@"," withString:@"."];
                        asrAbsolute = [formatter numberFromString:newVolumeWithChangeDot];
                        
                    }
                }
                
                [formatter release];
                NSNumber *asrFinal = nil;
                
                if (asrAbsolute.doubleValue > 1) {
                    asrFinal = [NSNumber numberWithDouble:asrAbsolute.doubleValue / 100];
                } else asrFinal = asrAbsolute;
                
                //NSLog(@"IMPORT: asr is :%@ final is:%@",asrAbsolute,asrFinal);
                [updatedResults setValue:asrFinal forKey:@"asr"];
            }
            if ([columnName isEqualToString:@"Country"]) [updatedResults setValue:volume forKey:@"country"];
            if ([columnName isEqualToString:@"Specific"]) [updatedResults setValue:volume forKey:@"specific"];
            if ([columnName isEqualToString:@"Minutes"]) {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                NSNumber *minutes = [formatter numberFromString:volume];
                [formatter release];
                [updatedResults setValue:minutes forKey:@"minutes"];
                
            }
            if ([columnName isEqualToString:@"Attempts"]) { 
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                NSNumber *attempts = [formatter numberFromString:volume];
                [formatter release];
                [updatedResults setValue:attempts forKey:@"attempts"]; 
            }
            
            if ([columnName isEqualToString:@"Date"]) { 
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                NSArray *formats = [NSArray arrayWithObjects:@"dd-MMM-yyyy",@"dd.MM.yy",@"MM.dd.yyyy",@"MM/dd/yy",@"dd.MMyy",@"MM/dd/yyyy",@"yyyy-MM-dd", nil];
                [formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
                
                //[formatter setDateFormat:@"dd.MM.yy"];
                NSDate *effectiveDate = nil;
                
                for (NSString *format in formats) {
                    [formatter setDateFormat:format];
                    effectiveDate = [formatter dateFromString:volume];
                    //NSLog(@"Format:%@,date:%@",format,effectiveDate);
                    
                    if (effectiveDate) break;
                }
                //NSLog(@"Format:date:%@",effectiveDate);
                
                if (!effectiveDate) effectiveDate = delegate.importRatesView.importRatesEffectiveDate.dateValue;
                
                [updatedResults setValue:effectiveDate forKey:@"effectiveDate"]; 
                [formatter release];
                
                
            }
            if ([columnName isEqualToString:@"subcode"])
            {
                // this is subcode
                NSMutableArray *codes = [updatedResults valueForKey:@"codes"];
                if ([codes count] > 1) NSLog(@"PARSING:warning, this is a more than 1 code to apply subcodes");
                
                NSArray *subcodes = [volume componentsSeparatedByString:@","];
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                NSNumber *subcode = [formatter numberFromString:[subcodes lastObject]];
                if (!subcode) codeIsNumber = NO;
                else {
                    NSMutableArray *codesParsed = [NSMutableArray arrayWithCapacity:0];
                    for (NSDictionary *codeDict in codes)
                    {
                        
                        
                        for (NSString *subcode in subcodes){
                            NSMutableString *subcodeMutable = [NSMutableString stringWithString:subcode];
                            
                            [subcodeMutable replaceOccurrencesOfString:@" " withString:@"" options:NSBackwardsSearch range: NSMakeRange(0, [subcodeMutable length])];
                            [subcodeMutable insertString:[codeDict valueForKey:@"code"] atIndex:0];
                            
                            NSDictionary *codeDict = [NSDictionary dictionaryWithObjectsAndKeys:subcodeMutable,@"code", nil];
                            [codesParsed addObject:codeDict];
                        }
                    }
                    [updatedResults setValue:codesParsed forKey:@"codes"];
                    isCodeWasInsideFile = YES;

                }
                [formatter release];
                
            }
            
            
        }
        
        
        
        //NSArray *codes = [parsedResult valueForKey:@"codes"];
        
        if (!isCodeWasInsideFile) {
            // if user don't have codes, we must fill their choises
            NSString *countryFirstVersion = [updatedResults valueForKey:@"country"];
            NSString *specificFirstVersion = [updatedResults valueForKey:@"specific"];
            if (!specificFirstVersion) specificFirstVersion = @"";
            NSArray *userSpecificDictionaries = [[NSUserDefaults standardUserDefaults] valueForKey:@"userSpecificDictionaries"];
            __block NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(externalCountry == %@) and (externalSpecific == %@)",countryFirstVersion,specificFirstVersion];
            NSArray *filteredUserSpecificDictionaries = [userSpecificDictionaries filteredArrayUsingPredicate:predicate];
            
            if ([filteredUserSpecificDictionaries count] > 0) {
                NSMutableArray *finalCodesList = [NSMutableArray arrayWithCapacity:0];
                //[filteredUserSpecificDictionaries enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *userSpecificDictionary, NSUInteger idx, BOOL *stop) {
                for (NSDictionary *userSpecificDictionary in filteredUserSpecificDictionaries) {
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList"
                                                              inManagedObjectContext:delegate.managedObjectContext];
                    [fetchRequest setEntity:entity];
                    
                    NSString *localCountry = [userSpecificDictionary valueForKey:@"localCountry"];
                    NSString *localSpecific = [userSpecificDictionary valueForKey:@"localSpecific"];
                    predicate = [NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",localCountry,localSpecific];
                    [fetchRequest setPredicate:predicate];
                    
                    NSError *error = nil;
                    NSArray *fetchedObjects = [delegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                    CountrySpecificCodeList *fetchedList = [fetchedObjects lastObject];
                    NSSet *codes = fetchedList.codesList;
                    
                    [codes enumerateObjectsWithOptions:NSSortStable usingBlock:^(CodesList *codesList, BOOL *stop) {                    
                        NSDictionary *codeRow = [NSDictionary dictionaryWithObjectsAndKeys:[codesList.code stringValue],@"code", nil];
                        [finalCodesList addObject:codeRow];
                    }];
                    [fetchRequest release];

                }//];
                [updatedResults setValue:finalCodesList forKey:@"codes"];
                
                isCodeWasInsideFile = YES;
            }

        }
        if (!isCodeWasInsideFile) [updatedResults setValue:@"not finded" forKey:@"finded"];

        if (codeIsNumber) [parsedResult addObject:updatedResults];

    }
//    [delegate.importedCSVparsedSource setContent:parsedResult];
    [delegate.importRatesView.importRatesSecondParserResult setContent:parsedResult];
    NSSortDescriptor *findedSort = [[NSSortDescriptor alloc] initWithKey:@"finded" ascending:NO];
    delegate.importRatesView.importRatesSecondParserResult.sortDescriptors = [NSArray arrayWithObject:findedSort];
    [findedSort release];
}


- (void) importCSVstartWithRelationshipName:(NSString *)relationshipName;
{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    
//    NSDictionary *currenChoices = [[delegate.importedCSVselections arrangedObjects] lastObject];
//    NSNumber *currentTargetChoice = [currenChoices valueForKey:@"selectionChoises"];
//    NSMutableArray *columnChoiceNumbers = [NSMutableArray arrayWithCapacity:0];
//    for (int rows = 0;rows <10 ;rows++)
//    {
//        NSString *selectionName = [NSString stringWithFormat:@"selection%@",[NSNumber numberWithInt:rows]];
//        [columnChoiceNumbers addObject:[currenChoices valueForKey:selectionName]];
//    }
    [self importCSVforArray:[delegate.importRatesView.importRatesFirsParserResult arrangedObjects] 
            forChoiceTarget:nil 
            forChoiceColumn:nil
        forRelationshipName:relationshipName];
    
//    for (NSMutableDictionary *row in [delegate.importRatesView.importRatesFirsParserResult arrangedObjects ]) {
//        //NSLog(@"importCSVstartWithRelationshipName: row is:%@",row);
//        //NSMutableDictionary *row = [[delegate.importedCSVparsedSource arrangedObjects ] objectAtIndex:rowIndex];
//        NSString *countryFirstVersion = [row valueForKey:@"country"];
//        NSString *specificFirstVersion = [row valueForKey:@"specific"];
//        if (!specificFirstVersion) specificFirstVersion = @"";
//        NSArray *userSpecificDictionaries = [[NSUserDefaults standardUserDefaults] valueForKey:@"userSpecificDictionaries"];
//        __block NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(externalCountry == %@) and (externalSpecific == %@)",countryFirstVersion,specificFirstVersion];
//        NSArray *filteredUserSpecificDictionaries = [userSpecificDictionaries filteredArrayUsingPredicate:predicate];
//        
//        if ([filteredUserSpecificDictionaries count] > 0) {
//            //NSDictionary *userSpecififcDictionary = [filteredUserSpecificDictionaries lastObject];
//            //AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//            //NSManagedObjectContext *moc = self.managedObjectContext;//[delegate managedObjectContext];
//            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//            NSEntityDescription *entity = [NSEntityDescription entityForName:@"CountrySpecificCodeList"
//                                                      inManagedObjectContext:self.moc];
//            [fetchRequest setEntity:entity];
//            //NSArray *fetchedObjectsForTest = [moc executeFetchRequest:fetchRequest error:nil];
//            /*[fetchedObjectsForTest enumerateObjectsWithOptions:NSSortConcurrent usingBlock:^(CountrySpecificCodeList *obj, NSUInteger idx, BOOL *stop) {
//             NSLog(@"%@/%@",obj.country,obj.specific);
//             }];*/
//            //NSMutableDictionary *row = [[importedCSVparsedSource selectedObjects ] lastObject];
//            NSMutableArray *finalCodesList = [NSMutableArray arrayWithCapacity:0];
//            //arrayWithArray:[row valueForKey:@"codes"]];
//            
//            [filteredUserSpecificDictionaries enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *userSpecificDictionary, NSUInteger idx, BOOL *stop) {
//                
//                NSString *localCountry = [userSpecificDictionary valueForKey:@"localCountry"];
//                NSString *localSpecific = [userSpecificDictionary valueForKey:@"localSpecific"];
//                
//                
//                predicate = [NSPredicate predicateWithFormat:@"(country == %@) and (specific == %@)",localCountry,localSpecific];
//                [fetchRequest setPredicate:predicate];
//                
//                NSError *error = nil;
//                NSArray *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
//                CountrySpecificCodeList *fetchedList = [fetchedObjects lastObject];
//                NSSet *codes = fetchedList.codesList;
//                
//                [codes enumerateObjectsWithOptions:NSSortStable usingBlock:^(CodesList *codesList, BOOL *stop) {
//                    
//                    //for (NSString *code in codes) {
//                    NSDictionary *codeRow = [NSDictionary dictionaryWithObjectsAndKeys:[codesList.code stringValue],@"code", nil];
//                    
//                    
//                    [finalCodesList addObject:codeRow];
//                    //}
//                    
//                }];
//                
//            }];
//            [row setValue:finalCodesList forKey:@"codes"];
//            
//            [fetchRequest release];
//            
//        }
//    }
    
}

-(void) processRatesStackFor:(NSMutableArray *)ratesStack 
                    progress:(ProgressUpdateController *)progress;
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//    [delegate.recoredStackProcessIndicator setHidden:NO];
    progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[ratesStack count]];
    progress.objectsCount = [NSNumber numberWithUnsignedInteger:0];
    
    NSMutableArray *newStack = [NSMutableArray arrayWithCapacity:[ratesStack count]];
    NSNumberFormatter *rateFormatter = [[NSNumberFormatter alloc] init];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];   
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];

    for (NSDictionary *dataAndRateSheet in ratesStack)
    {
        [progress updateProgressIndicatorRatesStack];

        NSDictionary *data = [dataAndRateSheet valueForKey:@"data"];
        NSString *rateSheetID = [dataAndRateSheet valueForKey:@"rateSheetID"];
        NSDate *effectiveDate = [data valueForKey:@"effectiveDate"];
        if ([effectiveDate timeIntervalSinceDate:[NSDate date]] < 0) {
            NSDictionary *codeList = [[data valueForKey:@"codes"] lastObject]; // here is bcs for rates stack all time one code per record. cheers! $)
            NSString *code = [codeList valueForKey:@"code"];
            NSString *today = [inputFormatter stringFromDate:[NSDate date]];
            NSString *rateString = [rateFormatter stringFromNumber:[data valueForKey:@"rate"]];
            if ([database updateForCode:code forDate:today forRate:rateString forRateSheet:rateSheetID forCountry:[data valueForKey:@"country"] forSpecific:[data valueForKey:@"specific"]]) continue;
            if ([database insertNewCode:code forDate:today forRate:rateString forRateSheetID:rateSheetID forCountry:[data valueForKey:@"country"] forSpecific:[data valueForKey:@"specific"]]) continue;
            NSLog(@"IMPORT: WARNING: imported row:%@\n don't have succceseful update or insert",data);
        } else { 
            [newStack addObject:dataAndRateSheet];
            [progress changeIndicatorRatesStackWithObjectsQuantity:[NSNumber numberWithUnsignedInteger:[newStack count]]];
        }

    }
    [ratesStack removeAllObjects];
    [ratesStack addObjectsFromArray:newStack];
//    [delegate.recoredStackProcessIndicator setHidden:YES];

    [inputFormatter release];
    [rateFormatter release];
    [pool drain]; pool = nil;

}

- (void) updatePriceWithData:(NSDictionary *)data 
               withRateSheet:(NSString *)rateSheet
                withProgress:(ProgressUpdateController *)progress
            withRatesStack:(NSMutableArray *)ratesStack
           withRateFormatter:(NSNumberFormatter *)rateFormatter
           withDateFormatter:(NSDateFormatter *)inputFormatter;

{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDate *effectiveDate = [data valueForKey:@"effectiveDate"];
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    //NSNumberFormatter *rateFormatter = [[NSNumberFormatter alloc] init ];
    //[rateFormatter setFormat:@"#0.0####"];
    //[rateFormatter setDecimalSeparator:@"."];
    //NSDateFormatter *inputFormatter = [[[NSDateFormatter alloc] init] autorelease];
    //[inputFormatter setDateFormat:@"yyyy-MM-dd"];

    if ([effectiveDate timeIntervalSinceDate:[NSDate date]] < 0) {
//        dispatch_async(dispatch_get_main_queue(), ^(void) { 
//            [delegate.destinationsView.importRatesProgress setHidden:NO];
//            delegate.destinationsView.importRatesLabelSecond.stringValue = @"processed:0%";
//            [delegate.destinationsView.importRatesLabelFirs setHidden:NO];
//            [delegate.destinationsView.importRatesLabelSecond setHidden:NO];
//        });
        NSArray *codes = [data valueForKey:@"codes"];
//        NSInteger codesCount = codes.count;
//        NSNumber *codesCountNumber = [NSNumber numberWithInteger:codesCount];
        
        //for (NSDictionary *codeList in [data valueForKey:@"codes"]) {
        [codes enumerateObjectsUsingBlock:^(NSDictionary *codeList, NSUInteger idx, BOOL *stop) {
            
            NSString *code = [codeList valueForKey:@"code"];
            
            // @"rate",@"codes"(array dict with @"code"),@"acd",@"asr",@"country",@"specific",@"minutes",@"attempts"
            NSString *today = [inputFormatter stringFromDate:[NSDate date]];
            
            NSString *rateString = [rateFormatter stringFromNumber:[data valueForKey:@"rate"]];
            NSAssert (rateString != nil,@"rate can't be nil to update in mysql");
            //if ([code length] == 0) NSAssert (nil != nil,@"code can't be empty to update in mysql");
            
            if (![database updateForCode:code forDate:today forRate:rateString forRateSheet:rateSheet forCountry:[data valueForKey:@"country"] forSpecific:[data valueForKey:@"specific"]]) { 
                if (![database insertNewCode:code forDate:today forRate:rateString forRateSheetID:rateSheet forCountry:[data valueForKey:@"country"] forSpecific:[data valueForKey:@"specific"]]) NSLog(@"IMPORT: WARNING: imported row:%@\n don't have succceseful update or insert",data);
            }
//            NSNumber *idxNumber = [NSNumber numberWithInteger:idx];
//            double percent = idxNumber.doubleValue / codesCountNumber.doubleValue ;
//            dispatch_async(dispatch_get_main_queue(), ^(void) { 
//                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
//                [formatter setMaximumFractionDigits:0];
//                delegate.destinationsView.importRatesProgress.doubleValue = percent;
//                NSString *percentString = [formatter stringFromNumber:[NSNumber numberWithDouble:percent * 100]];
//                delegate.destinationsView.importRatesLabelSecond.stringValue = [NSString stringWithFormat:@"processed:%%",percentString];
//                [formatter release];
//            });
        }];
//        dispatch_async(dispatch_get_main_queue(), ^(void) { 
//            [delegate.destinationsView.importRatesProgress setHidden:YES];
//            [delegate.destinationsView.importRatesLabelFirs setHidden:YES];
//            [delegate.destinationsView.importRatesLabelSecond setHidden:YES];
//        });

        //}
    } else {
        //NSMutableArray *ratesStack = [NSMutableArray array];
        //NSMutableArray *ratesStack = [NSMutableArray arrayWithContentsOfFile:[[delegate applicationSupportDirectory] stringByAppendingString:@"/ratesStack.ary"]];
        //if (!ratesStack) ratesStack = [NSMutableArray array];
        NSNumber *rate = [data valueForKey:@"rate"];
        NSDate *effectiveDate = [data valueForKey:@"effectiveDate"];
        NSString *code = [[data valueForKey:@"codes"] valueForKey:@"code"];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(data.rate == %@) and (data.effectiveDate == %@) and (rateSheetID == %@) and (data.codes.code == %@)",rate,effectiveDate,rateSheet,code];
        NSArray *filteredRatesStack = [ratesStack filteredArrayUsingPredicate:predicate];
        
        if ([filteredRatesStack count] == 0) {
            
            [ratesStack addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:data,@"data",rateSheet, @"rateSheetID",nil]];
                
            //BOOL success = [ratesStack writeToFile:[[delegate applicationSupportDirectory] stringByAppendingString:@"/ratesStack.ary"] atomically:YES];
            
            //#pragma unused (success)
            
           // NSLog(@"RATES STACK: Write to file :%@",success ? @"YES" : @"NO");
        }
        [progress changeIndicatorRatesStackWithObjectsQuantity:[NSNumber numberWithUnsignedInteger:[ratesStack count]]];

    }
    [pool drain]; pool = nil;
    //[rateFormatter release];
    
}

- (NSMutableArray *) updateTargetListWithData:(NSDictionary *)data 
                      withCarrierGUID:(NSString *)carrier 
                       withPrefix:(NSString *)prefix 
                  withRateSheetID:(NSString *)rateSheetID 
                withRateSheetName:(NSString *)rateSheetName 
                   withEntityName:(NSString *)entityName;
{
    /*Printing description of data:
    {
        acd = 3;
        asr = "0.5";
        codes =     (
                     {
                         code = 61;
                     }
                     );
        country = "AUSTRALIA - FIXED";
        rate = "0.012";
     forKey:@"minutes"];
     @"attempts"]; 
     @"effectiveDate"]; 
     */
    // change data for destinations controller format
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSArray *codes = [data valueForKey:@"codes"];
    NSMutableArray *codesNew = [NSMutableArray array];
    [codes enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *newRow = [NSMutableDictionary dictionaryWithCapacity:0];
        [newRow setValue:[obj valueForKey:@"code"] forKey:@"code"];
        [newRow setValue:@"y" forKey:@"enabled"];
        [newRow setValue:rateSheetID forKey:@"withRateSheetID"];
        [newRow setValue:rateSheetName forKey:@"rateSheetName"];
        [newRow setValue:prefix forKey:@"prefix"];
        [newRow setValuesForKeysWithDictionary:data];
        [codesNew addObject:newRow];
    }];
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    DestinationsClassController *destinationControllerNew = [[DestinationsClassController alloc] initWithMainMoc:[delegate managedObjectContext]];
    destinationControllerNew.carriers = [NSArray arrayWithObject:carrier];
    destinationControllerNew.externalDataCodes = codesNew;
    destinationControllerNew.progress = nil;
    [destinationControllerNew updateEntity:entityName];
    [pool drain],pool = nil;
    
    if (destinationControllerNew.isDestinationsPushListUpdated) { 
        NSMutableArray *arrayForReturn = destinationControllerNew.insertedDestinationsIDs;
        [destinationControllerNew release];

        return arrayForReturn;
    }
    else { 
        [destinationControllerNew release];

        return nil;
    }
    
}


- (void) importCSVfinishWithProgress:(ProgressUpdateController *)progress withRelationship:(NSString *)relationship;
{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    [progress startImportPrice];
    //@"Price update",@"Add to target list",@"Add to pushlist" - currenChoices
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"selected == %@", [NSNumber numberWithBool:YES]];
    NSArray *carrierListForAdd = [[delegate.importRatesView.addDestinationCarriersList arrangedObjects] filteredArrayUsingPredicate:predicate];
    //NSDictionary *currenChoices = [[delegate.importedCSVselections arrangedObjects] lastObject];

    NSArray *importedCSVparsedSource = [delegate.importRatesView.importRatesSecondParserResult arrangedObjects];

    NSNumber *currentTargetChoice = nil;
//    NSString *title = [delegate.importCSV title];
//    NSAssert(title != nil,@"title can't be nil");
    if ([relationship isEqualToString:@"destinationsListTargets"]) currentTargetChoice = [NSNumber numberWithInt:1];
    if ([relationship isEqualToString:@"destinationsListWeBuy"]) currentTargetChoice = [NSNumber numberWithInt:0];
    if ([relationship isEqualToString:@"destinationsListPushList"]) currentTargetChoice = [NSNumber numberWithInt:2];
    
    //NSLog(@"UPDATE DATA CONTROLLER: importRates will start for relationship:%@/%@ and carriersList:%@ and source:%@",relationship,currentTargetChoice,carrierListForAdd,importedCSVparsedSource);
    
    //[currenChoices valueForKey:@"selectionChoices"];
    //if (!currentTargetChoice) currentTargetChoice = [NSNumber numberWithInt:0];
    
    for (NSDictionary *carrier in carrierListForAdd)
    {
        NSArray *rateSheetsAndPrefixes = [carrier valueForKey:@"rateSheetsAndPrefixes"];
        NSArray *rateSheetsAndPrefixesSelected = nil;
        if ([rateSheetsAndPrefixes count] == 1) rateSheetsAndPrefixesSelected = rateSheetsAndPrefixes;
        else rateSheetsAndPrefixesSelected = [rateSheetsAndPrefixes filteredArrayUsingPredicate:predicate];
        NSString *carrierGUID = [carrier valueForKey:@"GUID"];
        
        if ([rateSheetsAndPrefixesSelected count] != 0) for (NSDictionary *rateSheetAndPrefix in rateSheetsAndPrefixesSelected)
        {
            NSString *rateSheetID = [rateSheetAndPrefix valueForKey:@"rateSheetID"];
            NSString *rateSheetName = [rateSheetAndPrefix valueForKey:@"rateSheetName"];
            NSString *prefix = [rateSheetAndPrefix valueForKey:@"prefix"];
            progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[importedCSVparsedSource count]];
            
            // if user like to remove old rates - why not ;-)
            
            if ([delegate.importRatesView.removePreviousButton state]) {
                
                if ([currentTargetChoice intValue] == 0) { 
                    [database deleteRateSheetWithID:rateSheetID];
                    
                }
                if ([currentTargetChoice intValue] == 1 ) [delegate.destinationsView.destinationsListTargets removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[delegate.destinationsView.destinationsListTargets arrangedObjects] count])]];
                if ([currentTargetChoice intValue] == 2) [delegate.destinationsView.destinationsListPushList removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[delegate.destinationsView.destinationsListPushList arrangedObjects] count])]];
                [self finalSave];    
                    //[self removeFromMainDatabaseDestinationsForCarrier:carrierName withEntityName:kDestinationsListTargets];
                    //[self removeFromMainDatabaseDestinationsForCarrier:carrierName withEntityName:kDestinationsListPushList];

            }
            NSMutableArray *ratesStack = [NSMutableArray arrayWithContentsOfFile:[[delegate applicationFilesDirectory].path stringByAppendingString:@"/ratesStack.ary"]];
            if (!ratesStack) ratesStack = [NSMutableArray array];
            NSNumberFormatter *rateFormatter = [[NSNumberFormatter alloc] init];
            [rateFormatter setFormat:@"#0.0####"];
            [rateFormatter setDecimalSeparator:@"."];
            NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
            [inputFormatter setDateFormat:@"yyyy-MM-dd"];
            NSMutableArray *allInsertedDestinationsIDs = [[NSMutableArray  alloc] initWithCapacity:0];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) { 
#if defined(SNOW_CLIENT_APPSTORE)
                delegate.destinationsView.importRatesLabelFirs.stringValue = @"import rates pushlist";
                delegate.destinationsView.importRatesLabelSecond.stringValue = @"processed:0%";
                [delegate.destinationsView.importRatesLabelFirs setHidden:NO];
                [delegate.destinationsView.importRatesLabelSecond setHidden:NO];

#else
                [delegate.destinationsView.importRatesProgress setHidden:NO];
                if ([currentTargetChoice intValue] == 0) delegate.destinationsView.importRatesLabelFirs.stringValue = @"import rates we buy";
                if ([currentTargetChoice intValue] == 1) delegate.destinationsView.importRatesLabelFirs.stringValue = @"import rates targets";
                if ([currentTargetChoice intValue] == 2) delegate.destinationsView.importRatesLabelFirs.stringValue = @"import rates pushlist";
                
                delegate.destinationsView.importRatesLabelSecond.stringValue = @"processed:0%";
                [delegate.destinationsView.importRatesLabelFirs setHidden:NO];
                [delegate.destinationsView.importRatesLabelSecond setHidden:NO];
                [delegate.destinationsView.importRatesButton setEnabled:NO];

#endif
            });
            NSInteger rowsCount = importedCSVparsedSource.count;
            NSNumber *rowsCountNumber = [[NSNumber alloc] initWithInteger:rowsCount];

            
//            for (NSDictionary *row in importedCSVparsedSource)
            
//            {
            [importedCSVparsedSource enumerateObjectsUsingBlock:^(NSDictionary *row, NSUInteger idx, BOOL *stop) {
                
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

                [progress updateProgressIndicatorRatesStack];
                if ([currentTargetChoice intValue] == 0) { 
                    [self updatePriceWithData:row
                                withRateSheet:rateSheetID
                                 withProgress:progress 
                               withRatesStack:ratesStack 
                            withRateFormatter:rateFormatter 
                            withDateFormatter:inputFormatter];
 
                }
                if ([currentTargetChoice intValue] == 1) [self updateTargetListWithData:row 
                                                                            withCarrierGUID:carrierGUID 
                                                                             withPrefix:prefix 
                                                                        withRateSheetID:rateSheetID 
                                                                      withRateSheetName:rateSheetName 
                                                                         withEntityName:@"DestinationsListTargets"];
                if ([currentTargetChoice intValue] == 2) {
                    NSMutableArray *inseredDestinations = [self updateTargetListWithData:row 
                                                                            withCarrierGUID:carrierGUID 
                                                                             withPrefix:nil 
                                                                        withRateSheetID:nil 
                                                                      withRateSheetName:nil 
                                                                          withEntityName:@"DestinationsListPushList"];
                    [allInsertedDestinationsIDs addObjectsFromArray:inseredDestinations];

                }
                NSNumber *idxNumber = [NSNumber numberWithInteger:idx];
                double percent = idxNumber.doubleValue / rowsCountNumber.doubleValue ;
                dispatch_async(dispatch_get_main_queue(), ^(void) { 
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    [formatter setMaximumFractionDigits:2];
                    delegate.destinationsView.importRatesProgress.doubleValue = percent * 100;
                    NSString *percentString = [formatter stringFromNumber:[NSNumber numberWithDouble:percent * 100]];
                    delegate.destinationsView.importRatesLabelSecond.stringValue = [NSString stringWithFormat:@"processed: %@%%",percentString];
                    [formatter release];
                });


                [pool drain],pool = nil;
//            }
            }];
//            if ([currentTargetChoice intValue] == 0) {

                dispatch_async(dispatch_get_main_queue(), ^(void) { 
#if defined(SNOW_CLIENT_APPSTORE)
                    [delegate.destinationsView.importRatesProgress setHidden:YES];
                    [delegate.destinationsView.importRatesLabelFirs setHidden:YES];
                    [delegate.destinationsView.importRatesLabelSecond setHidden:YES];

#else 
                    [delegate.destinationsView.importRatesProgress setHidden:YES];
                    [delegate.destinationsView.importRatesLabelFirs setHidden:YES];
                    [delegate.destinationsView.importRatesLabelSecond setHidden:YES];
                    [delegate.destinationsView.importRatesButton setEnabled:YES];

#endif
                });
//            }

            [rowsCountNumber release];
            
            //NSLog(@"UPDATE DATA CONTROLLER: inserted IDS:%@",allInsertedDestinationsIDs);
            if ([allInsertedDestinationsIDs count] > 0) {
                
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                    
//                    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//                    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                [allInsertedDestinationsIDs enumerateObjectsUsingBlock:^(NSManagedObjectID *necessaryID, NSUInteger idx, BOOL *stop) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
                        
//                        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
                        ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[[delegate managedObjectContext] persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
                        
                        //sleep(1);
                        [clientController putObjectWithTimeoutWithIDs:[NSArray arrayWithObject:necessaryID] mustBeApproved:NO];
                        [clientController release];
                    });
                }];
                
                //                });
#endif
            }
            
            //BOOL success = 
            [ratesStack writeToFile:[[delegate applicationFilesDirectory].path stringByAppendingString:@"/ratesStack.ary"] atomically:YES];
            //NSLog(@"RATES STACK: Write to file :%@",success ? @"YES" : @"NO");
            [rateFormatter release];
            [inputFormatter release];
            [allInsertedDestinationsIDs release];
            [self finalSave];    

        }
        else
        {
            for (NSDictionary *row in importedCSVparsedSource)
            {
                if ([currentTargetChoice intValue] == 1) [self updateTargetListWithData:row 
                                                                            withCarrierGUID:carrierGUID 
                                                                             withPrefix:nil 
                                                                        withRateSheetID:nil 
                                                                      withRateSheetName:nil 
                                                                         withEntityName:@"DestinationsListTargets"];
                if ([currentTargetChoice intValue] == 2) [self updateTargetListWithData:row 
                                                                            withCarrierGUID:carrierGUID 
                                                                             withPrefix:nil 
                                                                        withRateSheetID:nil 
                                                                      withRateSheetName:nil 
                                                                         withEntityName:@"DestinationsListPushList"];
            }

        }
    }
    [self finalSave];
    [progress stopImportPrice];

}

-(NSMutableDictionary *) parseRulesForIVRforResults:(NSArray *)result;

{
    //result = [NSArray arrayWithContentsOfFile:@"/Users/alex/Documents/rulesParsed.ary"];
    NSArray *carriersList = [result objectAtIndex:0];
    NSMutableDictionary *finalResult = [NSMutableDictionary dictionary];
    [carriersList enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != 0) [finalResult setValue:[NSMutableDictionary dictionary] forKey:obj];
    }];
    
    [result enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx != 0) {
           // NSString *countryName = [obj objectAtIndex:0];
            NSMutableArray *percents = [NSMutableArray arrayWithArray:obj];
            //[percents removeObjectAtIndex:0];
            [percents enumerateObjectsWithOptions:NSSortStable usingBlock:^(id percent, NSUInteger idx, BOOL *stop) {
                if (idx != 0) {
                    NSString *carrierName = [carriersList objectAtIndex:idx];
                    NSString *destinationSpecific = [percents objectAtIndex:0];
                    NSMutableDictionary *currentDestinationsList = [finalResult valueForKey:carrierName];
                    //NSString *percents = percent;
                    [currentDestinationsList setValue:percent forKey:destinationSpecific];

                }
            }];

        }
    }];
    
    //[self parseInternalDataToRulesForIVR:finalResult];
    return finalResult;
    
}

-(NSMutableString *) parseInternalDataToRulesForIVR:(NSMutableDictionary *)result
{
    NSMutableArray *carriersRow = [NSMutableArray array];
    [carriersRow addObject:@" "];
    NSMutableArray *destinationsRows = [NSMutableArray array];
    
    [result enumerateKeysAndObjectsWithOptions:NSSortStable usingBlock:^(id carrier, id destinations, BOOL *stop) {
        [carriersRow addObject:carrier];
        NSMutableDictionary *destinationsList = destinations;
        __block int index = 0;
        [destinationsList enumerateKeysAndObjectsWithOptions:NSSortStable usingBlock:^(id country, id percent, BOOL *stop) {
            if ([destinationsRows count] <= index) {
                // this is a first column
                [destinationsRows addObject:[NSMutableArray arrayWithObject:country]];
                NSMutableArray *currentRow = [destinationsRows objectAtIndex:index];
                [currentRow addObject:percent];

            } else {
                // this is all other columns (percent)
                NSMutableArray *currentRow = [destinationsRows objectAtIndex:index];
                [currentRow addObject:percent];
            }
            index++;
        }];
        
    }];
    
    //[carriersRow addObjectsFromArray:destinationsRows];
    NSMutableArray *resultForFile = [NSMutableArray arrayWithObject:carriersRow];
    
    //NSSortDescriptor *decending = [NSSortDescriptor 
    [resultForFile addObjectsFromArray:destinationsRows];
    
    NSMutableString *finalFile = [NSMutableString string];
    [resultForFile enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [finalFile appendFormat:@"%@\n",[obj componentsJoinedByString:@"\t"]];
    
    }];
    //NSLog(@"%@",finalFile);
    //[finalFile writeToFile:@"/Users/alex/Documents/rulesParsed.txt" atomically:YES encoding:NSASCIIStringEncoding error:nil];
    
    return finalFile;
}

#pragma mark -
#pragma mark SYNC methods


- (void) everyHourSync;

{
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];

    if (delegate.queueForUpdatesBusy) { 
        NSLog(@"UPDATE DATA CONTROLLER: keeping everyHourSync out");
        return; 
    }
    delegate.queueForUpdatesBusy = YES;

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc]];
    ClientController *clientController = [[ClientController alloc] initWithPersistentStoreCoordinator:[delegate persistentStoreCoordinator] withSender:self withMainMoc:[delegate managedObjectContext]];
    CompanyStuff *authorizedUser = [clientController authorization];
    [clientController release];

    [request setPredicate:[NSPredicate predicateWithFormat:@"(financialRate != 0) AND (companyStuff == %@)",authorizedUser]];
    NSError *error = nil;
    NSArray *carriers = [self.moc executeFetchRequest:request error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
    [request release], request = nil;
    
    NSMutableArray *carriersToExecute = [NSMutableArray array];
    NSLog (@"CYCLE UPDATES: everyHourSync carriers list:");
    for (Carrier *carrier in carriers) { [carriersToExecute addObject:[carrier objectID]];
        NSLog (@"%@",carrier.name);
    }
    ProgressUpdateController *progress = (ProgressUpdateController *)[[ProgressUpdateController alloc] initWithDelegate:delegate];
    [self startUserChoiceSyncForCarriers:carriersToExecute withProgress:progress withOperationName:@"Every hour sync"];
    [progress release];

}

- (void) twicePerDaySyncWithProgress:(ProgressUpdateController *)progress;
{
    
//    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    delegate.queueForUpdatesBusy = YES;

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"financialRate > 0"]];
    NSError *error = nil;
    NSArray *carriers = [self.moc executeFetchRequest:request error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
    [request release], request = nil;
    //[progress updateProgressIndicatorMessageGetExternalData:@"twice per day sync"];

    NSMutableArray *carriersToExecute = [NSMutableArray arrayWithCapacity:0];
    for (Carrier *carrier in carriers) {
        [carriersToExecute addObject:carrier.name];
    }
    NSLog (@"CYCLE UPDATES: twicePerDaySyncWithProgress carriers list:\n%@",carriersToExecute);
    [self startUserChoiceSyncForCarriers:carriersToExecute withProgress:progress withOperationName:@"Twice per hour sync"];

}

//- (void) everyDaySyncWithProgress:(ProgressUpdateController *)progress;
//{
////    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//
//    while (delegate.queueForUpdatesBusy)
//    {
//        sleep (5); 
//        NSLog (@"CYCLE UPDATES: operation every day sync - waiting for empty queue");  
//    }
//    
//    delegate.queueForUpdatesBusy = YES;
//
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:[NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc]];
//    CompanyStuff *authorizedStuff = (CompanyStuff *)[self.moc objectWithID:self.autorizedUserID];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"(financialRate == 0) or (financialRate == nil) AND (companyStuff.GUID == %@)",authorizedStuff.GUID]];
//    NSError *error = nil;
//    NSArray *carriers = [self.moc executeFetchRequest:request error:&error];
//    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
//    //[progress updateProgressIndicatorMessageGetExternalData:@"every day sync"];
//
//    NSMutableArray *carriersToExecute = [NSMutableArray arrayWithCapacity:0];
//    for (Carrier *carrier in carriers) {
//        [carriersToExecute addObject:[carrier objectID]];
//
//    }
//    [request release], request = nil;
//
//    //NSLog (@"CYCLE UPDATES: everyDaySyncWithProgress carriers list:\n%@",carriersToExecute);
//    [self startUserChoiceSyncForCarriers:carriersToExecute withProgress:progress withOperationName:@"Every day sync"];
//}


#pragma mark -
#pragma mark CORE DATA methods


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

-(BOOL) finalSave {
    if ([moc hasChanges]) {
        NSError *error = nil;
        if (![moc save: &error]) {
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
            return NO;
        }
    }
    return YES;

}

-(void) reloadLocalDataFromUserDataControllerForObject:(id)object;
{
    NSLog(@"USER CONTROLLER: export to server was done");
    [self finalSave]; 
}


@end
