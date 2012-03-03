//
//  CountryCodeListChange.m
//  snow
//
//  Created by Alex Vinogradov on 02.12.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ProgressUpdateController.h"
//#import "ProjectArrays.h"
#import "desctopAppDelegate.h"


@implementation ProgressUpdateController

@synthesize currentProgressStatusInTable;
@synthesize queuePosition;
@synthesize indexOfUpdatedobject;
@synthesize carrierName;
@synthesize subOperationName;
@synthesize percentDone;
@synthesize objectsQuantity;
@synthesize objectsCount;
@synthesize cycleSyncType;
@synthesize operationName;
@synthesize countObjects;

- (id)initWithDelegate:(desctopAppDelegate *)delegate withQueuePosition:(NSNumber *)_queuePosition withIndexOfUpdatedObject:(NSNumber *)_indexOfUpdatedobject;
{
    if ((self = [super init])) {
        appDelegate = [[NSApplication sharedApplication] delegate];
        //appDelegate = delegate;
        [self setQueuePosition:_queuePosition];
        [self setIndexOfUpdatedobject:_indexOfUpdatedobject];
        [self setCarrierName:@""];
        [self setSubOperationName:@""];
        [self setPercentDone:[NSNumber numberWithInt:0]];
        //[self setObjectsCount:[NSNumber numberWithInt:0]];
        objectsCount = [NSNumber numberWithInt:0];
        
        currentProgressStatusInTable = [[NSMutableDictionary alloc] initWithCapacity:0];
        [currentProgressStatusInTable setObject:carrierName forKey:@"carrier"];
        [currentProgressStatusInTable setObject:queuePosition forKey:@"queue"];
        [currentProgressStatusInTable setObject:subOperationName forKey:@"operation"];
        [currentProgressStatusInTable setObject:percentDone forKey:@"progress"];
        [currentProgressStatusInTable setObject:indexOfUpdatedobject forKey:@"index"];
        [self performSelectorOnMainThread:@selector(addNewObjectInCurrentObjectsCount:) withObject:currentProgressStatusInTable waitUntilDone:YES];
        //[appDelegate.operationsProgress addObject:currentProgressStatusInTable];
        /*@synchronized(self)
         {
         //if ([[appDelegate.operationsProgress arrangedObjects] count] > [_queuePosition unsignedIntegerValue]) [appDelegate.operationsProgress removeObjectAtArrangedObjectIndex:[queuePosition unsignedIntegerValue]];
         [appDelegate.operationsProgress insertObject:currentProgressStatusInTable atArrangedObjectIndex:[queuePosition unsignedIntegerValue]];
         }*/
    }
    return self;
}

- (id)initWithDelegate:(desctopAppDelegate *)delegate; 
//withProgressIndicator:(BOOL)usingProgressIndicator;
{
    if ((self = [super init])) {
        appDelegate = delegate;
        //[[NSApplication sharedApplication] delegate];
    }
    return self;
}
- (void)dealloc {
    [queuePosition release];
    [indexOfUpdatedobject release];
    [carrierName release];
    [subOperationName release];
    [percentDone release];
    [objectsCount release];
    [currentProgressStatusInTable release];
    [super dealloc];
}

- (void) updateProgressIndicatorCountGetExternalData;
{
    //[self perform
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        //if (!self.objectsCount) self.objectsCount = [NSNumber numberWithInt:0];
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        [self setPercentDone:[NSNumber numberWithDouble:countObjects/[objectsQuantity doubleValue]]];
        //int currentCount = [objectsCount intValue];
        countObjects++;
        //objectsCount = [NSNumber numberWithInt:currentCount];
        [delegate.getExternalInfoView.getExternalInfoProgress setHidden:NO];
        [delegate.getExternalInfoView.getExternalInfoProgress setDoubleValue:[percentDone doubleValue]]; 
    });
}

- (void) updateProgressIndicatorRatesStack;
{
    //[self perform
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        [self setPercentDone:[NSNumber numberWithDouble:[objectsCount doubleValue]/[objectsQuantity doubleValue]]];
        [self setObjectsCount:[NSNumber numberWithInt:[objectsCount intValue] + 1]];
        [delegate.getExternalInfoView.ratesStackProgressIndicator setDoubleValue:[percentDone doubleValue]]; 
    });
}

