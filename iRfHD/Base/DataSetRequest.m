//
//  DataSetRequest.m
//  IMpc
//
//  Created by pro on 11-3-24.
//  Copyright 2011 gzmpc. All rights reserved.
//  CLQ

#import "DataSetRequest.h"


@implementation DataSetRequest

@synthesize gridcode ;
@synthesize queryType ;
@synthesize dataSource ;
@synthesize querymoduleid ;
@synthesize sumfieldnames ;    
@synthesize orderfields;
@synthesize conditions ;
@synthesize pagerownum;
@synthesize startidx;

@synthesize sessionId;
@synthesize base;
@synthesize  SERVLET_URL;
@synthesize  ACTION_INIT;
@synthesize  ACTION_QUERY;
@synthesize  ACTION_DOWNLOAD;

@synthesize delegate;

-(id)initWithGridcode:(NSString *)_gridcode querytype:(NSString *)_queryType
			  datasource:(NSString *)_dataSource querymoduleid:(NSString *)_querymoduleid sumfieldnames:(NSString *)_sumfieldnames
{
	self.gridcode = _gridcode;
	self.queryType = _queryType;
	self.dataSource = _dataSource;
	self.querymoduleid = _querymoduleid;
	self.sumfieldnames = _sumfieldnames;
	self.conditions = [[NSMutableArray alloc]init];
	
	self.ACTION_QUERY = @"query";
	self.SERVLET_URL = @"/extjsgridQueryServlet/";
	self.ACTION_DOWNLOAD = @"/downloadservlet";
	self.base = [CommonUtil getLocalServerBase];
	return self;
}


-(NSString *)download:(NSString *)moduleid visibleCol:(NSString *)visibleCol theDelegate:(UIViewController *)downdelegate
{
	NSString *url = [[NSString alloc]initWithFormat:@"%@%@?", self.base , ACTION_DOWNLOAD];
	url = [url stringByAppendingFormat:@"gridcode=%@&",self.gridcode];
	url = [url stringByAppendingFormat:@"queryType=%@&",self.queryType];
	url = [url stringByAppendingFormat:@"dataSource=%@&",self.dataSource];
	url = [url stringByAppendingFormat:@"orderfields=%@&",self.orderfields];
	url = [url stringByAppendingFormat:@"downloadmoduleid=%@&",moduleid];
	url = [url stringByAppendingFormat:@"querymoduleid=%@&",self.querymoduleid];
	url = [url stringByAppendingFormat:@"visibleFields=%@&",visibleCol];
	url = [url stringByAppendingFormat:@"pageRowNum=%d&",10000];
	
	NSMutableArray *d = [self defaultCondition];
	[self.conditions addObjectsFromArray:d];
	NSMutableArray *allc = [[NSMutableArray alloc]initWithArray:self.conditions];
	NSUInteger length = [allc count];
	
	url = [url stringByAppendingFormat:@"oper_length=%d&",length];
	
	NSUInteger i;
	for(i=0;i<length;i++)
	{
		if([allc objectAtIndex:i]==nil)
			continue;
		NSDictionary *nd = [allc objectAtIndex:i];
		
		url = [url stringByAppendingFormat:@"fieldName_%d=%@&",i,
			   [[nd objectForKey:@"fieldName"]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding ]];
		url = [url stringByAppendingFormat:@"opera_%d=%@&",i,
			   [[nd objectForKey:@"opera"]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding ]];
		url = [url stringByAppendingFormat:@"value1_%d=%@&",i,
			   [[nd objectForKey:@"value1"]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding ]];
		if([nd objectForKey:@"value2"]!= nil){
		url = [url stringByAppendingFormat:@"value2_%d=%@&",i,
			   [[nd objectForKey:@"value2"]stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding ]];
		}

		
		
	}
	
	
	NSURL *httpUrl = [NSURL URLWithString:url];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	//[dateFormatter setDateFormat:@"hh:mm:ss"]
	[dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
	NSLog(@"Date%@", [dateFormatter stringFromDate:[NSDate date]]);
	
	NSString *filepath  = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:
			  [[NSString alloc]initWithFormat:@"%@.xls",
			   [dateFormatter stringFromDate:[NSDate date]]]
			  ];
	
//	IMpcAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:httpUrl];
	[request setDownloadDestinationPath:filepath];
	[request setDelegate:self];
	[request setUseCookiePersistence:NO];
//	[request setRequestCookies:[NSMutableArray arrayWithObject:delegate.iMpcCookie]];
	[request setDidFinishSelector:@selector(downloadFinished:)];
	if (progress == nil) {
		progress = [[UIProgressView alloc]initWithFrame:CGRectMake(60, 120, 200, 10)];
	}
	
	[downdelegate.view addSubview:progress];
	[request setDownloadProgressDelegate:progress];
	[request startAsynchronous];

	return nil;
	
}

