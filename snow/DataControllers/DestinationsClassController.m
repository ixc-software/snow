
//
//  DestinationsClassController.m
//  snow
//
//  Created by Oleksii Vynogradov on 21.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import "DestinationsClassController.h"
#import "ProjectArrays.h"
#import "DestinationsView.h"
#import "desctopAppDelegate.h"

#import "DestinationsListForSale.h"
#import "DestinationsListWeBuy.h"
#import "DestinationsListTargets.h"
#import "DestinationsListPushList.h"
#import "DestinationPerHourStat.h"
#import "CodesvsDestinationsList.h"
#import "Carrier.h"
#import "CodesList.h"
#import "CountrySpecificCodeList.h"
//#import "UserDataController.h"

// here is all private functions and properties
@interface DestinationsClassController () 

//@private
/*{
    BOOL destinationsListForSale;
    BOOL destinationsListWeBuy;
    BOOL destinationsListTargets;
}*/

@property (readwrite) BOOL destinationsListForSale;
@property (readwrite) BOOL destinationsListWeBuy;
@property (readwrite) BOOL destinationsListTargets;
//@property (assign) NSManagedObjectContext *mainMoc;
//@property (retain) NSManagedObjectContext *moc;
@property (retain) NSMutableString *currentCarrierName;
@property (retain) NSManagedObjectID *currentCarrierID;

- (NSMutableDictionary *) findCountrySpecificForCode:(NSString *)code;
- (void) removeFromMainDatabaseDestinations24hStatisticForCarrierGUID:(NSString *)carrierName withEntityName:(NSString *)entityName; //withMoc:(NSManagedObjectContext *)moc;
- (BOOL)safeSave; 

@end



@implementation DestinationsClassController
@synthesize delegate;

@synthesize externalDataCodes;
@synthesize internalCodes;
@synthesize additionalMessageForUser;
@synthesize usedCodesWithStatistic;
@synthesize carriers;
@synthesize destinations;
@synthesize progress;
@synthesize moc;
@synthesize insertedDestinationsIDs;
@synthesize isDestinationsPushListUpdated;
//@synthesize mainMoc;
@synthesize destinationsListForSale;
@synthesize destinationsListWeBuy;
@synthesize destinationsListTargets;
@synthesize currentCarrierName;
@synthesize currentCarrierID;