- (void) updateProgressIndicatorMessageGetExternalData:(NSString *)newMessage;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [self setObjectsCount:0];
        if ([newMessage isEqualToString:@""]) { 
            [delegate.getExternalInfoView.getExternalInfoProgress setHidden:YES];
            [delegate.getExternalInfoView.getExternalInfoProgressTextField setHidden:YES];
        }
        else { 
            [delegate.getExternalInfoView.getExternalInfoProgress  setHidden:NO];
            [delegate.getExternalInfoView.getExternalInfoProgressTextField setHidden:NO];
            [delegate.getExternalInfoView.getExternalInfoProgressTextField setStringValue:newMessage];
            
        }
        //[pool drain];
        return;
        
    });
}

- (void) startProgressIndicatorCountSeeWebRouting;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:NO];
        [appDelegate.mainProgressIndicator startAnimation:appDelegate];
        
    });
}

- (void) stopProgressIndicatorCountSeeWebRouting;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
        
    });
}

- (void) startProgressIndicatorAddDestinations;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:NO];
        [appDelegate.mainProgressIndicator startAnimation:appDelegate];
        
        
        //[appDelegate.nextEvent setEnabled:NO];
        //[appDelegate.nextEventAndAddDestination setEnabled:NO];
    });
}

- (void) stopProgressIndicatorCountAddDestinations;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
        
        //[appDelegate.nextEvent setEnabled:YES];
        //[appDelegate.nextEventAndAddDestination setEnabled:YES];
    });
}
- (void) startProgressIndicatorEventsChecking;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:NO];
        [appDelegate.mainProgressIndicator startAnimation:appDelegate];
        
    });
    
}
- (void) stopProgressIndicatorEventsChecking;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
        
    });
}

- (void) startProgressIndicatorEventsAddDestination;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:NO];
        [appDelegate.mainProgressIndicator startAnimation:appDelegate];
        
        
    });
}

- (void) stopProgressIndicatorEventsAddDestination;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
        
    });
}

- (void) startSync;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        [delegate.getExternalInfoView.getCarriersList setEnabled:NO];
        [delegate.getExternalInfoView.startSync setEnabled:NO];
    });
}
- (void) stopSync;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        [delegate.getExternalInfoView.getCarriersList setEnabled:YES];
        [delegate.getExternalInfoView.startSync setEnabled:YES];
     });
    
}
- (void) startAddDestinations;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:NO];
        [appDelegate.mainProgressIndicator startAnimation:appDelegate];
        
        
    });
    
}
- (void) stopAddDestinations;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
        
        
        
    });
}

- (void) startTestDestinations;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:NO];
        [appDelegate.mainProgressIndicator startAnimation:appDelegate];
    });
    
}
- (void) stopTestDestinations;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
        
    });
}

- (void) startTestDestinationsForTargets;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:NO];
        [appDelegate.mainProgressIndicator startAnimation:appDelegate];
    });
    
}
- (void) stopTestDestinationsForTargets;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
    });
    
}

- (void) startImportPrice;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        [delegate.getExternalInfoView.importCSVUploadPriceLabel setHidden:NO];
        [delegate.getExternalInfoView.ratesStackProgressIndicator setHidden:NO];
        
        
        //[appDelegate.mainProgressIndicator setHidden:NO];
        //[appDelegate.mainProgressIndicator startAnimation:appDelegate];
        //[self updateProgressIndicatorMessageGetExternalData:@"Import price.."];
    });
}

- (void) stopImportPrice;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
        
        
        [delegate.getExternalInfoView.importCSVUploadPriceLabel setHidden:YES];
        [delegate.getExternalInfoView.ratesStackProgressIndicator setHidden:YES];
        
        
        //[self updateProgressIndicatorMessageGetExternalData:@""];
    });
    
}
- (void) startParsingPrice;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:NO];
        [appDelegate.mainProgressIndicator startAnimation:appDelegate];
        
     });
    
}
-(void) stopParsingPrice;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
        
    });
    
}

- (void) startCycleDaylySync;
{
    //NSLog (@"SYNC:startCycleDaylySync");
    //self.cycleSyncType = @"dayly";
    
}

