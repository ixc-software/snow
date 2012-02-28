#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"

#import "ServerController.h"
#import "GCDAsyncSocket.h"
#import "JSONKit.h"

#import "DDKeychain.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
**/

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"])
	{
		if( [path isEqualToString:@"/GetCompaniesList"] || [path isEqualToString:@"/GetObjects"] || [path isEqualToString:@"/GetObjectsList"]|| [path isEqualToString:@"/PutObject"] || [path isEqualToString:@"/RemoveObject"] || [path isEqualToString:@"/LoginUser"] || [path isEqualToString:@"/GetObjectsWithGUIDs"])
		{
            //return YES;
            //NSNumber *contentLenght = [NSNumber numberWithInt:requestContentLength];
            //NSLog(@"Content lenght:%@",contentLenght);
            
            
			//Let's be extra cautious, and make sure the upload isn't 5 gigs
            if (!(requestContentLength < 80000000)) NSLog(@"Content lenght:not supported");
            
            
			return requestContentLength < 80000000;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
/*	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/post.html"])
	{
		HTTPLogVerbose(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
		
		HTTPLogVerbose(@"%@[%p]: postStr: %@", THIS_FILE, self, postStr);
		
		// Result will be of the form "answer=..."
		
		int answer = [[postStr substringFromIndex:7] intValue];
		
		NSData *response = nil;
		if(answer == 10)
		{
			response = [@"<html><body>Correct<body></html>" dataUsingEncoding:NSUTF8StringEncoding];
		}
		else
		{
			response = [@"<html><body>Sorry - Try Again<body></html>" dataUsingEncoding:NSUTF8StringEncoding];
		}
		
		return [[[HTTPDataResponse alloc] initWithData:response] autorelease];
	} */
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/LoginUser"] )
	{
		//NSLog(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
		
		NSLog(@"%@[%p]: Login:postStr: %@", THIS_FILE, self, postStr);
		
		// Result will be of the form "answer=..."
        ServerController *serverController = [[ServerController alloc] init];
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        serverController.moc = [delegate managedObjectContext]; 
        
        NSString *senderIP = [asyncSocket connectedHost];
        NSString *receiverIP = [asyncSocket localHost];
        //NSLog(@"GetCompaniesList: senderIP:%@,receiverIP:%@",senderIP,receiverIP);
        JSONDecoder *jkitDecoder = [JSONDecoder decoder];
        NSError *error = nil;
        NSDictionary *result = [jkitDecoder objectWithUTF8String:(const unsigned char *)[postStr UTF8String] length:[postStr length] error:&error];
        //NSLog(@"%@[%p]: GetObjects:decoding result: %@ with error:%@", THIS_FILE, self, result, [error localizedDescription]);
        
        NSString *authorizedUserEmail = [result valueForKey:@"authorizedUserEmail"];
        NSString *authorizedUserPassword = [result valueForKey:@"authorizedUserPassword"];
        
        NSString *answer = [serverController loginWithEmail:authorizedUserEmail withPassword:authorizedUserPassword withSenderIP:senderIP withReceiverIP:receiverIP];
        
        NSLog(@"%@[%p]: Login:answer: %@ ", THIS_FILE, self, answer);
		NSData *response = [answer dataUsingEncoding:NSUTF8StringEncoding];
        [serverController release];
        
        HTTPDataResponse *responseFinal = [[[HTTPDataResponse alloc] initWithData:response] autorelease];
        
        //[responseFinal.httpHeaders setValue:@"application/json" forKey:@"Content-Type"];
        
		return responseFinal;
	}
    
	if([method isEqualToString:@"POST"] && [path isEqualToString:@"/GetCompaniesList"] )
	{
		//NSLog(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
		
		NSLog(@"%@[%p]: GetCompaniesList:postStr: %@", THIS_FILE, self, postStr);
		
		// Result will be of the form "answer=..."
        ServerController *serverController = [[ServerController alloc] init];
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        serverController.moc = [delegate managedObjectContext]; 
//        
        NSString *senderIP = [asyncSocket connectedHost];
        NSString *receiverIP = [asyncSocket localHost];
        //NSLog(@"GetCompaniesList: senderIP:%@,receiverIP:%@",senderIP,receiverIP);
        NSString *answer = [serverController getCompaniesListwithSenderIP:senderIP 
                                                           withReceiverIP:receiverIP];
        
        NSLog(@"%@[%p]: GetCompaniesList:answer: %@ ", THIS_FILE, self, answer);
		NSData *response = [answer dataUsingEncoding:NSUTF8StringEncoding];
        [serverController release];
        
        HTTPDataResponse *responseFinal = [[[HTTPDataResponse alloc] initWithData:response] autorelease];
        
        //[responseFinal.httpHeaders setValue:@"application/json" forKey:@"Content-Type"];
        
		return responseFinal;
	}
    
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/GetObjects"] )
	{
		//NSLog(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
		NSLog(@"%@[%p]: GetObjects:postStr: %@", THIS_FILE, self, postStr);
		
        JSONDecoder *jkitDecoder = [JSONDecoder decoder];
        NSError *error = nil;
        NSDictionary *result = [jkitDecoder objectWithUTF8String:(const unsigned char *)[postStr UTF8String] length:[postStr length] error:&error];
        //NSLog(@"%@[%p]: GetObjects:decoding result: %@ with error:%@", THIS_FILE, self, result, [error localizedDescription]);
        
        NSString *authorizedUserEmail = [result valueForKey:@"authorizedUserEmail"];
        NSString *authorizedUserPassword = [result valueForKey:@"authorizedUserPassword"];
        NSString *objectGUID = [result valueForKey:@"objectGUID"];
        NSString *objectEntity = [result valueForKey:@"objectEntity"];
        NSNumber *isIncludeSubEntities = [result valueForKey:@"isIncludeSubEntities"];
        NSNumber *isIncludeAllObjects = [result valueForKey:@"isIncludeAllObjects"];
        //NSLog(@"Class:%@",[[result valueForKey:@"isIncludeAllSubentities"] class]);
        //        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        //        
        //        NSNumber *isIncludeAllSubentities = [formatter numberFromString:isIncludeAllSubentitiesString];
        //        NSNumber *isIncludeAllObjects = [formatter numberFromString:isIncludeAllObjectsString];
        //        [formatter release];
        
        
        ServerController *serverController = [[ServerController alloc] init];
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        serverController.moc = [delegate managedObjectContext]; 
        
        NSString *senderIP = [asyncSocket connectedHost];
        NSString *receiverIP = [asyncSocket localHost];
        //NSLog(@"GetObjects: senderIP:%@,receiverIP:%@",senderIP,receiverIP);
        NSString *answer = [serverController getObjectsForUserEmail:authorizedUserEmail 
                                                       withPassword:authorizedUserPassword 
                                                      forObjectGUID:objectGUID 
                                                    forObjectEntity:objectEntity 
                                          withIncludeAllSubentities:[isIncludeSubEntities boolValue] 
                                              withIncludeAllObjects:[isIncludeAllObjects boolValue]
                                                       withSenderIP:senderIP 
                                                     withReceiverIP:receiverIP];
        
        NSLog(@"%@[%p]: GetObjects:answer: %@ ", THIS_FILE, self, answer);
		NSData *response = [answer dataUsingEncoding:NSUTF8StringEncoding];
        //NSLog(@"data:%@",response);        
        HTTPDataResponse *responseFinal = [[[HTTPDataResponse alloc] initWithData:response] autorelease];
        
        //[responseFinal.httpHeaders setValue:@"application/json" forKey:@"Content-Type"];
        [serverController release];
		return responseFinal;
        
	}
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/GetObjectsList"] )
	{
		//NSLog(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
		//NSLog(@"%@[%p]: GetObjectsList:postStr: %@", THIS_FILE, self, postStr);
		
        JSONDecoder *jkitDecoder = [JSONDecoder decoder];
        NSError *error = nil;
        NSDictionary *result = [jkitDecoder objectWithUTF8String:(const unsigned char *)[postStr UTF8String] length:[postStr length] error:&error];
        //NSLog(@"%@[%p]: GetObjects:decoding result: %@ with error:%@", THIS_FILE, self, result, [error localizedDescription]);
        
        NSString *authorizedUserEmail = [result valueForKey:@"authorizedUserEmail"];
        NSString *authorizedUserPassword = [result valueForKey:@"authorizedUserPassword"];
        NSString *entityForList = [result valueForKey:@"entityForList"];
        NSString *mainObjectGUID = [result valueForKey:@"mainObjectGUID"];
        NSString *mainObjectEntity = [result valueForKey:@"mainObjectEntity"];
        NSString *dateFromString = [result valueForKey:@"dateFrom"];
        NSString *dateToString = [result valueForKey:@"dateTo"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSDate *dateFrom = [dateFormatter dateFromString:dateFromString];
        NSDate *dateTo = [dateFormatter dateFromString:dateToString];
        
        
        ServerController *serverController = [[ServerController alloc] init];
        NSString *senderIP = [asyncSocket connectedHost];
        NSString *receiverIP = [asyncSocket localHost];
        //NSLog(@"GetObjects: senderIP:%@,receiverIP:%@",senderIP,receiverIP);
        NSString *answer = [serverController getObjectsListForUserEmail:authorizedUserEmail 
                                                           withPassword:authorizedUserPassword 
                                                      withEntityForList:entityForList 
                                                     withMainObjectGUID:mainObjectGUID 
                                                   withMainObjectEntity:mainObjectEntity 
                                                           withDateFrom:dateFrom 
                                                             withDateTo:dateTo 
                                                           withSenderIP:senderIP 
                                                         withReceiverIP:receiverIP];        
        //NSLog(@"%@[%p]: GetObjectsList:answer: %@ ", THIS_FILE, self, answer);
		NSData *response = [answer dataUsingEncoding:NSUTF8StringEncoding];
        //NSLog(@"data:%@",response);        
        HTTPDataResponse *responseFinal = [[[HTTPDataResponse alloc] initWithData:response] autorelease];
        
        //[responseFinal.httpHeaders setValue:@"application/json" forKey:@"Content-Type"];
        [serverController release];
		return responseFinal;
        
	}
    
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/GetObjectsWithGUIDs"] )
	{
		//NSLog(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
		//NSLog(@"%@[%p]: GetObjectsWithGUIDs:postStr: %@", THIS_FILE, self, postStr);
		
        JSONDecoder *jkitDecoder = [JSONDecoder decoder];
        NSError *error = nil;
        NSDictionary *result = [jkitDecoder objectWithUTF8String:(const unsigned char *)[postStr UTF8String] length:[postStr length] error:&error];
        //NSLog(@"%@[%p]: GetObjects:decoding result: %@ with error:%@", THIS_FILE, self, result, [error localizedDescription]);
        
        NSString *authorizedUserEmail = [result valueForKey:@"authorizedUserEmail"];
        NSString *authorizedUserPassword = [result valueForKey:@"authorizedUserPassword"];
        NSString *entityForList = [result valueForKey:@"entity"];
        NSArray *guids = [result valueForKey:@"allGUIDs"];
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
        
        NSString *senderIP = [asyncSocket connectedHost];
        NSString *receiverIP = [asyncSocket localHost];
        //NSLog(@"GetObjects: senderIP:%@,receiverIP:%@",senderIP,receiverIP);
        NSString *answer = [serverController getObjectsWithGUIDsForUserEmail:authorizedUserEmail withPassword:authorizedUserPassword withEntity:entityForList withGUIDs:guids withSenderIP:senderIP withReceiverIP:receiverIP];        
        //NSLog(@"%@[%p]: GetObjectsWithGUIDs:answer: %@ ", THIS_FILE, self, answer);
		NSData *response = [answer dataUsingEncoding:NSUTF8StringEncoding];
        //NSLog(@"data:%@",response);        
        HTTPDataResponse *responseFinal = [[[HTTPDataResponse alloc] initWithData:response] autorelease];
        
        //[responseFinal.httpHeaders setValue:@"application/json" forKey:@"Content-Type"];
        [serverController release];
		return responseFinal;
        
	}
    
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/PutObject"] )
	{
        
		//NSLog(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
        //		NSData *messageData = [request messageData];
        //		NSDictionary *messageHeaders = [request allHeaderFields];
        //		BOOL isHeaderComplete = [request isHeaderComplete];
        
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
		NSLog(@"%@[%p]: PutObject:postStr: %@", THIS_FILE, self, postStr);
		
        JSONDecoder *jkitDecoder = [JSONDecoder decoder];
        NSDictionary *result = [jkitDecoder objectWithUTF8String:(const unsigned char *)[postStr UTF8String] length:[postStr length]];
        //NSLog(@"%@[%p]: PutObject:decoding result: %@", THIS_FILE, self, result);
        
        NSString *authorizedUserEmail = [result valueForKey:@"authorizedUserEmail"];
        NSString *authorizedUserPassword = [result valueForKey:@"authorizedUserPassword"];
        NSArray *necessaryData = [result valueForKey:@"necessaryData"];
        NSNumber *isMustBeApproved = [result valueForKey:@"isMustBeApproved"];
        
        
        
        ServerController *serverController = [[ServerController alloc] init];
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        serverController.moc = [delegate managedObjectContext]; 
        
        NSString *senderIP = [asyncSocket connectedHost];
        NSString *receiverIP = [asyncSocket localHost];
        //NSLog(@"PutObject: senderIP:%@,receiverIP:%@",senderIP,receiverIP);
        NSString *answer = [serverController putObjectForUserEmail:authorizedUserEmail 
                                                      withPassword:authorizedUserPassword 
                                                 withNecessaryData:necessaryData 
                                                    mustBeApproved:[isMustBeApproved boolValue] 
                                                      withSenderIP:senderIP 
                                                    withReceiverIP:receiverIP]; 
        
        NSLog(@"%@[%p]: PutObject:answer: %@ ", THIS_FILE, self, answer);
		NSData *response = [answer dataUsingEncoding:NSUTF8StringEncoding];
        [serverController release];
        
        HTTPDataResponse *responseFinal = [[[HTTPDataResponse alloc] initWithData:response] autorelease];
        
        //[responseFinal.httpHeaders setValue:@"application/json" forKey:@"Content-Type"];
        return responseFinal;
        
	}
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/RemoveObject"] )
	{
        
		//NSLog(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSString *postStr = nil;
		
		NSData *postData = [request body];
		if (postData)
		{
			postStr = [[[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding] autorelease];
		}
		NSLog(@"%@[%p]: RemoveObject:postStr: %@", THIS_FILE, self, postStr);
		
        JSONDecoder *jkitDecoder = [JSONDecoder decoder];
        NSDictionary *result = [jkitDecoder objectWithUTF8String:(const unsigned char *)[postStr UTF8String] length:[postStr length]];
        NSString *authorizedUserEmail = [result valueForKey:@"authorizedUserEmail"];
        NSString *authorizedUserPassword = [result valueForKey:@"authorizedUserPassword"];
        NSString *objectGUID = [result valueForKey:@"objectGUID"];
        NSString *objectEntity = [result valueForKey:@"objectEntity"];        
        
        ServerController *serverController = [[ServerController alloc] init];
//        AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
//        serverController.moc = [delegate managedObjectContext]; 
        
        NSString *senderIP = [asyncSocket connectedHost];
        NSString *receiverIP = [asyncSocket localHost];
        //NSLog(@"PutObject: senderIP:%@,receiverIP:%@",senderIP,receiverIP);
        NSString *answer = [serverController removeObjectWithGUID:objectGUID 
                                                  forObjectEntity:objectEntity 
                                                     forUserEmail:authorizedUserEmail 
                                                     withPassword:authorizedUserPassword 
                                                     withSenderIP:senderIP
                                                   withReceiverIP:receiverIP];
        
        NSLog(@"%@[%p]: RemoveObject:answer: %@ ", THIS_FILE, self, answer);
		NSData *response = [answer dataUsingEncoding:NSUTF8StringEncoding];
        [serverController release];
        
        HTTPDataResponse *responseFinal = [[[HTTPDataResponse alloc] initWithData:response] autorelease];
        
        //[responseFinal.httpHeaders setValue:@"application/json" forKey:@"Content-Type"];
        return responseFinal;
        
	}
    

	
	return [super httpResponseForMethod:method URI:path];
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
	
	// If we supported large uploads,
	// we might use this method to create/open files, allocate memory, etc.
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
	
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	BOOL result = [request appendData:postDataChunk];
	if (!result)
	{
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
}

- (BOOL)isPasswordProtected:(NSString *)path
{
	// We're only going to password protect the "secret" directory.
	
	BOOL result = [path hasPrefix:@"/"];
	
	HTTPLogTrace2(@"%@[%p]: isPasswordProtected(%@) - %@", THIS_FILE, self, path, (result ? @"YES" : @"NO"));
	
	return NO;
}
//
//- (BOOL)useDigestAccessAuthentication
//{
//	HTTPLogTrace();
//	
//	// Digest access authentication is the default setting.
//	// Notice in Safari that when you're prompted for your password,
//	// Safari tells you "Your login information will be sent securely."
//	// 
//	// If you return NO in this method, the HTTP server will use
//	// basic authentication. Try it and you'll see that Safari
//	// will tell you "Your password will be sent unencrypted",
//	// which is strongly discouraged.
//	
//	return YES;
//}
//
- (NSString *)passwordForUser:(NSString *)username
{
	HTTPLogTrace();
	
	// You can do all kinds of cool stuff here.
	// For simplicity, we're not going to check the username, only the password.
	if ([username isEqualToString:@"alex"]) return @"A87AE19C-FEBB-4C4C-A534-3CD036ED072A";
	else return [NSString stringWithFormat:@"%@",[NSNumber numberWithInt:arc4random() % 1000000000000000000]];
    
}
//
- (BOOL)isSecureServer
{
	HTTPLogTrace();
	
	// Create an HTTPS server (all connections will be secured via SSL/TLS)
	return YES;
}
//
- (NSArray *)sslIdentityAndCertificates
{
	HTTPLogTrace();
    
	NSArray *result = [DDKeychain SSLIdentityAndCertificates];
	if([result count] == 0)
	{
		[DDKeychain createNewIdentity];
		return [DDKeychain SSLIdentityAndCertificates];
	}
	return result;
}


@end