- (id)initWithMainMoc:(NSManagedObjectContext *)itsMainMoc;
{
    self = [super init];
    if (self) {
        //mainMoc = itsMainMoc;
        destinationsListForSale = NO;
        destinationsListWeBuy = NO;
        destinationsListTargets = NO;
        insertedDestinationsIDs = [[NSMutableArray alloc] init];
        delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        moc = [[NSManagedObjectContext alloc] init];
        [moc setStalenessInterval:0.0000001213];

        [moc setUndoManager:nil];
        //[moc setMergePolicy:NSOverwriteMergePolicy];
        [moc setPersistentStoreCoordinator:[delegate persistentStoreCoordinator]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(importerDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];

        currentCarrierName = [[NSMutableString alloc] initWithCapacity:0];
    }
    
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
    [insertedDestinationsIDs release];
    [usedCodesWithStatistic release];
    [carriers release];
    [progress release];
    [moc release];
    [currentCarrierName release];
    [currentCarrierID release];
    [super dealloc];
}

- (void)importerDidSave:(NSNotification *)saveNotification {
    NSManagedObjectContext *mainMoc = [delegate managedObjectContext];
    [mainMoc performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
                              withObject:saveNotification
                           waitUntilDone:NO];

//    if (![NSThread isMainThread]) {
//        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
//        return; 
//    }
//    
//    [delegate.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];

//    NSLog(@"MERGE in destination controller:%@",saveNotification);
//    AppDelegate *delegate = [[NSApplication sharedApplication] delegate];
////    @synchronized (delegate) {
////    }
//    
//    if ([NSThread isMainThread]) {
////    @synchronized (delegate) {
//        
//        [[delegate managedObjectContext] mergeChangesFromContextDidSaveNotification:saveNotification];
//
//            
////            [delegate.destinationsView localMocMustUpdate];
//            
//            delegate.isAnyControllersMakeMerge = NO;
////        }
//        
//    } else {
////        while (delegate.isAnyControllersMakeMerge) {
////            sleep(2);
////            //NSLog(@"MERGE in destination controller waiting");
////            
////        } 
////        delegate.isAnyControllersMakeMerge = YES;
////        
//        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
//    }
}


//- (void)mergeChanges:(NSNotification *)notification;
//{
////    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//
//	NSManagedObjectContext *mainContext = [delegate managedObjectContext];
//	
//	// Merge changes into the main context on the main thread
//	[mainContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:)	
//                                  withObject:notification
//                               waitUntilDone:YES];
//}

#pragma mark TODO - check if peerID important for targets import

- (BOOL) updateEntity:(NSString *)entityName;
{
    if ([externalDataCodes count] == 0) return YES;
    @autoreleasepool {
        
        //    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSError *error = nil;
        
        isDestinationsPushListUpdated = NO;
        NSString *globalUID = nil;
        
        if ([externalDataCodes count] > 5000) { 
            [progress updateOperationName:[NSString stringWithFormat:@"IMPORT DESTINATIONS:%@ waiting to finish heavy operation...",entityName]]; 
            globalUID = [[NSString alloc] initWithString:[[NSProcessInfo processInfo] globallyUniqueString]];
            //        NSUInteger processorCount = [[NSProcessInfo processInfo] activeProcessorCount];
            //        if (processorCount > 3) {
            //            processorCount = (processorCount - 3);
            //        } else
            //        {
            //            processorCount = 2;
            //        }
            NSUInteger processorCount = 2;
            
            while (delegate.numberForHardJobConcurentLines > processorCount)
            {
                sleep (2); 
                //NSLog (@"DESTINATIONS: operation waiting for finish heavy operation");  
            }
            [progress updateOperationName:[NSString stringWithFormat:@"IMPORT DESTINATIONS:%@",entityName]]; 
            
            @synchronized (delegate) {
                delegate.numberForHardJobConcurentLines = delegate.numberForHardJobConcurentLines + 1;
            }
        }
        
        //    UserDataController *userController = [[UserDataController alloc] init];
        //    userController.context = self.context;
        
        if (!self.additionalMessageForUser) self.additionalMessageForUser = @"";
        [progress updateOperationName:[NSString stringWithFormat:@"IMPORT DESTINATIONS:%@ %@ ",entityName,self.additionalMessageForUser]]; 
        
        if ([entityName isEqualToString:@"DestinationsListForSale"]) destinationsListForSale = YES;
        if ([entityName isEqualToString:@"DestinationsListWeBuy"]) destinationsListWeBuy = YES;
        if ([entityName isEqualToString:@"DestinationsListTargets"]) destinationsListTargets = YES;
        if ([entityName isEqualToString:@"DestinationsListPushList"]) destinationsListPushList = YES;
        
        
        
        progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[externalDataCodes count]];
        
        //NSLog(@"External destinationsList: %@\n for type of destinstion %@", externalDestinationsList, destinationTypeString);
        //    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSDateFormatter *formatterDate = [[NSDateFormatter alloc] init];
        [formatterDate setDateFormat:@"yyyy-MM-dd"];
        //NSPredicate *predicate;
        
        // we have to check and delete codes, which was delete from system 
        for (NSString *carrierGUID in carriers) {
            
            NSMutableArray *updatedDestinationsIDs = [[NSMutableArray alloc] init];

            
            
            NSFetchRequest *fetchRequestForCarriers = [[NSFetchRequest alloc] init];
            // get carrier object
            NSEntityDescription *entityForCarriers = [NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:self.moc];
            [fetchRequestForCarriers setEntity:entityForCarriers];
            NSPredicate *predicateForCarriers = [NSPredicate predicateWithFormat:@"(GUID == %@)",carrierGUID];
            [fetchRequestForCarriers setPredicate:predicateForCarriers];
            
            NSArray *carriersInternal = [self.moc executeFetchRequest:fetchRequestForCarriers error:&error];
            
            if (carriersInternal == nil) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
            __block Carrier *carrier = [carriersInternal lastObject];
            if (!carrier) {
                NSLog(@"UPDATE DESTINATION LIST WARNING: carrier not found for fetchRequest:%@",fetchRequestForCarriers);
            }
            [fetchRequestForCarriers release];
            
            // get full codes list
            
            NSFetchRequest *fetchRequestForCode = [[NSFetchRequest alloc] init];
            NSDate *startCheckPresentedCodes = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            
            NSArray *distinctCodes = [externalDataCodes valueForKeyPath:@"@distinctUnionOfObjects.code"];
            NSArray *distinctPrefixes = [externalDataCodes valueForKeyPath:@"@distinctUnionOfObjects.prefix"];
            NSArray *distinctPeerID = [externalDataCodes valueForKeyPath:@"@distinctUnionOfObjects.peerID"];
            NSPredicate *carrierPredicate = nil;
            if (destinationsListForSale) carrierPredicate = [NSPredicate predicateWithFormat:@"destinationsListForSale.carrier.GUID == %@",carrier.GUID];
            if (destinationsListWeBuy) carrierPredicate = [NSPredicate predicateWithFormat:@"destinationsListWeBuy.carrier.GUID == %@",carrier.GUID];
            if (destinationsListTargets) carrierPredicate = [NSPredicate predicateWithFormat:@"destinationsListTargets.carrier.GUID == %@",carrier.GUID];
            if (destinationsListPushList) carrierPredicate = [NSPredicate predicateWithFormat:@"destinationsListPushList.carrier.GUID == %@",carrier.GUID];
            
            NSEntityDescription *entityForCode = [NSEntityDescription entityForName:@"CodesvsDestinationsList"
                                                             inManagedObjectContext:self.moc];
            
            NSArray *allPredicates = nil;
            if (destinationsListForSale || destinationsListWeBuy) allPredicates = [NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"(code IN %@) or (originalCode IN %@)",distinctCodes,distinctCodes],[NSPredicate predicateWithFormat:@"prefix IN %@",distinctPrefixes],[NSPredicate predicateWithFormat:@"peerID IN %@",distinctPeerID], nil];
            else allPredicates = [NSArray arrayWithObjects:[NSPredicate predicateWithFormat:@"(code IN %@) or (originalCode IN %@)",distinctCodes,distinctCodes],nil];
            
            NSPredicate *filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:allPredicates];
            
            [fetchRequestForCode setPredicate:filterPredicate];
            [fetchRequestForCode setEntity:entityForCode];
            NSArray *allCarrierCodesImmutable = [self.moc executeFetchRequest:fetchRequestForCode error:&error];
            NSMutableArray *allCarrierCodes = [NSMutableArray arrayWithArray:allCarrierCodesImmutable];
            
            [fetchRequestForCode release];
            NSTimeInterval interval = [startCheckPresentedCodes timeIntervalSinceDate:[NSDate date]];
            NSLog(@"DESTINATIONS CLASS time to check codes was:%@ sec, result:",[NSNumber numberWithDouble:interval]);
            [currentCarrierName appendString:carrier.name];
            self.currentCarrierID = [carrier objectID];
            NSMutableArray *destinationsForCheckingLater = [[NSMutableArray alloc] init];
            
            
            if (destinationsListForSale) {
                NSFetchRequest *fetchRequestForDestinationsListForSale = [[NSFetchRequest alloc] init];
                NSEntityDescription *entityForDestinationsListForSale = [NSEntityDescription entityForName:@"DestinationsListForSale"
                                                                                    inManagedObjectContext:self.moc];
                [fetchRequestForDestinationsListForSale setEntity:entityForDestinationsListForSale];
                [fetchRequestForDestinationsListForSale setResultType:NSDictionaryResultType];
                [fetchRequestForDestinationsListForSale setPredicate:[NSPredicate predicateWithFormat:@"(carrier.name == %@)",carrier.name]];
                NSArray *destinationsLocal = [self.moc executeFetchRequest:fetchRequestForDestinationsListForSale error:&error];
                
                [fetchRequestForDestinationsListForSale release];
                if (destinationsLocal == nil) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
                [destinationsForCheckingLater addObjectsFromArray:destinationsLocal];
                
            }
            if (destinationsListWeBuy) {
                NSFetchRequest *fetchRequestForDestinationsListWeBuy = [[NSFetchRequest alloc] init];
                NSEntityDescription *entityForDestinationsListWeBuy = [NSEntityDescription entityForName:@"DestinationsListWeBuy"
                                                                                  inManagedObjectContext:self.moc];
                [fetchRequestForDestinationsListWeBuy setEntity:entityForDestinationsListWeBuy];
                [fetchRequestForDestinationsListWeBuy setResultType:NSDictionaryResultType];
                [fetchRequestForDestinationsListWeBuy setPredicate:[NSPredicate predicateWithFormat:@"(carrier.name == %@)",carrier.name]];
                NSArray *destinationsLocal = [self.moc executeFetchRequest:fetchRequestForDestinationsListWeBuy error:&error];

                [fetchRequestForDestinationsListWeBuy release];
                if (destinationsLocal == nil) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
                [destinationsForCheckingLater addObjectsFromArray:destinationsLocal];
            }
            if (destinationsListTargets) {
                NSFetchRequest *fetchRequestForDestinationsListTargets = [[NSFetchRequest alloc] init];
                NSEntityDescription *entityForDestinationsListTargets = [NSEntityDescription entityForName:@"destinationsListTargets"
                                                                                    inManagedObjectContext:self.moc];
                [fetchRequestForDestinationsListTargets setEntity:entityForDestinationsListTargets];
                [fetchRequestForDestinationsListTargets setResultType:NSDictionaryResultType];
                
                [fetchRequestForDestinationsListTargets setPredicate:[NSPredicate predicateWithFormat:@"(carrier.name == %@)",carrier.name]];
                NSArray *destinationsLocal = [self.moc executeFetchRequest:fetchRequestForDestinationsListTargets error:&error];
                [fetchRequestForDestinationsListTargets release];
                if (destinationsLocal == nil) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
                [destinationsForCheckingLater addObjectsFromArray:destinationsLocal];
            }
            if (destinationsListPushList) {
                NSFetchRequest *fetchRequestForDestinationsListPushList = [[NSFetchRequest alloc] init];
                NSEntityDescription *entityForDestinationsListPushList = [NSEntityDescription entityForName:@"DestinationsListPushList"
                                                                                     inManagedObjectContext:self.moc];
                [fetchRequestForDestinationsListPushList setEntity:entityForDestinationsListPushList];
                [fetchRequestForDestinationsListPushList setResultType:NSDictionaryResultType];
                
                [fetchRequestForDestinationsListPushList setPredicate:[NSPredicate predicateWithFormat:@"(carrier.name == %@)",carrier.name]];
                NSArray *destinationsLocal = [self.moc executeFetchRequest:fetchRequestForDestinationsListPushList error:&error];
                [fetchRequestForDestinationsListPushList release];
                if (destinationsLocal == nil) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
                [destinationsForCheckingLater addObjectsFromArray:destinationsLocal];
            }
            
            NSLog(@"For carrier:%@  total codes:%@ withExternalCodes:%@",carrier.name,[NSNumber numberWithUnsignedInteger:[allCarrierCodes count]],[NSNumber numberWithUnsignedInteger:[externalDataCodes count]]);
            double countExternalDataCode = [[NSNumber numberWithInteger:[externalDataCodes count]] doubleValue];
            int everyCountForCountUpdate = [[NSNumber numberWithDouble:countExternalDataCode * 0.01] intValue];
            int everyCountForCoreDataUpdate = [[NSNumber numberWithDouble:countExternalDataCode * 0.1] intValue];
            NSUInteger idx = 0;
            for (NSDictionary *destinationsExternal in externalDataCodes) {
                @autoreleasepool {
                    if (idx != 0 && everyCountForCountUpdate != 0 && idx % everyCountForCountUpdate == 0) {
                        [progress updateCurrentObjectsCount];
                    }
                    if (idx != 0 && [externalDataCodes count] > 100 && idx % everyCountForCoreDataUpdate == 0) {
                        //                //NSString *carrierNameForShow = carrier.name;
                        //                NSNumber *idxNumber = [NSNumber numberWithUnsignedInteger:idx];
                        //                NSNumber *externalDataCodesCount = [NSNumber numberWithUnsignedInteger:[externalDataCodes count]];
                        //                NSNumber *codesForCarrierCount = [NSNumber numberWithUnsignedInteger:[codesForCarrier count]];
                        //                NSNumber *destinationsForCheckingLaterCount = [NSNumber numberWithUnsignedInteger:[destinationsForCheckingLater count]];
                        
                        //                NSLog(@"Core data reseted for carrier:%@ with object number:%@ for codes Count:%@ and total codes for compare:%@ and destinations for compare:%@",currentCarrierName,idxNumber,externalDataCodesCount,codesForCarrierCount,destinationsForCheckingLaterCount);
                        //                [self safeSave];
                        //[pool drain], pool = nil;
                        //pool = [[NSAutoreleasePool alloc] init];
                        //                NSError *error = nil;
                        //                if ([self.moc hasChanges]) { 
                        //                    [self.moc save:&error];
                        //                    if (error) NSLog(@"DESTINATIONS:save error is:%@",[error localizedDescription]);
                        //                    else {
                        //                        NSSet *registeredObjects = [self.moc registeredObjects];
                        //                        for (NSManagedObject *obj in registeredObjects) {
                        //                            [self.moc refreshObject:obj mergeChanges:NO];
                        //                        }
                        //                    }
                        //                }
                        //[pool drain], pool = nil;
                        //pool = [[NSAutoreleasePool alloc] init];
                        
                    }
                    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                    
                    // format code
                    NSString *codeStr = [destinationsExternal valueForKey:@"code"];
                    NSNumber *code = [formatter numberFromString:codeStr];
                    NSNumber *originalCode = nil;
                    
                    NSString *country = nil;
                    NSString *specific = nil;
                    
                    if (code) {
                        
                        if (codeStr) { 
                            NSUInteger maxCodesDeep = 11;
                            if ([codeStr length] < maxCodesDeep) maxCodesDeep = [codeStr length];
                            NSDictionary *countrySpecific = [[ProjectArrays sharedProjectArrays].dictionaryDictionaryesForCountryCodes valueForKey:codeStr];
                            if ([[countrySpecific allKeys] count] == 2) {
                                country = [countrySpecific valueForKey:@"country"];
                                specific = [countrySpecific valueForKey:@"specific"];
                            } else 
                            {
                                // start deeper search
                                if (maxCodesDeep > 1) {
                                    NSRange currentRange = NSMakeRange(0,[codeStr length]);
                                    
                                    for (int codesDeep = 0; codesDeep < maxCodesDeep;codesDeep++)
                                    {
                                        currentRange.length = currentRange.length - 1;
                                        NSString *changedCodeStr = [codeStr substringWithRange:currentRange];
                                        //NSLog(@"search for code :%@", changedCode);
                                        countrySpecific = [[ProjectArrays sharedProjectArrays].dictionaryDictionaryesForCountryCodes valueForKey:changedCodeStr];
                                        if ([[countrySpecific allKeys] count] == 2)
                                        {
                                            NSNumber *changedCode = [formatter numberFromString:changedCodeStr];
                                            originalCode = [NSNumber numberWithDouble:[code doubleValue]];
                                            code = [NSNumber numberWithDouble:[changedCode doubleValue]];
                                            country = [countrySpecific valueForKey:@"country"];
                                            specific = [countrySpecific valueForKey:@"specific"];
                                            break;
                                        }  
                                        //[pool drain], pool = nil;
                                        //pool = [[NSAutoreleasePool alloc] init];
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        else
                        {
                            NSLog(@"UPDATE DESTINATION LIST WARNING: CODE IS EMPTY for destinationParameters:%@",destinationsExternal);
                        }
                        NSAssert( country != nil || specific != nil,@"UPDATE DESTINATION:country/specific can't be nil");
                        
                        //                if ([code isEqualToNumber:[NSNumber numberWithInt:9613]]) {
                        //                    NSLog(@"DESTINATION CONTROLLER:%@",destinationsExternal);
                        //                }
                        // format prefix 
                        NSString *prefix = [destinationsExternal valueForKey:@"prefix"];
                        
                        // format enable
                        BOOL enabledState = YES;
                        NSString *enabledString = [destinationsExternal valueForKey:@"enabled"];
                        NSString *yn = [destinationsExternal valueForKey:@"yn"];
                        if (([enabledString isEqualToString:@"n"]) || ([yn isEqualToString:@"n"])) enabledState = NO;
                        NSNumber *enabled = [NSNumber numberWithBool:enabledState];
                        
                        //format rate
                        NSNumber *rate = nil;
                        NSString *externalRate = [destinationsExternal valueForKey:@"price"];
                        
                        if ([[[destinationsExternal valueForKey:@"price"] class] isSubclassOfClass:[NSNumber class]]) rate = [destinationsExternal valueForKey:@"price"];
                        else {
                            externalRate = [externalRate stringByReplacingOccurrencesOfString:@"." withString:@","];
                            rate = [formatter numberFromString:externalRate];  
                        }
                        if (!rate) {
                            externalRate = [externalRate stringByReplacingOccurrencesOfString:@"," withString:@"."];
                            rate = [formatter numberFromString:externalRate];  
                            
                            //NSLog(@"DESTINATIONS CLASS: warning, rate not found for %@",destinationsExternal);
                        } 
                        if (!rate) NSLog(@"DESTINATIONS CLASS: warning, rate not found for %@",destinationsExternal);
                        
                        // format ratesheet name
                        NSString *rateSheetName = [destinationsExternal valueForKey:@"rateSheetName"];
                        //if (!rateSheetName) rateSheetName = @"Price table";
                        
                        // format peerID
                        NSString *peerIDStr = [destinationsExternal valueForKey:@"peerID"];
                        NSNumber *peerID = [formatter numberFromString:peerIDStr];
                        
                        // format rateSheetID
                        NSString *rateSheetID = [destinationsExternal valueForKey:@"rateSheetID"];
                        
                        // format chdate
                        NSString *chdate = [destinationsExternal objectForKey:@"chdate"];
                        NSDate *changeDate = [formatterDate dateFromString:chdate];
                        
                        //format ip
                        NSString *ip = [destinationsExternal valueForKey:@"ip"];
                        if (!ip) ip = @"undefined with local price";
                        
                        // get current code
                        NSPredicate *predicateForCurrentCodes = nil;
                        if (destinationsListForSale || destinationsListWeBuy) {
                            predicateForCurrentCodes = [NSPredicate predicateWithFormat:@"(code == %@ AND originalCode == %@) and (prefix == %@) and (peerID == %@)",
                                                        code,originalCode,prefix,peerID];
                        };
                        if (destinationsListTargets || destinationsListPushList) {
                            predicateForCurrentCodes = [NSPredicate predicateWithFormat:@"(code == %@ AND originalCode == %@)",code,originalCode];
                        }
                        
                        NSArray *codesFilteredFirstStep = [allCarrierCodesImmutable filteredArrayUsingPredicate:predicateForCurrentCodes];
                        NSMutableArray *codesFilteredFirstStepMutable = [NSMutableArray arrayWithArray:codesFilteredFirstStep];

                        if ([codesFilteredFirstStepMutable count] > 1) { 
                            [codesFilteredFirstStepMutable enumerateObjectsUsingBlock:^(CodesvsDestinationsList *code, NSUInteger idx, BOOL *stop) {
                                NSLog(@"UPDATE DESTINATION LIST:duplicate code will removed:%@ originalCode:%@ %@/%@ prefix:%@ peerID:%@ carrier:%@",code.code,code.originalCode,code.country,code.specific,code.prefix,code.peerID,carrier.name);
                                if (idx > 0) [self.moc deleteObject:code];
                            }];
                            [codesFilteredFirstStepMutable removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, codesFilteredFirstStepMutable.count - 1)]];
                            //NSLog(@"UPDATE DESTINATION LIST: final count of codesFilteredFirstStepMutable:%@",[NSNumber numberWithInteger:codesFilteredFirstStepMutable.count]);

                        }

                        // insert  new destination and add code
                        if ([codesFilteredFirstStepMutable count] == 0) {
                            // check if destination if already added
                            NSPredicate *predicateForDestinationsFirstStep = nil;
                            
                            if (destinationsListForSale || destinationsListWeBuy) {
                                predicateForDestinationsFirstStep = [NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@) and (prefix == %@) and (rateSheet == %@)",
                                                                     country,specific,prefix,rateSheetName];
                            }
                            if (destinationsListTargets || destinationsListPushList) {
                                predicateForDestinationsFirstStep = [NSPredicate predicateWithFormat:@"(country contains %@) AND (specific contains %@)",
                                                                     country,specific];
                            }
                            
                            NSArray *findedDestinationsAlreadyCreated = [destinationsForCheckingLater filteredArrayUsingPredicate:predicateForDestinationsFirstStep];
                            
                            
                            if (destinationsListForSale) {
                                CodesvsDestinationsList *objectCode = (CodesvsDestinationsList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                                objectCode.code = code;
                                objectCode.externalChangedDate = changeDate;
                                objectCode.country = country;
                                objectCode.specific = specific;
                                objectCode.originalCode = originalCode;
                                objectCode.rate = rate;
                                objectCode.prefix = prefix;
                                objectCode.rateSheetName = rateSheetName;
                                objectCode.rateSheetID = rateSheetID;
                                objectCode.peerID = peerID;
                                objectCode.enabled = enabled;
                                objectCode.modificationDate = [NSDate date];
                                
                                if ([findedDestinationsAlreadyCreated count] == 0) { 
                                    DestinationsListForSale *object = (DestinationsListForSale *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListForSale" inManagedObjectContext:self.moc];
                                    Carrier *carrierForInsert = (Carrier *)[self.moc objectWithID:self.currentCarrierID];
                                    
                                    object.carrier = carrierForInsert;
                                    object.country = country;
                                    object.specific = specific;
                                    object.prefix = prefix;
                                    object.rateSheet = rateSheetName;
                                    object.rateSheetID = rateSheetID;
                                    object.ipAddressesList = ip;
                                    object.enabled = enabled;
                                    object.rate = rate;
                                    object.changeDate = changeDate;
                                    object.modificationDate = [NSDate date];
                                    objectCode.destinationsListForSale = object;
                                    
                                    NSArray *keys = [[[object entity] attributesByName] allKeys];
                                    NSDictionary *objectFullInfo = [object dictionaryWithValuesForKeys:keys];
                                    [destinationsForCheckingLater addObject:objectFullInfo];
                                }
                                else { 
                                    NSFetchRequest *fetchRequestForDestinationsListForSale = [[NSFetchRequest alloc] init];
                                    
                                    NSEntityDescription *entityForDestinationsListForSale = [NSEntityDescription entityForName:@"DestinationsListForSale"
                                                                                                        inManagedObjectContext:self.moc];
                                    NSDictionary *objectForGet = [findedDestinationsAlreadyCreated lastObject];
                                    NSString *guid = [objectForGet valueForKey:@"GUID"];
                                    NSPredicate *predicateForDestinationsListForSale = [NSPredicate predicateWithFormat:@"(GUID == %@)",guid];
                                    [fetchRequestForDestinationsListForSale setPredicate:predicateForDestinationsListForSale];
                                    [fetchRequestForDestinationsListForSale setEntity:entityForDestinationsListForSale];
                                    //                                NSDictionary *relationShipsByName = [entity relationshipsByName];
                                    //                                NSMutableArray *allRelationships = [NSMutableArray array];
                                    //                                [relationShipsByName enumerateKeysAndObjectsWithOptions:NSSortStable usingBlock:^(id key, NSRelationshipDescription *relationshipDescription, BOOL *stop) {
                                    //                                    [allRelationships addObject:[relationshipDescription name]];
                                    //                                }];
                                    //                                NSArray *finalRelationships = [NSArray arrayWithArray:allRelationships];
                                    //                                [fetchRequest setRelationshipKeyPathsForPrefetching:finalRelationships];
                                    //                                
                                    NSArray *destinationForSale = [self.moc executeFetchRequest:fetchRequestForDestinationsListForSale error:&error];
                                    //                                [fetchRequest setRelationshipKeyPathsForPrefetching:nil];
                                    
                                    if ([destinationForSale count] != 1) NSLog(@"DESTINATION:warning, destination more than 1");
                                    [fetchRequestForDestinationsListForSale release];
                                    
                                    DestinationsListForSale *object = [destinationForSale lastObject];
                                    object.rateSheet = rateSheetName;
                                    object.rateSheetID = rateSheetID;
                                    object.ipAddressesList = ip;
                                    object.enabled = enabled;
                                    object.rate = rate;
                                    object.changeDate = changeDate;
                                    object.modificationDate = [NSDate date];
                                    objectCode.destinationsListForSale = object;
                                    
                                    
                                }
                                
                            }
                            
                            if (destinationsListWeBuy){ 

                                CodesvsDestinationsList *objectCode = (CodesvsDestinationsList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                                objectCode.code = code;
                                objectCode.country = country;
                                objectCode.specific = specific;
                                objectCode.originalCode = originalCode;
                                objectCode.rate = rate;
                                objectCode.prefix = prefix;
                                objectCode.rateSheetName = rateSheetName;
                                objectCode.rateSheetID = rateSheetID;
                                objectCode.peerID = peerID;
                                objectCode.enabled = enabled;
                                objectCode.modificationDate = [NSDate date];
                                objectCode.externalChangedDate = changeDate;

                                if ([findedDestinationsAlreadyCreated count] == 0) { 
                                    DestinationsListWeBuy *object = (DestinationsListWeBuy *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListWeBuy" inManagedObjectContext:self.moc];
                                    Carrier *carrierForInsert = (Carrier *)[self.moc objectWithID:currentCarrierID];
                                    
                                    object.carrier = carrierForInsert;
                                    object.country = country;
                                    object.specific = specific;
                                    object.prefix = prefix;
                                    object.rateSheet = rateSheetName;
                                    object.rateSheetID = rateSheetID;
                                    object.ipAddressesList = ip;
                                    object.enabled = enabled;
                                    object.rate = rate;
                                    object.changeDate = changeDate;
                                    object.modificationDate = [NSDate date];
                                    objectCode.destinationsListWeBuy = object;
                                    
                                    NSArray *keys = [[[object entity] attributesByName] allKeys];
                                    NSDictionary *objectFullInfo = [object dictionaryWithValuesForKeys:keys];
                                    [destinationsForCheckingLater addObject:objectFullInfo];
                                    //NSLog(@"DESTINATIONS LIST: CREATE code:%@  originalCode:%@ created for NEW destination WE BUY country:%@ specific:%@",objectCode.code,objectCode.originalCode,objectCode.country,objectCode.specific);

                                    
                                }
                                else { 
                                    //NSLog(@"DESTINATIONS LIST: code:%@  originalCode:%@ created for PRESENT destination WE BUY country:%@ specific:%@",objectCode.code,objectCode.originalCode,objectCode.country,objectCode.specific);

                                    NSFetchRequest *fetchRequestForDestinationsListWeBuy = [[NSFetchRequest alloc] init];
                                    
                                    NSEntityDescription *entityForDestinationsListWeBuy = [NSEntityDescription entityForName:@"DestinationsListWeBuy"
                                                                                                      inManagedObjectContext:self.moc];
                                    NSDictionary *objectForGet = [findedDestinationsAlreadyCreated lastObject];
                                    NSString *guid = [objectForGet valueForKey:@"GUID"];
                                    NSPredicate *predicateForDestinationsListWeBuy = [NSPredicate predicateWithFormat:@"(GUID == %@)",guid];
                                    [fetchRequestForDestinationsListWeBuy setPredicate:predicateForDestinationsListWeBuy];
                                    [fetchRequestForDestinationsListWeBuy setEntity:entityForDestinationsListWeBuy];
                                    
                                    //                                NSDictionary *relationShipsByName = [entity relationshipsByName];
                                    //                                NSMutableArray *allRelationships = [NSMutableArray array];
                                    //                                [relationShipsByName enumerateKeysAndObjectsWithOptions:NSSortStable usingBlock:^(id key, NSRelationshipDescription *relationshipDescription, BOOL *stop) {
                                    //                                    [allRelationships addObject:[relationshipDescription name]];
                                    //                                }];
                                    //                                NSArray *finalRelationships = [NSArray arrayWithArray:allRelationships];
                                    //                                [fetchRequest setRelationshipKeyPathsForPrefetching:finalRelationships];
                                    NSArray *destinationsWeBuy = [self.moc executeFetchRequest:fetchRequestForDestinationsListWeBuy error:&error];
                                    //                                [fetchRequest setRelationshipKeyPathsForPrefetching:nil];
                                    [fetchRequestForDestinationsListWeBuy release];
                                    
                                    DestinationsListWeBuy *object = [destinationsWeBuy lastObject];
                                    object.rateSheet = rateSheetName;
                                    object.rateSheetID = rateSheetID;
                                    object.ipAddressesList = ip;
                                    object.enabled = enabled;
                                    object.rate = rate;
                                    object.changeDate = changeDate;
                                    object.modificationDate = [NSDate date];
                                    objectCode.destinationsListWeBuy = object;
                                }                            
                            }
                            
                            if (destinationsListTargets) {
                                DestinationsListTargets *object = nil;
                                if ([findedDestinationsAlreadyCreated count] == 0) { 
                                    object = (DestinationsListTargets *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListTargets" inManagedObjectContext:self.moc];
                                    Carrier *carrierForInsert = (Carrier *)[self.moc objectWithID:currentCarrierID];
                                    
                                    object.carrier = carrierForInsert;
                                    object.country = country;
                                    object.specific = specific;
                                    //if (prefix != nil) object.prefix = prefix;
                                    //if (rateSheetName != nil) object.rateSheet = rateSheetName;
                                    object.enabled = enabled;
                                    object.rate = rate;
                                    object.acd = [destinationsExternal valueForKey:@"acd"];
                                    object.asr = [destinationsExternal valueForKey:@"asr"];
                                    object.minutesLenght = [destinationsExternal valueForKey:@"minutes"];
                                    object.callAttempts = [destinationsExternal valueForKey:@"attempts"];
                                    object.changeDate = changeDate;
                                    object.modificationDate = [NSDate date];
                                    
                                    NSArray *keys = [[[object entity] attributesByName] allKeys];
                                    NSDictionary *objectFullInfo = [object dictionaryWithValuesForKeys:keys];
                                    [destinationsForCheckingLater addObject:objectFullInfo];
                                    
                                    
                                }
                                else { 
                                    NSFetchRequest *fetchRequestForDestinationsListTargets = [[NSFetchRequest alloc] init];
                                    
                                    NSEntityDescription *entityForDestinationsListTargets = [NSEntityDescription entityForName:@"DestinationsListTargets"
                                                                                                        inManagedObjectContext:self.moc];
                                    NSDictionary *objectForGet = [findedDestinationsAlreadyCreated lastObject];
                                    NSString *guid = [objectForGet valueForKey:@"GUID"];
                                    NSPredicate *predicateForDestinationsListTargets = [NSPredicate predicateWithFormat:@"(GUID == %@)",guid];
                                    [fetchRequestForDestinationsListTargets setPredicate:predicateForDestinationsListTargets];
                                    [fetchRequestForDestinationsListTargets setEntity:entityForDestinationsListTargets];
                                    NSArray *destinationsTargets = [self.moc executeFetchRequest:fetchRequestForDestinationsListTargets error:&error];
                                    [fetchRequestForDestinationsListTargets release];
                                    
                                    object = [destinationsTargets lastObject];
                                    //object.rateSheet = rateSheetName;
                                    object.enabled = enabled;
                                    object.rate = rate;
                                    object.acd = [destinationsExternal valueForKey:@"acd"];
                                    object.asr = [destinationsExternal valueForKey:@"asr"];
                                    object.minutesLenght = [destinationsExternal valueForKey:@"minutes"];
                                    object.callAttempts = [destinationsExternal valueForKey:@"attempts"];
                                    object.modificationDate = [NSDate date];
                                    object.changeDate = changeDate;
                                    
                                    
                                }
                                
                                CodesvsDestinationsList *objectCode = (CodesvsDestinationsList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                                objectCode.code = code;
                                objectCode.externalChangedDate = changeDate;
                                objectCode.country = country;
                                objectCode.specific = specific;
                                objectCode.originalCode = originalCode;
                                objectCode.rate = rate;
                                //objectCode.prefix = prefix;
                                //objectCode.rateSheetName = rateSheetName;
                                objectCode.peerID = peerID;
                                objectCode.enabled = enabled;
                                objectCode.modificationDate = [NSDate date];
                                
                                objectCode.destinationsListTargets = object;
                                
                            }
                            
                            if (destinationsListPushList) {
                                DestinationsListPushList *object = nil;
                                if ([findedDestinationsAlreadyCreated count] == 0) { 
                                    object = (DestinationsListPushList *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListPushList" inManagedObjectContext:self.moc];
                                    Carrier *carrierForInsert = (Carrier *)[self.moc objectWithID:currentCarrierID];
                                    
                                    object.carrier = carrierForInsert;
                                    object.country = country;
                                    object.specific = specific;
                                    object.prefix = prefix;
                                    //object.rateSheet = rateSheetName;
                                    //object.enabled = enabled;
                                    object.rate = rate;
                                    object.acd = [destinationsExternal valueForKey:@"acd"];
                                    object.asr = [destinationsExternal valueForKey:@"asr"];
                                    object.minutesLenght = [destinationsExternal valueForKey:@"minutes"];
                                    object.callAttempts = [destinationsExternal valueForKey:@"attempts"];
                                    object.modificationDate = [NSDate date];
                                    //object.changeDate = changeDate;
                                    NSArray *keys = [[[object entity] attributesByName] allKeys];
                                    NSDictionary *objectFullInfo = [object dictionaryWithValuesForKeys:keys];
                                    [destinationsForCheckingLater addObject:objectFullInfo];
                                    
                                    //                                
                                    //                                CodesvsDestinationsList *objectCode = (CodesvsDestinationsList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                                    //                                objectCode.code = code;
                                    //                                objectCode.externalChangedDate = changeDate;
                                    //                                objectCode.country = country;
                                    //                                objectCode.specific = specific;
                                    //                                objectCode.originalCode = originalCode;
                                    //                                objectCode.rate = rate;
                                    //                                objectCode.prefix = prefix;
                                    //                                objectCode.rateSheetName = rateSheetName;
                                    //                                objectCode.peerID = peerID;
                                    //                                objectCode.enabled = enabled;
                                    //                                objectCode.modificationDate = [NSDate date];
                                    //                                objectCode.destinationsListPushList = object;
                                    //                                NSLog(@"DESTINATIONS LIST: code created for new destination PUSHLIST:%@ country:%@ specific:%@",objectCode.code,objectCode.country,objectCode.specific);
                                    
#if defined(SNOW_CLIENT_APPSTORE) || defined (SNOW_CLIENT_ENTERPRISE)
                                    if (![insertedDestinationsIDs containsObject:[object objectID]]) {
                                        isDestinationsPushListUpdated = YES;
                                        [insertedDestinationsIDs addObject:object];
                                    }
#endif
                                }
                                else {
                                    NSFetchRequest *fetchRequestForDestinationsListPushList = [[NSFetchRequest alloc] init];
                                    
                                    NSEntityDescription *entityForDestinationsListPushList = [NSEntityDescription entityForName:@"DestinationsListPushList"
                                                                                                         inManagedObjectContext:self.moc];
                                    NSDictionary *objectForGet = [findedDestinationsAlreadyCreated lastObject];
                                    NSString *guid = [objectForGet valueForKey:@"GUID"];
                                    NSPredicate *predicateForDestinationsListPushList = [NSPredicate predicateWithFormat:@"(GUID == %@)",guid];
                                    [fetchRequestForDestinationsListPushList setPredicate:predicateForDestinationsListPushList];
                                    [fetchRequestForDestinationsListPushList setEntity:entityForDestinationsListPushList];
                                    NSArray *destinationsPushList = [self.moc executeFetchRequest:fetchRequestForDestinationsListPushList error:&error];
                                    [fetchRequestForDestinationsListPushList release];
                                    
                                    object = [destinationsPushList lastObject];
                                    //object.rateSheet = rateSheetName;
                                    //object.enabled = enabled;
                                    object.rate = rate;
                                    object.acd = [destinationsExternal valueForKey:@"acd"];
                                    object.asr = [destinationsExternal valueForKey:@"asr"];
                                    object.minutesLenght = [destinationsExternal valueForKey:@"minutes"];
                                    object.callAttempts = [destinationsExternal valueForKey:@"attempts"];
                                    object.modificationDate = [NSDate date];
                                    
                                    //object.changeDate = changeDate;
#if defined(SNOW_CLIENT_APPSTORE)
                                    
                                    //                            if (![updatedDestinationsIDs containsObject:[object objectID]] && ![insertedDestinationsIDs containsObject:[object objectID]]) {
                                    //                                [self safeSave];
                                    //                                [userController addInRegistrationForAllObjectsInFutureArrayObject:object 
                                    //                                                                                     forOperation:userController.controller.objectOperationUpdate];
                                    //                                [updatedDestinationsIDs addObject:[object objectID]];
                                    //                                NSMutableString *twitterText = [[NSMutableString alloc] initWithCapacity:0];
                                    //                                [twitterText appendString:@"I'm currently interesting for those destination (s):"];
                                    // 
                                    //                                [twitterText appendFormat:@"%@/%@ with price %@ volume %@",object.country,object.specific,object.rate,object.minutesLenght];
                                    //                                
                                    //                                [delegate postTwitterMessageWithText:twitterText];
                                    //                            }
#endif
                                    
                                }
                                CodesvsDestinationsList *objectCode = (CodesvsDestinationsList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                                objectCode.code = code;
                                objectCode.externalChangedDate = changeDate;
                                objectCode.country = country;
                                objectCode.specific = specific;
                                objectCode.originalCode = originalCode;
                                objectCode.rate = rate;
                                objectCode.prefix = prefix;
                                objectCode.rateSheetName = rateSheetName;
                                objectCode.peerID = peerID;
                                objectCode.enabled = enabled;
                                objectCode.modificationDate = [NSDate date];
                                objectCode.destinationsListPushList = object;
                                NSLog(@"DESTINATIONS LIST: code created and added to destination:%@ country:%@ specific:%@",objectCode.code,objectCode.country,objectCode.specific);
                                
                            }
                            
                            
                        } else
                        {
                            // update code and update destination
                            CodesvsDestinationsList *currentCode = codesFilteredFirstStepMutable.lastObject;
                            [allCarrierCodes filterUsingPredicate:[NSPredicate predicateWithFormat:@"objectID != %@",currentCode.objectID]];
                            //NSLog(@"DESTINATIONS CLASS: >>>> allCarrierCodes count:%@",[NSNumber numberWithInteger:allCarrierCodes.count]);
                            //NSLog(@"DESTINATIONS LIST: UPDATE code:%@  originalCode:%@ created for NEW destination WE BUY country:%@ specific:%@",currentCode.code,currentCode.originalCode,currentCode.country,currentCode.specific);

                            if (!currentCode) NSLog(@"DESTINATIONS CLASS: >>>> warning code not found!");

                            if (destinationsListForSale) {
                                if ([currentCode.rate isEqualToNumber:rate] && [currentCode.rateSheetName isEqualToString:rateSheetName] && [currentCode.rateSheetID isEqualToString:rateSheetID] && [currentCode.peerID isEqualToNumber:peerID] && [currentCode.enabled isEqualToNumber:enabled] && [currentCode.externalChangedDate isEqualToDate:changeDate]) {
                                    // do nothing, code is same
                                } else {
                                    currentCode.rate = rate;
                                    currentCode.rateSheetName = rateSheetName;
                                    currentCode.rateSheetID = rateSheetID;
                                    currentCode.peerID = peerID;
                                    currentCode.enabled = enabled;
                                    currentCode.externalChangedDate = changeDate;
                                    currentCode.modificationDate = [NSDate date];
                                }
                                
                                DestinationsListForSale *currentDestination = currentCode.destinationsListForSale;
                                
                                if (!currentDestination) NSLog(@"DESTINATION CLASS: >>>>>>> warning, destinationForSale for update don't found for code:%@ ",currentCode);
                                
                                if ([updatedDestinationsIDs containsObject:[currentDestination objectID]]) {
                                    // we already updated destination, do stuff for check code so... smoking and drink vodka :)
                                } else {
                                    if ([currentDestination.rateSheet isEqualToString:rateSheetName] && [currentDestination.ipAddressesList isEqualToString:ip] && [currentDestination.enabled isEqualToNumber:enabled] && [currentDestination.rate isEqualToNumber:rate] && [currentDestination.changeDate isEqualToDate:changeDate]) {
                                        // do nothing, destination is same
                                    } else {
                                        //NSLog(@"Destination for sale:%@/%@ have update for code:%@ originalCode:%@ and rate:%@ ratesheet:%@ ip:%@ , enabled:%@",country,specific,code,originalCode,rate,rateSheetName,ip,enabled);
                                        NSFetchRequest *fetchRequestForCodesvsDestinationsList = [[NSFetchRequest alloc] init];
                                        
                                        NSEntityDescription *entityForCodesvsDestinationsList = [NSEntityDescription entityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                                        [fetchRequestForCodesvsDestinationsList setEntity:entityForCodesvsDestinationsList];
                                        
                                        NSPredicate *predicateForCodesvsDestinationsList = [NSPredicate predicateWithFormat:@"(destinationsListForSale == %@)",currentDestination];
                                        [fetchRequestForCodesvsDestinationsList setPredicate:predicateForCodesvsDestinationsList];
                                        [fetchRequestForCodesvsDestinationsList setReturnsDistinctResults:YES];
                                        [fetchRequestForCodesvsDestinationsList setResultType:NSDictionaryResultType];
                                        [fetchRequestForCodesvsDestinationsList setPropertiesToFetch:[NSArray arrayWithObject:@"rate"]];
                                        NSArray *codesWithUnickRate = [self.moc executeFetchRequest:fetchRequestForCodesvsDestinationsList error:&error];
                                        if (codesWithUnickRate == nil) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
                                        [fetchRequestForCodesvsDestinationsList release];
                                        int maxCount = 0;
                                        double maxRate = 0;
                                        
                                        if ([codesWithUnickRate count] > 1) {
                                            
                                            NSMutableDictionary *rates = [NSMutableDictionary dictionaryWithCapacity:0];
                                            if ([codesWithUnickRate count] != 1) [codesWithUnickRate enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *enumeratedCode, NSUInteger idx, BOOL *stop) {
                                                NSNumber *uniqueRate = [enumeratedCode valueForKey:@"rate"];
                                                
                                                NSFetchRequest *fetchRequestForCodeCount = [[NSFetchRequest alloc] init];
                                                
                                                NSPredicate *predicateForCodeCount = [NSPredicate predicateWithFormat:@"(destinationsListForSale == %@) and (rate == %@)",currentDestination,uniqueRate];
                                                [fetchRequestForCodeCount setPredicate:predicateForCodeCount];
                                                [fetchRequestForCodeCount setResultType:NSManagedObjectIDResultType];
                                                NSEntityDescription *entityForCodesvsDestinationsList = [NSEntityDescription entityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                                                [fetchRequestForCodeCount setEntity:entityForCodesvsDestinationsList];
                                                
                                                NSArray *countCodesArray = [self.moc executeFetchRequest:fetchRequestForCodeCount error:nil];
                                                NSUInteger countCodes = [countCodesArray count];
                                                //                                            [fetchRequest setResultType:NSManagedObjectResultType];[
                                                [fetchRequestForCodeCount release];
                                                
                                                //NSUInteger countCodes = [self.context countForFetchRequest:fetchRequest error:nil];
                                                [rates setObject:[NSNumber numberWithUnsignedInteger:countCodes] forKey:uniqueRate];
                                            }];
                                            
                                            // winned must have less rate in same count issues 
                                            
                                            for (NSNumber *rateFromRatesList in [rates allKeys]) {
                                                NSNumber *count = [rates objectForKey:rateFromRatesList];
                                                //NSLog (@"%@/%@ have rateFromRatesList:%@, count:%@, maxCount:%@, maxRate:%@",currentDestination.country,currentDestination.specific,rateFromRatesList,count,[NSNumber numberWithInt:maxCount],[NSNumber numberWithDouble:maxRate]);
                                                if (maxCount <= [count intValue]) { 
                                                    if (maxCount == [count intValue]) {
                                                        
                                                        // we are update destination rate only if we find rate less than maxrate
                                                        if (maxRate > [rateFromRatesList doubleValue]) {
                                                            maxCount = [count intValue]; 
                                                            maxRate = [rateFromRatesList doubleValue];
                                                        }
                                                    } else {
                                                        // in oother case, just update to max count
                                                        maxCount = [count intValue]; 
                                                        maxRate = [rateFromRatesList doubleValue];
                                                    }
                                                    
                                                }
                                            };
                                        }
                                        if (maxRate == 0) maxRate = [rate doubleValue];
                                        
                                        
                                        NSNumber *maxRateNumber = [NSNumber numberWithDouble:maxRate];
                                        
                                        currentDestination.rateSheet = rateSheetName;
                                        currentDestination.rateSheetID = rateSheetID;
                                        currentDestination.ipAddressesList = ip;
                                        currentDestination.enabled = enabled;
                                        currentDestination.rate = maxRateNumber;
                                        currentDestination.changeDate = changeDate;
                                        currentDestination.modificationDate = [NSDate date];
                                        
                                        [updatedDestinationsIDs addObject:[currentDestination objectID]];
                                    }
                                }
                                
                            }
                            if (destinationsListWeBuy){ 
                                if ([currentCode.rate isEqualToNumber:rate] && [currentCode.rateSheetName isEqualToString:rateSheetName] && [currentCode.rateSheetID isEqualToString:rateSheetID] && [currentCode.peerID isEqualToNumber:peerID] && [currentCode.enabled isEqualToNumber:enabled] && [currentCode.externalChangedDate isEqualToDate:changeDate]) {
                                    // do nothing, code is same
                                } else {
                                    
                                    currentCode.rate = rate;
                                    currentCode.rateSheetName = rateSheetName;
                                    currentCode.rateSheetID = rateSheetID;
                                    currentCode.peerID = peerID;
                                    currentCode.enabled = enabled;
                                    currentCode.externalChangedDate = changeDate;
                                    currentCode.modificationDate = [NSDate date];
                                }
                                
                                DestinationsListWeBuy *currentDestination = currentCode.destinationsListWeBuy;
                                if ([updatedDestinationsIDs containsObject:[currentDestination objectID]]) {
                                    // we already updated destination, do stuff for check code so... smoking and drink vodka :)
                                } else {
                                    
                                    if ([currentDestination.rateSheet isEqualToString:rateSheetName] && [currentDestination.ipAddressesList isEqualToString:ip] && [currentDestination.enabled isEqualToNumber:enabled] && [currentDestination.rate isEqualToNumber:rate]) {
                                        // do nothing, destination is same
                                    } else {
                                        //NSLog(@"Destination we buy:%@/%@ have update for code:%@ originalCode:%@ and rate:%@ ratesheet:%@ ip:%@ , enabled:%@",country,specific,code,originalCode,rate,rateSheetName,ip,enabled);
                                        NSFetchRequest *fetchRequestWithUnickRate = [[NSFetchRequest alloc] init];
                                        
                                        NSPredicate *predicateWithUnickRate = [NSPredicate predicateWithFormat:@"(destinationsListWeBuy == %@)",currentDestination];
                                        NSEntityDescription *entityForCodesvsDestinationsList = [NSEntityDescription entityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                                        [fetchRequestWithUnickRate setEntity:entityForCodesvsDestinationsList];
                                        
                                        [fetchRequestWithUnickRate setPredicate:predicateWithUnickRate];
                                        [fetchRequestWithUnickRate setReturnsDistinctResults:YES];
                                        [fetchRequestWithUnickRate setResultType:NSDictionaryResultType];
                                        [fetchRequestWithUnickRate setPropertiesToFetch:[NSArray arrayWithObject:@"rate"]];
                                        NSArray *codesWithUnickRate = [self.moc executeFetchRequest:fetchRequestWithUnickRate error:&error];
                                        if (codesWithUnickRate == nil) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd));
                                        [fetchRequestWithUnickRate release];
                                        int maxCount = 0;
                                        double maxRate = 0;
                                        
                                        if ([codesWithUnickRate count] > 1) {
                                            
                                            NSMutableDictionary *rates = [NSMutableDictionary dictionaryWithCapacity:0];
                                            if ([codesWithUnickRate count] != 1) [codesWithUnickRate enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSDictionary *enumeratedCode, NSUInteger idx, BOOL *stop) {
                                                NSNumber *uniqueRate = [enumeratedCode valueForKey:@"rate"];
                                                
                                                NSFetchRequest *fetchRequestForCodeCount = [[NSFetchRequest alloc] init];
                                                
                                                NSPredicate *predicateForCodeCount = [NSPredicate predicateWithFormat:@"(destinationsListWeBuy == %@) and (rate == %@)",currentDestination,uniqueRate];
                                                [fetchRequestForCodeCount setPredicate:predicateForCodeCount];
                                                [fetchRequestForCodeCount setResultType:NSManagedObjectIDResultType];
                                                NSEntityDescription *entityForCodesvsDestinationsList = [NSEntityDescription entityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                                                [fetchRequestForCodeCount setEntity:entityForCodesvsDestinationsList];
                                                
                                                NSArray *countCodesArray = [self.moc executeFetchRequest:fetchRequestForCodeCount error:nil];
                                                NSUInteger countCodes = [countCodesArray count];
                                                [fetchRequestForCodeCount release];
                                                //                                            [fetchRequest setResultType:NSManagedObjectResultType];
                                                
                                                
                                                // NSUInteger countCodes = [self.context countForFetchRequest:fetchRequest error:nil];
                                                [rates setObject:[NSNumber numberWithUnsignedInteger:countCodes] forKey:uniqueRate];
                                            }];
                                            
                                            // winned must have less rate in same count issues 
                                            //[rates enumerateKeysAndObjectsUsingBlock:^(NSNumber *rateFromRatesList, NSNumber *count, BOOL *stop) {
                                            
                                            for (NSNumber *rateFromRatesList in [rates allKeys]) {
                                                NSNumber *count = [rates objectForKey:rateFromRatesList];
                                                //NSLog (@"%@/%@ have rateFromRatesList:%@, count:%@, maxCount:%@, maxRate:%@",currentDestination.country,currentDestination.specific,rateFromRatesList,count,[NSNumber numberWithInt:maxCount],[NSNumber numberWithDouble:maxRate]);
                                                if (maxCount <= [count intValue]) { 
                                                    if (maxCount == [count intValue]) {
                                                        
                                                        // we are update destination rate only if we find rate less than maxrate
                                                        if (maxRate > [rateFromRatesList doubleValue]) {
                                                            maxCount = [count intValue]; 
                                                            maxRate = [rateFromRatesList doubleValue];
                                                        }
                                                    } else {
                                                        // in oother case, just update to max count
                                                        maxCount = [count intValue]; 
                                                        maxRate = [rateFromRatesList doubleValue];
                                                    }
                                                    
                                                }
                                            };
                                        }
                                        if (maxRate == 0) maxRate = [rate doubleValue];
                                        
                                        
                                        NSNumber *maxRateNumber = [NSNumber numberWithDouble:maxRate];
                                        currentDestination.rateSheet = rateSheetName;
                                        currentDestination.rateSheetID = rateSheetID;
                                        currentDestination.ipAddressesList = ip;
                                        currentDestination.enabled = enabled;
                                        currentDestination.rate = maxRateNumber;
                                        currentDestination.changeDate = changeDate;
                                        currentDestination.modificationDate = [NSDate date];
                                        
                                        [updatedDestinationsIDs addObject:[currentDestination objectID]];
                                        
                                    } 
                                }
                                
                            }
                            if (destinationsListTargets){ 
                                currentCode.rate = rate;
                                currentCode.rateSheetName = rateSheetName;
                                currentCode.rateSheetID = rateSheetID;
                                currentCode.peerID = peerID;
                                currentCode.enabled = enabled;
                                currentCode.externalChangedDate = changeDate;
                                currentCode.modificationDate = [NSDate date];
                                
                                DestinationsListTargets *currentDestination = currentCode.destinationsListTargets;
                                currentDestination.rateSheet = rateSheetName;
                                currentDestination.enabled = enabled;
                                currentDestination.rate = rate;
                                currentDestination.acd = [destinationsExternal valueForKey:@"acd"];
                                currentDestination.asr = [destinationsExternal valueForKey:@"asr"];
                                currentDestination.minutesLenght = [destinationsExternal valueForKey:@"minutes"];
                                currentDestination.callAttempts = [destinationsExternal valueForKey:@"attempts"];
                                currentDestination.changeDate = changeDate;
                                currentDestination.modificationDate = [NSDate date];
                                
                                
                            }
                            if (destinationsListPushList){ 
                                currentCode.rate = rate;
                                currentCode.rateSheetName = rateSheetName;
                                currentCode.rateSheetID = rateSheetID;
                                currentCode.peerID = peerID;
                                currentCode.enabled = enabled;
                                currentCode.externalChangedDate = changeDate;
                                currentCode.modificationDate = [NSDate date];
                                
                                DestinationsListPushList *currentDestination = currentCode.destinationsListPushList;
                                currentDestination.rate = rate;
                                currentDestination.acd = [destinationsExternal valueForKey:@"acd"];
                                currentDestination.asr = [destinationsExternal valueForKey:@"asr"];
                                currentDestination.minutesLenght = [destinationsExternal valueForKey:@"minutes"];
                                currentDestination.callAttempts = [destinationsExternal valueForKey:@"attempts"];
                                currentDestination.modificationDate = [NSDate date];
                                
                            }
                            
                        } 
                        //[codesFilteredFirstStepMutable release];
                        
                    }
                    
                    idx++;
                    [formatter release];
                    
                }
            }
            
            // final check for codes, which was untouch (don't need for targets
            [allCarrierCodes enumerateObjectsUsingBlock:^(CodesvsDestinationsList *codeToRemove, NSUInteger idx, BOOL *stop) {
                [self.moc deleteObject:codeToRemove];
            }];
            [destinationsForCheckingLater release];
            [updatedDestinationsIDs release];
            //        [fetchRequest release];
            
        }
        
        [formatterDate release];
        self.externalDataCodes = nil;
        
        //NSGarbageCollector *collector = [NSGarbageCollector defaultCollector];
        //[collector collectIfNeeded];
#if defined(SNOW_CLIENT_APPSTORE)
        
        if (isDestinationsPushListUpdated) {
            //[self.context processPendingChanges];
            //[userController retain];
            //        CompanyStuff *admin = [userController authorization];
            //        if (!admin) [userController defaultUser];
            //        
            //        NSAssert(admin != nil,@"admin is nil in add company");
            //        
            //        NSArray *keys = [[[admin entity] attributesByName] allKeys];
            //        NSDictionary *clientStuffFullInfo = [admin dictionaryWithValuesForKeys:keys];
            //
            //        NSMutableDictionary *objectsForRegistrationCompany = [NSMutableDictionary dictionaryWithCapacity:0];
            //
            //        NSMutableArray *new = [NSMutableArray arrayWithCapacity:0];
            //
            //        [insertedDestinationsIDs enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSManagedObjectID *insertedDestination, NSUInteger idx, BOOL *stop) {
            //            [new addObject:insertedDestination];
            //            
            //        }];
            //        [objectsForRegistrationCompany setValue:new forKey:@"new"];
            //
            //        NSManagedObject *anyObject = [self.context objectWithID:[insertedDestinationsIDs lastObject]];
            //        
            //        [objectsForRegistrationCompany setValue:[anyObject valueForKey:@"GUID"] forKey:@"rootObjectGUID"];
            //
            //        
            //        //[userController startRegistrationForAllObjectsInFutureArrayForTableView:nil sender:nil];
            //        [userController startRegistrationForObjects:objectsForRegistrationCompany 
            //                                       forTableView:nil 
            //                                          forSender:nil 
            //                                clientStuffFullInfo:clientStuffFullInfo];
            
            
        }
        
#endif
        
        //[userController release];
        
        @synchronized (delegate) {
            
            if (delegate.numberForHardJobConcurentLines != 0) delegate.numberForHardJobConcurentLines = delegate.numberForHardJobConcurentLines - 1;
        }
        [globalUID release];
        
        //[insertedDestinationsIDs release];
        [self safeSave];
        //    [insertedDestinationsIDs enumerateObjectsUsingBlock:^(NSManagedObject *destination, NSUInteger idx, BOOL *stop) {
        //        NSSet *codes = [destination valueForKey:@"codesvsDestinationsList"];
        //        [codes enumerateObjectsUsingBlock:^(CodesvsDestinationsList *code, BOOL *stop) {
        //            NSLog(@"For destination:%@/%@ code is:%@",[destination valueForKey:@"country"],[destination valueForKey:@"specific"],code.code);
        //        }];             
        //    }];
        //    [pool drain], pool = nil;
    }

    return NO;
}

- (NSMutableDictionary *) findCountrySpecificForCode:(NSString *)code;
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
    //changedCode = nil;
    
    return destinationParameters;
    
}

-(id)updateObjectStatisticFor:(id)object
{
    /*if (destinationsListForSale) {
        DestinationsListForSale *destination = (DestinationsListForSale *)object;
        double lastUsedMinutesLenghtd = [destination.lastUsedMinutesLenght doubleValue];
        if ([minutes class] != [NSNull class]) lastUsedMinutesLenghtd = [[numberTransfer numberFromString:minutes] doubleValue] + lastUsedMinutesLenghtd;
        
        double lastUsedCallAttemptsd = [destination.lastUsedCallAttempts doubleValue];
        if ([count class] != [NSNull class]) lastUsedCallAttemptsd = [[numberTransfer numberFromString:count] doubleValue] + lastUsedCallAttemptsd;
        
        double lastUsedProfitd = [destination.lastUsedProfit doubleValue];
        if ([profit class] != [NSNull class]) lastUsedProfitd = [[numberTransfer numberFromString:profit] doubleValue] + lastUsedProfitd;
        
        double lastUsedSuccessCallsd;
        if ([asr class] != [NSNull class])  lastUsedSuccessCallsd = lastUsedCallAttemptsd * [[numberTransfer numberFromString:asr] doubleValue];
        
        double lastUsedACDd;
        double lastUsedASRd;
        
        if (lastUsedSuccessCallsd != 0) {
            lastUsedACDd = lastUsedMinutesLenghtd / lastUsedSuccessCallsd;
            lastUsedASRd = lastUsedSuccessCallsd / lastUsedCallAttemptsd;
        } else 
        {
            // we are pickup old asr, * to old call attempts and devide to new call attempts - bingo, new asr when successeful calls = 0. acd keep same;
            lastUsedACDd = [destination.lastUsedACD doubleValue];
            lastUsedASRd = ([destination.lastUsedASR doubleValue] * [destination.lastUsedCallAttempts doubleValue]) /  lastUsedCallAttemptsd;
        }
        
        destination.lastUsedASR = [NSNumber numberWithDouble:lastUsedASRd];
        destination.lastUsedACD = [NSNumber numberWithDouble:lastUsedACDd];
        destination.lastUsedCallAttempts = [NSNumber numberWithDouble:lastUsedCallAttemptsd];
        destination.lastUsedMinutesLenght = [NSNumber numberWithDouble:lastUsedMinutesLenghtd];
        destination.lastUsedProfit = [NSNumber numberWithDouble:lastUsedProfitd];
        destination.lastUsedDate = [NSDate date];
    }*/
    return nil;
}

- (BOOL) updateStatisticForEntity:(NSString *)entity;
{
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @autoreleasepool {
        
        
        NSError *error = nil;
        NSNumberFormatter *numberTransfer = [[NSNumberFormatter alloc] init];
        [numberTransfer setDecimalSeparator:@"."];
        __block BOOL destinationNeedUpdateStatisticForCode = NO;
        __block BOOL destinationNeedNewStatisticForCode = NO;
        
        NSMutableArray *updatedDestinations = [[NSMutableArray alloc] init];
        
        if ([entity isEqualToString:@"DestinationsListForSale"]) destinationsListForSale = YES;
        if ([entity isEqualToString:@"DestinationsListWeBuy"]) destinationsListWeBuy = YES;
        [progress updateOperationName:[NSString stringWithFormat:@"STATISTIC: 24H UPDATE for %@",entity]];
        progress.objectsQuantity = [NSNumber numberWithUnsignedInteger:[usedCodesWithStatistic count]];
        
        for (NSString *carrierGUID in self.carriers) 
        {
            //        [pool drain], pool = nil;
            //        pool = [[NSAutoreleasePool alloc] init];
            
            [progress updateCurrentObjectsCount];
            [self removeFromMainDatabaseDestinations24hStatisticForCarrierGUID:carrierGUID withEntityName:entity];
            
            // updated destinations collection for understand where we has updates, where no
            for (NSDictionary *usedCode in self.usedCodesWithStatistic)
            {
                //            [pool drain], pool = nil;
                //            pool = [[NSAutoreleasePool alloc] init];
                
                NSString *codeStr = [usedCode valueForKey:@"code"];
                NSNumber *code = [numberTransfer numberFromString:codeStr];
                NSString *rateSheetId = nil;
                if ([usedCode valueForKey:@"id"]) rateSheetId = [usedCode valueForKey:@"id"];
                else  rateSheetId = @"65535";       
                
                // prefix normalization, mix with realprefix
                NSString *prefix = [usedCode valueForKey:@"prefix"];
                NSString *realPrefix = [usedCode valueForKey:@"realPrefix"];
                NSString *changedPrefix = nil;
                
                if ([realPrefix class] == [NSNull class]) realPrefix = @"";
                if ([prefix class] == [NSNull class]) prefix = @"";
                else 
                { 
                    if ([realPrefix length] != 0) changedPrefix = [prefix stringByReplacingOccurrencesOfString:realPrefix withString:@""];
                    if (changedPrefix) prefix = [NSString stringWithString:changedPrefix];
                    changedPrefix = nil;
                }
                if (!prefix) prefix = @"";
                
                NSArray *statistic = [usedCode valueForKey:@"statistic"];
                NSString *count = [[statistic objectAtIndex:0] valueForKey:@"Count"];
                NSString *minutes = [[statistic objectAtIndex:0] valueForKey:@"Minutes"];
                NSString *profit = [[statistic objectAtIndex:0] valueForKey:@"Profit"];
                NSString *asr = [[statistic objectAtIndex:0] valueForKey:@"ASR"];
                
                // get according destination based on code
                NSString *relationShipName = nil;
                if (destinationsListForSale) relationShipName = @"destinationsListForSale";            
                if (destinationsListWeBuy) relationShipName = @"destinationsListWeBuy";
                
                NSFetchRequest *compareCode = [[NSFetchRequest alloc] init];
                [compareCode setEntity:[NSEntityDescription entityForName:@"CodesvsDestinationsList"
                                                   inManagedObjectContext:self.moc]];
                [compareCode setPredicate:[NSPredicate predicateWithFormat:@"(%K.carrier.GUID == %@) and ((code == %@) OR (originalCode == %@)) and (%K.prefix == %@) and (rateSheetID == %@)",relationShipName, carrierGUID,code,code, relationShipName, prefix,rateSheetId]];
                [compareCode setIncludesSubentities:YES];
                NSArray *codeAfterComparing = [self.moc executeFetchRequest:compareCode error:&error];
                if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
                
                CodesvsDestinationsList *codeObject = [codeAfterComparing lastObject];
                if (!codeObject) {
                    NSLog(@"STAT: warning, we don't find according code with request:%@",compareCode);
                    [compareCode release],compareCode = nil;
                    
                    continue;
                    
                }
                [compareCode release],compareCode = nil;
                
                
                // update accodring destination statistis
                if (destinationsListForSale) {
                    DestinationsListForSale *destination = (DestinationsListForSale *)codeObject.destinationsListForSale;
                    // calculate new digits
                    
                    double lastUsedMinutesLenghtd = [destination.lastUsedMinutesLenght doubleValue];
                    if ([minutes class] != [NSNull class]) lastUsedMinutesLenghtd = [[numberTransfer numberFromString:minutes] doubleValue] + lastUsedMinutesLenghtd;
                    
                    double lastUsedCallAttemptsd = [destination.lastUsedCallAttempts doubleValue];
                    if ([count class] != [NSNull class]) lastUsedCallAttemptsd = [[numberTransfer numberFromString:count] doubleValue] + lastUsedCallAttemptsd;
                    
                    double lastUsedProfitd = [destination.lastUsedProfit doubleValue];
                    if ([profit class] != [NSNull class]) lastUsedProfitd = [[numberTransfer numberFromString:profit] doubleValue] + lastUsedProfitd;
                    
                    double lastUsedSuccessCallsd = 0;
                    if ([asr class] != [NSNull class])  lastUsedSuccessCallsd = lastUsedCallAttemptsd * [[numberTransfer numberFromString:asr] doubleValue];
                    
                    double lastUsedACDd;
                    double lastUsedASRd;
                    
                    if (lastUsedSuccessCallsd != 0) {
                        lastUsedACDd = lastUsedMinutesLenghtd / lastUsedSuccessCallsd;
                        lastUsedASRd = lastUsedSuccessCallsd / lastUsedCallAttemptsd;
                    } else 
                    {
                        // we are pickup old asr, * to old call attempts and devide to new call attempts - bingo, new asr when successeful calls = 0. acd keep same;
                        lastUsedACDd = [destination.lastUsedACD doubleValue];
                        lastUsedASRd = ([destination.lastUsedASR doubleValue] * [destination.lastUsedCallAttempts doubleValue]) /  lastUsedCallAttemptsd;
                    }
                    
                    destination.lastUsedASR = [NSNumber numberWithDouble:lastUsedASRd];
                    destination.lastUsedACD = [NSNumber numberWithDouble:lastUsedACDd];
                    destination.lastUsedCallAttempts = [NSNumber numberWithDouble:lastUsedCallAttemptsd];
                    destination.lastUsedMinutesLenght = [NSNumber numberWithDouble:lastUsedMinutesLenghtd];
                    destination.lastUsedProfit = [NSNumber numberWithDouble:lastUsedProfitd];
                    destination.lastUsedDate = [NSDate date];
                    
                    // insert per hour statistic
                    //if ([updatedDestinations containsObject:destination]) destinationHaveUpdatedCode = YES;
                    //else destinationHaveUpdatedCode = NO;
                    
                    NSArray *perHourStatistic =  [usedCode valueForKey:@"statisticPerHour"];
                    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
                    //NSNumberFormatter *numberTransfer = [[NSNumberFormatter alloc] init];
                    //[numberTransfer setDecimalSeparator:@"."];
                    
                    [perHourStatistic enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSString *acd = [obj valueForKey:@"ACD"];
                        NSString *count = [obj valueForKey:@"Count"];
                        NSString *minutes = [obj valueForKey:@"Minutes"];
                        NSString *profit = [obj valueForKey:@"Profit"];
                        NSString *amount = [obj valueForKey:@"Amount"];
                        NSString *asr = [obj valueForKey:@"ASR"];
                        NSString *externalDate = [obj valueForKey:@"Date"];
                        
                        [inputFormatter setDateFormat:@"yyyyMMddHH"];
                        NSDate *externalDateFormatted = [inputFormatter dateFromString:externalDate];
                        
                        // we have to update only per hour record, which we receive in this session. 
                        // other records have to be same as was before.
                        NSSet *perHourStatsFiltered = [destination.destinationPerHourStat filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"(externalDate == %@)",externalDate]];
                        if ([perHourStatsFiltered count] >1) NSLog(@"STAT: warning, per hour stat have more than one choice. Result is: \n%@\n",perHourStatsFiltered);
                        if ([perHourStatsFiltered count] == 0) {
                            // destination was updated, code was matched, but we have another hour, which don't need to make summary, we need to add as new.
                            destinationNeedNewStatisticForCode = YES;
                            destinationNeedUpdateStatisticForCode = NO;
                            //NSLog(@"STAT: warning, per hour stat don't have choice from :%@\n for date:%@\n",perHourStats,[countAsrAcdPerHour valueForKey:@"Date"]);
                        } else
                        {
                            if ([updatedDestinations containsObject:[destination objectID]]) destinationNeedUpdateStatisticForCode = YES;
                            
                            destinationNeedNewStatisticForCode = NO;
                            
                        }
                        
                        
                        if (destinationNeedUpdateStatisticForCode) {
                            // must be just one
                            DestinationPerHourStat *currentPerHourStat = [perHourStatsFiltered anyObject];
                            
                            double newMinutesLenghtd = [currentPerHourStat.minutesLenght doubleValue];
                            if ([minutes class] != [NSNull class]) newMinutesLenghtd = [[numberTransfer numberFromString:minutes] doubleValue] + newMinutesLenghtd;
                            
                            double newCallAttemptsd = [currentPerHourStat.callAttempts doubleValue];
                            if ([count class] != [NSNull class]) newCallAttemptsd = [[numberTransfer numberFromString:count] doubleValue] + newCallAttemptsd;
                            
                            double newProfitd = [currentPerHourStat.profit doubleValue];
                            if ([profit class] != [NSNull class]) newProfitd = [[numberTransfer numberFromString:profit] doubleValue] + newProfitd;
                            
                            double newAmountd = [currentPerHourStat.cashflow doubleValue];
                            if ([amount class] != [NSNull class]) newAmountd = [[numberTransfer numberFromString:amount] doubleValue] + newAmountd;
                            
                            double newSuccessCallsd = 0;
                            if ([asr class] != [NSNull class])  newSuccessCallsd = newCallAttemptsd * [[numberTransfer numberFromString:asr] doubleValue];
                            
                            double newACDd;
                            double newASRd;
                            if (newSuccessCallsd != 0) {
                                newACDd = newMinutesLenghtd / newSuccessCallsd;
                                newASRd= newSuccessCallsd / newCallAttemptsd;
                            } else
                            {
                                // we are pickup old asr, * to old call attempts and devide to new call attempts - bingo, new asr when successeful calls = 0. acd keep same;
                                newACDd = [currentPerHourStat.acd doubleValue];
                                newASRd = ([currentPerHourStat.asr doubleValue] * [currentPerHourStat.callAttempts doubleValue]) /  newCallAttemptsd;
                            }
                            currentPerHourStat.asr = [NSNumber numberWithDouble:newASRd];
                            currentPerHourStat.acd = [NSNumber numberWithDouble:newACDd];
                            currentPerHourStat.callAttempts = [NSNumber numberWithDouble:newCallAttemptsd];
                            currentPerHourStat.minutesLenght = [NSNumber numberWithDouble:newMinutesLenghtd];
                            currentPerHourStat.profit = [NSNumber numberWithDouble:newProfitd];
                            currentPerHourStat.cashflow = [NSNumber numberWithDouble:newAmountd];
                            
                            //currentPerHourStat.externalDate = 
                            
                        } 
                        if (destinationNeedNewStatisticForCode)
                        {
                            DestinationPerHourStat *newPerHourStat = (DestinationPerHourStat *)[NSEntityDescription 
                                                                                                insertNewObjectForEntityForName:@"DestinationPerHourStat"
                                                                                                inManagedObjectContext:self.moc];
                            newPerHourStat.date = externalDateFormatted;
                            newPerHourStat.externalDate = externalDate;
                            newPerHourStat.acd = [numberTransfer numberFromString:acd];
                            newPerHourStat.asr = [numberTransfer numberFromString:asr];
                            newPerHourStat.callAttempts = [numberTransfer numberFromString:count];
                            newPerHourStat.minutesLenght = [numberTransfer numberFromString:minutes];
                            newPerHourStat.profit = [numberTransfer numberFromString:profit];
                            newPerHourStat.cashflow = [numberTransfer numberFromString:amount];
                            newPerHourStat.destinationsListForSale = destination;
                            
                            if (![updatedDestinations containsObject:[destination objectID]]) [updatedDestinations addObject:[destination objectID]];
                            //NSLog(@"STAT:added new per hour stat:%@\n to destination:%@\n",newPerHourStat,destination);
                        }
                        
                    }];
                    
                    [inputFormatter release], inputFormatter = nil;
                    //[numberTransfer release], numberTransfer = nil;
                    
                    
                }
                
                if (destinationsListWeBuy) {
                    DestinationsListWeBuy *destination = (DestinationsListWeBuy *)codeObject.destinationsListWeBuy;
                    // calculate new digits
                    
                    double lastUsedMinutesLenghtd = [destination.lastUsedMinutesLenght doubleValue];
                    if ([minutes class] != [NSNull class]) lastUsedMinutesLenghtd = [[numberTransfer numberFromString:minutes] doubleValue] + lastUsedMinutesLenghtd;
                    
                    double lastUsedCallAttemptsd = [destination.lastUsedCallAttempts doubleValue];
                    if ([count class] != [NSNull class]) lastUsedCallAttemptsd = [[numberTransfer numberFromString:count] doubleValue] + lastUsedCallAttemptsd;
                    
                    double lastUsedProfitd = [destination.lastUsedProfit doubleValue];
                    if ([profit class] != [NSNull class]) lastUsedProfitd = [[numberTransfer numberFromString:profit] doubleValue] + lastUsedProfitd;
                    
                    double lastUsedSuccessCallsd = 0;
                    if ([asr class] != [NSNull class])  lastUsedSuccessCallsd = lastUsedCallAttemptsd * [[numberTransfer numberFromString:asr] doubleValue];
                    
                    double lastUsedACDd;
                    double lastUsedASRd;
                    
                    if (lastUsedSuccessCallsd != 0) {
                        lastUsedACDd = lastUsedMinutesLenghtd / lastUsedSuccessCallsd;
                        lastUsedASRd = lastUsedSuccessCallsd / lastUsedCallAttemptsd;
                    } else 
                    {
                        // we are pickup old asr, * to old call attempts and devide to new call attempts - bingo, new asr when successeful calls = 0. acd keep same;
                        lastUsedACDd = [destination.lastUsedACD doubleValue];
                        lastUsedASRd = ([destination.lastUsedASR doubleValue] * [destination.lastUsedCallAttempts doubleValue]) /  lastUsedCallAttemptsd;
                    }
                    
                    destination.lastUsedASR = [NSNumber numberWithDouble:lastUsedASRd];
                    destination.lastUsedACD = [NSNumber numberWithDouble:lastUsedACDd];
                    destination.lastUsedCallAttempts = [NSNumber numberWithDouble:lastUsedCallAttemptsd];
                    destination.lastUsedMinutesLenght = [NSNumber numberWithDouble:lastUsedMinutesLenghtd];
                    destination.lastUsedProfit = [NSNumber numberWithDouble:lastUsedProfitd];
                    destination.lastUsedDate = [NSDate date];
                    
                    // insert per hour statistic
                    //if ([updatedDestinations containsObject:destination]) destinationHaveUpdatedCode = YES;
                    //else destinationHaveUpdatedCode = NO;
                    
                    NSArray *perHourStatistic =  [usedCode valueForKey:@"statisticPerHour"];
                    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
                    //NSNumberFormatter *numberTransfer = [[NSNumberFormatter alloc] init];
                    //[numberTransfer setDecimalSeparator:@"."];
                    
                    [perHourStatistic enumerateObjectsWithOptions:NSSortStable usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSString *acd = [obj valueForKey:@"ACD"];
                        NSString *count = [obj valueForKey:@"Count"];
                        NSString *minutes = [obj valueForKey:@"Minutes"];
                        NSString *profit = [obj valueForKey:@"Profit"];
                        NSString *amount = [obj valueForKey:@"Amount"];
                        NSString *asr = [obj valueForKey:@"ASR"];
                        NSString *externalDate = [obj valueForKey:@"Date"];
                        
                        [inputFormatter setDateFormat:@"yyyyMMddHH"];
                        NSDate *externalDateFormatted = [inputFormatter dateFromString:externalDate];
                        
                        // we have to update only per hour record, which we receive in this session. 
                        // other records have to be same as was before.
                        NSSet *perHourStatsFiltered = [destination.destinationPerHourStat filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"(externalDate == %@)",externalDate]];
                        if ([perHourStatsFiltered count] >1) NSLog(@"STAT: warning, per hour stat have more than one choice. Result is: \n%@\n",perHourStatsFiltered);
                        if ([perHourStatsFiltered count] == 0) {
                            // destination was updated, code was matched, but we have another hour, which don't need to make summary, we need to add as new.
                            destinationNeedNewStatisticForCode = YES;
                            destinationNeedUpdateStatisticForCode = NO;
                            //NSLog(@"STAT: warning, per hour stat don't have choice from :%@\n for date:%@\n",perHourStats,[countAsrAcdPerHour valueForKey:@"Date"]);
                        } else
                        {
                            if ([updatedDestinations containsObject:[destination objectID]]) destinationNeedUpdateStatisticForCode = YES;
                            destinationNeedNewStatisticForCode = NO;
                        }
                        
                        
                        if (destinationNeedUpdateStatisticForCode) {
                            // must be just one
                            DestinationPerHourStat *currentPerHourStat = [perHourStatsFiltered anyObject];
                            
                            double newMinutesLenghtd = [currentPerHourStat.minutesLenght doubleValue];
                            if ([minutes class] != [NSNull class]) newMinutesLenghtd = [[numberTransfer numberFromString:minutes] doubleValue] + newMinutesLenghtd;
                            
                            double newCallAttemptsd = [currentPerHourStat.callAttempts doubleValue];
                            if ([count class] != [NSNull class]) newCallAttemptsd = [[numberTransfer numberFromString:count] doubleValue] + newCallAttemptsd;
                            
                            double newProfitd = [currentPerHourStat.profit doubleValue];
                            if ([profit class] != [NSNull class]) newProfitd = [[numberTransfer numberFromString:profit] doubleValue] + newProfitd;
                            
                            double newAmountd = [currentPerHourStat.cashflow doubleValue];
                            if ([amount class] != [NSNull class]) newAmountd = [[numberTransfer numberFromString:amount] doubleValue] + newAmountd;
                            
                            double newSuccessCallsd = 0;
                            if ([asr class] != [NSNull class])  newSuccessCallsd = newCallAttemptsd * [[numberTransfer numberFromString:asr] doubleValue];
                            
                            double newACDd;
                            double newASRd;
                            if (newSuccessCallsd != 0) {
                                newACDd = newMinutesLenghtd / newSuccessCallsd;
                                newASRd= newSuccessCallsd / newCallAttemptsd;
                            } else
                            {
                                // we are pickup old asr, * to old call attempts and devide to new call attempts - bingo, new asr when successeful calls = 0. acd keep same;
                                newACDd = [currentPerHourStat.acd doubleValue];
                                newASRd = ([currentPerHourStat.asr doubleValue] * [currentPerHourStat.callAttempts doubleValue]) /  newCallAttemptsd;
                            }
                            currentPerHourStat.asr = [NSNumber numberWithDouble:newASRd];
                            currentPerHourStat.acd = [NSNumber numberWithDouble:newACDd];
                            currentPerHourStat.callAttempts = [NSNumber numberWithDouble:newCallAttemptsd];
                            currentPerHourStat.minutesLenght = [NSNumber numberWithDouble:newMinutesLenghtd];
                            currentPerHourStat.profit = [NSNumber numberWithDouble:newProfitd];
                            currentPerHourStat.cashflow = [NSNumber numberWithDouble:newAmountd];
                            
                            //currentPerHourStat.externalDate = 
                            
                        } 
                        if (destinationNeedNewStatisticForCode)
                        {
                            DestinationPerHourStat *newPerHourStat = (DestinationPerHourStat *)[NSEntityDescription 
                                                                                                insertNewObjectForEntityForName:@"DestinationPerHourStat"
                                                                                                inManagedObjectContext:self.moc];
                            newPerHourStat.date = externalDateFormatted;
                            newPerHourStat.externalDate = externalDate;
                            newPerHourStat.acd = [numberTransfer numberFromString:acd];
                            newPerHourStat.asr = [numberTransfer numberFromString:asr];
                            newPerHourStat.callAttempts = [numberTransfer numberFromString:count];
                            newPerHourStat.minutesLenght = [numberTransfer numberFromString:minutes];
                            newPerHourStat.profit = [numberTransfer numberFromString:profit];
                            newPerHourStat.destinationsListWeBuy = destination;
                            
                            [updatedDestinations addObject:[destination objectID]];
                        }
                        
                    }];
                    
                    [inputFormatter release], inputFormatter = nil;
                }
            }
        }
        [numberTransfer release], numberTransfer = nil;
        [self safeSave];
        //[usedCodesWithStatistic = nil;
        [updatedDestinations release];
        //    [pool drain], pool = nil;
        
    }
    return YES;
}

- (void) removeFromMainDatabaseDestinations24hStatisticForCarrierGUID:(NSString *)carrierGUID 
                                                       withEntityName:(NSString *)entityName //withMoc:(NSManagedObjectContext *)moc;
{
    
    NSError *error = nil;
    NSFetchRequest *requestDestinations = [[NSFetchRequest alloc] init];
    [requestDestinations setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self.moc]];
    //[requestDestinations setPredicate:[NSPredicate predicateWithFormat:@"(carrier.GUID == %@)", carrierGUID]];
    if ([entityName isEqualToString:@"DestinationsListForSale"]) [requestDestinations setPredicate:[NSPredicate predicateWithFormat:@"(carrier.GUID == %@) AND (lastUsedACD > 0 OR lastUsedASR > 0 OR lastUsedCallAttempts > 0 OR lastUsedIncome > 0 OR lastUsedMinutesLenght > 0 OR lastUsedMinutesLenght > 0)",carrierGUID]];
    if ([entityName isEqualToString:@"DestinationsListWeBuy"]) [requestDestinations setPredicate:[NSPredicate predicateWithFormat:@"(carrier.GUID == %@) AND (lastUsedACD > 0 OR lastUsedASR > 0 OR lastUsedCallAttempts > 0 OR lastUsedMinutesLenght > 0 OR lastUsedMinutesLenght > 0)",carrierGUID]];

    [requestDestinations setResultType:NSManagedObjectIDResultType];
    NSArray *destinationsIDs = [self.moc executeFetchRequest:requestDestinations error:&error];
    if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (NSManagedObjectID *destination in destinationsIDs)
    {
        NSManagedObject *dest = [self.moc objectWithID:destination];
        [dest setValue:nil forKey:@"lastUsedACD"];
        [dest setValue:nil forKey:@"lastUsedASR"];
        [dest setValue:nil forKey:@"lastUsedCallAttempts"];
        [dest setValue:nil forKey:@"lastUsedDate"];
        [dest setValue:nil forKey:@"lastUsedMinutesLenght"];
        [dest setValue:nil forKey:@"lastUsedProfit"];
        if ([entityName isEqualToString:@"DestinationsListForSale"]) [dest setValue:nil forKey:@"lastUsedIncome"];
        [dest setValue:[NSDate date] forKey:@"modificationDate"];
        [pool drain],pool = nil;
        pool = [[NSAutoreleasePool alloc] init];
    }
    [pool drain],pool = nil;

    [requestDestinations release], requestDestinations = nil;
    [self safeSave];
    return;
}

- (NSArray *) insertDestinationsForEntity:(NSString *)entity;
{
    NSNumberFormatter *numberTransfer = [[NSNumberFormatter alloc] init];
    NSMutableArray *addedObjectIDS = [NSMutableArray arrayWithCapacity:0];
    NSError *error = nil; 
//    NSManagedObjectContext *moc = self.moc;
    NSString *relationShip = nil;
    if ([entity isEqualToString:@"DestinationsListForSale"]) { 
        relationShip = @"destinationsListForSale"; 
        destinationsListForSale = YES; 
    }
    if ([entity isEqualToString:@"DestinationsListTargets"]) {
        relationShip = @"destinationsListTargets";
        destinationsListTargets =  YES;
    }
    if ([entity isEqualToString:@"DestinationsListPushList"]) {
        relationShip = @"destinationsListPushList";
        destinationsListPushList =  YES;
    }
    

    for (NSString *carrierGUID in self.carriers)
    {
        //Carrier *carrier = 
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(carrier.GUID == %@)",carrierGUID];
        NSArray *destinationsOfCarrier;
        NSString *ips = nil;
        NSString *rateSheetName = nil;
        Carrier *carrierObject = nil;
        
        NSFetchRequest *requestDestinations = [[[NSFetchRequest alloc] init] autorelease];
        if (destinationsListForSale) [requestDestinations setEntity:[NSEntityDescription entityForName:@"DestinationsListForSale" inManagedObjectContext:moc]];
        if (destinationsListTargets) [requestDestinations setEntity:[NSEntityDescription entityForName:@"DestinationsListTargets" inManagedObjectContext:moc]];
        if (destinationsListPushList) [requestDestinations setEntity:[NSEntityDescription entityForName:@"DestinationsListPushList" inManagedObjectContext:moc]];

        [requestDestinations setPredicate:predicate];
        destinationsOfCarrier = [moc executeFetchRequest:requestDestinations error:&error];
        if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
        if ([destinationsOfCarrier count] != 0) { 
            carrierObject = [[destinationsOfCarrier lastObject] valueForKey:@"carrier"];
            if (destinationsListForSale)  ips = [[destinationsOfCarrier lastObject] valueForKey:@"ipAddressesList"];
            if (destinationsListForSale) rateSheetName = [[destinationsOfCarrier lastObject] valueForKey:@"rateSheet"];
        } else
        {
            [requestDestinations setEntity:[NSEntityDescription entityForName:@"Carrier" inManagedObjectContext:moc]];
            [requestDestinations setPredicate:[NSPredicate predicateWithFormat:@"(GUID == %@)",carrierGUID]];
            carrierObject = [[moc executeFetchRequest:requestDestinations error:&error] lastObject];
        }

    
        

        for (NSDictionary *destination in self.destinations)
        {
            /*  NSDictionary *destinationForAdd = [NSDictionary dictionaryWithObjectsAndKeys:
            countryForAdd,@"country",
            specificForAdd,@"specific", 
            [rateSheetAndPrefix valueForKey:@"prefix"],@"prefix",
            [rateSheetAndPrefix valueForKey:@"rateSheetID"],@"rateSheetID",
            rateForAdd,@"rate",groupsForAdd,@"groups",
            nil];*/
            
            NSString *countryName = [destination valueForKey:@"country"];
            NSString *specificName = [destination valueForKey:@"specific"];
            NSString *prefix = [destination valueForKey:@"prefix"];
            NSString *rateSheetID = [destination valueForKey:@"rateSheetID"];
            NSNumber *rate = nil;
            id rateToCheck = [destination valueForKey:@"rate"];
            if ([[rateToCheck class] isSubclassOfClass:[NSNumber class]]) {
                rate = rateToCheck;
            } else {
                NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                rate = [formatter numberFromString:rateToCheck];
                if (!rate) {
                    rateToCheck = [rateToCheck stringByReplacingOccurrencesOfString:@"," withString:@"."];
                    rate = [formatter numberFromString:rateToCheck];
                    if (!rate) { 
                        rateToCheck = [rateToCheck stringByReplacingOccurrencesOfString:@"." withString:@","];
                        rate = [formatter numberFromString:rateToCheck];
                    }
                }
                [formatter release];
            }
            NSString *inPeerId = [destination valueForKey:@"inPeerId"];

            NSArray *result;
            predicate = [NSPredicate predicateWithFormat:@"(%K.carrier.GUID == %@) AND (%K.country == %@) AND (%K.specific == %@) AND (prefix == %@) AND (rateSheetID == %@)",relationShip,carrierGUID,relationShip,countryName,relationShip,specificName,prefix,rateSheetID];
            [requestDestinations setEntity:[NSEntityDescription entityForName:@"CodesvsDestinationsList"
                                                       inManagedObjectContext:moc]];
            [requestDestinations setPredicate:predicate];
            result = [moc executeFetchRequest:requestDestinations error:&error];
            if (error) NSLog(@"Failed to executeFetchRequest to data store: %@ in function:%@", [error localizedDescription],NSStringFromSelector(_cmd)); 
            if ([result count] > 0) {
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                NSString *warning = [NSString stringWithFormat:@"WARNING: Destination:%@/%@/n is already present for carrier:%@/n with prefix:%@ and ratesheetID:%@ and will be deleted",countryName,specificName,carrierObject.name,prefix,rateSheetID];
                [dict setValue:warning forKey:NSLocalizedDescriptionKey];
                [dict setValue:@"There was an error for insert new destination." forKey:NSLocalizedFailureReasonErrorKey];
                NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
                [[NSApplication sharedApplication] presentError:error];
                NSManagedObject *destination = [[result lastObject] valueForKey:relationShip];
                [moc deleteObject:destination];
                [self safeSave];
            }
            
            if (destinationsListForSale) {
                DestinationsListForSale *object = (DestinationsListForSale *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListForSale" inManagedObjectContext:moc];
                object.changeDate = [NSDate date];
                object.country = countryName;
                object.specific = specificName;
                object.prefix = prefix;
                object.rateSheet = rateSheetName;
                object.ipAddressesList = ips;
                object.enabled = [NSNumber numberWithBool:YES];
                object.rate = rate;
                object.carrier = carrierObject;
                NSArray *codesList = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@)",countryName,specificName]];
                NSArray *codesListWithOutSpecific = [[codesList lastObject] valueForKey:@"code"];
                [codesListWithOutSpecific enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSString *codeStr, NSUInteger idx, BOOL *stop) {
                    CodesvsDestinationsList *newCode = (CodesvsDestinationsList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                    newCode.destinationsListForSale = object;
                    newCode.internalChangedDate = [NSDate date];
                    newCode.code = [numberTransfer numberFromString:codeStr];
                    newCode.country = countryName;
                    newCode.specific = specificName;
                    //newCode.originalCode = @"";
                    newCode.rate = rate;
                    newCode.prefix = prefix;
                    newCode.rateSheetName = rateSheetName;
                    newCode.rateSheetID = rateSheetID;
                    newCode.peerID = [numberTransfer numberFromString:inPeerId];
                    newCode.country = countryName;
                    newCode.enabled = [NSNumber numberWithBool:YES];
                
                }];
            }
            if (destinationsListTargets) {
                DestinationsListTargets *object = (DestinationsListTargets *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListTargets" inManagedObjectContext:self.moc];
                object.changeDate = [NSDate date];
                object.country = countryName;
                object.specific = specificName;
                //object.prefix = prefix;
                //object.rateSheet = rateSheetName;
                //object.ipAddressesList = ips;
                //object.enabled = [NSNumber numberWithBool:YES];
                object.rate = rate;
                object.carrier = carrierObject;
                NSArray *codesList = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@)",countryName,specificName]];
                NSArray *codesListWithOutSpecific = [[codesList lastObject] valueForKey:@"code"];
                [codesListWithOutSpecific enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSString *codeStr, NSUInteger idx, BOOL *stop) {
                    CodesvsDestinationsList *newCode = (CodesvsDestinationsList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                    newCode.destinationsListTargets = object;
                    newCode.internalChangedDate = [NSDate date];
                    newCode.code = [numberTransfer numberFromString:codeStr];
                    newCode.country = countryName;
                    newCode.specific = specificName;
                    //newCode.originalCode = @"";
                    newCode.rate = rate;
                    //newCode.prefix = prefix;
                    //newCode.rateSheetName = rateSheetName;
                    //newCode.rateSheetID = rateSheetID;
                    newCode.peerID = [numberTransfer numberFromString:inPeerId];
                    newCode.country = countryName;
                    newCode.enabled = [NSNumber numberWithBool:YES];
                    
                }];
            }
            if (destinationsListPushList) {
                
                DestinationsListPushList *object = (DestinationsListPushList *)[NSEntityDescription insertNewObjectForEntityForName:@"DestinationsListPushList" inManagedObjectContext:self.moc];
                //object.changeDate = [NSDate date];
                object.country = countryName;
                object.specific = specificName;
                //object.prefix = prefix;
                //object.rateSheet = rateSheetName;
                //object.ipAddressesList = ips;
                //object.enabled = [NSNumber numberWithBool:YES];
                object.rate = rate;
                object.carrier = carrierObject;
                NSArray *codesList = [[ProjectArrays sharedProjectArrays].myCountrySpecificCodeList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(country == %@) AND (specific == %@)",countryName,specificName]];
                NSArray *codesListWithOutSpecific = [[codesList lastObject] valueForKey:@"code"];
                [codesListWithOutSpecific enumerateObjectsWithOptions:NSSortStable usingBlock:^(NSString *codeStr, NSUInteger idx, BOOL *stop) {
                    CodesvsDestinationsList *newCode = (CodesvsDestinationsList *)[NSEntityDescription insertNewObjectForEntityForName:@"CodesvsDestinationsList" inManagedObjectContext:self.moc];
                    newCode.destinationsListPushList = object;
                    newCode.internalChangedDate = [NSDate date];
                    newCode.code = [numberTransfer numberFromString:codeStr];
                    newCode.country = countryName;
                    newCode.specific = specificName;
                    //newCode.originalCode = @"";
                    newCode.rate = rate;
                    //newCode.prefix = prefix;
                    //newCode.rateSheetName = rateSheetName;
                    //newCode.rateSheetID = rateSheetID;
                    newCode.peerID = [numberTransfer numberFromString:inPeerId];
                    newCode.country = countryName;
                    newCode.enabled = [NSNumber numberWithBool:YES];
                    
                }];
                [self safeSave];
#if defined(SNOW_CLIENT_APPSTORE) | defined (SNOW_CLIENT_ENTERPRISE)

//                NSMutableString *twitterText = [[NSMutableString alloc] initWithCapacity:0];
//
//                [twitterText appendString:@"I'm currently interesting for this destination:"];
//                
//                [twitterText appendFormat:@"%@/%@ with price %@ volume %@",object.country,object.specific,object.rate,object.minutesLenght];
//                
//                [delegate.carriersView.twitterController postTwitterMessageWithText:twitterText];
//                [twitterText release];
#endif
                [addedObjectIDS addObject:[object objectID]];
                
            }


        }
    }
    [numberTransfer release], numberTransfer = nil;
    NSArray *finalResult = [NSArray arrayWithArray:addedObjectIDS];
    return finalResult;
}

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


- (BOOL)safeSave; 
{
    BOOL success = YES;
    //NSManagedObjectContext *moc = self.context;
    
    if ([self.moc hasChanges]) {
        
        NSError *error = nil;
        if (![self.moc save: &error]) {
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
            success = NO;
        } else [self.moc reset];
    }
    return success;
}



@end
