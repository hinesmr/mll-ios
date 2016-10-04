//
//  main.h
//  reader 
//
//  Created by Michael R. Hines on 8/13/14.
//
//

#ifndef reader_main_h
#define reader_main_h

#import <UIKit/UIKit.h>
#include "mica.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) mica *couch;
@property (strong, nonatomic) NSString * token;

@end
#endif
