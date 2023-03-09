//
//  SHGLTool.h
//  OpenGLDemo
//
//  Created by Ray on 2023/3/8.
//
#import <OpenGLES/ES2/gl.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 使用顶点着色器与片元着色器
 接着前面的准备工作，下面开始链接着色器。
 主要步骤：
 1、创建 shader：glCreateShader
 2、装载 shader：glShaderSource
 3、编译 shader：glCompileShader
 4、删除 shader：glDeleteShader 释放资源
 着色器加载封装
 */
@interface SHGLTool : NSObject
+ (GLuint)loadShaders:(NSString *)vertFilePath frag:(NSString *)fragFilePath;
+ (GLuint)loadShaders:(NSString *)vertContent fragContent:(NSString *)fragContent;
@end

NS_ASSUME_NONNULL_END
