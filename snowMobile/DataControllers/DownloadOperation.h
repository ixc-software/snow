//
//  DownloadOperation.h
//  snow
//
//  Created by Alex Vinogradov on 02.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DownloadOperation;

@protocol DownloadOperationDelegate <NSObject>

@optional
// Notification posted by NSManagedObjectContext when saved.
- (void)importerDidSave:(NSNotification *)saveNotification;
// Called by the importer when parsing is finished.
- (void)importerDidFinishParsingData:(DownloadOperation *)download;
// Called by the importer in the case of an error.
- (void)importer:(DownloadOperation *)download didFailWithError:(NSError *)error;
- (void)importerDidChangeParsingData:(DownloadOperation *)importer ;

@end


@interface DownloadOperation : NSOperation {
@private
    id <DownloadOperationDelegate> delegate;
    NSManagedObjectContext *insertionContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    BOOL downloadExternalDataWasUnsucceseful;
    NSString *operationName;
    NSNumber *percentDone;
    BOOL isError;
    BOOL isItLatestMessage;
}
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectContext *insertionContext;
@property (nonatomic, assign) id <DownloadOperationDelegate> delegate;
@property (readwrite) BOOL downloadExternalDataWasUnsucceseful;
@property (nonatomic, retain) NSString *operationName;
@property (nonatomic, retain) NSNumber *percentDone;
@property (readwrite) BOOL isError;
@property (readwrite) BOOL isItLatestMessage;

- (void)main;

@end
