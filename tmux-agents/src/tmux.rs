use std::io;
use std::path::PathBuf;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PaneId(pub String);

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PaneInfo {
    pub id: PaneId,
    pub session: String,
    pub window_id: String,
    pub window_index: u32,
    pub current_path: PathBuf,
    pub title: String,
}

pub trait Tmux {
    fn list_panes(&self) -> io::Result<Vec<PaneInfo>>;
    fn focus(&self, pane: &PaneId) -> io::Result<()>;
}

pub fn parse_pane_ref(s: &str) -> Option<PaneId> {
    let (_, pane) = s.rsplit_once('.')?;
    pane.starts_with('%').then(|| PaneId(pane.to_string()))
}
