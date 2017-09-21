//
//  ViewController.m
//  FaceAR_SDK_IOS_OpenFace_RunFull
//
//

#import "ViewController.h"
#import "GPUImage.h"
#import "Appdelegate.h"
///// opencv
#import <opencv2/opencv.hpp>
///// C++
#include <iostream>
///// user
#include "FaceARDetectIOS.h"

//
#import "GPUImageBeautifyFilter.h"
#import "MySpline.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) GPUImageView *filterView;
@end
#define MAX_EFFECT_COUNT 127
@implementation ViewController {
  
    NSString *girls;
    BOOL image_detection_Enable;
    GPUImageBeautifyFilter *beautifyFilter;
    
    float effect_parameters[MAX_EFFECT_COUNT];
    int current_index;
    int frame_count;
}
enum{
    EFFECT_LIP=0,
    EFFECT_EYEBROWS=1,
    EFFECT_BLUSH=2,
    EFFECT_EYESHADOW=3,
    EFFECT_SKINBLUR=4,
    EFFECT_HIGHLIGHT=5,
    EFFECT_CONTOUR=6
    
};
enum{
    MIXEDCOLOR_ADDCOLOR=1,
    MIXEDCOLOR_SELF=2
    
};

-(void)AlertText:(cv::Mat) img{
    
    
      cv::resize(img,img,cv::Size(640,960));
    std::string text = "Cann't detect any face";
    int fontFace = CV_FONT_HERSHEY_SCRIPT_SIMPLEX;
    double fontScale = 1.8;
    int thickness = 8;
    cv::Point textOrg(10, img.rows/2);
    cv::Point textOrg_shdow(textOrg.x+2, textOrg.y+2);
    
    cv::putText(img, text, textOrg_shdow, fontFace, fontScale, cv::Scalar(100,100,100), thickness,8);
    thickness = 5;
    cv::putText(img, text, textOrg, fontFace, fontScale, cv::Scalar(255,0,0), thickness,8);
    
    text = "on your photo!";
    thickness = 8;
    cv::Point textOrg1(img.cols/2-80, img.rows/2+80);
    cv::Point textOrg_shdow1(textOrg1.x+2, textOrg1.y+2);
    
    cv::putText(img, text, textOrg_shdow1, fontFace, fontScale, cv::Scalar(100,100,100), thickness,8);
    thickness = 5;
    cv::putText(img, text, textOrg1, fontFace, fontScale, cv::Scalar(255,0,0), thickness,8);

    UIImage *res=[self UIImageFromCVMat:img];
    self.imageView.image=res;
}
- (BOOL)processImage:(cv::Mat &)image returnInfo:(cv::Mat_<double>&)shape2D;
{
    
    cv::Mat targetImage(480,640,CV_8UC3);
    
    
    cv::cvtColor(image, targetImage, cv::COLOR_BGRA2BGR);
    
    cv::resize(targetImage, targetImage,cv::Size(600,800));
    
    shape2D.release();
  
    BOOL res=false;
    
    if(targetImage.empty()){
        std::cout << "targetImage empty" << std::endl;
    }
    else
    {
        
        target_image=targetImage.clone();
        float fx, fy, cx, cy;
        cx = 1.0*targetImage.cols / 2.0;
        cy = 1.0*targetImage.rows / 2.0;
        
        fx = 500 * (targetImage.cols / 640.0);
        fy = 500 * (targetImage.rows / 480.0);
        
        fx = (fx + fy) / 2.0;
        fy = fx;
        
       res= [[[FaceARDetectIOS alloc] init ]run_FaceAR:targetImage frame__:frame_count fx__:fx fy__:fy cx__:cx cy__:cy returnInfo:shape2D resVisiblilities:visibilities];
        
    }
    
    cv::cvtColor(targetImage, image, cv::COLOR_BGRA2BGR);
    return res;
 
}
-(void) startAnimation{
    [UIView animateWithDuration:5.25 animations:^{
        //self.img_gallery.frame.origin.y=0.1;
           CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -15);
        self.img_gallery.transform =transform;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
           // self.leftFootImageView.transform = [self calculateTransformForFootToAngle:-M_PI / 8.0];
        } completion:NULL];
    }];}
-(void)Alert{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Warning!"
                                 message:@"Cann't detect the face in Photo!"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Confirm"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                       [self dismissViewControllerAnimated:NO completion:nil];
                                }];
    
      [alert addAction:yesButton];
    //[alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad {
    image_detection_Enable=false;
    [super viewDidLoad];
    
    
    
    array_image = [[NSMutableArray alloc] init];
    [array_image addObject:[UIImage imageNamed:@"temp_lip.png"]];
    [array_image addObject:[UIImage imageNamed:@"temp_eyebrow.png"]];
    [array_image addObject:[UIImage imageNamed:@"temp_blush.png"]];
    [array_image addObject:[UIImage imageNamed:@"temp_eyeshadow.png"]];
    [array_image addObject:[UIImage imageNamed:@"temp_face_smooth.png"]];
    [array_image addObject:[UIImage imageNamed:@"temp_highlight.png"]];
   // [array_image addObject:[UIImage imageNamed:@"temp_eyeline.png"]];
    mem_array_image=[[NSMutableArray alloc] initWithArray:array_image];
    self.img_gallery.delegate = self;
    
    self.img_gallery.backgroundColor = [UIColor whiteColor];

    
    
    [self.complete_button setEnabled:true];
    [self.contour_button setEnabled:true];
    [self.retouch_button setEnabled:true];
    [self.effect_slider setHidden:true];
    [self.img_gallery setHidden:true];
    


    
    current_index=0;
    
    mem_index=-1;
    
    for (int i=0;i<10;i++){
        effect_parameters[i]=0;
    }
    //    effect_parameters[EFFECT_CONTOUR]=0.8;

  //  self.effect_slider.center.x=self.view.bounds.size.width/2;
    CGAffineTransform transform=CGAffineTransformMakeRotation(-M_PI_2);
    CGAffineTransform kl=CGAffineTransformTranslate(transform,0,self.view.bounds.size.width*2/5);
    self.effect_slider.transform =  kl;
    //)transform,self.view.bounds.size.width/2);

    beautifyFilter=[[GPUImageBeautifyFilter alloc] init];
    
    AppDelegate* appDelegate;
    appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    _select_Image=appDelegate.mem_image;

  
    
    cv::Mat mat=[self cvMatFromUIImage:_select_Image];
    
    
    image_detection_Enable =[self processImage:mat returnInfo:face_info];
    
    smooth_image=mat.clone();
    UIImage *res=[self UIImageFromCVMat:mat];
    self.imageView.image=res;
    if(image_detection_Enable==NO){
        
        [self.complete_button setEnabled:false];
        [self.contour_button setEnabled:false];
        [self.retouch_button setEnabled:false];
        //[self.img_gallery setHidden:false];
        //[self.effect_slider setHidden:true];
        
        [self AlertText:mat];
    }else
        
   self.imageView.image=appDelegate.mem_image;
    
}


- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}
- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

cv::Mat maskBlur(cv::Mat image, cv::Mat mask){
    cv::Mat res;
    image.convertTo(image,CV_32FC3,1.0/255.0);
    
    cv::Mat mask_1;
    cvtColor(mask, mask_1, CV_BGR2GRAY);
    mask_1.convertTo(mask_1,CV_32FC1,1.0/255.0);
    
    // cv::GaussianBlur(mask_1,mask_1,cv::Size(11,11),5.0);
    
    std::vector<cv::Mat> ch_img(3);
    std::vector<cv::Mat> ch_bg(3);
    
    cv::Mat bg=cv::Mat(image.size(),CV_32FC3);
    bg=cv::Scalar(1.0,1.0,1.0);
    cv::split(image,ch_img);
    cv::split(bg,ch_bg);
    ch_img[0]=ch_img[0].mul(mask_1)+ch_bg[0].mul(1.0-mask_1);
    ch_img[1]=ch_img[1].mul(mask_1)+ch_bg[1].mul(1.0-mask_1);
    ch_img[2]=ch_img[2].mul(mask_1)+ch_bg[2].mul(1.0-mask_1);
    cv::merge(ch_img,res);
    cv::merge(ch_bg,bg);
    //res.convertTo(res,CV_32F,255.0);
    return res;
}
cv::Rect getBounds(std::vector<cv::Point> vertexs){
    int left=vertexs[0].x;
    int top=vertexs[0].y;
    int bottom=vertexs[0].y;
    int right=vertexs[0].x;
    
    for (int i=0;i<vertexs.size();i++){
        
        left=std::min(left,vertexs[i].x);
        
        top=std::min(top,vertexs[i].y);
        
        right=std::max(right,vertexs[i].x);
        
        bottom=std::max(bottom,vertexs[i].y);
        
    }
    return cv::Rect(left,top,right-left,bottom-top);
}

cv::Mat mixImages(cv::Mat src,cv::Mat mask, cv::Scalar color,float alpa,int paint_type)
{
    cv::Mat res;
    
    cv::Mat dg = src.clone();//background Image
    
    res= dg.clone();
    cv::Scalar aver_color=cv::mean(src);
    //cv::Scalar mem_color;
   
    for (int x = 0; x < dg.cols; x++)
    {
        for (int y = 0; y < dg.rows; y++)
            {
                
            int R = cv::saturate_cast<uchar>((dg.at<cv::Vec3b>(y, x)[0]));
            int G = cv::saturate_cast<uchar>((dg.at<cv::Vec3b>(y, x)[1]));
            int B = cv::saturate_cast<uchar>((dg.at<cv::Vec3b>(y, x)[2]));
            int mR = cv::saturate_cast<uchar>((mask.at<cv::Vec3b>(y, x)[0]));
            int RR=0;
            int GG=0;
            int BB=0;
            float rf= mR/255.0;
            float rt=alpa;
            rt=(rt-1)*rf+1;
            if(paint_type==MIXEDCOLOR_ADDCOLOR)
            {
            if(R>=0)RR = (R*rt + color.val[0]*(1-rt));
            if(G>=0)GG = (G*rt + color.val[1]*(1-rt));
            if(B>=0)BB = (B*rt + color.val[2]*(1-rt));
            
            }
            else{
                
                 float a=(R+G+B)/3.0;
                 float k=a*(1.0+rt*0.8*exp(-a/25.5));
                 rt=0.6*rt;
                
                RR=k*rt+R*(1.0-rt);
                GG=k*rt+G*(1.0-rt);
                BB=k*rt+B*(1.0-rt);

                
            }
            if (RR<0)RR=0;if(RR>255)RR=255;
            if (GG<0)GG=0;if(GG>255)GG=255;
            if (BB<0)BB=0;if(BB>255)BB=255;
            
            res.at<cv::Vec3b>(y, x)[0] = RR;
            res.at<cv::Vec3b>(y, x)[1] = GG;
            res.at<cv::Vec3b>(y, x)[2] = BB;
            
            
        }
    }
    return res;
}
float distance(cv::Point  p1, cv::Point p2){
    float res=0;
    float x2=p2.x;
    float x1=p1.x;
    float y2=p2.y;
    float y1=p1.y;
    float dx=x2-x1;
    float dy=y2-y1;
    res= sqrt(dx*dx + dy*dy);
    return res;
}