/*
 
 public String download(String moduleid,String visibleCol){
 String url = ConstSet.base + ACTION_DOWNLOAD + "?";
 url += "gridcode=" + this.gridcode + "&";
 url += "queryType=" + this.queryType + "&";
 url += "dataSource=" + this.dataSource + "&";
 url += "orderfields=" + this.orderfields + "&";
 url += "stagetype="+ this.stagetype + "&";//clq
 url += "stageid="+this.stageid + "&";
 url += "downloadmoduleid=" + moduleid + "&";
 url += "querymoduleid=" + this.querymoduleid + "&";
 url += "visibleFields=" + visibleCol + "&";
 url += "pageRowNum=" + 10000 + "&";
 ArrayList d = this.defaultCondition();
 this.conditions.addAll(d);
 ArrayList allc = this.conditions;
 int length = allc.size();
 url += "oper_length=" + length + "&";
 for (int i = 0; i < length; i++){
 if(allc.get(i) == null)
 continue;
 url += "fieldName_" + i + "=" + URLEncoder.encode(((HashMap)allc.get(i)).get("fieldName").toString()) + "&";
 url += "opera_" + i + "=" + URLEncoder.encode(((HashMap)allc.get(i)).get("opera").toString()) + "&";
 url += "value1_" + i + "=" + URLEncoder.encode(((HashMap)allc.get(i)).get("value1").toString()) + "&";
 if(((HashMap)allc.get(i)).get("value2") != null)
 url += "value2_" + i + "=" + URLEncoder.encode(((HashMap)allc.get(i)).get("value2").toString()) + "&";
 }     
 
 return url;
 //ø™ ºµ˜”√
 
 //	        HttpGet request = new HttpGet(url);
 //	       
 //	        try {  
 //	             
 //	            HttpClient client = new DefaultHttpClient();
 //	            
 //	            HttpResponse response = client.execute(request);  
 //	            if(response.getStatusLine().getStatusCode()==HttpStatus.SC_OK){ 
 //	            	HttpEntity entity = response.getEntity(); 
 //	            	InputStream inputStream = entity.getContent();  
 //	            	final Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
 //	            	java.io.File f = new java.io.File("");
 //	            	
 //	            }else{  
 //	            	
 //	            }  
 //	        } catch (UnsupportedEncodingException e) {  
 //	            // TODO Auto-generated catch block  
 //	            e.printStackTrace();  
 //	        } catch (ClientProtocolException e) {  
 //	            // TODO Auto-generated catch block  
 //	            e.printStackTrace();  
 //	        } catch (IOException e) {  
 //	            // TODO Auto-generated catch block  
 //	            e.printStackTrace();  
 //	        }
 
 
 }
 
 */

