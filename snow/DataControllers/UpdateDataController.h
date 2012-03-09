//
//  InitUpdateIXC.h
//  snow
//
//  Created by Alex Vinogradov on 28.10.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ProgressUpdateController.h"
#import "DestinationsListWeBuyResults.h"
#import "desctopAppDelegate.h"
#import "MySQLIXC.h"
#import "ProgressUpdateController.h"
#import "Carrier.h"
#import "CurrentCompany.h"

@class MySQLIXC;

@class ProgressUpdateController;
@class desctopAppDelegate;

@interface UpdateDataController : NSObject {
    //__weak AppDelegate *appDelegate;
    desctopAppDelegate *delegate;

    MySQLIXC *database;
    //NSManagedObjectContext *managedObjectContext;
    NSURL *url;
//    NSManagedObjectID *autorizedUserID;
//    NSManagedObjectID *autorizedUserCompanyID;
    
    NSManagedObjectContext *moc;

}

@property (assign)  MySQLIXC *database;
@property (assign)  desctopAppDelegate *delegate;

//@property (assign)  NSManagedObjectContext *managedObjectContext;
//@property (retain)  NSManagedObjectID *autorizedUserID;
//@property (retain)  NSManagedObjectID *autorizedUserCompanyID;

@property (assign) NSManagedObjectContext *moc;

//- (id)initWithDelegate:(AppDelegate *)delegate withManagedObjectContext:(NSManagedObjectContext *)_managedObjectContext withDatabase:(MySQLIXC *)_database; 

- (id)initWithDatabase:(MySQLIXC *)_database; 


// methods which need mysql connection
- (void)updateCarrierContactforCarrier:(Carrier *)carrier;
-(BOOL)  updateDestinationListforCarrier:(NSManagedObjectID *)carrierID 
                         destinationType:(NSInteger)destinationType
            withProgressUpdateController:(ProgressUpdateController *)progress;

-(void)  updateStatisticforCarrierGUID:(NSString *)carrierGUID 
                        andCarrierName:(NSString *)carrierName
                       destinationType:(NSInteger)destinationType
          withProgressUpdateController:(ProgressUpdateController *)progress;

-(void)  updatePerHourStatisticforCarrierGUID:(NSString *)carrierGUID
                                  carrierName:(NSString *)carrierName
                              destinationType:(NSInteger)destinationType
                 withProgressUpdateController:(ProgressUpdateController *)progress;


-(void) updateCarriersFinancialRatingAndLastUpdatedTimeForCarrierGUID:(NSManagedObjectID *)carrierID withTotalProfit:(NSNumber *)totalProfitNumber;
- (void) updateResponsibleContactforCarrier:(Carrier *)carrier forCurrentCompany:(CurrentCompany *)currentCompany;
- (void) getDestinationsListAndOutGroupsForAddInCountry:(NSString *)country;
- (void) readExternalCountryCodesListWithProgressUpdateController:(ProgressUpdateController *)progress;
- (void) updateRoutingTableForDestinations:(NSArray *)destinations;
- (NSNumber *) checkIfRatesWasUpdatedforCarrierGUID:(NSManagedObjectID *)carrierID andCarrierName:(NSString *)carrierName;

-(NSArray *) inserDestinationsForCarriers:(NSArray *)carrierListForAdd 
                          andDestinations:(NSArray *)destinationsListForAdd 
                                forEntity:(NSString *)entity 
                              withPercent:(NSNumber *)percent 
                   withLinesForActivation:(NSNumber *)lines;

- (void) everyHourSync;
- (void) twicePerDaySyncWithProgress:(ProgressUpdateController *)progress;
//- (void) everyDaySyncWithProgress:(ProgressUpdateController *)progress;
- (BOOL) processUpdateDestinationForSaleForCodes:(NSSet *)codes withRate:(NSNumber *)rate withDatabaseConnection:(MySQLIXC *)databaseForUpdate;
- (void) updatePriceWithData:(NSDictionary *)data 
               withRateSheet:(NSString *)rateSheet
                withProgress:(ProgressUpdateController *)progress
              withRatesStack:(NSMutableArray *)ratesStack
           withRateFormatter:(NSNumberFormatter *)rateFormatter
           withDateFormatter:(NSDateFormatter *)inputFormatter;

