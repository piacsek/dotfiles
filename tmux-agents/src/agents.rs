use std::collections::{HashMap, HashSet};
use std::path::PathBuf;

use crate::registry::{Kind, SessionRecord};
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
    alive: &dyn Fn(i32) -> bool,
) -> Vec<Agent> {
    let mut agents: Vec<Agent> = records
        .into_iter()
        .filter(|record| record.kind == Kind::Interactive && alive(record.pid))
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
        .collect();
    agents.sort_by(|a, b| (&a.session, a.window_index).cmp(&(&b.session, b.window_index)));
    disambiguate_labels(&mut agents);
    agents
}

fn disambiguate_labels(agents: &mut [Agent]) {
    let mut counts: HashMap<&str, usize> = HashMap::new();
    for agent in agents.iter() {
        *counts.entry(agent.label.as_str()).or_default() += 1;
    }
    let duplicated: HashSet<String> = counts
        .into_iter()
        .filter(|(_, n)| *n > 1)
        .map(|(label, _)| label.to_string())
        .collect();
    for agent in agents.iter_mut() {
        if duplicated.contains(&agent.label) {
            agent.label = format!("{} ·{}:{}", agent.label, agent.session, agent.window_index);
        }
    }
}

fn basename(path: &std::path::Path) -> String {
    path.file_name()
        .map(|n| n.to_string_lossy().into_owned())
        .unwrap_or_else(|| path.display().to_string())
}
