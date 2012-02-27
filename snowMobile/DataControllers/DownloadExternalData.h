//
//  DownloadExternalData.h
//  snow
//
//  Created by Alex Vinogradov on 02.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadOperation.h"

@class DownloadOperation;

@protocol DownloadExternalDataDelegate <NSObject>

@optional
- (void)dataWasUpdateWithResult:(DownloadOperation *)importer;
- (void)countWasUpdateWithResult:(DownloadOperation *)importer;

@end

@interface DownloadExternalData : NSObject <DownloadOperationDelegate> {
@private
    NSManagedObjectContext *managedObjectContext;	    
    id <DownloadExternalDataDelegate> delegateData;

    DownloadOperation *downloadOp;
    NSOperationQueue *operationQueue;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) id <DownloadExternalDataDelegate> delegateData;
@property (nonatomic, retain) DownloadOperation *downloadOp;
@property (nonatomic, retain, readonly) NSOperationQueue *operationQueue;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;


-(void) downloadAndPutInLocalDatabaseEventsArray;


@end
