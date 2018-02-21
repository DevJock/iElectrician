//
//  AppLib.h
//  MusicTiles
//
//  Created by Chiraag Bangera on 12/12/14.
//  Copyright (c) 2014 Chiraag Bangera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface AppLib : NSObject
{
    AppDelegate *appDelegate;
}

-(void)checkAndCopy:(NSString *)filename;
-(BOOL)fileCheck:(NSString *)fileName;
- (void)writeStringToFile:(NSString*)aString with:(NSString *)fileName;
- (NSString*)readStringFromFile:(NSString *)fileName;
-(NSArray *)listFileAtPath:(NSString *)path;
-(NSString *)sizeOfFolder:(NSString *)folderPath;
- (bool)deleteFile:(NSString *)fileName;
-(void)deleteFilesOfType:(NSString *)extension;
-(NSString *)documentsPath;
-(NSData *)fetchDatafromServer:(NSString *)URLString;
-(NSMutableDictionary *) parseJSONResponse:(NSData *)URLResponse;
-(void)saveJSONDataToFile:(NSMutableDictionary *)theData with:(NSString *)fileName;
-(NSString *)pathToFile:(NSString *)fileName;
-(NSMutableDictionary *)mergeDictionaries:(NSMutableDictionary *)lhs with:(NSMutableDictionary *)rhs;
-(void)saveImagetoFile:(UIImage *)image with:(NSString *)filename;
-(UIImage *)loadImagefromFile:(NSString *)filename;
-(NSMutableDictionary *)dataFromBundle:(NSString *)fileName;
-(NSMutableDictionary *)loadJSONDataFromFile:(NSString *)fileName;
-(NSString *)abbreviateNumber:(int)num;
-(UIColor *)colorDecoder:(NSString *)cCode;
-(BOOL)saveSettings:(NSString *)value forKey:(NSString *)key;
-(NSString *)retriveSettings:(NSString *)key;

@end
