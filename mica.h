//
//  mica.h
//  reader 
//
//  Created by Michael R. Hines on 8/16/14.
//
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <sys/socket.h>
#import <CoreFoundation/CoreFoundation.h>

#ifndef reader_mica_h
#define reader_mica_h


@interface MyViewController : UIViewController
@end

@interface mica : NSObject;
- (void) updateReplication: (CBLReplication *)event : (NSString *) type;
- (void) storePushToken;
@end

typedef enum : NSInteger {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

extern NSString *kReachabilityChangedNotification;

@interface Reachability : NSObject
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;
+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;
+ (instancetype)reachabilityForInternetConnection;
+ (instancetype)reachabilityForLocalWiFi;
- (BOOL)startNotifier;
- (void)stopNotifier;
- (NetworkStatus)currentReachabilityStatus;
- (BOOL)connectionRequired;

@end

#endif
