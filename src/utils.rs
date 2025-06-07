use std::path::Path;

/// 格式化文件大小显示
#[allow(dead_code)]
pub fn format_file_size(size: u64) -> String {
    const UNITS: &[&str] = &["B", "KB", "MB", "GB"];
    let mut size = size as f64;
    let mut unit_index = 0;

    while size >= 1024.0 && unit_index < UNITS.len() - 1 {
        size /= 1024.0;
        unit_index += 1;
    }

    if size >= 10.0 {
        format!("{:.0} {}", size, UNITS[unit_index])
    } else {
        format!("{:.1} {}", size, UNITS[unit_index])
    }
}

/// 获取文件大小
#[allow(dead_code)]
pub fn get_file_size<P: AsRef<Path>>(path: P) -> std::io::Result<u64> {
    let metadata = std::fs::metadata(path)?;
    Ok(metadata.len())
}

/// 检查文件是否为MP4格式
pub fn is_mp4_file<P: AsRef<Path>>(path: P) -> bool {
    path.as_ref()
        .extension()
        .map(|ext| ext.to_string_lossy().to_lowercase() == "mp4")
        .unwrap_or(false)
}

/// 生成输出文件路径
#[allow(dead_code)]
pub fn generate_output_path<P: AsRef<Path>>(
    input_path: P,
    new_extension: &str,
) -> std::path::PathBuf {
    let path = input_path.as_ref();
    path.with_extension(new_extension)
}

/// 验证文件名是否安全（不包含特殊字符）
#[allow(dead_code)]
pub fn is_safe_filename<P: AsRef<Path>>(path: P) -> bool {
    let path = path.as_ref();
    if let Some(filename) = path.file_name() {
        let filename_str = filename.to_string_lossy();
        // 检查是否包含危险字符
        !filename_str.contains(&['<', '>', ':', '"', '|', '?', '*'][..])
            && !filename_str.starts_with('.')
            && !filename_str.is_empty()
    } else {
        false
    }
}

/// 创建安全的文件名
#[allow(dead_code)]
pub fn sanitize_filename(filename: &str) -> String {
    let dangerous_chars = ['<', '>', ':', '"', '|', '?', '*', '\\', '/'];
    let mut safe_name = String::new();

    for ch in filename.chars() {
        if dangerous_chars.contains(&ch) {
            safe_name.push('_');
        } else {
            safe_name.push(ch);
        }
    }

    // 确保文件名不为空且不以点开始
    if safe_name.is_empty() || safe_name.starts_with('.') {
        safe_name = format!("video_{}", safe_name);
    }

    safe_name
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::PathBuf;

    #[test]
    fn test_format_file_size() {
        assert_eq!(format_file_size(512), "512 B");
        assert_eq!(format_file_size(1024), "1.0 KB");
        assert_eq!(format_file_size(1536), "1.5 KB");
        assert_eq!(format_file_size(1048576), "1.0 MB");
        assert_eq!(format_file_size(1073741824), "1.0 GB");
    }

    #[test]
    fn test_is_mp4_file() {
        assert!(is_mp4_file("test.mp4"));
        assert!(is_mp4_file("TEST.MP4"));
        assert!(!is_mp4_file("test.gif"));
        assert!(!is_mp4_file("test"));
    }

    #[test]
    fn test_generate_output_path() {
        let input = PathBuf::from("video.mp4");
        let output = generate_output_path(&input, "gif");
        assert_eq!(output, PathBuf::from("video.gif"));
    }

    #[test]
    fn test_is_safe_filename() {
        assert!(is_safe_filename("normal_file.mp4"));
        assert!(!is_safe_filename("file<with>bad:chars.mp4"));
        assert!(!is_safe_filename(".hidden_file.mp4"));
        assert!(!is_safe_filename(""));
    }

    #[test]
    fn test_sanitize_filename() {
        assert_eq!(sanitize_filename("normal_file.mp4"), "normal_file.mp4");
        assert_eq!(
            sanitize_filename("file<with>bad:chars.mp4"),
            "file_with_bad_chars.mp4"
        );
        assert_eq!(sanitize_filename(".hidden"), "video_.hidden");
        assert_eq!(sanitize_filename(""), "video_");
    }
}
