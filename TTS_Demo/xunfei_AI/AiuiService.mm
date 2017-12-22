//
//  AiuiService.m
//  MSCDemo
//
//  Created by 侯效林 on 2017/5/23.
//
//

#import <Foundation/Foundation.h>
#include "AiuiService.h"
#include "writer.h"


IAIUIAgent *m_angent;
ISpeechUtility *m_utility;
TestListener m_listener;
LocationRequest *m_locationRequest;

#pragma mark - aiui initialization

//aiui initialization
void AiuiInitialize()
{
    
    //Get location information
    m_locationRequest = [[LocationRequest alloc] init];
    [m_locationRequest locationAsynRequest];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    cachePath = [cachePath stringByAppendingString:@"/"];
    NSLog(@"cachePath=%@",cachePath);
    
    AIUISetting::setSaveDataLog(true);
    AIUISetting::setLogLevel(info);
    AIUISetting::initLogger([cachePath UTF8String]);
    
    //set the configuration file path
    NSString *appPath = [[NSBundle mainBundle] resourcePath];
    NSString *cfgFilePath = [[NSString alloc] initWithFormat:@"%@/aiui.cfg",appPath];
    NSString *cfg = [NSString stringWithContentsOfFile:cfgFilePath encoding:NSUTF8StringEncoding error:nil];
    
    //set the resource path for module VAD
    NSString *vadFilePath = [[NSString alloc] initWithFormat:@"%@/meta_vad_16k.jet",appPath];
    //set correct resource path for module VAD in aiui configuration file
    NSString *cfgString  = [cfg stringByReplacingOccurrencesOfString:@"vad_res_path" withString:vadFilePath];
    const char *cfgBuffer = [cfgString UTF8String];
    
    m_angent = IAIUIAgent::createAgent(cfgBuffer, &m_listener);
    
    if (NULL != m_angent)
    {
        IAIUIMessage * wakeupMsg = IAIUIMessage::create(AIUIConstant::CMD_WAKEUP);
        m_angent->sendMessage(wakeupMsg);
        
        wakeupMsg->destroy();
    }
    
}


#pragma mark - aiui send data

//aiui send data
void AiuiSendBuffer(const void *buffer ,int size , bool isEnd)
{
    //whether or not this is the last data
    if(isEnd){
        
        //set the flag of last data
        IAIUIMessage * stopWrite = IAIUIMessage::create(AIUIConstant::CMD_STOP_WRITE,
                                                        0, 0, "data_type=audio,sample_rate=16000");
        m_angent->sendMessage(stopWrite);
        
        stopWrite->destroy();
    }
    else
    {
        //send audio data
        Buffer* pcmBuffer = Buffer::alloc(size);
        memcpy(pcmBuffer->data(), buffer, size);
        
        NSString *params = [[NSString alloc] initWithFormat:@"data_type=audio,sample_rate=16000"];
        
        //In order to the accuracy of Speech Understanding,we need location information.
        if(m_locationRequest){
            
            CLLocation *location = [m_locationRequest getLocation];
            
            if(location){
                
                NSNumber *lng = nil;
                NSNumber *lat = nil;
                
                CLLocationCoordinate2D clm = [location coordinate];
                
                lng = [[NSNumber alloc] initWithDouble:round(clm.longitude*100000000)/100000000];
                lat = [[NSNumber alloc] initWithDouble:round(clm.latitude*100000000)/100000000];
                
                //Set latitude and longitude
                params = [[NSString alloc] initWithFormat:@"%@,msc.lng=%@,msc.lat=%@",params,lng.stringValue,lat.stringValue];
            }
        }
        
        NSLog(@"params=%@",params);
        
        IAIUIMessage * writeMsg = IAIUIMessage::create(AIUIConstant::CMD_WRITE,0, 0, [params UTF8String], pcmBuffer);
        m_angent->sendMessage(writeMsg);
        writeMsg->destroy();
    }
    
}


#pragma mark - aiui listener

void TestListener::onStart()
{
    using namespace VA;
    using namespace std;
    
    IAIUIMessage * wakeupMsg = IAIUIMessage::create(AIUIConstant::CMD_WAKEUP);
    
    
    m_angent->sendMessage(wakeupMsg);
    
    
    wakeupMsg->destroy();
    
    m_runResult = nil;
}