cv::Point xcPoint(int index,int rows,cv::Mat_<double> shape){
    cv::Point res((int)shape.at<double>(index), (int)shape.at<double>(index +rows));
    return res;
}
cv::Point divPoint(cv::Point p1,cv::Point p2,float div){
    cv::Point res;
    res.x=p1.x+(p2.x-p1.x)/div;
    res.y=p1.y+(p2.y-p1.y)/div;
    return res;
}
void polygonImageToImage(cv::Mat &background,std::vector<cv::Point>vertexs){
    
    
}
void polygonAddSmoothImage(cv::Mat &backGround, std::vector<cv::Point> vertexs, cv::Scalar overlayColor,int blur_fact,int blur_f1,float alpha,int paint_type,float Rx,float Ry){
    
    cv::Rect lip_rect=getBounds(vertexs);
    
    float dy=lip_rect.height*Ry;
    
    float dx=lip_rect.width*Rx;
    
    float bx=dx;
    
    float by=dy;
    
       
    lip_rect=cv::Rect(lip_rect.x-dx,lip_rect.y-dy,lip_rect.width+dx+bx,lip_rect.height+dy+by);
    //cv::rectangle(backGround,lip_rect, cv::Scalar(0,0,255));
 
    if (lip_rect.x-dx<0)
        lip_rect.x=0;
    if (lip_rect.y-dy<0)
        lip_rect.y=0;
    if(lip_rect.width+dx+bx>backGround.cols)
        lip_rect.width=backGround.cols-dx;
    if(lip_rect.height+dy+by>backGround.rows)
        lip_rect.height=backGround.rows-dy;
    cv::Mat src_Mask(backGround.rows,backGround.cols, CV_8UC3, cv::Scalar(0,0,0));
    
    std::vector<std::vector<cv::Point> > fillContAll;
    
    fillContAll.push_back(vertexs);
    
    cv::fillPoly( src_Mask, fillContAll,  cv::Scalar( 255, 255, 255));
    
    cv::Mat small_lip;
    cv::Mat small_mask= src_Mask(lip_rect);
    cv::Mat src=backGround(lip_rect);

    
    cv::GaussianBlur(small_mask,small_mask,cv::Size(blur_fact,blur_fact),blur_f1);
    small_lip=mixImages(src,small_mask,overlayColor,alpha,paint_type);
    
    //
    cv::Mat dstROI=backGround(lip_rect);
    
    small_lip.copyTo(dstROI);
}
void contourCheek(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,int rows,float alpa){
    std::vector<cv::Point>makeEdge;
    float dis_1=distance(xcPoint(0,rows,shape),xcPoint(16,rows,shape));
    int kk=int(dis_1*0.2);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    
    std::vector<cv::Point>makeEdge_right;
    
    cv::Point p1=divPoint(xcPoint(14,rows,shape),xcPoint(15,rows,shape),2);
    cv::Point p2=divPoint(xcPoint(45,rows,shape),xcPoint(12,rows,shape),1.8);
    cv::Point p3=divPoint(xcPoint(46,rows,shape),xcPoint(11,rows,shape),1.5);
    cv::Point p4=xcPoint(10,rows,shape);
    cv::Point p5=xcPoint(11,rows,shape);
    cv::Point p6=xcPoint(12,rows,shape);
    cv::Point p7=xcPoint(13,rows,shape);
    cv::Point p8=xcPoint(14,rows,shape);

    makeEdge_right.push_back(p1);
    makeEdge_right.push_back(p2);
    makeEdge_right.push_back(p3);
    makeEdge_right.push_back(p4);
    makeEdge_right.push_back(p5);
    makeEdge_right.push_back(p6);
    makeEdge_right.push_back(p7);
    makeEdge_right.push_back(p8);
    
    MySpline *spline1=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_right.size();i++){
        [spline1 addPointWithX:makeEdge_right[i].x Y:makeEdge_right[i].y];
        // cv::circle(backGround, makeEdge_right[i],2,cv::Scalar(255,0,0));
    }
    std::vector<cv::Point>sline_1= [spline1 getSplinePoints];
    polygonAddSmoothImage(backGround, sline_1, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.3,0.1);
     std::vector<cv::Point>makeEdge_left;
    cv::Point q1=divPoint(xcPoint(2,rows,shape),xcPoint(1,rows,shape),2);
    cv::Point q2=divPoint(xcPoint(36,rows,shape),xcPoint(4,rows,shape),1.8);
    cv::Point q3=divPoint(xcPoint(41,rows,shape),xcPoint(5,rows,shape),1.5);
    cv::Point q4=xcPoint(6,rows,shape);
    cv::Point q5=xcPoint(5,rows,shape);
    cv::Point q6=xcPoint(4,rows,shape);
    cv::Point q7=xcPoint(3,rows,shape);
    cv::Point q8=xcPoint(2,rows,shape);
    makeEdge_left.push_back(q1);
    makeEdge_left.push_back(q2);
    makeEdge_left.push_back(q3);
    makeEdge_left.push_back(q4);
    makeEdge_left.push_back(q5);
    makeEdge_left.push_back(q6);
    makeEdge_left.push_back(q7);
    makeEdge_left.push_back(q8);
    MySpline *spline2=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_left.size();i++){
        [spline2 addPointWithX:makeEdge_left[i].x Y:makeEdge_left[i].y];
    }
    std::vector<cv::Point>sline_2= [spline2 getSplinePoints];

    polygonAddSmoothImage(backGround, sline_2, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.3,0.1);

    
}
void MakeBlush(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,int rows,float alpa){
    
    std::vector<cv::Point>makeEdge;
    float dis_1=distance(xcPoint(0,rows,shape),xcPoint(16,rows,shape));
    int kk=int(dis_1*0.1);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    std::vector<cv::Point>makeEdge_right;
    cv::Point p1=divPoint(xcPoint(14,rows,shape),xcPoint(15,rows,shape),2);
    cv::Point p2=divPoint(xcPoint(45,rows,shape),xcPoint(12,rows,shape),4);
    cv::Point p3=divPoint(xcPoint(47,rows,shape),xcPoint(10,rows,shape),3);
    cv::Point p4=divPoint(p3,xcPoint(11,rows,shape),2);
    cv::Point p5=divPoint(p4,xcPoint(12,rows,shape),2);
    cv::Point p6=xcPoint(13,rows,shape);
    cv::Point p7=xcPoint(14,rows,shape);

    makeEdge_right.push_back(p1);
    makeEdge_right.push_back(p2);
    makeEdge_right.push_back(p3);
    makeEdge_right.push_back(p4);
    makeEdge_right.push_back(p5);
    makeEdge_right.push_back(p6);
    makeEdge_right.push_back(p7);
    
    MySpline *spline1=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_right.size();i++){
        [spline1 addPointWithX:makeEdge_right[i].x Y:makeEdge_right[i].y];
            }
    std::vector<cv::Point>sline_1= [spline1 getSplinePoints];

    
    std::vector<cv::Point>makeEdge_left;
    cv::Point q1=divPoint(xcPoint(2,rows,shape),xcPoint(1,rows,shape),2);
    cv::Point q2=divPoint(xcPoint(36,rows,shape),xcPoint(3,rows,shape),4);
    cv::Point q3=divPoint(xcPoint(40,rows,shape),xcPoint(6,rows,shape),3);
    cv::Point q4=divPoint(q3,xcPoint(5,rows,shape),2);
    cv::Point q5=divPoint(q4,xcPoint(4,rows,shape),2);
    cv::Point q6=xcPoint(3,rows,shape);
    cv::Point q7=xcPoint(2,rows,shape);
    makeEdge_left.push_back(q1);
    makeEdge_left.push_back(q2);
    makeEdge_left.push_back(q3);
    makeEdge_left.push_back(q4);
    makeEdge_left.push_back(q5);
    makeEdge_left.push_back(q6);
    makeEdge_left.push_back(q7);
    MySpline *spline2=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_left.size();i++){
        [spline2 addPointWithX:makeEdge_left[i].x Y:makeEdge_left[i].y];
    }
    std::vector<cv::Point>sline_2= [spline2 getSplinePoints];

  
    polygonAddSmoothImage(backGround, sline_1, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.1,0.1);
    polygonAddSmoothImage(backGround, sline_2, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.1,0.1);
    
}
void highLightDownEyes(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,int rows,float alpa){
    std::vector<cv::Point>makeEdge_right;
    float dis_1=distance(xcPoint(42,rows,shape),xcPoint(45,rows,shape));
    cv::Point p1=divPoint(xcPoint(16,rows,shape),xcPoint(45,rows,shape),3);
    cv::Point p2=xcPoint(45,rows,shape)+cv::Point(0,dis_1/3);
    cv::Point p3=xcPoint(46,rows,shape)+cv::Point(0,dis_1/3);
    cv::Point p4=xcPoint(47,rows,shape)+cv::Point(0,dis_1/3);
    cv::Point p5=xcPoint(42,rows,shape)+cv::Point(0,dis_1/3);
    
    cv::Point p6= divPoint(xcPoint(35,rows,shape),xcPoint(12,rows,shape),3);
    cv::Point p7= divPoint(xcPoint(46,rows,shape),xcPoint(12,rows,shape),2);
    
    makeEdge_right.push_back(p1);
    makeEdge_right.push_back(p2);
    makeEdge_right.push_back(p3);
    makeEdge_right.push_back(p4);
    makeEdge_right.push_back(p5);
    makeEdge_right.push_back(p6);
    makeEdge_right.push_back(p7);
    
    MySpline *spline1=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_right.size();i++){
        [spline1 addPointWithX:makeEdge_right[i].x Y:makeEdge_right[i].y];
      //  cv::circle(backGround,makeEdge_right[i],2, cv::Scalar(255,0,0));
    }
    std::vector<cv::Point>sline_1= [spline1 getSplinePoints];
    int kk=int(dis_1*0.8);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    polygonAddSmoothImage(backGround, sline_1, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.3,0.2);
    
    
    std::vector<cv::Point>makeEdge_left;
    cv::Point u1=divPoint(xcPoint(0,rows,shape),xcPoint(36,rows,shape),3);
    cv::Point u2=xcPoint(36,rows,shape)+cv::Point(0,dis_1/3);
    cv::Point u3=xcPoint(41,rows,shape)+cv::Point(0,dis_1/3);
    cv::Point u4=xcPoint(40,rows,shape)+cv::Point(0,dis_1/3);
    cv::Point u5=xcPoint(39,rows,shape)+cv::Point(0,dis_1/3);
    
    cv::Point u6= divPoint(xcPoint(31,rows,shape),xcPoint(4,rows,shape),3);
    cv::Point u7= divPoint(xcPoint(41,rows,shape),xcPoint(4,rows,shape),2);
    
    makeEdge_left.push_back(u1);
    makeEdge_left.push_back(u2);
    makeEdge_left.push_back(u3);
    makeEdge_left.push_back(u4);
    makeEdge_left.push_back(u5);
    makeEdge_left.push_back(u6);
    makeEdge_left.push_back(u7);
    
    MySpline *spline2=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_left.size();i++){
        [spline2 addPointWithX:makeEdge_left[i].x Y:makeEdge_left[i].y];
       // cv::circle(backGround,makeEdge_left[i],2, cv::Scalar(255,0,0));
    }
    std::vector<cv::Point>sline_2= [spline2 getSplinePoints];

    polygonAddSmoothImage(backGround, sline_2, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.3,0.2);

}
void highLightUpLip(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,int rows,float alpa){
    std::vector<cv::Point>makeEdge_right;
    float dis_1=distance(xcPoint(33,rows,shape),xcPoint(51,rows,shape));
    
    cv::Point p1=divPoint(xcPoint(33,rows,shape),xcPoint(51,rows,shape),2);
    
    
    cv::Point p2=divPoint(xcPoint(50,rows,shape),xcPoint(32,rows,shape),2);
    cv::Point p3=divPoint(xcPoint(49,rows,shape),xcPoint(31,rows,shape),4);
    cv::Point p4=xcPoint(48,rows,shape)-cv::Point(0,dis_1/6);
    cv::Point p5=xcPoint(49,rows,shape)-cv::Point(0,dis_1/6);
    cv::Point p6=xcPoint(50,rows,shape)-cv::Point(0,dis_1/6);
    cv::Point p7=xcPoint(51,rows,shape)-cv::Point(0,dis_1/6);
    cv::Point p8=xcPoint(52,rows,shape)-cv::Point(0,dis_1/6);
    
    cv::Point p9=xcPoint(53,rows,shape)-cv::Point(0,dis_1/6);
    cv::Point p10=xcPoint(54,rows,shape)-cv::Point(0,dis_1/6);
    
    cv::Point p11=divPoint(xcPoint(53,rows,shape),xcPoint(35,rows,shape),4);
    cv::Point p12=divPoint(xcPoint(52,rows,shape),xcPoint(34,rows,shape),2);
    
    makeEdge_right.push_back(p1);
    makeEdge_right.push_back(p2);
    makeEdge_right.push_back(p3);
    makeEdge_right.push_back(p4);
    makeEdge_right.push_back(p5);
    makeEdge_right.push_back(p6);
    makeEdge_right.push_back(p7);
    makeEdge_right.push_back(p8);
    makeEdge_right.push_back(p9);
    makeEdge_right.push_back(p10);
    makeEdge_right.push_back(p11);
    makeEdge_right.push_back(p12);
    
    MySpline *spline1=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_right.size();i++){
        [spline1 addPointWithX:makeEdge_right[i].x Y:makeEdge_right[i].y];
       // cv::circle(backGround,makeEdge_right[i],2, cv::Scalar(255,0,0));
    }
    std::vector<cv::Point>sline_1= [spline1 getSplinePoints];
    int kk=int(dis_1*0.5);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    polygonAddSmoothImage(backGround, sline_1, color,kk,kk/2,alpa*1.2,MIXEDCOLOR_ADDCOLOR,0.3,0.5);
}
void highLightDownLip(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,int rows,float alpa){
    std::vector<cv::Point>makeEdge_right;
    float dis_1=distance(xcPoint(57,rows,shape),xcPoint(8,rows,shape));
    
    cv::Point p1=divPoint(xcPoint(57,rows,shape),xcPoint(8,rows,shape),5);
    
    
    cv::Point p2=divPoint(xcPoint(6,rows,shape),xcPoint(58,rows,shape),3);
    cv::Point p3=divPoint(xcPoint(7,rows,shape),xcPoint(58,rows,shape),6);
    cv::Point p4=divPoint(xcPoint(8,rows,shape),xcPoint(57,rows,shape),6);
    cv::Point p5=divPoint(xcPoint(9,rows,shape),xcPoint(56,rows,shape),6);
    cv::Point p6=divPoint(xcPoint(10,rows,shape),xcPoint(56,rows,shape),3);
    
    makeEdge_right.push_back(p1);
    makeEdge_right.push_back(p2);
    makeEdge_right.push_back(p3);
    makeEdge_right.push_back(p4);
    makeEdge_right.push_back(p5);
    makeEdge_right.push_back(p6);
    
    MySpline *spline1=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_right.size();i++){
        [spline1 addPointWithX:makeEdge_right[i].x Y:makeEdge_right[i].y];
        //cv::circle(backGround,makeEdge_right[i],2, cv::Scalar(255,0,0));
    }
    std::vector<cv::Point>sline_1= [spline1 getSplinePoints];
    int kk=int(dis_1*0.5);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    polygonAddSmoothImage(backGround, sline_1, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.8,0.5);

}
void highLightJawline(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,int rows,float alpa){
    
    std::vector<cv::Point>makeEdge_right;
    float dis_1=distance(xcPoint(57,rows,shape),xcPoint(8,rows,shape));
    
    cv::Point p1=xcPoint(13,rows,shape);
    cv::Point p2=xcPoint(12,rows,shape);
    cv::Point p3=xcPoint(11,rows,shape);
    cv::Point p4=xcPoint(10,rows,shape);
    cv::Point p5=divPoint(xcPoint(10,rows,shape),xcPoint(26,rows,shape),15);

    
    makeEdge_right.push_back(p1);
    makeEdge_right.push_back(p2);
    makeEdge_right.push_back(p3);
    makeEdge_right.push_back(p4);
    makeEdge_right.push_back(p5);
    
    MySpline *spline1=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_right.size();i++){
        [spline1 addPointWithX:makeEdge_right[i].x Y:makeEdge_right[i].y];
       // cv::circle(backGround,makeEdge_right[i],2, cv::Scalar(255,0,0));
    }
    std::vector<cv::Point>sline_1= [spline1 getSplinePoints];
    int kk=int(dis_1*0.5);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    polygonAddSmoothImage(backGround, sline_1, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.3,0.5);
    
    std::vector<cv::Point>makeEdge_left;
   
    cv::Point q1=xcPoint(3,rows,shape);
    cv::Point q2=xcPoint(4,rows,shape);
    cv::Point q3=xcPoint(5,rows,shape);
    cv::Point q4=xcPoint(6,rows,shape);
    cv::Point q5=divPoint(xcPoint(6,rows,shape),xcPoint(17,rows,shape),15);
    
    
    makeEdge_left.push_back(q1);
    makeEdge_left.push_back(q2);
    makeEdge_left.push_back(q3);
    makeEdge_left.push_back(q4);
    makeEdge_left.push_back(q5);
    
    MySpline *spline2=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_left.size();i++){
        [spline2 addPointWithX:makeEdge_left[i].x Y:makeEdge_left[i].y];
    }
    std::vector<cv::Point>sline_2= [spline2 getSplinePoints];
    kk=int(dis_1*0.5);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    polygonAddSmoothImage(backGround, sline_2, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.3,0.5);
    
}
void highLightForheadAndNose(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,int rows,float alpa){
    
    /*********************************************
     
     Highlighting for forehead and nose
     
     *********************************************/
    float dis_1=distance(xcPoint(31,rows,shape),xcPoint(35,rows,shape));
    int kk=int(dis_1*0.8);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    
    
    std::vector<cv::Point>makeEdge_right;
    cv::Point p1=xcPoint(22,rows,shape);
    cv::Point p2=xcPoint(23,rows,shape);
    cv::Point p3=xcPoint(24,rows,shape);
    cv::Point p4=xcPoint(25,rows,shape);
    cv::Point p5=xcPoint(26,rows,shape);
    
    cv::Point p6= xcPoint(24,rows,shape)-(xcPoint(44,rows,shape)-xcPoint(24,rows,shape));
    cv::Point p7= xcPoint(27,rows,shape)-(xcPoint(33,rows,shape)-xcPoint(27,rows,shape));
    
    cv::Point p13=xcPoint(21,rows,shape);
    cv::Point p12=xcPoint(20,rows,shape);
    cv::Point p11=xcPoint(19,rows,shape);
    cv::Point p10=xcPoint(18,rows,shape);
    cv::Point p9=xcPoint(17,rows,shape);
    cv::Point p8= xcPoint(19,rows,shape)-(xcPoint(37,rows,shape)-xcPoint(19,rows,shape));
    
    cv::Point p14=divPoint(xcPoint(27,rows,shape),xcPoint(39,rows,shape),3);
    cv::Point p15=divPoint(xcPoint(30,rows,shape),xcPoint(31,rows,shape),3);
    cv::Point p16=divPoint(xcPoint(30,rows,shape),xcPoint(35,rows,shape),3);
    cv::Point p17=divPoint(xcPoint(27,rows,shape),xcPoint(42,rows,shape),3);
    
    
    makeEdge_right.push_back(p1);
    makeEdge_right.push_back(p2);
    makeEdge_right.push_back(p3);
    makeEdge_right.push_back(p4);
    //makeEdge_right.push_back(p5);
    makeEdge_right.push_back(p6);
    makeEdge_right.push_back(p7);
    makeEdge_right.push_back(p8);
    //makeEdge_right.push_back(p9);
    makeEdge_right.push_back(p10);
    makeEdge_right.push_back(p11);
    makeEdge_right.push_back(p12);
    makeEdge_right.push_back(p13);
    makeEdge_right.push_back(p14);
    makeEdge_right.push_back(p15);
    makeEdge_right.push_back(p16);
    makeEdge_right.push_back(p17);
    
    MySpline *spline1=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge_right.size();i++){
        [spline1 addPointWithX:makeEdge_right[i].x Y:makeEdge_right[i].y];
    }
    std::vector<cv::Point>sline_1= [spline1 getSplinePoints];
    polygonAddSmoothImage(backGround, sline_1, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.1,0.2);
    
    
    
    
   }
