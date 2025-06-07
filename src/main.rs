use anyhow::{Context, Result};
use clap::Parser;
use indicatif::{ProgressBar, ProgressStyle};
use std::path::PathBuf;
use std::process::Command;
use walkdir::WalkDir;

mod converter;
mod utils;

use converter::VideoConverter;
use utils::*;

#[derive(Parser)]
#[command(name = "video-gif")]
#[command(about = "将文件夹中的MP4视频文件转换为GIF动图")]
#[command(version = "1.1.0")]
struct Args {
    /// 包含MP4文件的文件夹路径
    #[arg(help = "包含MP4文件的文件夹路径")]
    folder: PathBuf,
    
    /// 输出GIF的帧率 (默认: 10)
    #[arg(short = 'r', long = "fps", default_value = "10")]
    fps: u32,
    
    /// 输出GIF的最大宽度 (默认: 480)
    #[arg(short = 'w', long = "width", default_value = "480")]
    width: u32,
    
    /// 静默模式，不显示进度
    #[arg(short = 'q', long = "quiet")]
    quiet: bool,
}

/// 获取FFmpeg可执行文件的路径
/// 优先使用内置的ffmpeg.exe，如果不存在则使用系统PATH中的ffmpeg
fn get_ffmpeg_path() -> String {
    // 尝试找到内置的ffmpeg.exe
    let exe_dir = std::env::current_exe()
        .ok()
        .and_then(|exe_path| exe_path.parent().map(|p| p.to_path_buf()));
    
    if let Some(dir) = exe_dir {
        let bundled_ffmpeg = dir.join("ffmpeg.exe");
        if bundled_ffmpeg.exists() {
            return bundled_ffmpeg.to_string_lossy().to_string();
        }
    }
    
    // 如果内置版本不存在，回退到系统PATH中的ffmpeg
    "ffmpeg".to_string()
}

fn main() -> Result<()> {
    let args = Args::parse();
    
    // 获取FFmpeg路径
    let ffmpeg_path = get_ffmpeg_path();
    
    // 检查FFmpeg是否可用
    check_ffmpeg_availability(&ffmpeg_path)?;
    
    // 验证输入文件夹
    if !args.folder.exists() {
        anyhow::bail!("指定的文件夹不存在: {}", args.folder.display());
    }
    
    if !args.folder.is_dir() {
        anyhow::bail!("指定的路径不是文件夹: {}", args.folder.display());
    }
    
    // 查找所有MP4文件
    let mp4_files = find_mp4_files(&args.folder)?;
    
    if mp4_files.is_empty() {
        println!("在文件夹 {} 中未找到MP4文件", args.folder.display());
        return Ok(());
    }
    
    println!("找到 {} 个MP4文件", mp4_files.len());
    
    // 创建转换器
    let converter = VideoConverter::new(args.fps, args.width, ffmpeg_path);
    
    // 设置进度条
    let progress_bar = if !args.quiet {
        let pb = ProgressBar::new(mp4_files.len() as u64);
        pb.set_style(
            ProgressStyle::default_bar()
                .template("{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {pos}/{len} ({eta})")
                .unwrap()
                .progress_chars("#>-"),
        );
        Some(pb)
    } else {
        None
    };
    
    // 转换文件
    let mut success_count = 0;
    let mut error_count = 0;
    
    for (index, mp4_file) in mp4_files.iter().enumerate() {
        let gif_file = mp4_file.with_extension("gif");
        
        if let Some(ref pb) = progress_bar {
            pb.set_message(format!("转换: {}", mp4_file.file_name().unwrap().to_string_lossy()));
        } else if !args.quiet {
            println!("[{}/{}] 转换: {}", index + 1, mp4_files.len(), mp4_file.display());
        }
        
        match converter.convert(mp4_file, &gif_file) {
            Ok(_) => {
                success_count += 1;
                if !args.quiet && progress_bar.is_none() {
                    println!("✅ 转换成功: {}", gif_file.display());
                }
            }
            Err(e) => {
                error_count += 1;
                eprintln!("❌ 转换失败 {}: {}", mp4_file.display(), e);
            }
        }
        
        if let Some(ref pb) = progress_bar {
            pb.inc(1);
        }
    }
    
    if let Some(pb) = progress_bar {
        pb.finish_with_message("转换完成");
    }
    
    // 显示结果摘要
    println!("\n=== 转换结果 ===");
    println!("✅ 成功: {} 个文件", success_count);
    if error_count > 0 {
        println!("❌ 失败: {} 个文件", error_count);
    }
    println!("📁 输出目录: {}", args.folder.display());
    
    Ok(())
}

fn check_ffmpeg_availability(ffmpeg_path: &str) -> Result<()> {
    let output = Command::new(ffmpeg_path)
        .arg("-version")
        .output()
        .context("无法执行FFmpeg命令。请确保FFmpeg已安装或内置的ffmpeg.exe文件完整。")?;
    
    if !output.status.success() {
        anyhow::bail!("FFmpeg命令执行失败。请检查FFmpeg安装。");
    }
    
    Ok(())
}

fn find_mp4_files(folder: &PathBuf) -> Result<Vec<PathBuf>> {
    let mut mp4_files = Vec::new();
    
    for entry in WalkDir::new(folder)
        .max_depth(1)
        .into_iter()
        .filter_map(|e| e.ok())
    {
        let path = entry.path();
        if path.is_file() {
            if let Some(extension) = path.extension() {
                if extension.to_string_lossy().to_lowercase() == "mp4" {
                    mp4_files.push(path.to_path_buf());
                }
            }
        }
    }
    
    mp4_files.sort();
    Ok(mp4_files)
} 