//getdata
-(void)requestDataWithPage:(int)page pageNum:(unsigned)pageNum needpagecount:(BOOL)needpagecount
{
	//List<NameValuePair> params = new ArrayList<NameValuePair>();  

	
	NSString *httpUrl = [[NSString alloc]initWithFormat:@"%@%@%@", self.base , SERVLET_URL , ACTION_QUERY];
	NSURL *url = [NSURL URLWithString:httpUrl];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	
	[request setPostValue:[NSString stringWithFormat:@"%d",(page-1)*pageNum] forKey:@"startIndex"];
	[request setPostValue:[NSString stringWithFormat:@"%d",pageNum] forKey:@"pageRowNum"];
    if (needpagecount) {
        [request setPostValue:@"true" forKey:@"needpagecount"];
    }
	[request setPostValue:self.gridcode forKey:@"gridcode"];
	[request setPostValue:self.queryType forKey:@"queryType"];
	[request setPostValue:self.dataSource forKey:@"dataSource"];
	[request setPostValue:self.querymoduleid forKey:@"querymoduleid"];
	[request setPostValue:self.sumfieldnames forKey:@"sumfieldnames"];
	
	if(self.orderfields != nil){
		[request setPostValue:self.orderfields forKey:@"orderfields"];
	}
	
	NSMutableArray *d = [self defaultCondition];
	[self.conditions addObjectsFromArray:d];
	NSMutableArray *allc = [[NSMutableArray alloc]initWithArray:self.conditions];
	NSUInteger length = [allc count];
	NSUInteger i;
	for(i=0;i<length;i++)
	{
		if([allc objectAtIndex:i]==nil)
			continue;
		NSDictionary *nd = [allc objectAtIndex:i];

		[request setPostValue:[nd objectForKey:@"fieldName"] forKey:[NSString stringWithFormat:@"fieldName_%d",i]];
		[request setPostValue:[nd objectForKey:@"opera"] forKey:[NSString stringWithFormat:@"opera_%d",i]];
		[request setPostValue:[nd objectForKey:@"value1"] forKey:[NSString stringWithFormat:@"value1_%d",i]];
		
		if([nd objectForKey:@"value2"]!= nil){
			[request setPostValue:[nd objectForKey:@"value2"] forKey:[NSString stringWithFormat:@"value2_%d",i]];
		}
		
	}
	
	[request setPostValue:[NSString stringWithFormat:@"%d" ,length] forKey:@"oper_length"];
	
	//[request setPersistentConnectionTimeoutSeconds:120];
	[request setTimeOutSeconds:120];

	[request setUseCookiePersistence:NO];
	[request setRequestCookies:[NSMutableArray arrayWithObject:[CommonUtil getSession]]];
	
	[request setDelegate:self];
	[request setUserInfo:nil];
	[request startAsynchronous];
	
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
	// Use when fetching text data
	NSString *responseString = [request responseString];
    NSError *error = nil;
	NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    if (error) {
        if (delegate && [delegate respondsToSelector:@selector(dataReadDidFail:)]) {
            [delegate performSelector:@selector(dataReadDidFail:) withObject:error];
        }
    }
    else {
        if (delegate && [delegate respondsToSelector:@selector(didQueryData:)]) {
            [delegate performSelector:@selector(didQueryData:) withObject:result];
        }
        NSArray *rows = [result objectForKey:@"rows"];
        if (delegate && [delegate respondsToSelector:@selector(dataDidRead:)]) {
            [delegate performSelector:@selector(dataDidRead:) withObject:rows];
        }
    }
    
	// Use when fetching binary data
	//NSData *responseData = [request responseData];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
    if (delegate && [delegate respondsToSelector:@selector(requestDataFailed:)]) {
        [delegate performSelector:@selector(requestDataFailed:) withObject:error];
    }
}


-(NSMutableArray *)defaultCondition
{
	return [NSMutableArray array];
}

-(void)pushCondition:(NSDictionary *)condition{
	
	[self.conditions addObject:condition];
}

-(void)pushConditions:(NSArray *)cds
{
	[self.conditions addObjectsFromArray:cds];
}

-(void)clearCondition
{
	[self.conditions removeAllObjects];
	
}

-(void)downloadFinished:(ASIHTTPRequest *)request
{
	
	[progress removeFromSuperview];
	
	UIAlertView *alt = [[UIAlertView alloc]initWithTitle:@"提示" message:[[NSString alloc]initWithFormat:@"下载完成,文件路径:%@",[request downloadDestinationPath]]
												delegate:nil
									   cancelButtonTitle:@"确定" otherButtonTitles:nil];
	[alt show];
}

@end
