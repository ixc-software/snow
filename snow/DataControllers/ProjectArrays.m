//
//  ProjectArrays.m
//  snow
//
//  Created by Alex Vinogradov on 20.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "ProjectArrays.h"
#import "SynthesizeSingleton.h"

@implementation ProjectArrays

SYNTHESIZE_SINGLETON_FOR_CLASS(ProjectArrays)

@synthesize myCountrySpecificCodeList, countrySpecificCodeList,queryProgress,myCountrySpecificCodeListWithClass,dictionaryForCountryCodesResult,dictionaryDictionaryesForCountryCodes,databaseConnections;

- (id) init
{
    self = [super init];
    if (self != nil) {
        @synchronized(self)
        {
            myCountrySpecificCodeList = [[NSMutableArray alloc] init];
            myCountrySpecificCodeListWithClass = [[NSMutableArray alloc] init];
            //NSMutableDictionary *emptyDict = [NSMutableDictionary dictionary];
            //[emptyDict setValue:@"" forKey:@"quene"];

            //self.queryProgress = [[NSMutableArray alloc] initWithObjects:emptyDict, nil];
            queryProgress = [[NSMutableArray alloc] init];
            dictionaryForCountryCodesResult = [[NSDictionary alloc] init];
            
            databaseConnections = [[NSMutableArray alloc] init];
            dictionaryDictionaryesForCountryCodes = [[NSMutableDictionary alloc] init];

        }
    }
    return self;
}

- (void)dealloc {
    // Clean-up code here.
    [myCountrySpecificCodeListWithClass release];
    [dictionaryForCountryCodesResult release];
    [databaseConnections release];
    [dictionaryDictionaryesForCountryCodes release];
    [myCountrySpecificCodeList release];
    [queryProgress release];
    [super dealloc];
}

@end