- (void) startUserChoiceSyncForCarriers:(NSArray *)carriersToExecute withProgress:(ProgressUpdateController *)progress withOperationName:(NSString *)operationName;
- (void) testDestinations:(NSArray *)destinations;
-(void) updateCompanyAccountsWithProgress:(ProgressUpdateController *)progress;
-(void) getInvoicesAndPaymentsForCarrier:(NSManagedObjectID *)carrierName;
- (void) carriersListWithProgress:(ProgressUpdateController *)progress;
-(void) processRatesStackFor:(NSMutableArray *)ratesStack 
                    progress:(ProgressUpdateController *)progress;

// methods which don't need mysql connection
- (void) removeFromMainDatabaseDestinations3monthStatisticForCarrier:(NSString *)carrierName withRelationShipsName:(NSString *)relationShipsName;
- (void) removeFromMainDatabaseDestinations24hStatisticForCarrier:(NSString *)carrierName withEntityName:(NSString *)entityName;
- (void) removeFromMainDatabaseCarrier:(NSString *)carrierName;
- (void) removeFromMainDatabaseDestinationsForCarrier:(NSString *)carrierName withEntityName:(NSString *)entityName;
- (NSArray *)getRateSheetsAndPrefixListToChoiceByUserForCarrierID:(NSManagedObjectID *)carrierID withRelationShipName:(NSString *)relationShipName;
- (NSArray *)fillCarriersForAddArrayForCarriers:(NSArray *)carriers withRelationShipName:(NSString *)relationShipName forCurrentContent:(NSArray *)currentContent;
- (NSArray *) parseCVSimported:(NSArray *)array 
                    forCarrier:(NSString *)carrier 
          withRelationshipName:(NSString *)relationshipName;
- (void) importCSVstartWithRelationshipName:(NSString *)relationshipName;
- (void) importCSVfinishWithProgress:(ProgressUpdateController *)progress withRelationship:(NSString *)relationship;
- (NSArray *)destinationsArrayDictionariesToArrayArrays:(NSArray *)destinations;
- (void) parseToExcelArray:(NSArray *)array withSaveUrl:(NSString *)saveUrl;
- (void)sendEmailMessageTo:(NSString *)to withSubject:(NSString *)subject withContent:(NSString *)content withFrom:(NSString *)from withFilePaths:(NSArray *)filePaths;
- (void) fillEventsListInternallyAndSaveToDiskForExternalUsing:(NSArray *)filteredEvents;
- (NSArray *) transformContentFromHorizontalToVerticalDataForBinding:(NSManagedObject *)content;
- (void) checkCalendarsForCountryListAndFutureEvents:(NSArray *)calendars;
- (void)logError:(NSError*)error;
- (void) setupDefaultDatabaseConnections;
- (NSArray *) databaseConnections;
- (NSArray *) databaseConnectionCTP;
- (void) testResultMailToCustomer:(NSArray *)testsForSend;
- (NSString *) testResultWriteLogToFile:(DestinationsListWeBuyResults *)result;
- (NSDictionary *) testResultWriteMediaToFile:(DestinationsListWeBuyResults *)result;
-(NSMutableDictionary *) parseRulesForIVRforResults:(NSArray *)result;
-(NSMutableString *) parseInternalDataToRulesForIVR:(NSMutableDictionary *)result;
- (NSMutableDictionary *) getIVRConfigurationTable;
-(BOOL) finalSave;
-(NSMutableArray *) parseToExcelwithSaveUrl:(NSString *)fullPath forSheetNumber:(int) sheetNumber;
-(NSArray *)allExcelBookSheetsForUSR:(NSString *)saveURL;
- (void) parseChoicesFillingForCarrier:(NSString *)carrier withRelationshipName:(NSString *)relationshipName;
- (void) importCSVforArray:(NSArray *)array 
           forChoiceTarget:(NSNumber *)choiceTarget 
           forChoiceColumn:(NSArray *)choiceColumn
       forRelationshipName:(NSString *)relationshipName;
-(void) carriersListWithProgress:(ProgressUpdateController *)progress 
               forCurrentCompany:(NSManagedObjectID *)currentCompanyID 
forIsUpdateCarriesListOnExternalServer:(BOOL)isUpdateCarriesListOnExternalServer;


@end