void contouringNose(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,int rows,float alpa){
    
    alpa=0.8+(1.0-(1-(alpa-0.4)/0.6))*0.2;
    std::vector<cv::Point>makeEdge1;
    cv::Point u1=divPoint(xcPoint(27,rows,shape),xcPoint(39,rows,shape),3);
    cv::Point u2=divPoint(xcPoint(29,rows,shape),xcPoint(39,rows,shape),3);
    cv::Point u3=divPoint(xcPoint(31,rows,shape),xcPoint(39,rows,shape),4);
    cv::Point u4=divPoint(u3,u1,2);
    cv::Point u5=divPoint(xcPoint(39,rows,shape),xcPoint(27,rows,shape),5);
    makeEdge1.push_back(u1);
    makeEdge1.push_back(u2);
    makeEdge1.push_back(u3);
    makeEdge1.push_back(u4);
    makeEdge1.push_back(u5);
    
    MySpline *spline2=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge1.size();i++){
        [spline2 addPointWithX:makeEdge1[i].x Y:makeEdge1[i].y];
       // cv::circle(backGround, makeEdge1[i],2,cv::Scalar(255,0,0));
    }
    
    
    float dis_2=distance(xcPoint(31,rows,shape),xcPoint(30,rows,shape));
    int kk=int(dis_2*0.9);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    std::vector<cv::Point>sline_2= [spline2 getSplinePoints];
    polygonAddSmoothImage(backGround, sline_2, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.8,0.2);
    
    
    std::vector<cv::Point>makeEdge2;
    cv::Point n1=divPoint(xcPoint(27,rows,shape),xcPoint(42,rows,shape),3);;
    cv::Point n2=divPoint(xcPoint(29,rows,shape),xcPoint(42,rows,shape),3);;
    cv::Point n3=divPoint(xcPoint(35,rows,shape),xcPoint(42,rows,shape),4);
    cv::Point n4=divPoint(n3,n1,2);
    cv::Point n5=divPoint(xcPoint(42,rows,shape),xcPoint(27,rows,shape),2);;
    makeEdge2.push_back(n1);
    makeEdge2.push_back(n2);
    makeEdge2.push_back(n3);
    makeEdge2.push_back(n4);
    makeEdge2.push_back(n5);
    
    
    MySpline *spline12=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<makeEdge2.size();i++){
        [spline12 addPointWithX:makeEdge2[i].x Y:makeEdge2[i].y];
        
    }
    
    
    float dis_12=distance(xcPoint(31,rows,shape),xcPoint(30,rows,shape));
    kk=int(dis_12*0.9);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    std::vector<cv::Point>sline_12= [spline12 getSplinePoints];
    polygonAddSmoothImage(backGround, sline_12, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.8,0.2);


}
void MakeHighlight(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,int rows,float alpa){
    
    highLightDownLip(backGround,  shape, color, rows, alpa);
    highLightDownEyes(backGround,  shape, color, rows, alpa);
    highLightUpLip(backGround,  shape, color, rows, alpa);
    highLightJawline(backGround,  shape, color, rows, alpa);
    highLightForheadAndNose(backGround,  shape, color, rows, alpa);
    contouringNose(backGround,  shape, cv::Scalar(50,10,10), rows, alpa);
    contourCheek(backGround,  shape, cv::Scalar(50,10,10), rows, alpa);
    
}
void MakeEyeshadow(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,bool left_right,int rows,float alpa){
    std::vector<cv::Point>eyeMakeEdge;
    cv::Point u1;
    cv::Point u2;
    cv::Point u3;
    cv::Point u4;
    cv::Point p1;
    cv::Point p2;
    cv::Point p3;
    cv::Point p4;
    float dis_1=0;
    if (left_right==true){
        u1=xcPoint(17,rows,shape);
        u2=xcPoint(18,rows,shape);
        u3=xcPoint(19,rows,shape);
        u4=xcPoint(21,rows,shape);
        p1=xcPoint(36,rows,shape);
        p2=xcPoint(37,rows,shape);
        p3=xcPoint(38,rows,shape);
        p4=xcPoint(39,rows,shape);
        
    } else{
        u1=xcPoint(26,rows,shape);
        u2=xcPoint(25,rows,shape);
        u3=xcPoint(24,rows,shape);
        u4=xcPoint(22,rows,shape);
        p1=xcPoint(45,rows,shape);
        p2=xcPoint(44,rows,shape);
        p3=xcPoint(43,rows,shape);
        p4=xcPoint(42,rows,shape);
    }
    //Snow tail detection
    
    float rt=0.8;
    float nnx=p1.x-(p2.x-p1.x)*rt;
    float nny=p1.y-(p2.y-p1.y)*rt;
    p1=cv::Point(nnx,nny);
    rt=0.6;
    nnx=u1.x-(u2.x-u1.x)*rt;
    nny=u1.y-(u2.y-u1.y)*rt;
    u1=cv::Point(nnx,nny);
    
    dis_1=distance(u4,p4);
    
    eyeMakeEdge.push_back(p1-cv::Point(0,dis_1/5));
    eyeMakeEdge.push_back(p2-cv::Point(0,dis_1/5));
    eyeMakeEdge.push_back(p3-cv::Point(0,dis_1/8));
    eyeMakeEdge.push_back(p4-cv::Point(0,dis_1/5));
    eyeMakeEdge.push_back(divPoint(p4,u4,4));
    eyeMakeEdge.push_back(divPoint(p3,u3,3.8));
    eyeMakeEdge.push_back(divPoint(p2,u2,2.5));
    eyeMakeEdge.push_back(divPoint(p1,u1,1.5));
    
    MySpline *spline=[[MySpline alloc] init:4];
    for (unsigned long i=0;i<eyeMakeEdge.size();i++){
        [spline addPointWithX:eyeMakeEdge[i].x Y:eyeMakeEdge[i].y];
       // cv::circle(backGround, eyeMakeEdge[i],2,cv::Scalar(255,0,0));
    }
    std::vector<cv::Point>sline= [spline getSplinePoints];
    int kk=int(dis_1*0.4);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;

    polygonAddSmoothImage(backGround, sline, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.5,0.5);
    
    
}
void LipEnhancement(cv::Mat &backGround, std::vector<cv::Point> lipVertex, cv::Scalar lipOverlayColor,float dist,float alpa){
    
    int kk=int(dist*0.2);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;

    polygonAddSmoothImage(backGround, lipVertex, lipOverlayColor,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.1,0.1);
    
    
}
cv::Point normallPointOfLine(cv::Point p1,cv::Point p2,float dist){
    float dx=p2.x-p1.x;
    float dy=p2.y-p1.y;
    float D=sqrt(dx*dx+dy*dy);
    
    float yy=-dx*dist/D+p1.y;
    float xx=-dy*dist/D+p1.x;
    return cv::Point(xx,yy);
}
void drawEyeBrows(cv::Mat &backGround, cv::Mat_<double> shape, cv::Scalar color,bool left_right,int rows,float alpa){
    
    cv::Point u1;
    cv::Point u2;
    cv::Point u3;
    cv::Point u4;
    cv::Point u5;
    cv::Point p1;
    cv::Point p2;
    cv::Point p3;
    cv::Point p4;
    cv::Point p5;
    cv::Point ss;
    float dis_1=0;
    
    if (left_right==true){
        u1=xcPoint(17,rows,shape);
        u2=xcPoint(18,rows,shape);
        u3=xcPoint(19,rows,shape);
        u4=xcPoint(20,rows,shape);
        u5=xcPoint(21,rows,shape);
        ss=xcPoint(38,rows,shape);
 
        
    } else{
        u1=xcPoint(26,rows,shape);
        u2=xcPoint(25,rows,shape);
        u3=xcPoint(24,rows,shape);
        u4=xcPoint(23,rows,shape);
        u5=xcPoint(22,rows,shape);
        ss=xcPoint(43,rows,shape);
   
    }
    dis_1=distance(u4,ss)*0.5;
    u2.x=u1.x+(u5.x-u1.x)*1/3;
    p1=cv::Point(u1.x,u1.y+dis_1*0.2);
    p2=cv::Point(u2.x,u2.y+dis_1*0.3);
    p3=cv::Point(u3.x,u3.y+dis_1*0.4);
    p4=cv::Point(u4.x,u4.y+dis_1*0.5);
   // u5.y=u5.y+dis_1*0.5;
    u5.x=u4.x+(u5.x-u4.x)*3/5;
    p5=cv::Point(u5.x,u5.y+dis_1*0.6);
    
    std::vector<cv::Point>eyeMakeEdge;
    eyeMakeEdge.push_back(u1);
    eyeMakeEdge.push_back(u2);
    //eyeMakeEdge.push_back(u3);
    //eyeMakeEdge.push_back(u4);
    eyeMakeEdge.push_back(u5);
    eyeMakeEdge.push_back(p5);
    //eyeMakeEdge.push_back(p4);
    //eyeMakeEdge.push_back(p3);
    eyeMakeEdge.push_back(p2);
    eyeMakeEdge.push_back(p1);
    MySpline *spline=[[MySpline alloc] init:12];
    for (unsigned long i=0;i<eyeMakeEdge.size();i++){
        [spline addPointWithX:eyeMakeEdge[i].x Y:eyeMakeEdge[i].y];
        //cv::circle(backGround, eyeMakeEdge[i], 1, cv::Scalar(0,255,0));
    }
    std::vector<cv::Point>sline= [spline getSplinePoints];
    int kk=int(dis_1*0.3);
    if(kk%2==0)kk+=1;
    if(kk<4)kk=3;
    polygonAddSmoothImage(backGround, sline, color,kk,kk/2,alpa,MIXEDCOLOR_ADDCOLOR,0.2,0.2);
    
    
}