- (void) stopCycleDaylySync;
{
    //NSLog (@"SYNC:EveryDaySyncFinish");
    
}

- (void) startCycleTwicePerDaySync;
{
    //NSLog (@"SYNC:start startCycleTwicePerDaySync");
    // self.cycleSyncType = @"twice";
    
}

- (void) stopCycleTwicePerDaySync;
{
    //NSLog (@"SYNC:updateTwicePerDaySync");
    
}

- (void) startCyclePerHourlySync;
{    
    //self.cycleSyncType = @"hourly";
    //NSLog (@"SYNC:start startCyclePerHourlySync");
    
    
}

- (void) stopCyclePerHourSync;
{
    
}

- (void) startGetCarriersList;
{    
    //self.cycleSyncType = @"hourly";
    // NSLog (@"SYNC:start startCyclePerHourlySync");
    dispatch_async(dispatch_get_main_queue(), ^(void) {         
    });
    
}

- (void) stopGetCarriersList;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
    });
}

- (void) startRatesheetParsing;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:NO];
        
        [appDelegate.mainProgressIndicator startAnimation:appDelegate];
        
       
        //[self updateProgressIndicatorMessageGetExternalData:@"Import price.."];
    });
}

- (void) stopRatesheetParsing;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        [appDelegate.mainProgressIndicator setHidden:YES];
        [appDelegate.mainProgressIndicator stopAnimation:appDelegate];
        
        //[self updateProgressIndicatorMessageGetExternalData:@""];
    });
    
}


- (void) changeIndicatorRatesStackWithObjectsQuantity:(NSNumber *)quantity;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        if ([quantity intValue] == 0) {
            
//            [appDelegate.ratesStackIndicator setTitle:@"empty"];
//            [appDelegate.ratesStackIndicator setImage:[NSImage imageNamed:@"status-available"]];
//            [appDelegate.ratesStackIndicator setImagePosition:NSImageLeft];
//        } else
//        {
//            [appDelegate.ratesStackIndicator setImage:[NSImage imageNamed:@"redlight"]];
//            [appDelegate.ratesStackIndicator setImagePosition:NSImageLeft];
//            [appDelegate.ratesStackIndicator setTitle:[NSString stringWithFormat:@"%@ records",quantity]];
        }
    });
}

- (void) cycleRemaindTime:(NSNumber *)remindTime;
{
    dispatch_async(dispatch_get_main_queue(), ^{ 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        if ([self.cycleSyncType isEqualToString:@"dayly"]) [delegate.getExternalInfoView.cycleUpdateDaylyCount setTitle:[NSString stringWithFormat:@"To start per day sync remind: %@s",remindTime]];
        if ([self.cycleSyncType isEqualToString:@"twice"]) [delegate.getExternalInfoView setTitle:[NSString stringWithFormat:@"%@s",remindTime]];
        if ([self.cycleSyncType isEqualToString:@"hourly"]) [delegate.getExternalInfoView.cycleUpdatePerHourCount setTitle:[NSString stringWithFormat:@"To start per hour sync remind: %@s",remindTime]];
        //NSLog(@"PROGRESS CONTROLLER:for cycle:%@ remind time is:%@",cycleSyncType,remindTime);
    });
}


- (void) updateSystemMessage:(NSString *)systemMessage;
{    
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
//        [appDelegate.systemNotifications setStringValue:[NSString stringWithString:systemMessage]];
    });
}

- (void) addNewObjectInCurrentObjectsCount:(NSDictionary *)dict
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        [delegate.getExternalInfoView.operationProgress addObject:dict];
        [delegate.getExternalInfoView.startSync setEnabled:NO];
    });
}

- (void) updateObjectInCurrentObjectsCount:(NSNumber *)index
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@",index];
        NSMutableDictionary *currentStatus = [[[delegate.getExternalInfoView.operationProgress arrangedObjects] filteredArrayUsingPredicate:predicate] lastObject];
        [currentStatus setValue:percentDone forKey:@"progress"];
    });
}

