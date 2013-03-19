//
//  DataSetRequest.h
//  IMpc
//
//  Created by pro on 11-3-24.
//  Copyright 2011 gzmpc. All rights reserved.
//  clq

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@protocol DataSetRequestDelegate <NSObject>

@optional
-(void)didQueryData:(NSDictionary *)result;
-(void)requestDataFailed:(NSError *)error;
-(void)dataDidRead:(NSArray *)rows;
-(void)dataReadDidFail:(NSError *)error;

@end

@interface DataSetRequest : NSObject
<ASIHTTPRequestDelegate>
{

	NSString *gridcode ;
	NSString *queryType ;
	NSString *dataSource ;
	NSString *querymoduleid ;
	NSString *sumfieldnames ;
	NSString *stagetype ;
	NSString *stageid ;     
	NSString *orderfields;
	NSMutableArray *conditions ;
	NSString * pagerownum;
	NSString * startidx;
	
	NSString * sessionId;
	NSString * base;
	NSString * SERVLET_URL ;
	NSString * ACTION_INIT;
	NSString * ACTION_QUERY;
	NSString * ACTION_DOWNLOAD;
	
	UIProgressView * progress;
    
    __weak id<DataSetRequestDelegate> delegate;
}

@property (nonatomic,strong) NSString *gridcode ;
@property (nonatomic,strong) NSString *queryType ;
@property (nonatomic,strong) NSString *dataSource ;
@property (nonatomic,strong) NSString *querymoduleid ;
@property (nonatomic,strong) NSString *sumfieldnames ; 
@property (nonatomic,strong) NSString *orderfields;
@property (nonatomic,strong) NSMutableArray *conditions ;
@property (nonatomic,strong) NSString * pagerownum;
@property (nonatomic,strong) NSString * startidx;

@property (strong) NSString *sessionId;
@property (strong) NSString *base;
@property (strong) NSString * SERVLET_URL;
@property (strong) NSString * ACTION_INIT;
@property (strong) NSString * ACTION_QUERY;
@property (strong) NSString * ACTION_DOWNLOAD;

@property (nonatomic,weak) id<DataSetRequestDelegate> delegate;


//初始化
-(id)initWithGridcode:(NSString *)gridcode querytype:(NSString *)queryType
			  datasource:(NSString *)dataSource querymoduleid:(NSString *)querymoduleid sumfieldnames:(NSString *)sumfieldnames;

//download
-(NSString *)download:(NSString *)moduleid visibleCol:(NSString *)visibleCol theDelegate:(UIViewController *)downdelegate;

//getdata
-(void)requestDataWithPage:(int)page pageNum:(unsigned int)pageNum needpagecount:(BOOL)needpagecount;

- (void)requestFinished:(ASIHTTPRequest *)request;

- (void)requestFailed:(ASIHTTPRequest *)request;
	
-(NSMutableArray *)defaultCondition;

-(void)pushCondition:(NSDictionary *)condition;

-(void)pushConditions:(NSArray *)cds;

-(void)clearCondition;

-(void)downloadFinished:(ASIHTTPRequest *)request;

@end


