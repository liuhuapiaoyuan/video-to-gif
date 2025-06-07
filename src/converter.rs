use anyhow::{Context, Result};
use std::path::Path;
use std::process::Command;

pub struct VideoConverter {
    fps: u32,
    width: u32,
    ffmpeg_path: String,
}

impl VideoConverter {
    pub fn new(fps: u32, width: u32, ffmpeg_path: String) -> Self {
        Self { fps, width, ffmpeg_path }
    }
    
    pub fn convert<P: AsRef<Path>>(&self, input: P, output: P) -> Result<()> {
        let input_path = input.as_ref();
        let output_path = output.as_ref();
        
        // 构建FFmpeg命令
        let mut cmd = Command::new(&self.ffmpeg_path);
        cmd.arg("-y") // 覆盖输出文件
            .arg("-i").arg(input_path) // 输入文件
            .arg("-r").arg(self.fps.to_string()) // 设置帧率
            .arg("-vf").arg(format!("scale={}:-1", self.width)) // 设置宽度，高度自动
            .arg("-f").arg("gif") // 输出格式
            .arg(output_path); // 输出文件
        
        // 执行命令
        let output = cmd.output()
            .with_context(|| format!("执行FFmpeg命令失败: {:?}", cmd))?;
        
        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("FFmpeg转换失败: {}", stderr);
        }
        
        // 验证输出文件是否存在
        if !output_path.exists() {
            anyhow::bail!("输出文件未生成: {}", output_path.display());
        }
        
        Ok(())
    }
    
    /// 获取转换参数的描述
    pub fn get_params_description(&self) -> String {
        format!("帧率: {}fps, 宽度: {}px", self.fps, self.width)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_converter_creation() {
        let converter = VideoConverter::new(15, 640, "ffmpeg".to_string());
        assert_eq!(converter.fps, 15);
        assert_eq!(converter.width, 640);
        assert_eq!(converter.ffmpeg_path, "ffmpeg");
    }
    
    #[test]
    fn test_params_description() {
        let converter = VideoConverter::new(12, 320, "ffmpeg".to_string());
        assert_eq!(converter.get_params_description(), "帧率: 12fps, 宽度: 320px");
    }
} 