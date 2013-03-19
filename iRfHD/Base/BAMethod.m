//
//  BAMethod.m
//  IMpc
//
//  Created by pro on 11-3-24.
//  Copyright 2011 gzmpc. All rights reserved.
//

#import "BAMethod.h"
#import "ASIHTTPRequest.h"


static NSString *BAMethod_SERVLET_URL = @"/bacreatorServlet";
static NSString *BAMethod_PARAMS_PRIFIX = @"ajaxParams_";
static NSString *BAMethod_VALUE_PRIFIX = @"ajaxParamsValue_";
//static NSString *BAMethod_MODULEID = @"moduleid";
//static NSString *BAMethod_METHODNAME = @"methodName";
//static NSString *BAMethod_CALLBACKRELY = @"callbackRely";

@implementation BAMethod

@synthesize className,moduleId,methodName;
@synthesize sessionCookie;

#pragma mark init 
-(id)initWithClassName:(NSString *)classname
{
    self = [super init];
    if (self) {
    //	IMpcAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    //	self.sessionCookie = [[NSMutableArray alloc]initWithObjects:delegate.iMpcCookie,nil];
        self.className = classname;
        _async = YES;
    }
	return self;
}
				 
#pragma mark invoke

-(void)invokeByAsync:(NSArray *)params target:(id) _target action:(SEL) _action
{
    target = _target;
    action = _action;
    [self invoke:params ];
}

-(id)invokeBySync:(NSArray *)params
{
    _async = NO;
    return [self invoke:params];
}


-(id)translateResult:(ASIHTTPRequest *)_request
{
    // Use when fetching text data
	NSString *responseString = [_request responseString];
	NSLog(@"%@ request return : %@",self.className,responseString);
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (result != nil) {
        NSDictionary *obj = (NSDictionary*)result;
        if ([obj objectForKey:@"error"]) {
            [CommonUtil alert:[obj objectForKey:@"error"] msg:[obj objectForKey:@"errorInfo"]];
        }
        else {
            id data = [obj objectForKey:@"data"];
            
            return data;
        }
        
    }
    else {
        [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:[NSString stringWithFormat:@"翻译json发生错误[%@]",[error localizedDescription]]];
    }
    
    return nil;
	// Use when fetching binary data
	//NSData *responseData = [request responseData];
}


#pragma mark -
#pragma mark ASIHTTPRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)_request
{
    id result = [self translateResult:_request];
    if(target != nil && [target respondsToSelector: action]) {
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:action withObject:result];
#       pragma clang diagnostic pop
    }
}

-(void)requestFailed:(ASIHTTPRequest *)_request
{
    NSError *error = [_request error];
    [CommonUtil alert:NSLocalizedString(@"Error", @"Error") msg:[NSString stringWithFormat:@"与后台联系[%@]发生错误[%@]",self.className,[error localizedDescription]]];
}

