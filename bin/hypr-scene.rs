#!/usr/bin/env rust-script
//! ```cargo
//! [dependencies]
//! serde_json = "1.0"
//! ```

use std::env;
use std::io::Write;
use std::os::unix::net::UnixStream;
use std::process;

fn main() {
    let args: Vec<String> = env::args().collect();

    if args.len() != 2 {
        eprintln!("Usage: hypr-scene <1|2|3>");
        eprintln!("  1 = Column 1 (workspaces 1,2,3,4)");
        eprintln!("  2 = Column 2 (workspaces 5,6,7,8)");
        eprintln!("  3 = Column 3 (workspaces 9,10,11,12)");
        process::exit(1);
    }

    let scene = match args[1].as_str() {
        "1" => vec![
            ("DP-1", 1),
            ("DP-3", 2),
            ("DP-2", 3),
            ("HDMI-A-1", 4),
        ],
        "2" => vec![
            ("DP-1", 5),
            ("DP-3", 6),
            ("DP-2", 7),
            ("HDMI-A-1", 8),
        ],
        "3" => vec![
            ("DP-1", 9),
            ("DP-3", 10),
            ("DP-2", 11),
            ("HDMI-A-1", 12),
        ],
        _ => {
            eprintln!("Invalid scene: {}. Must be 1, 2, or 3.", args[1]);
            process::exit(1);
        }
    };

    // Connect to Hyprland IPC socket
    let socket_path = match env::var("HYPRLAND_INSTANCE_SIGNATURE") {
        Ok(sig) => format!("/tmp/hypr/{}/.socket.sock", sig),
        Err(_) => {
            eprintln!("Error: HYPRLAND_INSTANCE_SIGNATURE not set. Are you running Hyprland?");
            process::exit(1);
        }
    };

    let mut stream = match UnixStream::connect(&socket_path) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("Error connecting to Hyprland socket: {}", e);
            process::exit(1);
        }
    };

    // Send workspace switching commands in rapid succession
    for (monitor, workspace) in scene.iter() {
        let focus_monitor = format!("dispatch focusmonitor {}", monitor);
        let switch_workspace = format!("dispatch workspace {}", workspace);

        if let Err(e) = stream.write_all(focus_monitor.as_bytes()) {
            eprintln!("Error sending command: {}", e);
        }
        if let Err(e) = stream.write_all(switch_workspace.as_bytes()) {
            eprintln!("Error sending command: {}", e);
        }
    }

    // Final focus back to main monitor (DP-3)
    let final_focus = "dispatch focusmonitor DP-3";
    if let Err(e) = stream.write_all(final_focus.as_bytes()) {
        eprintln!("Error sending final focus: {}", e);
    }
}