- (void) updateCurrentObjectsCount;
{
    //NSLog(@"PROGRESS CONTROLLER:replace present object:updateCarrierName with %@",newCarrierName);
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        
        [self setPercentDone:[NSNumber numberWithDouble:[objectsCount doubleValue]/[objectsQuantity doubleValue]]];
        NSNumber *newCount = [NSNumber numberWithInt:([objectsCount intValue] + [[NSNumber numberWithDouble:[objectsQuantity intValue]* 0.01] intValue])];
        
        [self setObjectsCount:newCount];
        //dispatch_async(dispatch_get_main_queue(), ^(void) { 
        [self updateObjectInCurrentObjectsCount:indexOfUpdatedobject]; 
    });
    //});
    
    //[self performSelectorOnMainThread:@selector(updateObjectInCurrentObjectsCount:) withObject:indexOfUpdatedobject waitUntilDone:YES];
}

- (void) updateCarrierName:(NSString *)newCarrierName;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        //NSLog(@"PROGRESS CONTROLLER:replace present object:updateCarrierName with %@",newCarrierName);
        [self setObjectsCount:0];
        
        [self setCarrierName:newCarrierName];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@",indexOfUpdatedobject];
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        NSMutableDictionary *currentStatus = [[[delegate.getExternalInfoView.operationProgress arrangedObjects] filteredArrayUsingPredicate:predicate] lastObject];
        
        [currentStatus setValue:newCarrierName forKey:@"carrier"];
    });
}

- (void) updateOperationName:(NSString *)newOperationName;
{
    
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        //NSLog(@"PROGRESS CONTROLLER:replace present object:updateOperationName with %@",newOperationName);
        [self setObjectsCount:0];
        [self setSubOperationName:newOperationName];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@",indexOfUpdatedobject];
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        NSMutableDictionary *currentStatus = [[[delegate.getExternalInfoView.operationProgress arrangedObjects] filteredArrayUsingPredicate:predicate] lastObject];
        
        [currentStatus setValue:[NSString stringWithFormat:@"%@ %@",self.operationName,self.subOperationName] forKey:@"operation"];
    });
}

- (void) updateOperationNameForMsyqlQueryStart;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        NSString *operationFullName = [NSString stringWithFormat:@"%@ %@",self.operationName,self.subOperationName];
        //[self setSubOperationName:[NSString stringWithFormat:@"%@%@",self.subOperationName,@"[query start]"]];
        NSString *newOperationName = [NSString stringWithFormat:@"%@%@",operationFullName,@"[query start]"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@",indexOfUpdatedobject];
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        NSMutableDictionary *currentStatus = [[[delegate.getExternalInfoView.operationProgress arrangedObjects] filteredArrayUsingPredicate:predicate] lastObject];
        [currentStatus setValue:newOperationName forKey:@"operation"];
    });
}

- (void) updateOperationNameForMsyqlQueryFinish;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        NSString *operationFullName = [NSString stringWithFormat:@"%@ %@",self.operationName,self.subOperationName];
        
        //NSString *currentOperationName = self.subOperationName;
        //NSString *newOperationName = [currentOperationName stringByReplacingOccurrencesOfString:@"[query start]" withString:@""];
        //[self setSubOperationName:newOperationName];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@",indexOfUpdatedobject];
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        NSMutableDictionary *currentStatus = [[[delegate.getExternalInfoView.operationProgress arrangedObjects] filteredArrayUsingPredicate:predicate] lastObject];
        [currentStatus setValue:operationFullName forKey:@"operation"];
    });
}


- (void) updateOperationNameForMsyqlQueryWaitingStart;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        NSString *operationFullName = [NSString stringWithFormat:@"%@ %@",self.operationName,self.subOperationName];
        //[self setSubOperationName:[NSString stringWithFormat:@"%@%@",self.subOperationName,@"[query start]"]];
        NSString *newOperationName = [NSString stringWithFormat:@"%@%@",operationFullName,@"[query waiting]"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@",indexOfUpdatedobject];
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        NSMutableDictionary *currentStatus = [[[delegate.getExternalInfoView.operationProgress arrangedObjects] filteredArrayUsingPredicate:predicate] lastObject];
        [currentStatus setValue:newOperationName forKey:@"operation"];
    });
}

