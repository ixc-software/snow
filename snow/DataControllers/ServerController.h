//
//  MyClass.h
//  snow
//
//  Created by Oleksii Vynogradov on 04.09.11.
//  Copyright 2011 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>


@class desctopDelegate;
@interface ServerController : NSObject {
//@private
  
    NSManagedObjectContext *moc;
    desctopDelegate *delegate;
}
@property (assign)  desctopDelegate *delegate;

@property (retain) NSManagedObjectContext *moc;
-(NSString *)loginWithEmail:(NSString *)email
               withPassword:(NSString *)password
               withSenderIP:(NSString *)senderIP
             withReceiverIP:(NSString *)receiverIP;

-(NSString *)getCompaniesListwithSenderIP:(NSString *)senderIP
                           withReceiverIP:(NSString *)receiverIP;

-(NSString *)updateInternalGraphForUserEmail:(NSString *)userEmail 
                               withPassword:(NSString *)password                       
                               withSenderIP:(NSString *)senderIP
                             withReceiverIP:(NSString *)receiverIP;

-(NSString *)getObjectsForUserEmail:(NSString *)userEmail 
                      withPassword:(NSString *)password 
                     forObjectGUID:(NSString *)objectGUID
                   forObjectEntity:(NSString *)objectEntity 
         withIncludeAllSubentities:(BOOL)isIncludeAllSubentities
             withIncludeAllObjects:(BOOL)isIncludeAllObjects
                      withSenderIP:(NSString *)senderIP
                    withReceiverIP:(NSString *)receiverIP;

-(NSString *)putObjectForUserEmail:(NSString *)userEmail 
                      withPassword:(NSString *)password
                 withNecessaryData:(NSString *)necessaryData
                    mustBeApproved:(BOOL)isMustBeApproved   
                      withSenderIP:(NSString *)senderIP
                    withReceiverIP:(NSString *)receiverIP;

-(NSString *)removeObjectWithGUID:(NSString *)objectGUID 
                  forObjectEntity:(NSString *)objectEntity 
                      forUserEmail:(NSString *)userEmail 
                     withPassword:(NSString *)password                       
                     withSenderIP:(NSString *)senderIP
                   withReceiverIP:(NSString *)receiverIP;
-(NSString *)getObjectsListForUserEmail:(NSString *)userEmail 
                           withPassword:(NSString *)password 
                      withEntityForList:(NSString *)entityForList 
                     withMainObjectGUID:(NSString *)mainObjectGUID
                   withMainObjectEntity:(NSString *)mainObjectEntity
                           withDateFrom:(NSDate *)dateFrom
                             withDateTo:(NSDate *)dateTo
                           withSenderIP:(NSString *)senderIP
                         withReceiverIP:(NSString *)receiverIP;
-(NSString *)getObjectsWithGUIDsForUserEmail:(NSString *)userEmail 
                                withPassword:(NSString *)password 
                                  withEntity:(NSString *)entity 
                                   withGUIDs:(NSArray *)guids
                                withSenderIP:(NSString *)senderIP
                              withReceiverIP:(NSString *)receiverIP;


@end