-(id)invoke:(NSArray *)params
{

	if (moduleId == nil) {
		@throw([NSException exceptionWithName:@"错误" reason:@"模块ID不能为空" userInfo:nil]);
	}
	if (methodName == nil) {
		@throw([NSException exceptionWithName:@"错误" reason:@"方法名不能为空" userInfo:nil]);
		
	}
	
    NSString *httpUrl = [NSString stringWithFormat:@"%@%@", [CommonUtil getLocalServerBase] , BAMethod_SERVLET_URL ];
    NSURL *url = [NSURL URLWithString:httpUrl];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
	[request setPostValue:className forKey:@"className"];
	[request setPostValue:moduleId forKey:@"moduleid"];
	[request setPostValue:methodName forKey:@"methodName"];
//	[request setPostValue:callbackRely forKey:@"callbackRely"];
	
	NSUInteger paramsLength = 0;
	if (params != nil && [params count]>0) {
		paramsLength = [params count];
		NSUInteger ei = 0;// 
		for ( NSUInteger i = 0; i < paramsLength; i++) {
			id paramstype = [params objectAtIndex:i];
			
			if ([paramstype isKindOfClass:[NSString class]]  ||[paramstype isKindOfClass:[NSMutableString class]]
				) {
				[request setPostValue:(NSString *)[params objectAtIndex:i] forKey:[NSString stringWithFormat:@"%@%d",BAMethod_VALUE_PRIFIX,ei]];
				[request setPostValue:[NSString stringWithFormat:@"String:%@%d",BAMethod_VALUE_PRIFIX,ei] 
							   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_PARAMS_PRIFIX,i]];
				ei++;
			} else if ([paramstype isKindOfClass:[NSArray class]] || [paramstype isKindOfClass:[NSMutableArray class]] ) {// 
				// Array 
				NSMutableArray *listparams = [params objectAtIndex:i];
				NSUInteger plength = [listparams count];
				id mapparamstype =  [listparams objectAtIndex:0];
				//String type=mapparamstype.getClass().getName();
				NSString *type = [[mapparamstype class]description];
				if (plength == 0)
					type = @"emptyArray";
				if ([mapparamstype isKindOfClass:[NSString class]] || [mapparamstype isKindOfClass:[NSMutableString class]]) {
					
					NSMutableString *paramStr = [[NSMutableString alloc]init];
					for ( NSUInteger m = 0; m < plength; m++) {
						[request setPostValue:(NSString *)[listparams objectAtIndex:m] 
									   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_VALUE_PRIFIX,ei]];
						
						[request setPostValue:[NSString stringWithFormat:@"String:%@%d",BAMethod_VALUE_PRIFIX,ei] 
									   forKey:[NSString stringWithFormat:@"%@%d_%d",BAMethod_PARAMS_PRIFIX,i,m]];
						
						//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_VALUE_PRIFIX+ei,listparams.get(m).toString()));
						//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i+"_"+m,BAMethod_VALUE_PRIFIX+ei));
						//paramStr.append(BAMethod_PARAMS_PRIFIX+i+"_"+m+",");
						[paramStr appendFormat:@"%@%d_%d,",BAMethod_PARAMS_PRIFIX,i,m];
						
						ei++;
					}
					[request setPostValue:[NSString stringWithFormat:@"StringArray:%@",paramStr] 
								   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_PARAMS_PRIFIX,i]];
					
					//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"StringArray:"+paramStr.toString()));
					// StringArray:param1,param2
					// £¨∆‰÷–param1{key:value}
				} else if ([mapparamstype isKindOfClass:[NSDictionary class]] 
						   || [mapparamstype isKindOfClass:[NSMutableDictionary class]] ) { // Map[] ObjectArray:
					// obj1,obj2
					// obj1:key,valuehtml;key2,value2html
					NSMutableString *paramStr = [[NSMutableString alloc]init];
					for ( NSUInteger m = 0; m < plength; m++) {
						NSDictionary *map = (NSDictionary *)[listparams objectAtIndex:m];//(Map) listparams.get(m);
						NSMutableString *mapParamstr = [[NSMutableString alloc]init];
						//Iterator it = map.keySet().iterator();
						NSArray *mapallkeys = [map allKeys];
						for(NSString *key in mapallkeys) {
							
							NSString *v = (NSString *)[map objectForKey:key]; 
							[request setPostValue:v 
										   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_VALUE_PRIFIX,ei]];
							//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_VALUE_PRIFIX+ei,v));
							[mapParamstr appendFormat:@"%@,%@%d;",key,BAMethod_VALUE_PRIFIX,ei];
							//mapParamstr.append(key).append(",").append(BAMethod_VALUE_PRIFIX+ei+";");
							ei++;
						}
						[request setPostValue:mapParamstr 
									   forKey:[NSString stringWithFormat:@"%@%d_%d",BAMethod_PARAMS_PRIFIX,i,m]];
						//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i+"_"+ m,mapParamstr.toString()));
						//paramStr.append(BAMethod_PARAMS_PRIFIX+i+"_"+ m+",");
						[paramStr appendFormat:@"%@%d_%d,",BAMethod_PARAMS_PRIFIX,i,m];
						
						
					}
					[request setPostValue:[NSString stringWithFormat:@"ObjectArray:%@",paramStr] 
								   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_PARAMS_PRIFIX,i]];
					//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"ObjectArray:"+paramStr.toString()));
					// StringArray:param1,param2
					// £¨∆‰÷–param1{key:value}
				} else if ([type isEqualToString:@"emptyArray"]) {
					[request setPostValue:@"emptyArray:" 
								   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_PARAMS_PRIFIX,i]];
					//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"emptyArray:"));
					// ø’∞◊µƒ ˝◊È
				} else {
					//throw new Exception("¿‡–Õ" + type + "‘› ±≤ª÷ß≥÷£¨«Î¡™œµπ‹¿Ì»À‘±");
					@throw([NSException exceptionWithName:@"错误,类型暂不支持" reason:type userInfo:nil]);
				}
			} else if( [paramstype isKindOfClass:[NSDictionary class]] || [paramstype isKindOfClass:[NSMutableDictionary class]]) {// Object
				NSMutableString *paramstr = [[NSMutableString alloc]init];
				NSDictionary *map = (NSDictionary *)paramstype;
				//Iterator it = map.keySet().iterator();
				NSArray *mapallkey = [map allKeys];
				for(NSString *key in mapallkey) {
					NSString *v = (NSString *)[map objectForKey:key];
					[request setPostValue:v 
								   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_VALUE_PRIFIX,ei]];
					//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_VALUE_PRIFIX+ei,v));
					//paramstr.append(key).append(",").append(BAMethod_VALUE_PRIFIX+ei+";");
					[paramstr appendFormat:@"%@,%@%d;",key,BAMethod_VALUE_PRIFIX,ei];
					ei++;
				}
				
				if ([paramstr length] == 0)
					//paramstr.append("null");// ÷˜“™ «”√”⁄◊™ªØSessionContext
					[paramstr appendString:@"null"];
				[request setPostValue:[NSString stringWithFormat:@"Object:%@",paramstr] 
							   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_PARAMS_PRIFIX,i]];
				//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"Object:"+paramstr.toString()));
				
				
			} else if ([paramstype isKindOfClass:[NSNumber class]]) {//BOOL的特殊类型
				if ([paramstype boolValue]) {
					[request setPostValue:@"true"
								   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_VALUE_PRIFIX,ei]];
				}else {
					[request setPostValue:@"false"
								   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_VALUE_PRIFIX,ei]];
				}

				//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_VALUE_PRIFIX+ei,paramstype.toString()));
				
				[request setPostValue:[NSString stringWithFormat:@"Boolean:%@%d",BAMethod_VALUE_PRIFIX,ei] 
							   forKey:[NSString stringWithFormat:@"%@%d",BAMethod_PARAMS_PRIFIX,i]];
				//ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"Boolean:"+BAMethod_VALUE_PRIFIX+ei));
				
				ei++;
			} else {
				//throw new Exception("¿‡–Õ" + paramstype.getClass().getName() + "‘› ±≤ª÷ß≥÷£¨«Î¡™œµπ‹¿Ì»À‘±");
				@throw([NSException exceptionWithName:@"错误,类型暂不支持" reason:[[paramstype class] description] userInfo:nil]);
			}
		}
	}
	[request setPostValue:[NSString stringWithFormat:@"%d",paramsLength] 
				   forKey:@"paramsLength"];
	//ajaxHttpParams.add(new BasicNameValuePair("paramsLength",String.valueOf(paramsLength)));
	
	//
	 [request setTimeOutSeconds:120];
	 
