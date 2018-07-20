//
//  Const.m
//  SmartHub
//
//  Created by Anaconda on 11/26/14.
//  Copyright (c) 2014 Panda. All rights reserved.
//

#import "Const.h"


BlueTooth               *mBLEComm;
NSString                *myDB = @"empty.db";

NSString                *sendCatName = @"";
NSString                *sendImageName = @"";
NSString                *defaultCatridgeName = @"KURE";
NSString                *defaultImageName = @"tempimg";
NSString                *defaultUserImageName = @"tempuserimg";
int                     sendMode = 0;
int                     ScreenHeight;
int                     ScreenWidth;

int                     selectScreenIndex = -1;
int                     childSafetyValue = 0;
int                     batteryLevel = 100;
int                     coinValue = 60;
Boolean                 getImageStatus = false;

NSString                *learnSiteURL = @"http://www.mydxlife.com/EcoSmartPen";
NSString                *fillOutURL = @"http://www.mydxlife.com/EcoSmartPen";



NSString *symptomsSelImgName[] = {@"pain_sel", @"anxiety_sel", @"stress_sel", @"cancer_sel", @"epilepsy_sel", @"arthritis_sel", @"bipolar_sel", @"depression_sel", @"insomnia_sel"};
NSString *symptomsImgName[SYMPTOMS_COUNT] = {@"pain_nor", @"anxiety_nor", @"stress_nor", @"cancer_nor", @"epilepsy_nor", @"arthritis_nor", @"bipolar_nor", @"depression_nor", @"insomnia_nor"};
NSString *symptomsLblName[SYMPTOMS_COUNT] = {@"Pain", @"Anxiety", @"Stress", @"Cancer", @"Epilepsy", @"Arthritis", @"Bipolar", @"Depression", @"Insomnia"};

NSString *feelingSelImgName[] = {@"happy_sel", @"sad_sel", @"relaxed_sel", @"agitated_sel", @"energetic_sel", @"inactive_sel", @"social_sel", @"antisocial_sel", @"focused_sel", @"scattered_sel", @"motivated_sel", @"discouraged_sel", @"noeffect_sel"};
NSString *feelingImgName[FEELS_COUNT] = {@"happy_nor", @"sad_nor", @"relaxed_nor", @"agitated_nor", @"energetic_nor", @"inactive_nor", @"social_nor", @"antisocial_nor", @"focused_nor", @"scattered_nor", @"motivated_nor", @"discouraged_nor", @"noeffect_nor"};
NSString *feelingLblName[FEELS_COUNT] = {@"Happy", @"Sad", @"Relaxed", @"Agitated", @"Energetic", @"Inactive", @"Social", @"Antisocial", @"Focused", @"Scattered", @"Motivated", @"Discouraged", @"No Effect"};

float colors_array[] = {93,0,128,0,24,255,0,153,36,255,233,0,229,79,0,138,26,255,0,183,255,103,229,23,255,191,38,229,44,34,224,224,224,0,0,0};
