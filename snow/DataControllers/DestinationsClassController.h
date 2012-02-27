//
//  DestinationsClassController.h
//  snow
//
//  Created by Oleksii Vynogradov on 21.04.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressUpdateController.h"
#import "MySQLIXC.h"

@class desctopAppDelegate;

@interface DestinationsClassController : NSObject {
@private
    NSArray *externalDataCodes;
    //NSNumber *externalDataCodesCount;
    NSArray *internalCodes;
    NSString *additionalMessageForUser;

   /* Printing description of destinationsExternal:
    {
    // external destinations part:
        chdate = "2009-04-19";
        code = 101;
        enabled = y;
        ip = "193.108.120.163";
        peerID = 1;
        prefix = "";
        price = "0.65000";
        rateSheetID = 1003;
        rateSheetName = "all_out";
        yn = y;
    // targets part:
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
     minutes = 
     attempts =
     effectiveDate = 
     code =
     enabled = 
     withRateSheetID = 
     rateSheetName = 
     prefix = 
     */
    NSArray *usedCodesWithStatistic;

    BOOL destinationsListForSale;
    BOOL destinationsListWeBuy;
    BOOL destinationsListTargets;
    BOOL destinationsListPushList;
    NSArray *carriers;
    NSArray *destinations;
    /*  NSDictionary *destinationForAdd = [NSDictionary dictionaryWithObjectsAndKeys:
     countryForAdd,@"country",
     specificForAdd,@"specific", 
     [rateSheetAndPrefix valueForKey:@"prefix"],@"prefix",
     [rateSheetAndPrefix valueForKey:@"rateSheetID"],@"rateSheetID",
     rateForAdd,@"rate",groupsForAdd,@"groups",
     nil];*/

    ProgressUpdateController *progress;
    NSManagedObjectContext *moc;
    //NSManagedObjectContext *mainMoc;

    NSMutableArray *insertedDestinationsIDs;
    BOOL isDestinationsPushListUpdated;
    NSMutableString *currentCarrierName;
    NSManagedObjectID *currentCarrierID;
    desctopAppDelegate *delegate;
}
@property (assign)  desctopAppDelegate *delegate;

@property (readwrite) BOOL isDestinationsPushListUpdated;
@property (retain) NSMutableArray *insertedDestinationsIDs;
@property (retain) NSArray *externalDataCodes;
@property (retain) NSString *additionalMessageForUser;

@property (retain) NSArray *internalCodes;

@property (retain) NSArray *usedCodesWithStatistic;

@property (retain) NSArray *carriers;
@property (retain) NSArray *destinations;
@property (retain) ProgressUpdateController *progress;
@property (retain) NSManagedObjectContext *moc;


// rules for public function:
// [what they are do][with what they working]
- (BOOL) updateEntity:(NSString *)entityName;
- (BOOL) updateStatisticForEntity:(NSString *)entity;
- (NSArray *) insertDestinationsForEntity:(NSString *)entity;
- (id)initWithMainMoc:(NSManagedObjectContext *)itsMainMoc;

@end