-(cv::Mat)processingFaceImage:(cv::Mat )captured_image addValue:(float*)param {
    
    cv::Mat back_image=captured_image.clone();
    cv::Mat_<double> shape2D=face_info;
    int n = shape2D.rows/2;
    
    // Drawing feature points
    
    MySpline *spline_jaw=[[MySpline alloc] init:14];
    MySpline *spline_eyebrow1=[[MySpline alloc] init:2];
    MySpline *spline_eyebrow2=[[MySpline alloc] init:2];
    MySpline *spline_lip1=[[MySpline alloc] init:21];
    MySpline *spline_lip2=[[MySpline alloc] init:21];
    NSMutableArray *noseLine=[[NSMutableArray alloc] init];
    int x = 0;
    int y = 0;
    if(n >= 66)
    {
        for( int i = 0; i < n; ++i)
        {
            
            
            
            if(visibilities.at<int>(i)){
                cv::Point featurePoint((int)shape2D.at<double>(i), (int)shape2D.at<double>(i +n));
              //  double fontScale = 0.5;
              //  int thickness = 1;
              //  std::string text =  std::to_string(i);
                
                //cv::putText(captured_image, text, xcPoint(i,n, shape2D), CV_FONT_HERSHEY_PLAIN, fontScale, cv::Scalar(0,0,255), thickness,8);
                //cv::circle(captured_image, xcPoint(i,n, shape2D), 1, cv::Scalar(0,255,0));
                if (i<17){
                    [spline_jaw addPointWithX:featurePoint.x Y:featurePoint.y];
                }else if(i<22){
                    [spline_eyebrow1 addPointWithX:featurePoint.x Y:featurePoint.y];
                }else if(i<27){
                    [spline_eyebrow2 addPointWithX:featurePoint.x Y:featurePoint.y];
                }else if(i<36){
                    CGPoint p1=CGPointMake(featurePoint.x,featurePoint.y);
                    [noseLine addObject:[NSValue valueWithCGPoint:p1]];
                }else if(i<42){
                    // [spline_eye1 addPointWithX:featurePoint.x Y:featurePoint.y];
                    //  if(i==36){x=featurePoint.x;y=featurePoint.y;}
                    //  if(i==41)[spline_eye1 addPointWithX:x Y:y];
                }else if(i<48){
                    // [spline_eye2 addPointWithX:featurePoint.x Y:featurePoint.y];
                    // if(i==42){x=featurePoint.x;y=featurePoint.y;}
                    // if(i==47)[spline_eye2 addPointWithX:x Y:y];
                }else if(i<55){
                    
                    [spline_lip1 addPointWithX:featurePoint.x Y:featurePoint.y];
                    if(i==48){x=featurePoint.x;y=featurePoint.y;}
                    if(i==54){
                        
                        cv::Point f60((int)shape2D.at<double>(60), (int)shape2D.at<double>(60 +n));
                        cv::Point f61((int)shape2D.at<double>(61), (int)shape2D.at<double>(61 +n));
                        cv::Point f62((int)shape2D.at<double>(62), (int)shape2D.at<double>(62 +n));
                        cv::Point f63((int)shape2D.at<double>(63), (int)shape2D.at<double>(63 +n));
                        cv::Point f64((int)shape2D.at<double>(64), (int)shape2D.at<double>(64 +n));
                        
                        [spline_lip1 addPointWithX:f64.x Y:f64.y];
                        [spline_lip1 addPointWithX:f63.x Y:f63.y];
                        [spline_lip1 addPointWithX:f62.x Y:f62.y];
                        [spline_lip1 addPointWithX:f61.x Y:f61.y];
                        [spline_lip1 addPointWithX:f60.x Y:f60.y];
                        [spline_lip1 addPointWithX:x Y:y];
                    }
                }else  if(i<60){
                    
                    if(i==55){
                        
                        cv::Point f54((int)shape2D.at<double>(54), (int)shape2D.at<double>(54 +n));
                        [spline_lip2 addPointWithX:f54.x Y:f54.y];
                        x=f54.x;y=f54.y;
                    }
                    [spline_lip2 addPointWithX:featurePoint.x Y:featurePoint.y+3];
                    if(i==59){
                        cv::Point f48((int)shape2D.at<double>(48), (int)shape2D.at<double>(48 +n));
                        
                        cv::Point f66((int)shape2D.at<double>(66), (int)shape2D.at<double>(66 +n));
                        cv::Point f67((int)shape2D.at<double>(67), (int)shape2D.at<double>(67 +n));
                        cv::Point f65((int)shape2D.at<double>(65), (int)shape2D.at<double>(65 +n));
                        [spline_lip2 addPointWithX:f48.x Y:f48.y];
                        [spline_lip2 addPointWithX:f67.x Y:f67.y];
                        [spline_lip2 addPointWithX:f66.x Y:f66.y];
                        [spline_lip2 addPointWithX:f65.x Y:f65.y];
                        [spline_lip2 addPointWithX:x Y:y];
                    }
                    
                }
                
            }
           
        }
        
        
    }
    
    std::vector<cv::Point>jawline= [spline_jaw getSplinePoints];
    for (int i=0;i<jawline.size();i++){
       // cv::circle(back_image, jawline[i], 0.2, cv::Scalar(0,255,0));
    }
    
    std::vector<cv::Point>eyebrow1= [spline_lip1 getSplinePoints];
    for (int i=0;i<eyebrow1.size();i++){
        
       // cv::circle(back_image, eyebrow1[i], 4, cv::Scalar(0,255,0));
    }
    std::vector<cv::Point>eyebrow2= [spline_lip2 getSplinePoints];
    for (int i=0;i<eyebrow2.size();i++){
      
       // cv::circle(back_image, eyebrow2[i], 4, cv::Scalar(0,255,0));
    }
    /* */
    
    
    //******Highlight effect
    float h=0.4+(1-param[EFFECT_HIGHLIGHT])*0.6;
    MakeHighlight(back_image,shape2D,cv::Scalar(250,250,250),n,h);

   
   // back_image=back_image*0.88;
    float b=0.5+(1-param[EFFECT_EYEBROWS])*0.5;
    drawEyeBrows(back_image,shape2D,cv::Scalar(21,5,5),true,n,b);
    drawEyeBrows(back_image,shape2D,cv::Scalar(21,5,5),false,n,b);
    
    
    //*******************EyeShadow*******************
    float s=0.1+(1-param[EFFECT_EYESHADOW])*0.9;
    
    MakeEyeshadow(back_image,shape2D,cv::Scalar(14,12,10),true,n,s);
    MakeEyeshadow(back_image,shape2D,cv::Scalar(14,12,10),false,n,s);
    
  

    
    //*******Blush effect
    float q=0.7+(1-param[EFFECT_BLUSH])*0.3;
    MakeBlush(back_image,shape2D,cv::Scalar(250,120,120),n,q);
    
    
  
    
    //*******Lip enhancemend
    float f=0.6+(1-param[EFFECT_LIP])*0.4;
    
    cv::Point f51((int)shape2D.at<double>(51), (int)shape2D.at<double>(51 +n));
    cv::Point f57((int)shape2D.at<double>(57), (int)shape2D.at<double>(57 +n));
    
    //***********************
    float dist=distance(f51,f57);
    std::vector<cv::Point>lip1= [spline_lip1 getSplinePoints];
    LipEnhancement(back_image,lip1,cv::Scalar(196,36,80),dist,f);
    
    std::vector<cv::Point>lip2= [spline_lip2 getSplinePoints];
    LipEnhancement(back_image,lip2,cv::Scalar(196,36,80),dist,f);
    



    return back_image;
    
    
}