- (void) updateOperationNameForMsyqlQueryWaitingFinish;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        NSString *operationFullName = [NSString stringWithFormat:@"%@ %@",self.operationName,self.subOperationName];
        
        //NSString *currentOperationName = self.subOperationName;
        //NSString *newOperationName = [currentOperationName stringByReplacingOccurrencesOfString:@"[query start]" withString:@""];
        //[self setSubOperationName:newOperationName];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@",indexOfUpdatedobject];
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
        
        NSMutableDictionary *currentStatus = [[[delegate.getExternalInfoView.operationProgress arrangedObjects] filteredArrayUsingPredicate:predicate] lastObject];
        [currentStatus setValue:operationFullName forKey:@"operation"];
    });
}



- (void) hideTables;
{
    
    //[appDelegate.carriersTableViewTop90 setHidden:YES];
    //[appDelegate.destinationsListForSaleTableView setHidden:YES];
    //[appDelegate.destinationsListWeBuyTableView setHidden:YES];
    //[appDelegate.codesvsDestinationsForSaleTableView setHidden:YES];
    //[appDelegate.codesvsDestinationsWeBuyTableView setHidden:YES];
    //[appDelegate.carriersTableViewTop90 setHidden:YES];
    //[appDelegate.deleteProcessTop90 setHidden:NO];
    //[appDelegate.carriersTableViewTop10 setHidden:YES];
    //[appDelegate.deleteProcessTop10 setHidden:NO];
    //[appDelegate.carriersTableView0 setHidden:YES];
    //[appDelegate.deleteProcess0 setHidden:NO];
    //[appDelegate.carriersTableViewUpdated setHidden:YES];
    //[appDelegate.deleteProcessUpdated setHidden:NO];
    //[appDelegate.deleteProcess0 setHidden:YES];
    //[appDelegate.carriersTableView0 setHidden:NO];
    //[appDelegate.deleteProcessUpdated startAnimation:self];
    //[appDelegate.deleteProcess0 startAnimation:self];
    //[appDelegate.deleteProcessTop10 startAnimation:self];
    //[appDelegate.deleteProcessTop90 startAnimation:self];
    
}

- (void) unHideTables;
{
    //[appDelegate.destinationsListForSaleTableView setHidden:NO];
    //[appDelegate.destinationsListWeBuyTableView setHidden:NO];
    //[appDelegate.codesvsDestinationsForSaleTableView setHidden:NO];
    //[appDelegate.codesvsDestinationsWeBuyTableView setHidden:NO];
    //[appDelegate.deleteProcessTop90 setHidden:YES];
    //[appDelegate.carriersTableViewTop90 setHidden:NO];
    //[appDelegate.deleteProcessTop10 setHidden:YES];
    //[appDelegate.carriersTableViewTop10 setHidden:NO];
    //[appDelegate.deleteProcess0 setHidden:YES];
    //[appDelegate.carriersTableView0 setHidden:NO];
    //[appDelegate.deleteProcessUpdated setHidden:YES];
    //[appDelegate.carriersTableViewUpdated setHidden:NO];
    //[appDelegate.deleteProcessUpdated stopAnimation:self];
    //[appDelegate.deleteProcess0 stopAnimation:self];
    //[appDelegate.deleteProcessTop10 stopAnimation:self];
    //[appDelegate.deleteProcessTop90 stopAnimation:self];
    
}

-(void) removeObject:(NSDictionary *)currentStatus
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        [[delegate.getExternalInfoView.operationProgress content] removeObject:currentStatus];
        //[appDelegate.operationsProgress rearrangeObjects];
    });
}

- (void) clearForRecord:(NSNumber *)recordId;
{
    
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"index == %@",indexOfUpdatedobject];
        NSMutableDictionary *currentStatus = [[[delegate.getExternalInfoView.operationProgress arrangedObjects] filteredArrayUsingPredicate:predicate] lastObject];
        [self removeObject:currentStatus];
        NSLog(@"PROGRESS INDICATOR: cleared index:%@ for status:%@",recordId,currentStatus);
    });
}


- (void) clearPoll;
{
    dispatch_async(dispatch_get_main_queue(), ^(void) { 
        desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];

        [[delegate.getExternalInfoView.operationProgress content] removeAllObjects];
        [delegate.getExternalInfoView.operationProgress rearrangeObjects];
    });
}




@end
