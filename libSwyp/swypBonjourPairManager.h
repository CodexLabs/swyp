//
//  swypBonjourPairManager.h
//  swyp
//
//  Created by Alexander List on 1/14/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "swypBonjourServiceAdvertiser.h"
#import "swypBonjourServiceListener.h"

/**
 This class manages the resolution of bonjour candidates to pass them off to the swypConnectionManager as swypConnectionSessions. 
 */
@interface swypBonjourPairManager : NSObject <swypInterfaceManager, swypBonjourServiceAdvertiserDelegate>{
	swypBonjourServiceAdvertiser *		_serviceAdvertiser;
	swypBonjourServiceListener *		_serviceListener;
	
	NSMutableDictionary *				_swypOutTimeoutTimerBySwypInfoRef;
	NSMutableSet		*				_validSwypOutsForConnectionReceipt;
	
	id<swypInterfaceManagerDelegate>	_delegate;
}
@end