void TestListener::onSetController(FloatView *param)
{
    m_controller = param;
}


void TestListener::syncStatus()
{
    if (NULL != m_angent)
    {
        using namespace VA;
        using namespace std;
        
        Json::Value dataJson;
        dataJson["k1"] = "v1";
        dataJson["k2"] = "v2";
        
        Json::FastWriter writer;
        string dataStr = writer.write(dataJson);
        
        Buffer* dataBuffer = Buffer::alloc(dataStr.length() + 1);
        dataStr.copy((char*) dataBuffer->data(), dataStr.length() + 1);
        
        IAIUIMessage* syncMsg=IAIUIMessage::create(AIUIConstant::CMD_SYNC,AIUIConstant::SYNC_DATA_STATUS,0,"{\"withSign\": \"0\"}",dataBuffer);
        
        m_angent->sendMessage(syncMsg);
    }
}

void TestListener::syncSchema()
{
    NSLog(@"uid:%@",[[IFlySpeechUtility getUtility] parameterForKey:@"uid"]);
    if (NULL != m_angent)
    {
        using namespace VA;
        using namespace std;
        
        Json::Value paramJson;
        paramJson["id_name"] = "uid";
        paramJson["res_name"] = "IFLYTEK.telephone_contact";
        
        Json::Value dataJson;
        dataJson["param"]=paramJson;
        dataJson["data"]="eyJuYW1lIjoi55m95rKZ5YiYIn0KeyJuYW1lIjoi54+t6ZW/In0KeyJuYW1lIjoi5oql57SnIn0KeyJuYW1lIjoi5rOi5rOiIn0KeyJuYW1lIjoi5ZC06LSk5q2mIn0KeyJuYW1lIjoi5YiY5b635ruRIn0KeyJuYW1lIjoi5ZC0576e5rOiIn0=";
        
        Json::FastWriter writer;
        string dataStr = writer.write(dataJson);
        
        Buffer* dataBuffer = Buffer::alloc(dataStr.length() + 1);
        dataStr.copy((char*) dataBuffer->data(), dataStr.length() + 1);
        
        IAIUIMessage* syncMsg=IAIUIMessage::create(AIUIConstant::CMD_SYNC,AIUIConstant::SYNC_DATA_SCHEMA,0,"{\"withSign\": \"0\"}",dataBuffer);
        
        m_angent->sendMessage(syncMsg);
    }
}

void TestListener::sendTextMessage()
{
    if (NULL != m_angent)
    {
        using namespace VA;
        using namespace std;
        
        onStart();
        string text = "合肥的天气";
        Buffer* textData = Buffer::alloc(text.length());
        text.copy((char*) textData->data(), text.length());
        
        IAIUIMessage* writeMsg=IAIUIMessage::create(AIUIConstant::CMD_WRITE,0,0,"data_type=text",textData);
        m_angent->sendMessage(writeMsg);
        writeMsg->destroy();
    }
}
/*
 aiui callback
 */
