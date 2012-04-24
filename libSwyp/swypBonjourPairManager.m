//
//  swypBonjourPairManager.m
//  swyp
//
//  Created by Alexander List on 1/14/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "swypBonjourPairManager.h"

@implementation swypBonjourPairManager

#pragma mark bonjourAdvertiser
-(void)	bonjourServiceAdvertiserReceivedConnectionFromSwypClientCandidate:(swypClientCandidate*)clientCandidate withStreamIn:(NSInputStream*)inputStream streamOut:(NSOutputStream*)outputStream serviceAdvertiser: (swypBonjourServiceAdvertiser*)advertiser{
	
	if ([_validSwypOutsForConnectionReceipt count] == 0)
		return;
	swypClientCandidate * candidate =	[[swypClientCandidate alloc] init];
	// if xmpp 	[candidate setNametag:[peerInfo valueForKey:@"smppPeer"]];
	
	swypInfoRef *swypRef			= 	[_validSwypOutsForConnectionReceipt anyObject];
	
	if (swypRef != nil){
		[candidate setMatchedLocalSwypInfo:swypRef];
	}
	
	swypConnectionSession * pendingClient	=	[[swypConnectionSession alloc] initWithSwypCandidate:candidate inputStream:inputStream outputStream:outputStream];
	
	[_delegate interfaceManager:self receivedUninitializedSwypClientCandidateConnectionSession:pendingClient withConnectionMethod:swypConnectionMethodWifiLoc];
	
	SRELS(candidate);

}

-(void)	bonjourServiceAdvertiserFailedAdvertisingWithError:(NSError*) error serviceAdvertiser: (swypBonjourServiceAdvertiser*)advertiser{
	
}

-(void)_advertiseTimedOutWithTimer:(NSTimer*)timer{
	
	[self stopAdvertisingSwypOut:timer.userInfo];
	
}


#pragma mark swypInterfaceManager
-(void)	suspendNetworkActivity{
	[_serviceAdvertiser suspendNetworkActivity];
}

/** Allow network activity to resume on this interface. Ususally app is going foreground, or workspace is opening for first time.
 
 Don't restart stuff that was paused.*/
-(void)	resumeNetworkActivity{
	[_serviceAdvertiser resumeNetworkActivity];
}

///@name swypOut
/** Begin advertising a specifc swypOut. Don't accept any connections from it yet as it hasn't completed successfully.
 
 Set a timeout for advertisement; let swypInterfaceManagerDelegate know when expired. */
-(void) advertiseSwypOutAsPending:(swypInfoRef*)ref{

}

/** Continue advertising specifc swypOut, perhaps updating with finalized swyp-info where necessary. Accept connections.
 
 Set a timeout for advertisement; let swypInterfaceManagerDelegate know when expired. */
-(void) advertiseSwypOutAsCompleted:(swypInfoRef*)ref{
	[_serviceAdvertiser setAdvertising:TRUE];
	[_validSwypOutsForConnectionReceipt addObject:ref];
	
	NSTimer * advertiseTimer	=	[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_advertiseTimedOutWithTimer:) userInfo:ref repeats:NO];
	[_swypOutTimeoutTimerBySwypInfoRef setObject:advertiseTimer forKey:[NSValue valueWithNonretainedObject:ref]];	
	[_validSwypOutsForConnectionReceipt addObject:ref];
}


/** No longer advertise a swyp out; remove from reference queue. No longer accept a connection for it (if an interface is able to tell this). 
 
 Do not send further delegate messages with this ref. Perhaps the swyp failed.
 */
-(void) stopAdvertisingSwypOut:(swypInfoRef*)ref{
	if ([_validSwypOutsForConnectionReceipt containsObject:ref] == NO)
		return;
	
	
	NSTimer * advertiseTimer	=	[_swypOutTimeoutTimerBySwypInfoRef objectForKey:[NSValue valueWithNonretainedObject:ref]];
	
	[advertiseTimer invalidate];
	
	[_swypOutTimeoutTimerBySwypInfoRef removeObjectForKey:[NSValue valueWithNonretainedObject:ref]];	
	[_validSwypOutsForConnectionReceipt removeObject:ref];
	
	[_delegate interfaceManager:self isDoneAdvertisingSwypOutAsPending:ref forConnectionMethod:swypConnectionMethodBluetooth];

	if ([_validSwypOutsForConnectionReceipt count] == 0){
		[_serviceAdvertiser setAdvertising:FALSE];
	}
}

