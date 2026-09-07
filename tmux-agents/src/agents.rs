use std::path::PathBuf;

use crate::tmux::PaneId;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Agent {
    pub pid: i32,
    pub label: String,
    pub cwd: PathBuf,
    pub pane: PaneId,
    pub session: String,
    pub window_index: u32,
    pub title: Option<String>,
}
