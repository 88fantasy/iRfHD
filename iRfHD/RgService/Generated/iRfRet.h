/*
	iRfRet.h
	The interface definition of properties and methods for the iRfRet object.
	Generated by SudzC.com
*/

#import "Soap.h"
	

@interface iRfRet : SoapObject
{
	NSString* _msg;
	BOOL _ret;
	
}
		
	@property (strong, nonatomic) NSString* msg;
	@property BOOL ret;

	+ (iRfRet*) createWithNode: (CXMLNode*) node;
	- (id) initWithNode: (CXMLNode*) node;
	- (NSMutableString*) serialize;
	- (NSMutableString*) serialize: (NSString*) nodeName;
	- (NSMutableString*) serializeAttributes;
	- (NSMutableString*) serializeElements;

@end