//
//  GetExternalInfoOperation.h
//  snow
//
//  Created by Oleksii Vynogradov on 2/7/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetExternalInfoOperation : NSObject
{
    NSManagedObjectID *carrierID;
    NSNumber *index;
    NSNumber *queuePosition;
    NSString *operationName;
    NSNumber *totalProfit;
    NSManagedObjectID *currentCompanyID;
    NSString *carrierGUID;
    NSString *carrierName;

}

@property (retain) NSNumber *totalProfit;
@property (retain) NSNumber *index;
@property (retain) NSNumber *queuePosition;
@property (retain) NSManagedObjectID *currentCompanyID;
@property (retain) NSString *carrierGUID;
@property (retain) NSString *carrierName;


- (id)initAndUpdateCarrier:(NSManagedObjectID *)carrierIDFor
                 withIndex:(NSNumber *)indexFor
         withQueuePosition:(NSNumber *)queuePositionFor
         withOperationName:(NSString *)operationNameFor
           withTotalProfit:(NSNumber *)totalProfitFor
           withCarrierGUID:(NSString *)carrierGUIDFor
           withCarrierName:(NSString *)carrierNameFor;
//      withCurrentCompanyID:(NSManagedObjectID *)currentCompanyIDfor;

-(void)main;
@end
