use std::path::PathBuf;

use tmux_agents::agents::{Agent, discover};
use tmux_agents::registry::{Kind, SessionRecord, Status};
use tmux_agents::tmux::{PaneId, PaneInfo};

fn record(pid: i32, cwd: &str, tmux: Option<&str>) -> SessionRecord {
    SessionRecord {
        pid,
        cwd: PathBuf::from(cwd),
        name: None,
        kind: Kind::Interactive,
        status: Status::Idle,
        tmux: tmux.map(str::to_string),
    }
}

fn pane(id: &str, session: &str, window_index: u32, title: &str) -> PaneInfo {
    PaneInfo {
        id: PaneId(id.to_string()),
        session: session.to_string(),
        window_id: "@1".to_string(),
        window_index,
        current_path: PathBuf::from("/irrelevant"),
        title: title.to_string(),
    }
}

fn alive(_: i32) -> bool {
    true
}

#[test]
fn interactive_record_with_live_pid_and_known_pane_becomes_an_agent() {
    let records = vec![record(42, "/home/me/dotfiles", Some("dotfiles:@7.%53"))];
    let panes = vec![pane("%53", "dotfiles", 2, "✳ Fix the picker")];

    let agents = discover(records, &panes, &alive);

    assert_eq!(
        agents,
        vec![Agent {
            pid: 42,
            label: "dotfiles".to_string(),
            cwd: PathBuf::from("/home/me/dotfiles"),
            pane: PaneId("%53".to_string()),
            session: "dotfiles".to_string(),
            window_index: 2,
            title: Some("Fix the picker".to_string()),
        }]
    );
}
