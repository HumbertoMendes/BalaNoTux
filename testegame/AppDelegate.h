//
//  AppDelegate.h
//  testegame
//
//  Created by Patrick Tracanelli <patrick@bsd.com.br>
//  Copyright FreeBSD Brasil LTDA 2012-%%PRESENTYEAR%%. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
