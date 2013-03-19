/*
	iRfServices.m
	Creates a list of the services available with the iRf prefix.
	Generated by SudzC.com
*/
#import "iRfServices.h"

@implementation iRfServices

@synthesize logging, server, defaultServer;

@synthesize rgService;


#pragma mark Initialization

-(id)initWithServer:(NSString*)serverName{
	if(self = [self init]) {
		self.server = serverName;
	}
	return self;
}

+(iRfServices*)service{
	return (iRfServices*)[[[iRfServices alloc] init] autorelease];
}

+(iRfServices*)serviceWithServer:(NSString*)serverName{
	return (iRfServices*)[[[iRfServices alloc] initWithServer:serverName] autorelease];
}

#pragma mark Methods

-(void)setLogging:(BOOL)value{
	logging = value;
	[self updateServices];
}

-(void)setServer:(NSString*)value{
	[server release];
	server = [value retain];
	[self updateServices];
}

-(void)updateServices{

	[self updateService: self.rgService];
}

-(void)updateService:(SoapService*)service{
	service.logging = self.logging;
	if(self.server == nil || self.server.length < 1) { return; }
	service.serviceUrl = [service.serviceUrl stringByReplacingOccurrencesOfString:defaultServer withString:self.server];
}

#pragma mark Getter Overrides


-(iRfRgService*)rgService{
	if(rgService == nil) {
		rgService = [[iRfRgService alloc] init];
	}
	return rgService;
}


@end
			