//	 IMpcAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	 
	 [request setUseCookiePersistence:NO];
	 [request setRequestCookies:[NSMutableArray arrayWithObject:[CommonUtil getSession]]];
	 
	 
	 [request setUserInfo:nil];
//   [request setDidFinishSelector:@selector(requestFinished:)];
//	 [request setDidFailSelector:@selector(requestFailed:)];
	 
    if (_async) {
        [request setDelegate:self];
        [request startAsynchronous];
    }
	else {
        [request startSynchronous];
        
        if ([request error]) {
            [self requestFailed:request];
        }
        else {
            return [self translateResult:request];
        }
    }
    return nil;
}


+(BAMethod *) baWithClassName:(NSString*)_className moduleId:(NSString*)_moduleid methodName:(NSString*)_methodName
{
    BAMethod *ba = [[BAMethod alloc]initWithClassName:_className];
    ba.moduleId = _moduleid;
    ba.methodName = _methodName;
    return ba;
}


@end


/*
 public class BAMethod {
 private String base;//¬∑æ∂
 final String BAMethod_SERVLET_URL = "/bacreatorServlet";
 final String BAMethod_PARAMS_PRIFIX = "ajaxParams_";
 final String BAMethod_VALUE_PRIFIX = "ajaxParamsValue_";
 
 private String className;
 private String sessionId;
 
 public BAMethod(String classname,String sessionid,String base){
 this.className = classname;
 this.sessionId = sessionid;
 this.base = base;
 }
 
 **
 * µ˜”√∑Ω∑®
 * @throws Exception 
 * 
 * */