void TestListener::onEvent(IAIUIEvent& event)
{
    NSLog(@"%s",__func__);
    switch (event.getEventType()) {
        case AIUIConstant::EVENT_STATE:
        {
            switch (event.getArg1()) {
                case AIUIConstant::STATE_IDLE:
                {
                    NSLog(@"EVENT_STATE IDLE");
                }
                    break;
                    
                case AIUIConstant::STATE_READY:
                {
                    NSLog(@"EVENT_STATE READY");
                }
                    break;
                    
                case AIUIConstant::STATE_WORKING:
                {
                    NSLog(@"EVENT_STATE WORKING");
                }
                    break;
                default:
                    NSLog(@"EVENT_STATE event.getArg1()=%d",event.getArg1());
                    break;
            }
        }
            break;
            
        case AIUIConstant::EVENT_WAKEUP:
        {
            
            NSLog(@"EVENT_WAKEUP: arg1=%d arg2=%d,info=%s",event.getArg1(),event.getArg2(),event.getInfo());
        }
            break;
            
        case AIUIConstant::EVENT_SLEEP:
        {
            
            NSLog(@"EVENT_SLEEP: arg1=%d",event.getArg1());
        }
            break;
            
        case AIUIConstant::EVENT_VAD:
        {
            switch (event.getArg1()) {
                case AIUIConstant::VAD_BOS:
                {
                    NSLog(@"EVENT_VAD VAD_BOS");
                }
                    break;
                    
                case AIUIConstant::VAD_EOS:
                {
                    NSLog(@"EVENT_VAD VAD_EOS");
                    if(m_controller){
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //停止
                            [m_controller stop];
                            
                            
                        });
                    }
                }
                    break;
                    
                case AIUIConstant::VAD_VOL:
                {
                    //                    NSLog(@"EVENT_VAD VAD_VOL");
                } break;
            }
        } break;
            
            //parse results
        case AIUIConstant::EVENT_RESULT:
        {
            NSLog(@"************EVENT_RESULT***************start");
            
            using namespace VA;
            Json::Value bizParamJson;
            Json::Reader reader;
            
            if(!reader.parse(event.getInfo(), bizParamJson,false)){
                NSLog(@"parse error!,getinfo=%s",event.getInfo());
            }
            
            Json::Value data = (bizParamJson["data"])[0];
            Json::Value params = data["params"];
            Json::Value content = (data["content"])[0];
            std::string sub =  params["sub"].asString();
            
            if(sub == "nlp"){
                Json::Value empty;
                Json::Value contentId = content.get("cnt_id", empty);
                
                if(contentId.empty()){
                    NSLog(@"Content Id is empty");
                    break;
                }
                
                std::string cnt_id = contentId.asString();
                
                Buffer *buffer = event.getData()->getBinary(cnt_id.c_str());
                
                if(NULL != buffer){
                    
                    const char * resultStr = (char *) buffer->data();
                    if(resultStr == NULL){
                        return;
                    }
                    
                    NSMutableString *tmp = [[NSMutableString alloc] initWithUTF8String:resultStr];
                    
                    if(tmp == nil){
                        return;
                    }
                    
                    if(m_runResult == nil)
                    {
                        m_runResult = tmp;
                    }
                    else
                    {
                        [m_runResult appendString:@"\nNext Result:\n"];
                        [m_runResult appendString:tmp];
                    }
                    
                    if(m_controller){
                        
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [m_controller showResult:m_runResult];
                        });
                        
                    }
                    
                }
            }
            
            const char *info  = event.getInfo();
            if(info != NULL)
            {
                NSLog(@"result info=%s",event.getInfo());
            }
            
            //            NSLog(@"************EVENT_RESULT***************end");
            
        } break;
            
            //handle error
        case AIUIConstant::EVENT_ERROR:
        {
            
            NSLog(@"EVENT_ERROR,info=%s,arg1=%d",event.getInfo(),event.getArg1());
            
            if(m_controller){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [m_controller stop];
                    
                    
                });
            }
        }
            break;
            
        case AIUIConstant::EVENT_CMD_RETURN:
        {
            if(AIUIConstant::CMD_SYNC == event.getArg1()){
                int retcode = event.getArg2();
                int dtype =event.getData()->getInt("sync_dtype", -1);
                switch (dtype)
                {
                    case AIUIConstant::SYNC_DATA_STATUS:
                    {
                        if (AIUIConstant::SUCCESS == retcode)
                        {
                            NSLog(@"CMD_SYNC sync status success.");
                        } else {
                            NSLog(@"CMD_SYNC sync status error= %d",retcode);
                        }
                    } break;
                        
                    case AIUIConstant::SYNC_DATA_SCHEMA:
                    {
                        std::string sid = event.getData()->getString("sid", "");
                        
                        if (AIUIConstant::SUCCESS == retcode)
                        {
                            NSLog(@"sync schema success.");
                        } else {
                            NSLog(@"sync schema error= %d",retcode);
                        }
                        
                        NSLog(@"sid=%s",sid.c_str());
                    } break;
                        
                    case AIUIConstant::SYNC_DATA_QUERY:
                    {
                        if (AIUIConstant::SUCCESS == retcode)
                        {
                            NSLog(@"sync query success");
                        } else {
                            NSLog(@"sync query error= %d",retcode);
                        }
                    } break;
                }
            }
            
        }
        default:
            NSLog(@"event.getEventType()=%d",event.getEventType());
            break;
    }
}

