//
//  AiuiService.h
//  MSCDemo
//
//  Created by 侯效林 on 2017/5/23.
//
//

#ifndef AiuiService_h
#define AiuiService_h


#include "iflymsc/AIUI.h"
#include "iflymsc/AIUIConstant.h"

#include "reader.h"
#import "LocationRequest.h"

#include "FloatView.h"



using namespace aiui;

class TestListener : public IAIUIListener
{
private:
    
    NSMutableString *m_runResult;
    FloatView *m_controller;
    
public:
    
    void onStart();
    void onEvent(IAIUIEvent& event);
    void onSetController(FloatView *param);
    
    void syncStatus();
    void syncSchema();
    void sendTextMessage();
};

//aiui initialization
void AiuiInitialize();

/*
 FUNC ： send data
 PARAM：
 buffer: buffer data
 size  : data length
 isEnd : whether or not this data is the last data
 */
void AiuiSendBuffer(const void *buffer ,int size , bool isEnd);


#endif /* AiuiService_h */