-(cv::Mat)addSmoothEffect:(cv::Mat) faceImage addFact:(GLfloat)v{
   
    
    [beautifyFilter SetValueWithFilter:v];
    
    
    UIImage *r=[self UIImageFromCVMat:faceImage];
    
    GPUImagePicture *imagePicture = [[GPUImagePicture alloc] initWithImage:r];
    
    //[beautifyFilter setInte]
    [imagePicture addTarget:beautifyFilter];
    
    [beautifyFilter useNextFrameForImageCapture];
    
    [imagePicture processImage];
    
    UIImage *result = [beautifyFilter imageFromCurrentFramebuffer];
    
    [imagePicture removeOutputFramebuffer];
   
    return [self cvMatFromUIImage:result];
    
}

- (IBAction)autoRetouchButtonPressed:(id)sender
{
   
     if(image_detection_Enable==YES){
         
        [self.img_gallery setHidden:true];
        [self.effect_slider setHidden:true];
        cv::Mat temp=target_image.clone();
         
         effect_parameters[EFFECT_LIP]=0.8f;
         effect_parameters[EFFECT_EYEBROWS]=0.8f;
         effect_parameters[EFFECT_BLUSH]=0.7f;
         effect_parameters[EFFECT_SKINBLUR]=0.7f;
         effect_parameters[EFFECT_EYESHADOW]=1.0f;    
         effect_parameters[EFFECT_HIGHLIGHT]=0.5f;
         cv::Mat ires=[self addSmoothEffect:temp addFact:effect_parameters[EFFECT_SKINBLUR]*0.8];
         
         cv::cvtColor(ires, smooth_image, cv::COLOR_BGRA2BGR);
   
         cv::Mat rr=[ self processingFaceImage:smooth_image addValue:effect_parameters];
       UIImage *r=[self UIImageFromCVMat:rr];
       self.imageView.image=r;
       [self.effect_slider setHidden:true];
     }else  [self AlertText:target_image];
   
}
- (IBAction)comtour_face_down:(id)sender {
    
    [self.img_gallery setHidden:true];
   // [self.effect_slider setHidden:false];
    current_index=EFFECT_HIGHLIGHT;
    effect_parameters[EFFECT_HIGHLIGHT]=0.6f;
    [self.effect_slider setValue:effect_parameters[EFFECT_HIGHLIGHT]];
    
    cv::Mat temp= [self processingFaceImage:smooth_image addValue:effect_parameters];
    UIImage *r=[self UIImageFromCVMat:temp];
    self.imageView.image=r;

 
}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([touch.view isEqual: self.view] || touch.view == nil) {
        result_image=self.imageView.image;
        self.imageView.image=_select_Image;
        return;
    }
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    
    if ([touch.view isEqual: self.view] || touch.view == nil) {
        self.imageView.image=result_image;
        return;
    }

    
}

