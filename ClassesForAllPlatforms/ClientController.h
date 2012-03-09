//
//  ClientController.h
//  snow
//
//  Created by Oleksii Vynogradov on 04.09.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainSystem.h"
#import "CompanyStuff.h"

@interface ClientController : NSObject {
@private
    NSManagedObjectContext *moc;
    NSManagedObjectContext *mainMoc;

    NSURL *mainServer;
    NSMutableData *receivedData;
    BOOL downloadCompleted;
    id sender;
    NSNumber *downloadSize;

}
@property (retain) NSManagedObjectContext *moc;
@property (assign) NSManagedObjectContext *mainMoc;

@property (retain) NSNumber *downloadSize;

@property (assign) id sender;

@property (retain) NSURL *mainServer;

-(id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator withSender:(id)senderForThisClass withMainMoc:(NSManagedObjectContext *)itMainMoc;


-(CompanyStuff *)authorization;
//-(BOOL)checkIfCurrentAdminCanLogin;

-(MainSystem *) firstSetup;

-(MainSystem *)getMainSystem;


-(void)getCompaniesListWithImmediatelyStart:(BOOL)isImmediatelyStart;
-(NSString *)getAllObjectsForEntity:(NSString *)entityName immediatelyStart:(BOOL)isImmediatelyStart isUserAuthorized:(BOOL)isUserAuthorized;
-(void)putObjectWithTimeoutWithIDs:(NSArray *)objectIDs mustBeApproved:(BOOL)isMustBeApproved;
-(void)removeObjectWithID:(NSManagedObjectID *)objectID;

-(void) setUserDefaultsObject:(id)object forKey:(NSString *)key;
-(NSString *)localStatusForObjectsWithRootGuid:(NSString *)rootObjectGUID;
-(void) finalSave:(NSManagedObjectContext *)mocForSave; 
//-(BOOL) checkIfCurrentAdminCanLogin;
-(void) updateLocalGraphFromSnowEnterpriseServerWithDateFrom:(NSDate *)dateFrom 
                                                  withDateTo:(NSDate *)dateTo
                               withIncludeCarrierSubentities:(BOOL)isIncludeCarrierSubentities;

-(NSArray *)getAllObjectsListWithEntityForList:(NSString *)entityForList 
                            withMainObjectGUID:(NSString *)mainObjectGUID 
                          withMainObjectEntity:(NSString *)mainObjectEntity 
                                     withAdmin:(CompanyStuff *)admin  
                                  withDateFrom:(NSDate *)dateFrom 
                                    withDateTo:(NSDate *)dateTo;
-(NSArray *)getAllObjectsWithGUIDs:(NSArray *)guids 
                            withEntity:(NSString *)entity 
                             withAdmin:(CompanyStuff *)admin;
-(NSArray *) updateGraphForObjects:(NSArray *)allObjects 
                        withEntity:(NSString *)entityFor 
                         withAdmin:(CompanyStuff *)admin 
                    withRootObject:(NSManagedObject *)rootObject
             isEveryTenPercentSave:(BOOL)isEveryTenPercentSave;

-(void) updateLocalGraphFromSnowEnterpriseServerForCarrierID:(NSManagedObjectID *)carrierID
                                                withDateFrom:(NSDate *)dateFrom 
                                                  withDateTo:(NSDate *)dateTo
                                                   withAdmin:(CompanyStuff *)admin;
-(void) processLoginForEmail:(NSString *)email forPassword:(NSString *)password;

@end
