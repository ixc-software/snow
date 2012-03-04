#import <Foundation/Foundation.h>
#import "HTTPResponse.h"

@class HTTPConnection;

// 
// This class is a UnitTest for the delayResponeHeaders capability of HTTPConnection
// 

@interface HTTPResponseTest : NSObject <HTTPResponse>
{
	HTTPConnection *connection;
	dispatch_queue_t connectionQueue;
	NSData *receivedData;
    
    NSUInteger offset;
	NSData *data;
	dispatch_queue_t concurrentQueue;

    
	BOOL readyToSendResponseHeaders;
}

- (id)initWithConnection:(HTTPConnection *)connectionFor withReceivedData:(NSData *)receivedDataFor;

@end
