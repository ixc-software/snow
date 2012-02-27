//
//  debugAnalizerAppDelegate.h
//  debugAnalizer
//
//  Created by Oleksii Vynogradov on 2/25/12.
//  Copyright (c) 2012 IXC-USA Corp. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface debugAnalizerAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
