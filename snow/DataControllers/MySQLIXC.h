//
//  MyHandler.h
//  snow
//
//  Created by Alex Vinogradov on 28.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ProgressUpdateController.h"
#import <Cocoa/Cocoa.h>

#import "desctopAppDelegate.h"
#import "GetExternalInfoOperation.h"
#import "mysql.h"

@class ProgressUpdateController;
@class desctopAppDelegate;

@interface MySQLIXC :  NSObject {
    NSArray *connections;
    NSUInteger queneNumber;
    //AppDelegate *appDelegate; 
    //AppDelegate *appDelegate; 

    BOOL queryDone;
    BOOL connected;
    //BOOL _currentQueueStatus;
    NSTimer *repeatingTimer;
    NSOperationQueue *checkingMysqlQuery;
    MYSQL *sql;
    MYSQL *sqlPut;
    //MYSQL_RES *qResult;
    NSString *carrierName;

    NSTimer *keepAliveTimer;    ProgressUpdateController *progress;
    BOOL updateProgress;
}
@property(readwrite) NSUInteger queneNumber;


- (id)initWithQuene:(NSUInteger)quene 
         andCarrier:(NSManagedObjectID *)carrierID 
       withProgress:(ProgressUpdateController *)_progress 
       withDelegate:(GetExternalInfoOperation *)_getExternalInfoDelegate;

- (id)initWithDelegate:(desctopAppDelegate *)delegate 
          withProgress:(ProgressUpdateController *)_progress;


-(BOOL) mysqlConnect;

@property(retain) NSArray *connections;
@property(retain) ProgressUpdateController *progress;


@property(readwrite) BOOL queryDone;
@property(readwrite) BOOL connected;

//@property (retain) NSTimer *repeatingTimer;
@property (retain)  NSString *carrierName;



@property(retain) NSOperationQueue *checkingMysqlQuery;
//@property(assign) MYSQL *sql;
//@property(assign) MYSQL *sqlPut;
//@property(assign) MYSQL_RES *qResult;


//@property(assign) MYSQL *mySqlGet0;
//@property(assign) MYSQL *mySqlPut0;


-(NSArray *) carriersList;
-(NSArray *) destinationsForSaleList:(NSString *)carrier;
-(NSArray *) destinationsWeAreBuyList:(NSString *)carrier;

// statistic group (we receive acd, asr count
-(NSArray *) inStatUsedCodes:(NSString *)carrier day:(NSString *)day;
-(NSArray *) outStatUsedCodes:(NSString *)carrier day:(NSString *)day;
-(NSArray *) inStatistic:(NSString *)carrier withCode:(NSString *)code withDay:(NSString *)day withRateSheetId:(NSString *)rateSheetId withPrefix:(NSString *)prefix;
-(NSArray *) outStatistic:(NSString *)carrier withCode:(NSString *)code withDay:(NSString *)day withRateSheetId:(NSString *)rateSheetId  withPrefix:(NSString *)prefix;


-(NSArray *) inStatisticPerHour:(NSString *)carrier withCode:(NSString *)code day:(NSString *)day prefix:(NSString *)prefix;
-(NSArray *) outStatisticPerHour:(NSString *)carrier withCode:(NSString *)code day:(NSString *)day;

// static data group
-(NSArray *) carrierStuff:(NSString *)carrier;

// routing update
-(NSArray *) receiveRoutingTableForCode:(NSString *)code prefix:(NSString *)prefix carrier:(NSString *)carrier;

-(NSArray *) carrierResponsible:(NSString *)carrier;

// updates
-(BOOL) updateForCode:(NSString *)code  forDate:(NSString *)date forRate:(NSString *)rate  forRateSheet:(NSString *)rateSheetID forCountry:(NSString *)country forSpecific:(NSString *)specific;
-(BOOL) insertNewCode:(NSString *)code  forDate:(NSString *)date forRate:(NSString *)rate  forRateSheetID:(NSString *)rateSheetID forCountry:(NSString *)country forSpecific:(NSString *)specific;

// mysql interface
-(NSArray *)fetchNamedAllWith:(NSString *)query;
-(BOOL) reset;
-(NSArray *) insertWithQuery:(NSString *)query;
-(NSArray *) getOutGroupsListWithOutPeersListInsideForCountry:(NSString *)country forSpecific:(NSString *)specific;
-(NSString *) insertNewInpeerForCarrier:(NSString *)carrier withRateSheetID:(NSString *)rateSheetID withIPAddresses:(NSString *)ipAddressesList withPrefix:(NSString *)prefix withCountry:(NSString *)country withSpecific:(NSString *)specific withCodeList:(NSArray *)codesList withOutPeersGroups:(NSArray *)outPeersGroups forRate:(NSString *)rate;
-(BOOL) checkIfPriceWasChangesWithRateSheetID:(NSString *)rateSheetID withDate:(NSString *)date ; 
-(void) deleteRateSheetWithID:(NSString *)rateSheetID;
-(NSNumber *)getCTPpeerIdForCarrier:(NSString *)carrier andPeerName:(NSString *)peerName;
-(NSArray *)getCTPdestinationsNumberForPrefix:(NSArray *)prefixes;
-(NSNumber *)putCTPtestingTaskWithNumbers:(NSString *)numbers withCTPPeerId:(NSString *)peerID;
-(BOOL)getCTPtestingCheckResultForRequestID:(NSNumber *)requestID;
-(NSArray *)getCTPtestingResultForRequestID:(NSNumber *)requestID;
-(NSArray *) fetchBinaryData:(NSString *)query;
-(BOOL) updateOutGroupsListWithOutPeersListInsideForOutGroup:(NSString *)outGroupID forEnabledOutPeers:(NSArray *)enabled forDisabledOutPeers:(NSArray *)disabled;
-(NSArray *) inStatUsedCodesWithStatisticForCarrier:(NSString *)carrier day:(NSString *)day;
-(NSArray *) outStatUsedCodesWithStatisticForCarrier:(NSString *)carrier day:(NSString *)day;
-(NSArray *)getCompanyAccounts;
-(NSArray *) getInvoicesAndPaymentsForCarrier:(NSString *)carrierName;
-(NSNumber *) createNewGroup:(NSDictionary *)outPeerGroup;
-(NSNumber *) idForInsertedInvoiceOrPaymentForCarrier:(NSString *)carrier forAccountName:(NSString *)accountName forServiceDate:(NSDate *)serviceDate forSumm:(NSNumber *)amount forInvoice:(BOOL)isInvoice forReceived:(BOOL)isReceived;

-(NSUInteger) countOfStatisticForSalePerHourForCarrier:(NSString *)carrier fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

-(NSUInteger) countOfStatisticWeBuyPerHourForCarrier:(NSString *)carrier fromDate:(NSDate *)fromDate toDate:(NSDate *)toDate;

-(NSString *)mysqlStringFromDate:(NSDate *)date;

@end
