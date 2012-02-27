//
//  GetExternalInfoOperation.m
//  snow
//
//  Created by Oleksii Vynogradov on 2/7/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import "GetExternalInfoOperation.h"
#import "ProgressUpdateController.h"
#import "MySQLIXC.h"
#import "UpdateDataController.h"
#import "GetExternalInfoView.h"

@implementation GetExternalInfoOperation

@synthesize totalProfit,index,queuePosition,currentCompanyID,carrierGUID,carrierName;

- (id)initAndUpdateCarrier:(NSManagedObjectID *)carrierIDFor
                 withIndex:(NSNumber *)indexFor
         withQueuePosition:(NSNumber *)queuePositionFor
         withOperationName:(NSString *)operationNameFor
           withTotalProfit:(NSNumber *)totalProfitFor
           withCarrierGUID:(NSString *)carrierGUIDFor
           withCarrierName:(NSString *)carrierNameFor;
{
    if (!(self = [super init])) return nil;
    else {
        carrierID = carrierIDFor;
        queuePosition = queuePositionFor;
        index = indexFor;
        operationName = operationNameFor;
        totalProfit = totalProfitFor;
        carrierGUID = carrierGUIDFor;
        carrierName = carrierNameFor;
        return self;
    }
}

-(void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.25]];
     
    desctopAppDelegate *delegate = (desctopAppDelegate *)[[NSApplication sharedApplication] delegate];
//    Carrier *necessaryCarrier = (Carrier *)[delegate.managedObjectContext objectWithID:carrierID];
    ProgressUpdateController *progress = [[ProgressUpdateController alloc]  
                                          initWithDelegate:delegate 
                                          withQueuePosition:queuePosition 
                                          withIndexOfUpdatedObject:index];
    
    MySQLIXC *databaseForUsing = [[MySQLIXC alloc] initWithQuene:index.unsignedIntegerValue 
                                                      andCarrier:carrierID 
                                                    withProgress:progress 
                                                    withDelegate:nil];
    
    //[self setDatabase:databaseForUsing];
    
    UpdateDataController *update = [[UpdateDataController alloc] initWithDatabase:databaseForUsing];
    
    databaseForUsing.connections = delegate.getExternalInfoView.databaseConnections.arrangedObjects;
    //[databaseForUsing release];
//    Carrier *necessaryCarrier = (Carrier *)[update.moc objectWithID:carrierID];
//    NSString *carrierGUID = necessaryCarrier.GUID;
//    NSString *carrierName = necessaryCarrier.name;
    
    [progress updateCarrierName:carrierName];
    progress.operationName = operationName;
    
    //0 - dont need update 1 - destinationsListForSale 2 - destinationsListWeBuy 3 - both
    
    
//    NSString *carrierGUID = [[NSString alloc] initWithString:necessaryCarrier.GUID];
//    NSString *carrierName = [[NSString alloc] initWithString:necessaryCarrier.name];
    NSDate *startCheckRates = [[NSDate alloc] initWithTimeIntervalSinceNow:0];

    NSNumber *updateRates = [update checkIfRatesWasUpdatedforCarrierGUID:carrierID andCarrierName:carrierName];
    NSTimeInterval interval = [startCheckRates timeIntervalSinceDate:[NSDate date]];
    [startCheckRates release];
    //[NSNumber numberWithInt:3];//[update checkIfRatesWasUpdatedforCarrierGUID:carrierGUID andCarrierName:carrierName];
    NSLog(@"STAT:Carrier %@ need rates update: %@ time to check if need update:%@", carrierName, updateRates,[NSNumber numberWithDouble:interval]);
    BOOL outgoingDestinationsListIsEmpty = NO;
    BOOL incomingDestinationsListIsEmpty = NO;
    
    if (updateRates.intValue != 0) {
        NSDate *startCheckRates = [[NSDate alloc] initWithTimeIntervalSinceNow:0];

        incomingDestinationsListIsEmpty = [update updateDestinationListforCarrier:carrierID destinationType:0 withProgressUpdateController:progress];
        outgoingDestinationsListIsEmpty = [update updateDestinationListforCarrier:carrierID destinationType:1 withProgressUpdateController:progress];
        NSTimeInterval interval = [startCheckRates timeIntervalSinceDate:[NSDate date]];
        NSNumber *updateTime = [NSNumber numberWithDouble:interval/60];
        
        NSLog(@"STAT:Carrier %@ rates was update time:%@ min ", carrierName,updateTime);

        [startCheckRates release];

    }
        if ([operationName isEqualToString:@"Every hour sync"]) {
            if (!incomingDestinationsListIsEmpty) { 
                NSLog(@"STAT:Carrier %@ per hour incoming stat will update", carrierName);
                
                [update updatePerHourStatisticforCarrierGUID:carrierGUID carrierName:carrierName destinationType:0 withProgressUpdateController:progress];
            }
            if (!outgoingDestinationsListIsEmpty) { 
                NSLog(@"STAT:Carrier %@ per hour outgoing stat will update", carrierName);
                
                [update updatePerHourStatisticforCarrierGUID:carrierGUID carrierName:carrierName destinationType:1 withProgressUpdateController:progress];
            }
            
        } else {
            NSDate *startCheckRates = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
            

            if (!incomingDestinationsListIsEmpty) { 
                
                [update updateStatisticforCarrierGUID:carrierGUID andCarrierName:carrierName destinationType:0 withProgressUpdateController:progress];
                
            }
            if (!outgoingDestinationsListIsEmpty) { 
                [update updateStatisticforCarrierGUID:carrierGUID andCarrierName:carrierName destinationType:1 withProgressUpdateController:progress];
            }
            NSTimeInterval interval = [startCheckRates timeIntervalSinceDate:[NSDate date]];

            NSLog(@"STAT:Carrier %@ pre dayly outgoing stat was update time:%@ min", carrierName,[NSNumber numberWithDouble:interval/60]);
            [startCheckRates release];

        }
    NSDate *startFinancialRatingAndInvoices = [[NSDate alloc] initWithTimeIntervalSinceNow:0];
    
    [update updateCarriersFinancialRatingAndLastUpdatedTimeForCarrierGUID:carrierID withTotalProfit:self.totalProfit];
    [update getInvoicesAndPaymentsForCarrier:carrierID];
    NSTimeInterval intervalForFinancial = [startFinancialRatingAndInvoices timeIntervalSinceDate:[NSDate date]];

    [startFinancialRatingAndInvoices release];
    NSLog(@"STAT:Carrier %@ financial and invoices was update time:%@ min ", carrierName,[NSNumber numberWithDouble:intervalForFinancial/60]);

    [progress clearForRecord:index];

    [progress release];
    [databaseForUsing reset];
    [databaseForUsing release];
    [update release];
//    [carrierGUID release],[carrierName release];
    [pool drain],pool = nil;
    
}

-(void)dealloc
{
    [totalProfit release];
    [index release];
    [queuePosition release];
    [carrierName release];
    [carrierGUID release];
//    [currentCompanyID release];
}

@end