- (IBAction)complete_face_down:(id)sender {
    cv::Mat res=target_image.clone();
   if(self.img_gallery.isHidden==YES){
    [self.img_gallery setHidden:false];
    [self.effect_slider setHidden:false];
   }else{
       [self.img_gallery setHidden:true];
       [self.effect_slider setHidden:true];
   }
  
}
- (IBAction)Exit_View:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
    
}
- (IBAction)chane_Value:(id)sender {
    
    
        GLfloat v= ((UISlider *)sender).value*0.8;
        
        
        effect_parameters[current_index]=v;
        cv::Mat res;
        
        if (current_index==EFFECT_SKINBLUR){
            cv::Mat temp=target_image.clone();
            cv::Mat ires=[self addSmoothEffect:temp addFact:effect_parameters[EFFECT_SKINBLUR]*0.8];
            cv::cvtColor(ires, smooth_image, cv::COLOR_BGRA2BGR);
            
        }
        res=[self processingFaceImage:smooth_image addValue:effect_parameters];
        UIImage *r=[self UIImageFromCVMat:res];
        self.imageView.image=r;
       


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark : UIcollectionview Delegate.

//Collection implement part

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return array_image.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"selected_image";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    
    UIImageView *img1 = (UIImageView *)[cell viewWithTag:99];
    img1.image = [array_image objectAtIndex:indexPath.row];
    
    
    return cell;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    

    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    

    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 
    
    static NSString *identifier = @"selected_image";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (indexPath.row!=mem_index  ){
            
    UIImageView *img1 = (UIImageView *)[cell viewWithTag:99];
    
    img1.image = [mem_array_image objectAtIndex:indexPath.row];
    
    cv::Mat t1=[self cvMatFromUIImage:img1.image];
    
    img1.image =[self UIImageFromCVMat:t1*0.5];
    
    if(mem_index!=-1)
    array_image[mem_index]=mem_array_image[mem_index];
    
    array_image[indexPath.row]=img1.image;
    
    [self.effect_slider setValue:effect_parameters[indexPath.row]];
    
    [_img_gallery reloadData];
    current_index=(int)indexPath.row;
    mem_index=(int)indexPath.row;
    }
    
    
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}







@end
