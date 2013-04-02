//
//  DataSetRequest.h
//  IMpc
//
//  Created by pro on 11-3-24.
//  Copyright 2011 gzmpc. All rights reserved.
//  clq

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"

@protocol DataSetRequestDelegate;

@interface DataSetRequest : NSObject
<ASIHTTPRequestDelegate>
{

	NSString *gridcode ;
	NSString *queryType ;
	NSString *dataSource ;
	NSString *querymoduleid ;
	NSString *sumfieldnames ;
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
    
    BOOL pagecount;
    
    NSDictionary *userInfo;
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

@property (nonatomic,weak) id<DataSetRequestDelegate> delegate;

@property (nonatomic,strong) NSDictionary *userInfo;
@property (assign) BOOL pagecount;

//初始化
//-(id)initWithGridcode:(NSString *)_gridcode;

-(id)initWithGridcode:(NSString *)_gridcode querytype:(NSString *)_queryType
			  datasource:(NSString *)_dataSource querymoduleid:(NSString *)_querymoduleid sumfieldnames:(NSString *)_sumfieldnames;

//download
//-(NSString *)download:(NSString *)moduleid visibleCol:(NSString *)visibleCol theDelegate:(UIViewController *)downdelegate;

//getdata
-(void)doQueryWithConditions:(NSArray*)conditions byRetAll:(BOOL) all;

-(void)requestDataWithPage:(int)page pageNum:(unsigned int)pageNum needpagecount:(BOOL)needpagecount;

- (void)requestFinished:(ASIHTTPRequest *)request;

- (void)requestFailed:(ASIHTTPRequest *)request;
	
-(NSMutableArray *)defaultCondition;

-(void)pushCondition:(NSDictionary *)condition;

-(void)pushConditions:(NSArray *)cds;

-(void)clearCondition;

-(void)downloadFinished:(ASIHTTPRequest *)request;

@end


@protocol DataSetRequestDelegate <NSObject>

@optional
-(void)dataSetRequest:(DataSetRequest *)dataSetRequest didQueryData:(NSDictionary *)result;
-(void)dataSetRequest:(DataSetRequest *)dataSetRequest requestDataFailed:(NSError *)error;
-(void)dataSetRequest:(DataSetRequest *)dataSetRequest dataDidRead:(NSArray *)rows;
-(void)dataSetRequest:(DataSetRequest *)dataSetRequest dataReadDidFail:(NSError *)error;

@end


typedef NS_OPTIONS(NSInteger, DataSetRequestPageNum) {
    DataSetRequestPageNumUnlimited = - 10
};