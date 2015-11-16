//
//  CCDataManager.m
//  CoCode
//
//  Created by wuxueqian on 15/11/7.
//  Copyright (c) 2015年 wuxueqian. All rights reserved.
//

#import "CCDataManager.h"
#import <RegexKitLite.h>
#import "HTMLParser.h"
#import <FXKeychain.h>

#define kUserAgentPC @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/537.75.14"

static NSString *const kUserIsLogin = @"userIsLogin";
static NSString *const kUsername = @"username";
static NSString *const kUserid = @"userid";
static NSString *const kAvatarURL = @"avatarURL";
static NSString *const kBaseUrl = @"http://cocode.cc";

typedef NS_ENUM(NSInteger, CCRequestMethod){
    CCRequestMethodJSONGET = 1,
    CCRequestMethodHTTPGET = 2,
    CCRequestMethodHTTPPOST = 3,
    CCRequestMethodHTTPGETPC = 4
};

@interface CCDataManager()

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, copy) NSString *userAgentMobile;
@property (nonatomic, copy) NSString *userAgentPC;

@end

@implementation CCDataManager

+ (instancetype)sharedManager{
    static CCDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CCDataManager alloc] init];
    });
    return manager;
}

- (instancetype)init{
    if (self = [super init]) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        self.userAgentMobile = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        self.userAgentPC = kUserAgentPC;
        
        //AFHttp
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
        AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
        self.manager.requestSerializer = serializer;
        
        //Logged user case
        BOOL isLogin = [[kUserDefaults objectForKey:kUserIsLogin] boolValue];
        if (isLogin) {
            CCUserModel *user = [[CCUserModel alloc] init];
            user.login = YES;
            CCMemberModel *member = [[CCMemberModel alloc] init];
            user.member = member;
            user.member.memberUserName = [kUserDefaults objectForKey:kUsername];
            user.member.memberID = [kUserDefaults objectForKey:kUserid];
            user.member.memberAvatarLarge = [kUserDefaults objectForKey:kAvatarURL];
            _user = user;
        }
    }
    return self;
}

- (void)setUser:(CCUserModel *)user{
    _user = user;
    if (user) {
        self.user.login = YES;
        [kUserDefaults setObject:user.member.memberUserName forKey:kUsername];
        [kUserDefaults setObject:user.member.memberID forKey:kUserid];
        [kUserDefaults setObject:user.member.memberAvatarLarge forKey:kAvatarURL];
        [kUserDefaults setObject:@"YES" forKey:kUserIsLogin];
        [kUserDefaults synchronize];
    }else{
        [kUserDefaults removeObjectForKey:kUsername];
        [kUserDefaults removeObjectForKey:kUserid];
        [kUserDefaults removeObjectForKey:kAvatarURL];
        [kUserDefaults removeObjectForKey:kUserIsLogin];
        [kUserDefaults synchronize];
    }
}

#pragma mark - Main Request Method