/*
public java.lang.Object invoke(Map properties) throws Exception{
	
	String moduleid = (String) properties.get("moduleid");
	String methodName = (String) properties.get("methodName");
	String callbackRely = (String) properties.get("callbackRely");
	if (moduleid == null || "".equals(moduleid)) {
		throw new Exception("ƒ£øÈID≤ª‘ –ÌŒ™ø’");
		
	}
	if (methodName == null || "".equals(methodName)) {
		throw new Exception("∏√≤Ÿ◊˜∂‘”¶µƒ∑Ω∑®√˚≤ªƒ‹Œ™ø’");
		
	}
	List<NameValuePair> ajaxHttpParams = new ArrayList<NameValuePair>();  
	ajaxHttpParams.add(new BasicNameValuePair("className",this.className));
	ajaxHttpParams.add(new BasicNameValuePair("moduleid",moduleid));
	ajaxHttpParams.add(new BasicNameValuePair("methodName",methodName));
	ajaxHttpParams.add(new BasicNameValuePair("callbackRely",callbackRely));   
	
	
	ArrayList params = (ArrayList) properties.get("params");// –Ë“™≈–∂œÀ¸¥Ê≤ª¥Ê‘⁄
	int paramsLength = 0;
	if (params != null && params.size()>0) {
		paramsLength = params.size();
		int ei = 0;// √ø∏ˆ≤Œ ˝Ãıº˛µƒ÷µ
		for ( int i = 0; i < paramsLength; i++) {
			Object paramstype = params.get(i);				
			if (paramstype instanceof String || paramstype instanceof Long 
				|| paramstype instanceof Integer || paramstype instanceof Double
				|| paramstype instanceof Float
				) {
				ajaxHttpParams.add(new BasicNameValuePair(BAMethod_VALUE_PRIFIX+ei,params.get(i).toString()));
				ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"String:"+BAMethod_VALUE_PRIFIX+ei));
				
				ei++;
			} else if (paramstype instanceof List || paramstype instanceof ArrayList) {// ∑÷ø™ «“ª∏ˆ∂‘œÛªπ «“ª∏ˆ ˝◊È∂‘œÛ.»Áπ˚ «“ª∏ˆ∂‘œÛ£¨æÕ“‘“ª∏ˆObjectø™Õ∑£¨»Áπ˚ «“ª∏ˆ ˝◊È£¨æÕ“‘Arrayø™Õ∑
				// Array ÷ª÷ß≥÷◊÷∑˚ ˝◊È∫Õ∂‘œÛ ˝◊È
				List listparams =  (List) params.get(i);
				int plength = listparams.size();
				Object mapparamstype =  listparams.get(0);
				String type=mapparamstype.getClass().getName();
				if (plength == 0)// »Áπ˚ «ø’µƒ ˝◊È,≥§∂»Œ™0
					type = "emptyArray";
				if (mapparamstype instanceof String || mapparamstype instanceof Long 
					|| mapparamstype instanceof Integer || mapparamstype instanceof Double
					|| mapparamstype instanceof Float) {
					
					StringBuffer paramStr = new StringBuffer();
					for ( int m = 0; m < plength; m++) {
						ajaxHttpParams.add(new BasicNameValuePair(BAMethod_VALUE_PRIFIX+ei,listparams.get(m).toString()));
						ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i+"_"+m,BAMethod_VALUE_PRIFIX+ei));
						paramStr.append(BAMethod_PARAMS_PRIFIX+i+"_"+m+",");
						
						ei++;
					}
					ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"StringArray:"+paramStr.toString()));
					// StringArray:param1,param2
					// £¨∆‰÷–param1{key:value}
				} else if (mapparamstype instanceof Map) { // Map[] ObjectArray:
					// obj1,obj2
					// obj1:key,valuehtml;key2,value2html
					StringBuffer paramStr = new StringBuffer();
					for ( int m = 0; m < plength; m++) {
						Map map = (Map) listparams.get(m);
						StringBuffer mapParamstr = new StringBuffer();
						Iterator it = map.keySet().iterator();
						while (it.hasNext()) {
							String key = (String) it.next();
							String v = (String) map.get(key);
							ajaxHttpParams.add(new BasicNameValuePair(BAMethod_VALUE_PRIFIX+ei,v));
							mapParamstr.append(key).append(",").append(BAMethod_VALUE_PRIFIX+ei+";");
							ei++;
						}
						ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i+"_"+ m,mapParamstr.toString()));
						paramStr.append(BAMethod_PARAMS_PRIFIX+i+"_"+ m+",");
						
						
					}
					ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"ObjectArray:"+paramStr.toString()));
					// StringArray:param1,param2
					// £¨∆‰÷–param1{key:value}
				} else if (type.equals("emptyArray")) {
					ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"emptyArray:"));
					// ø’∞◊µƒ ˝◊È
				} else {
					throw new Exception("¿‡–Õ" + type + "‘› ±≤ª÷ß≥÷£¨«Î¡™œµπ‹¿Ì»À‘±");
				}
			} else if( paramstype instanceof Map) {// Object
				StringBuffer paramstr = new StringBuffer();
				Map map = (Map)paramstype;
				Iterator it = map.keySet().iterator();
				while (it.hasNext()) {
					String key = (String) it.next();
					String v = (String) map.get(key);
					ajaxHttpParams.add(new BasicNameValuePair(BAMethod_VALUE_PRIFIX+ei,v));
					paramstr.append(key).append(",").append(BAMethod_VALUE_PRIFIX+ei+";");
					ei++;
				}
				
				if (paramstr.length() == 0)
					paramstr.append("null");// ÷˜“™ «”√”⁄◊™ªØSessionContext
				ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"Object:"+paramstr.toString()));
				
				
				
			} else if (paramstype instanceof Boolean) {
				ajaxHttpParams.add(new BasicNameValuePair(BAMethod_VALUE_PRIFIX+ei,paramstype.toString()));
				ajaxHttpParams.add(new BasicNameValuePair(BAMethod_PARAMS_PRIFIX+i,"Boolean:"+BAMethod_VALUE_PRIFIX+ei));
				
				ei++;
			} else {
				throw new Exception("¿‡–Õ" + paramstype.getClass().getName() + "‘› ±≤ª÷ß≥÷£¨«Î¡™œµπ‹¿Ì»À‘±");
			}
		}
	}
	ajaxHttpParams.add(new BasicNameValuePair("paramsLength",String.valueOf(paramsLength)));
	
	//ø™ ºµ˜”√
	String httpUrl = base + BAMethod_SERVLET_URL;  
	HttpPost request = new HttpPost(httpUrl);  
	request.setHeader("Cookie", login.sessionid);
	JSONObject obj = null;  
	try {  
		HttpEntity entity = new UrlEncodedFormEntity(ajaxHttpParams, "UTF-8");  
		request.setEntity(entity);  
		HttpClient client = new DefaultHttpClient();
		
		HttpResponse response = client.execute(request);  
		if(response.getStatusLine().getStatusCode()==HttpStatus.SC_OK){  
			String str = EntityUtils.toString(response.getEntity());  
			obj = new JSONObject(str);
		}else{  
			obj.put("data", "«Î«Û¥ÌŒÛ");  
		}  
	} catch (UnsupportedEncodingException e) {  
		// TODO Auto-generated catch block  
		e.printStackTrace();  
	} catch (ClientProtocolException e) {  
		// TODO Auto-generated catch block  
		e.printStackTrace();  
	} catch (IOException e) {  
		// TODO Auto-generated catch block  
		e.printStackTrace();  
	} 		
	return obj;
}

}

*/