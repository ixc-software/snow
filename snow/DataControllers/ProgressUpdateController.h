//
//  CountryCodeListChange.h
//  snow
//
//  Created by Alex Vinogradov on 02.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class desctopAppDelegate;

@interface ProgressUpdateController : NSObject {
    __weak desctopAppDelegate *appDelegate;
    //AppDelegate *appDelegate;

    //IBOutlet NSButton *cycleUpdatePerHourCount;
    //IBOutlet NSButton *cycleUpdateTwicePerDayCount;
    //IBOutlet NSButton *cycleUpdateDaylyCount;
    
    //IBOutlet NSButton *ratesStackIndicator;
    
    NSMutableDictionary *currentProgressStatusInTable;
    NSNumber *queuePosition;
    NSNumber *indexOfUpdatedobject;
    NSString *carrierName;
    NSString *subOperationName;
    NSNumber *percentDone;
    NSNumber *objectsQuantity;
    NSNumber *objectsCount;
    NSString *cycleSyncType;
    NSString *operationName;
    double countObjects;
}

@property (readwrite) double countObjects;

@property (retain) NSMutableDictionary *currentProgressStatusInTable;

@property (retain) NSNumber *queuePosition;
@property (retain) NSNumber *indexOfUpdatedobject;
@property (retain) NSString *carrierName;
@property (retain) NSString *subOperationName;
@property (retain) NSString *operationName;

@property (retain) NSNumber *percentDone;
@property (retain) NSNumber *objectsQuantity;
@property (retain) NSNumber *objectsCount;
@property (retain) NSString *cycleSyncType;

- (id)initWithDelegate:(desctopAppDelegate *)delegate withQueuePosition:(NSNumber *)_queuePosition withIndexOfUpdatedObject:(NSNumber *)_indexOfUpdatedobject;
- (id)initWithDelegate:(desctopAppDelegate *)delegate ;
 //withProgressIndicator:(BOOL)usingProgressIndicator;


- (void) updateCurrentObjectsCount;
- (void) updateCarrierName:(NSString *)newCarrierName;
- (void) updateOperationName:(NSString *)newOperationName;
- (void) updateSystemMessage:(NSString *)systemMessage;
- (void) updateProgressIndicatorCountGetExternalData;
- (void) updateProgressIndicatorMessageGetExternalData:(NSString *)newMessage;
- (void) clearPoll;
- (void) startProgressIndicatorCountSeeWebRouting;
- (void) stopProgressIndicatorCountSeeWebRouting;
- (void) hideTables;
- (void) unHideTables;
- (void) startSync;
- (void) stopSync;
- (void) startProgressIndicatorAddDestinations;
- (void) stopProgressIndicatorCountAddDestinations;
- (void) startAddDestinations;
- (void) stopAddDestinations;
- (void) updateOperationNameForMsyqlQueryStart;
- (void) updateOperationNameForMsyqlQueryFinish;
- (void) startCycleDaylySync;
- (void) stopCycleDaylySync;
- (void) startCycleTwicePerDaySync;
- (void) stopCycleTwicePerDaySync;
- (void) startCyclePerHourlySync;
- (void) stopCyclePerHourSync;
- (void) cycleRemaindTime:(NSNumber *)remindTime;
- (void) clearForRecord:(NSNumber *)recordId;
- (void) startProgressIndicatorEventsChecking;
- (void) stopProgressIndicatorEventsChecking;
- (void) startProgressIndicatorEventsAddDestination;
- (void) stopProgressIndicatorEventsAddDestination;
- (void) changeIndicatorRatesStackWithObjectsQuantity:(NSNumber *)quantity;
- (void) startImportPrice;
- (void) stopImportPrice;
- (void) startTestDestinations;
- (void) stopTestDestinations;
- (void) startTestDestinationsForTargets;
- (void) stopTestDestinationsForTargets;
- (void) startGetCarriersList;
- (void) stopGetCarriersList;
- (void) startParsingPrice;
- (void) stopParsingPrice;
- (void) updateProgressIndicatorRatesStack;
- (void) updateOperationNameForMsyqlQueryWaitingStart;
- (void) updateOperationNameForMsyqlQueryWaitingFinish;

@end
