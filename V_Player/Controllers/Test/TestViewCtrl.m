//
//  TestViewCtrl.m
//  V_Player
//
//  Created by 黄聪 on 2017/2/25.
//  Copyright © 2017年 黄聪. All rights reserved.
//

#import "TestViewCtrl.h"
#import "avformat.h"
#import "avcodec.h"
#import "imgutils.h"
#import "swscale.h"

@interface TestViewCtrl ()

@end

@implementation TestViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //常量
    NSInteger videoStream;
    
    
    
    //ffmpeg
    av_register_all();
    
    //format结构体
    AVFormatContext *formatContext;
    AVCodecContext *pCodecCxt;
    AVCodecParameters *codecParams;

    AVCodec *pCodec;
    AVFrame *frameIn;
    AVFrame *frameRGBOut;
    
    //视频路径
    NSString *filePathStr = @"/Users/huangcong/Desktop/342.mp4";
    const char *filePathChar = [filePathStr cStringUsingEncoding:NSASCIIStringEncoding];
    formatContext = avformat_alloc_context();
    if (avformat_open_input(&formatContext, filePathChar, NULL, NULL)!=0) {
        NSLog(@"打不开文件信息");
    }
    
    if (avformat_find_stream_info(formatContext, nil)<0) {
        NSLog(@"打不开流信息");
    }
    
    NSLog(@"\n-----------------------file info---------------------------------");
    av_dump_format(formatContext, 0, filePathChar, 0);
    NSLog(@"-----------------------------------------------------------------");
    
    for (NSInteger i = 0; i<formatContext->nb_streams; i++) {
        if (formatContext->streams[i]->codecpar->codec_type == AVMEDIA_TYPE_VIDEO) {
            videoStream = i;
            break;
        }
    }
    
    if (videoStream == -1) {
        NSLog(@"没有找到视频流");
    }else {
        pCodecCxt=formatContext->streams[videoStream]->codec;
        
        codecParams = formatContext->streams[videoStream]->codecpar;
        
        
        
        pCodec = avcodec_find_decoder(codecParams->codec_id);
//        pCodecCxt = avcodec_alloc_context3(pCodec);
        
        if (pCodec == NULL) {
            NSLog(@"不找不到解码器id");
            return;
        }
        if (avcodec_open2(pCodecCxt, pCodec, NULL)<0) {
            NSLog(@"打不开编码器");
            return;
        }
        
        frameIn = av_frame_alloc();
        frameRGBOut = av_frame_alloc();
        
        uint8_t *buffer;
        NSInteger numBytes;
        
        
        numBytes = av_image_get_buffer_size(AV_PIX_FMT_RGB24, codecParams->width, codecParams->height,1);
        buffer = (uint8_t *)av_malloc(numBytes*sizeof(uint8_t));
        
        av_image_fill_arrays(frameRGBOut->data, frameRGBOut->linesize, buffer, AV_PIX_FMT_RGB24, codecParams->width, codecParams->height, 1);
        
        NSInteger frameFinished;
        AVPacket packet;
        struct SwsContext *img_convert_ctx;
        int i = 0;
        
        while(av_read_frame(formatContext, &packet)>=0) {
            // Is this a packet from the video stream?
            if(packet.stream_index==videoStream) {
                // Decode video frame
                
                avcodec_send_packet(pCodecCxt, &packet);
                
                avcodec_receive_frame(pCodecCxt, frameIn);

                if(frameFinished) {
                    // Convert the image from its native format to RGB
                    // other codes
                    img_convert_ctx = sws_getContext(codecParams->width, codecParams->height,
                                                     pCodecCxt->pix_fmt, codecParams->width, codecParams->height,
                                                     AV_PIX_FMT_RGB24, SWS_BICUBIC, NULL, NULL, NULL);
                    // other codes
                    // Convert the image from its native format to RGB
                    sws_scale(img_convert_ctx, (const uint8_t* const*)frameIn->data, frameIn->linesize,
                              0, codecParams->height, frameRGBOut->data, frameRGBOut->linesize);
                    
                } }
            
            

            // Save the frame to disk
            if(++i<=5)
                
            [self savePicture:*frameRGBOut width:pCodecCxt->width height:pCodecCxt->height index:i];

            // Free the packet that was allocated by av_read_frame
            
            av_packet_unref(&packet);
        }
        avcodec_free_context(&pCodecCxt);
        avformat_free_context(formatContext);
        av_free(buffer);
        av_free(frameIn);
        av_free(frameRGBOut);
        
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)savePicture:(AVFrame)pict width:(int)width height:(int)height index:(int)iFrame
{
    FILE *pFile;
    int  y;
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSString *filename = [NSString stringWithFormat:@"frame%d.bmp",iFrame];
    
    NSString *filePath = [docPath stringByAppendingPathComponent:filename];
    
    // Open file
    NSLog(@"write image file: %@",filePath);
    pFile=fopen([filePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    if(pFile==NULL)
        return;
    
    // Write header
    fprintf(pFile, "P6\n%d %d\n255\n", width, height);
    
    // Write pixel data
    for(y=0; y<height; y++)
        fwrite(pict.data[0]+y*pict.linesize[0], 1, width*3, pFile);
    
    // Close file
    fclose(pFile);
}



@end