- (NSURLSessionDataTask *)requestWithMethod:(CCRequestMethod)method
                              URLString:(NSString *)URLString
                             parameters:(NSDictionary *)parameters
                                success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                failure:(void (^)(NSError *error))failure{
    
    //Status bar network indicator
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    //Handle block
    void (^handleResponseBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id responseObject){
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        success(task, responseObject);
    };
    
    //HTTP  session
    NSURLSessionDataTask *task = nil;
    [self.manager.requestSerializer setValue:self.userAgentMobile forHTTPHeaderField:@"User-Agent"];
    
    if (method == CCRequestMethodJSONGET) {
        AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        task = [self.manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask * task, id responseObject) {
            handleResponseBlock(task, responseObject);
        } failure:^(NSURLSessionDataTask * task, NSError * error) {
            //TODO NSlog
            NSLog(@"Error: \n%@", error.description);
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    if (method == CCRequestMethodHTTPGET){
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        task = [self.manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
            handleResponseBlock(task, responseObject);
        }failure:^(NSURLSessionDataTask *task, NSError *error){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    if (method == CCRequestMethodHTTPPOST) {
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        task = [self.manager POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
            handleResponseBlock(task, responseObject);
        }failure:^(NSURLSessionDataTask *task, NSError *error){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    if (method == CCRequestMethodHTTPGETPC) {
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        [self.manager.requestSerializer setValue:self.userAgentPC forKey:@"User-Agent"];
        task = [self.manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject){
            handleResponseBlock(task, responseObject);
        }failure:^(NSURLSessionDataTask *task, NSError *error){
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    
    return task;
}


#pragma mark - Business request method

- (NSURLSessionDataTask *)getTopicListNewestWithPage:(NSInteger)page
                                             success:(void (^)(CCTopicList *))success
                                             failure:(void (^)(NSError *))failure{
    NSDictionary *parameters;
    if (page && page > 0) {
        parameters = @{@"page":@(page-1)};
    }
    return [self requestWithMethod:CCRequestMethodJSONGET URLString:@"latest.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        CCTopicList *list = [CCTopicList getTopicListFromResponseObject:responseObject];
        
        if (list) {
            success(list);
        }else{
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:CCErrorTypeGetTopicListFailure userInfo:nil];
            failure(error);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)getTopicListLatestWithPage:(NSInteger)page
                                             success:(void (^)(CCTopicList *))success
                                             failure:(void (^)(NSError *))failure{
    NSDictionary *parameters;
    if (page && page > 0) {
        parameters = @{@"page":@(page-1)};
    }
    return [self requestWithMethod:CCRequestMethodJSONGET URLString:@"new.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        CCTopicList *list = [CCTopicList getTopicListFromResponseObject:responseObject];
        
        if (list) {
            success(list);
        }else{
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:CCErrorTypeGetTopicListFailure userInfo:nil];
            failure(error);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)getTopicListHotWithPage:(NSInteger)page
                                         inPeriod:(NSInteger)period
                                          success:(void (^)(CCTopicList *))success
                                          failure:(void (^)(NSError *))failure{
    NSDictionary *parameters;
    if (page && page > 0) {
        parameters = @{@"page":@(page-1)};
    }
    NSString *urlString;
    switch ((int)period) {
        case 1:
            urlString = @"top/daily.json";
            break;
        case 2:
            urlString = @"top/weekly.json";
            break;
        case 3:
            urlString = @"top/monthly.json";
            break;
        case 4:
            urlString = @"top/quarterly.json";
            break;
        case 5:
            urlString = @"top/yearly.json";
            break;
        default:
            urlString = @"top/all.json";
            break;
    }
    return [self requestWithMethod:CCRequestMethodJSONGET URLString:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        CCTopicList *list = [CCTopicList getTopicListFromResponseObject:responseObject];
        
        if (list) {
            success(list);
        }else{
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:CCErrorTypeGetTopicListFailure userInfo:nil];
            failure(error);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)getTopicWithTopicID:(NSInteger)topicID success:(void (^)(CCTopicModel *))success failure:(void (^)(NSError *))failure{
    //TODO confirm topicID
    NSString *urlString = [NSString stringWithFormat:@"t/topic/%d.json",(int)topicID];
    return [self requestWithMethod:CCRequestMethodJSONGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        CCTopicModel *topic = [CCTopicModel getTopicModelFromResponseObject:responseObject];
        if (topic) {
            success(topic);
        }else{
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:CCErrorTypeGetTopicError userInfo:nil];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)getTopicListWithPage:(NSInteger)page categoryUrl:(NSURL *)categoryUrl success:(void (^)(CCTopicList *))success failure:(void (^)(NSError *))failure{
    
    NSDictionary *parameters;
    if (page && page > 0) {
        parameters = @{@"page":@(page-1)};
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", categoryUrl.absoluteString, @".json"];
    
    return [self requestWithMethod:CCRequestMethodJSONGET URLString:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        CCTopicList *list = [CCTopicList getTopicListFromResponseObject:responseObject];
        
        if (list) {
            success(list);
        }else{
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:CCErrorTypeGetTopicListFailure userInfo:nil];
            failure(error);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

@end
