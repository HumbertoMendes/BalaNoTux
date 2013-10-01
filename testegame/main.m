//
//  main.m
//  testegame
//
//  Created by Patrick Tracanelli <patrick@ids.com.br>
//  Copyright FreeBSD Brasil LTDA 2012-%%PRESENTYEAR%%. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    [pool release];
    return retVal;
}