/** Tells whether actually being advertised */
-(BOOL) isAdvertisingSwypOut:(swypInfoRef*)ref{
	return [_validSwypOutsForConnectionReceipt containsObject:ref];
}

/** Standardized init function for interfaces */
-(id) initWithInterfaceManagerDelegate:(id<swypInterfaceManagerDelegate>)delegate{
	if (self = [super init]){
		_serviceAdvertiser = [[swypBonjourServiceAdvertiser alloc] init];
		[_serviceAdvertiser setDelegate:self];
		//_serviceListener = [[swypBonjourServiceListener alloc] init];
		_delegate = delegate;
		
		_validSwypOutsForConnectionReceipt = [[NSMutableSet alloc] init];
		_swypOutTimeoutTimerBySwypInfoRef = [[NSMutableDictionary alloc] init];
	}
	return self;
}


/** Start looking for and resolving for any networked candidates. Candidates are returned to swypInterfaceManagerDelegate.
 
 Set a timeout for search; let swypInterfaceManagerDelegate know when expired.
 */
-(void)	startFindingSwypInServerCandidatesForRef:(swypInfoRef*)ref{
	
}

/** No longer search for additional swypIn servers for this ref; remove from reference queue. 
 
 Do not send further delegate messages with this ref after notifying of the stoppage. */
-(void) stopFindingSwypInServerCandidatesForRef:(swypInfoRef*)ref{
	
}

#pragma mark bonjour
-(void) dealloc{

	[super dealloc];
}

//#pragma mark resolution and connection
//-(void)	_startResolvingConnectionToServerCandidate:	(swypServerCandidate*)serverCandidate{
//	NSNetService * resolveService	=	[serverCandidate netService]; 
//	
//	if ([_resolvingServerCandidates objectForKey:[NSValue valueWithNonretainedObject:resolveService]] != nil){
//		return;
//	}
//	
//	EXOLog(@"Began resolving server candidate: %@", [[serverCandidate netService] name]);
//	[resolveService				setDelegate:self];
//	[resolveService				resolveWithTimeout:3];
//	[_resolvingServerCandidates setObject:serverCandidate forKey:[NSValue valueWithNonretainedObject:resolveService]];
//}
//
//-(void)	_startConnectionToServerCandidate:			(swypServerCandidate*)serverCandidate{
//	NSNetService *		connectService	=	[serverCandidate netService];
//	
//	NSInputStream *		inputStream		=	nil;
//	NSOutputStream *	outputSteam		=	nil;
//	
//	//neither are open
//	BOOL success	=	[connectService getInputStream:&inputStream outputStream:&outputSteam];
//	if (success && inputStream != nil && outputSteam != nil){
//		[self _initializeConnectionSessionObjectForCandidate:serverCandidate streamIn:inputStream streamOut:outputSteam];
//	}else {
//		[_delegate	connectionSessionCreationFailedForCandidate:serverCandidate withHandshakeManager:self error:[NSError errorWithDomain:swypHandshakeManagerErrorDomain code:swypHandshakeManagerSocketSetupError userInfo:nil]];
//	}
//	
//}
//#pragma mark NSNetServiceDelegate
//- (void)netServiceDidResolveAddress:(NSNetService *)sender{
//	swypServerCandidate	*	candidate	=	[_resolvingServerCandidates objectForKey:[NSValue valueWithNonretainedObject:sender]];
//	
//	
//	EXOLog(@"Resolved candidate: %@", [sender name]);
//	
//	if (candidate != nil){
//		[self _startConnectionToServerCandidate:candidate];
//		[sender setDelegate:nil];
//		[_resolvingServerCandidates removeObjectForKey:[NSValue valueWithNonretainedObject:sender]];
//	}
//}
//- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict{
//	swypServerCandidate	*	candidate	=	[_resolvingServerCandidates objectForKey:[NSValue valueWithNonretainedObject:sender]];
//	
//	EXOLog(@"Did not resolve candidate: %@", [sender name]);
//	if (candidate != nil){
//		[_delegate	connectionSessionCreationFailedForCandidate:candidate withHandshakeManager:self error:[NSError errorWithDomain:[errorDict valueForKey:NSNetServicesErrorDomain] code:[[errorDict valueForKey:NSNetServicesErrorCode] intValue] userInfo:nil]];
//		[sender setDelegate:nil];
//		[sender stop];
//		[_resolvingServerCandidates removeObjectForKey:[NSValue valueWithNonretainedObject:sender]];
//	}
//}


@end
