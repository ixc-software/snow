//
//  DownloadExternalData.m
//  snow
//
//  Created by Alex Vinogradov on 02.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DownloadExternalData.h"


@implementation DownloadExternalData

@synthesize managedObjectContext,downloadOp,operationQueue,persistentStoreCoordinator,delegateData;

static NSString * const kLastStoreUpdateKey = @"LastStoreUpdate";
static NSTimeInterval const kRefreshTimeInterval = 3;



-(void) downloadAndPutInLocalDatabaseEventsArray;
{
    NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:kLastStoreUpdateKey];
    if (lastUpdate == nil || -[lastUpdate timeIntervalSinceNow] > kRefreshTimeInterval) {
        self.downloadOp = [[[DownloadOperation alloc] init] autorelease];
        downloadOp.delegate = self;
        downloadOp.persistentStoreCoordinator = self.persistentStoreCoordinator;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [downloadOp setQueuePriority:NSOperationQueuePriorityVeryLow];
        [self.operationQueue addOperation:downloadOp];
    }
}
- (NSOperationQueue *)operationQueue {
    if (operationQueue == nil) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
}


#pragma mark <DownloadOperationDelegate> Implementation
- (void)importerDidChangeParsingData:(DownloadOperation *)importer {
    if (self.delegateData != nil && [self.delegateData respondsToSelector:@selector(countWasUpdateWithResult:)]) {
        [self.delegateData countWasUpdateWithResult:importer];
    }
}

// This method will be called on a secondary thread. Forward to the main thread for safe handling of UIKit objects.
- (void)importerDidSave:(NSNotification *)saveNotification {
    
    if ([NSThread isMainThread]) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:saveNotification];
        [self performSelectorOnMainThread:@selector(save) withObject:nil waitUntilDone:YES];

    } else {
        [self performSelectorOnMainThread:@selector(importerDidSave:) withObject:saveNotification waitUntilDone:NO];
    }
}
- (void)handleImportCompletion {
    // Store the current time as the time of the last import. This will be used to determine whether an
    // import is necessary when the application runs.
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastStoreUpdateKey];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.downloadOp = nil;
}


// This method will be called on a secondary thread. Forward to the main thread for safe handling of UIKit objects.
- (void)importerDidFinishParsingData:(DownloadOperation *)importer {
    if (self.delegateData != nil && [self.delegateData respondsToSelector:@selector(dataWasUpdateWithResult:)]) {
        [self.delegateData dataWasUpdateWithResult:importer];
    }
}

-(void)save;
{
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    //NSLog(@"save was done");

}

@end
