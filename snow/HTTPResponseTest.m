#import "HTTPResponseTest.h"
#import "HTTPConnection.h"
#import "HTTPLogging.h"

#import "JSONKit.h"
#import "ServerController.h"

// Log levels: off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_OFF; // | HTTP_LOG_FLAG_TRACE;

// 
// This class is a UnitTest for the delayResponeHeaders capability of HTTPConnection
// 

@interface HTTPResponseTest (PrivateAPI)
- (void)doAsyncStuff;
- (void)asyncStuffFinished;
@end


@implementation HTTPResponseTest

- (id)initWithConnection:(HTTPConnection *)connectionFor withReceivedData:(NSData *)receivedDataFor;
{
	if ((self = [super init]))
	{
		HTTPLogTrace();
		receivedData = [receivedDataFor retain];
        
		connection = connectionFor; // Parents retain children, children do NOT retain parents
		
		connectionQueue = dispatch_get_current_queue();
		dispatch_retain(connectionQueue);
		
		readyToSendResponseHeaders = NO;
		
		concurrentQueue = dispatch_queue_create("HTTPAsyncGetObjectsResponse", NULL);
		dispatch_async(concurrentQueue, ^{
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			[self doAsyncStuff];
			[pool release];
		});
	}
	return self;
}

- (void)doAsyncStuff
{
	// This method is executed on a global concurrent queue
	
	HTTPLogTrace();
	
//	[NSThread sleepForTimeInterval:5.0];
	
	dispatch_async(connectionQueue, ^{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        JSONDecoder *jkitDecoder = [JSONDecoder decoder];
        NSError *error = nil;
        NSString *postStr = [[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding] autorelease];

        NSDictionary *result = [jkitDecoder objectWithUTF8String:(const unsigned char *)[postStr UTF8String] length:[postStr length] error:&error];
        //NSLog(@"%@[%p]: GetObjects:decoding result: %@ with error:%@", THIS_FILE, self, result, [error localizedDescription]);
        
        NSString *authorizedUserEmail = [result valueForKey:@"authorizedUserEmail"];
        NSString *authorizedUserPassword = [result valueForKey:@"authorizedUserPassword"];
        NSString *entityForList = [result valueForKey:@"entity"];
        NSArray *guids = [[NSArray alloc] initWithArray:[result valueForKey:@"allGUIDs"]];
        //        NSNumber *isIncludeAllObjects = [result valueForKey:@"isIncludeAllObjects"];
        //NSLog(@"Class:%@",[[result valueForKey:@"isIncludeAllSubentities"] class]);
        //        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        //        
        //        NSNumber *isIncludeAllSubentities = [formatter numberFromString:isIncludeAllSubentitiesString];
        //        NSNumber *isIncludeAllObjects = [formatter numberFromString:isIncludeAllObjectsString];
        //        [formatter release];
        
        
        ServerController *serverController = [[ServerController alloc] init];
        //        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
        //        serverController.moc = [delegate managedObjectContext]; 
        
        NSString *senderIP = nil;//[asyncSocket connectedHost];
        NSString *receiverIP = nil;//[asyncSocket localHost];
        //NSLog(@"GetObjects: senderIP:%@,receiverIP:%@",senderIP,receiverIP);
        NSString *answer = [serverController getObjectsWithGUIDsForUserEmail:authorizedUserEmail withPassword:authorizedUserPassword withEntity:entityForList withGUIDs:guids withSenderIP:senderIP withReceiverIP:receiverIP];        
        //NSLog(@"%@[%p]: >>>>>>>>>>>>>>>>>>>>>>>>GetObjectsWithGUIDs:answer: %@ ", THIS_FILE, self, answer);
        [guids release];
		data = [[answer dataUsingEncoding:NSUTF8StringEncoding] retain];

		[self asyncStuffFinished];
		[pool release];
	});
}

- (void)asyncStuffFinished
{
	// This method is executed on the connectionQueue
	
	HTTPLogTrace();
	
	readyToSendResponseHeaders = YES;
	[connection responseHasAvailableData:self];
}

- (BOOL)delayResponeHeaders
{
	HTTPLogTrace2(@"%@[%p] %@ -> %@", THIS_FILE, self, THIS_METHOD, (readyToSendResponseHeaders ? @"NO" : @"YES"));
	
	return !readyToSendResponseHeaders;
}

- (void)connectionDidClose
{
	// This method is executed on the connectionQueue
	
	HTTPLogTrace();
	
	connection = nil;
}

- (UInt64)contentLength
{
	HTTPLogTrace();
	UInt64 result = (UInt64)[data length];
	
	HTTPLogTrace2(@"%@[%p]: contentLength - %llu", THIS_FILE, self, result);
	
	return result;

	return 0;
}

- (UInt64)offset
{
	HTTPLogTrace();
    return offset;

	return 0;
}

- (void)setOffset:(UInt64)offsetParam
{
	HTTPLogTrace();
    offset = (NSUInteger)offsetParam;

	// Ignored
}

- (NSData *)readDataOfLength:(NSUInteger)lengthParameter
{
	HTTPLogTrace();
    
    HTTPLogTrace2(@"%@[%p]: readDataOfLength:%lu", THIS_FILE, self, (unsigned long)lengthParameter);
	
	NSUInteger remaining = [data length] - offset;
	NSUInteger length = lengthParameter < remaining ? lengthParameter : remaining;
	
	void *bytes = (void *)([data bytes] + offset);
	
	offset += length;
	
	return [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:NO];

	return nil;
}

- (BOOL)isDone
{
	HTTPLogTrace();
	BOOL result = (offset == [data length]);
	
	HTTPLogTrace2(@"%@[%p]: isDone - %@", THIS_FILE, self, (result ? @"YES" : @"NO"));
	
	return result;
	
	return YES;
}
- (BOOL)isAsynchronous 
{
    return YES;
    
}
- (void)dealloc
{
	HTTPLogTrace();
    [data release];
	[receivedData release];
	dispatch_release(connectionQueue);
	dispatch_release(concurrentQueue);

	[super dealloc];
}

@end
