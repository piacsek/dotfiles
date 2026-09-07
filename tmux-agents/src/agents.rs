use std::path::PathBuf;

use crate::registry::SessionRecord;
use crate::tmux::{PaneId, PaneInfo, parse_pane_ref};

const TITLE_PREFIX: &str = "✳ ";

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

pub fn discover(
    records: Vec<SessionRecord>,
    panes: &[PaneInfo],
    _alive: &dyn Fn(i32) -> bool,
) -> Vec<Agent> {
    records
        .into_iter()
        .filter_map(|record| {
            let pane_id = parse_pane_ref(record.tmux.as_deref()?)?;
            let pane = panes.iter().find(|p| p.id == pane_id)?;
            Some(Agent {
                pid: record.pid,
                label: basename(&record.cwd),
                cwd: record.cwd,
                pane: pane.id.clone(),
                session: pane.session.clone(),
                window_index: pane.window_index,
                title: pane.title.strip_prefix(TITLE_PREFIX).map(str::to_string),
            })
        })
        .collect()
}

fn basename(path: &std::path::Path) -> String {
    path.file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_else(|| path.display().to_string())
}
