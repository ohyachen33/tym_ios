//
//  RequestBody.m
//  Alexa
//
//  Created by Alain Hsu on 9/12/16.
//  Copyright © 2016 tymphanysz. All rights reserved.
//

#import "RequestBody.h"

@implementation RequestBody

+ (NSData*)deployRequestBody:(AlexaVoiceServiceAPI)api audioData:(NSData*)audioData boundary:(NSString*)boundary
{
    switch (api) {
        case AVSSynchronizeStateAPI:
        {
            //Message
            NSMutableData *postData = [[NSMutableData alloc] initWithData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Disposition: form-data; name=\"metadata\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Type: application/json; charset=UTF-8\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            NSDictionary *messageDic = @{@"context": @[
//                                                @{
//                                                    @"header": @{
//                                                            @"namespace": @"AudioPlayer",
//                                                            @"name": @"PlaybackState"
//                                                            },
//                                                    @"payload": @{
//                                                            @"token": @"",
//                                                            @"offsetInMilliseconds": @7000,
//                                                            @"playerActivity": @"FINISHED"
//                                                            }
//                                                },
//                                                @{
//                                                    @"header": @{
//                                                            @"namespace": @"Alerts",
//                                                            @"name": @"AlertsState"
//                                                            },
//                                                    @"payload": @{
//                                                            @"allAlerts": @[
//                                                                    ],
//                                                            @"activeAlerts": @[
//                                                                    ]
//                                                            }
//                                                },
//                                                @{
//                                                    @"header": @{
//                                                            @"namespace": @"Speaker",
//                                                            @"name": @"VolumeState"
//                                                            },
//                                                    @"payload": @{
//                                                            @"volume": @25,
//                                                            @"muted": @false
//                                                            }
//                                                },
//                                                @{
//                                                    @"header": @{
//                                                            @"namespace": @"SpeechSynthesizer",
//                                                            @"name": @"SpeechState"
//                                                            },
//                                                    @"payload": @{
//                                                            @"token": @"",
//                                                            @"offsetInMilliseconds": @0,
//                                                            @"playerActivity": @"FINISHED"
//                                                            }
//                                                }
                                            ],
                                         @"event": @{
                                                @"header": @{
                                                        @"namespace": @"System",
                                                        @"name": @"SynchronizeState",
                                                        @"messageId": @"messageId-123"
                                                        },
                                                @"payload": @{
                                                        }
                                                }
                                         };
            
            NSData *messageData = [NSJSONSerialization dataWithJSONObject:messageDic options:NSJSONWritingPrettyPrinted error:nil];
            [postData appendData:messageData];
            
            [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            return postData;
        }
            break;
            
        case AVSSpeechRecognizerAPI:
        {
            NSMutableData *postData = [[NSMutableData alloc] initWithData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Disposition: form-data; name=\"metadata\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Type: application/json; charset=UTF-8\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            NSDictionary *dic =
            @{
              @"context": @[
                      @{
                          @"header": @{
                                  @"namespace": @"AudioPlayer",
                                  @"name": @"PlaybackState"
                                  },
                          @"payload": @{
                                  @"token": @"",
                                  @"offsetInMilliseconds": @7000,
                                  @"playerActivity": @"FINISHED"
                                  }
                          },
                      @{
                          @"header": @{
                                  @"namespace": @"Alerts",
                                  @"name": @"AlertsState"
                                  },
                          @"payload": @{
                                  @"allAlerts": @[
                                          ],
                                  @"activeAlerts": @[
                                          ]
                                  }
                          },
                      @{
                          @"header": @{
                                  @"namespace": @"Speaker",
                                  @"name": @"VolumeState"
                                  },
                          @"payload": @{
                                  @"volume": @25,
                                  @"muted": @false
                                  }
                          },
                      @{
                          @"header": @{
                                  @"namespace": @"SpeechSynthesizer",
                                  @"name": @"SpeechState"
                                  },
                          @"payload": @{
                                  @"token": @"",
                                  @"offsetInMilliseconds": @0,
                                  @"playerActivity": @"FINISHED"
                                  }
                          }
                      ],
              @"event": @{
                      @"header": @{
                              @"namespace": @"SpeechRecognizer",
                              @"name": @"Recognize",
                              @"messageId": @"messageId-123",
                              @"dialogRequestId": @"dialogRequestId-321"
                              },
                      @"payload": @{
                              @"profile": @"CLOSE_TALK",
                              @"format": @"AUDIO_L16_RATE_16000_CHANNELS_1"
                              }
                      }
              };
            
            NSData *messageData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            [postData appendData:messageData];
            
            //Audio
            [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Disposition: form-data; name=\"audio\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[NSData dataWithData:audioData]];
            [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            return postData;
        }
            break;
            
        default:
            return nil;
    }
}

+ (NSData*)deployRequestBody:(AlexaVoiceServiceAPI)api name:(NSString*)name token:(NSString*)token boundary:(NSString*)boundary
{
    switch (api) {
        case AVSSpeechSynthesizerAPI:
        {
            NSMutableData *postData = [[NSMutableData alloc] initWithData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Disposition: form-data; name=\"metadata\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [postData appendData:[@"Content-Type: application/json; charset=UTF-8\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            
            
            NSDictionary *dic =
            @{
              @"event": @{
                      @"header": @{
                              @"namespace": @"SpeechSynthesizer",
                              @"name": name,
                              @"messageId": @"messageId-124",
                              },
                      @"payload": @{
                              @"token": token
                              }
                      }
              };
            
            NSData *messageData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            [postData appendData:messageData];
            [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            return postData;
            
        }
            break;

            
        default:
            return nil;
    }
}

@end
